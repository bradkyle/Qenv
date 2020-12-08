
.engine.Setup               :{
   .ingest.Setup[
       .conf.c[`engine;`ingestHost];
       .conf.c[`engine;`ingestPort]];
   };

.events:.ingest.NewEpisode[.conf.c[`engine;`stepFrequency]]; // TODO
.engine.Threshold:.engine.WaterMark+(.conf.c[`engine;`pullInterval]);
.engine.LastMark:max events`time;
    nevents:.ingest.AsyncGetBatch[];
   $[count[nevents]>1;[
       .engine.Threshold:.engine.WaterMark+(.conf.c[`engine;`dataInterval]);
       .ingress.AddBatch[(events,nevents)];
   ];[
       // Advance the state
       .ingress.AddBatch[events];
   ]];

/ .pipeline.handle:hopen `::5001;

.pipeline.Setup        :{[host;port]
    .pipeline.LastRequestTime:0N;
    .pipeline.HasFuture:0b;
    .pipeline.LastMark:0N;
    .pipeline.handle:hopen `::port; // TODO
    };

.pipeline.SyncRequestBatch :{ // TODO timeout
    :.pipeline.handle("`time xasc select from events where",
                        "(time>first[time]) and ", 
                        "(time<(first[time]+`minute$120)) and ",
                        "(kind in (`MARK`LIQUIDATION`DEPTH`TRADE))");
    };

// Use roughly 3 hour window, if the watermark passes 1.5 hours request the next 
// batch (forward from the last mark) which would add 3 hours to the rollout
// 
.pipeline.AsyncRequestBatch :{ // TODO timeout
    if[(not[.pipeline.HasFuture] or 0b);[ // TODO create future
        neg[.pipeline.handle](".pipeline.batch:`time xasc select from events where",
                        "(time>first[time]) and ", 
                        "(time<(first[time]+`minute$5)) and ",
                        "(kind in (`MARK`LIQUIDATION`DEPTH`TRADE))");
        / neg[.pipeline.handle][];
        .pipeline.HasFuture:1b;
        .pipeline.LastRequestTime:.z.p;
    ]];
    };

// Advance 
// given the current watermark (the last )
.pipeline.AsyncGetBatch     :{
    if[.pipeline.HasFuture;[ // Todo create future
        batch:.pipeline.handle".pipeline.batch";
        $[type[batch] in (99 98h);[
            .pipeline.HasFuture:0b;
            :batch;
        ];'INVALID_PIPELINE_RESPONSE];
    ]];
    };

// Sends A sy
.pipeline.NewEpisode  :{[dataInterval]
    :.pipeline.SyncRequestBatch[];
    };
