\d .pipe.source

BatchIndex:();
StepIndex:();
EventBatch:();
FeatureBatch:();

/ Env Utils
// =====================================================================================>

firstDay:{`datetime$((select first date from events)[`date])};


/ date       time                    intime                  kind  cmd datum
/ ---------------------------------------------------------------------------------------
/ 2020.07.26 2020.07.26T23:54:24.490 2020.07.26T23:54:24.547 TRADE NEW `SELL 993500i 1i
/ 2020.07.26 2020.07.26T23:54:44.650 2020.07.26T23:54:44.708 TRADE NEW `BUY  993550i 92i
/ 2020.07.26 2020.07.26T23:54:44.650 2020.07.26T23:54:44.708 TRADE NEW `BUY  993550i 110i
/ 2020.07.26 2020.07.26T23:54:44.650 2020.07.26T23:54:44.708 TRADE NEW `BUY  993550i 200i
/ 2020.07.26 2020.07.26T23:54:44.650 2020.07.26T23:54:44.708 TRADE NEW `BUY  993550i 4i

// Probabalistic choice
// @n: number of choices
// @k: count of choices
// @p: probability spread
PChoice :{[n;k;p]k?raze ("j"$p*10 xexp max count each("."vs'string p)[;1])#'til n};

// Returns the next batch from the

// Batches are synonymous with episode // TODO train test split
// TODO test next
// TODO batch by price movement
GenNextEpisode    :{
    // If the batch idxs which correspond with the length of an episode are
    // not set create the set of batch idxs.
    // set the batch window intervals above.

    // TODO check day is divisible by batch size? 
    // TODO missing events at start of events
    if[count[.env.BatchIndex]<1;[ 
        bidx:select start:((`date$time)+(.env.BatchSize xbar `minute$time)) from .env.EventSource;
        bidx:update end:next start from bidx;
        bidx:update end:first[(select last time from .env.EventSource)`time]^end from bidx;
        .env.BatchIndex:bidx;
    ]];

    nextBatch:$[
       (.env.BatchSelectMethod=`.env.BATCHSELECTMETHOD$`RANDOM);
        [.env.BatchIndex@rand count[bidx]];
       (.env.BatchSelectMethod=`.env.BATCHSELECTMETHOD$`CHRONOLOGICAL);
        [.env.BatchIndex@(.env.CurrentEpisde mod count[.env.BatchIndex])];
       (.env.BatchSelectMethod=`.env.BATCHSELECTMETHOD$`CURRICULUM); // TODO
        ['NOTIMPLEMENTED];
        ['INVALID_BATCH_SELECTION_METHOD]];

    $[(.env.WindowKind=`.env.WINDOWKIND$`TEMPORAL);
        [
            .env.EventBatch:select time, intime, kind, cmd, datum by grp:(`date$time)+5 xbar `second$time from .env.EventSource where time within value[nextBatch];
            if[.env.UseFeatures;.env.FeatureBatch:0N];
        ];
    (.env.WindowKind=`.env.WINDOWKIND$`EVENTCOUNT);
        [
            .env.EventBatch:select time, intime, kind, cmd, datum by grp:5 xbar i from .env.EventSource where time within value[nextBatch];
            if[.env.UseFeatures;.env.FeatureBatch:0N];
        ];
    (.env.WindowKind=`.env.WINDOWKIND$`THRESHCOUNT);
        ['NOTIMPLEMENTED];
    ['INVALID_WINDOWING_METHOD]];

      // TODO insert feature batch.
      // TODO upsert new episode with event count etc.

     .state.StepIndex: key .env.EventBatch;
    };
