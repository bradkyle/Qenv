
\d .pipe

\cd ../env
\l adapter.q
\cd ../pipe
\l ../../lcl/ev
\cd /home/kx/qenv/qenv/pipe

// Source Event Tables
// =====================================================================================>

Adapter:`.adapter.ADAPTERTYPE$`MARKETMAKER;
BatchSize:0;
StepIndex:();
EventBatch:();
FeatureBatch:();

// step rate i.e. by number of events, by interval, by number of events within interval, by number of events outside interval. 

// batching/episodes and episode randomization/replay buffer.

// get daily 


SetBatch: {[]
    EventBatch:0; 
    };

firstDay:{`datetime$((select first date from events)[`date])}


// SIMPLE DERIVE STEP RATE
Advance :{[step;actions]
    $[
        (step=0);
        [
            idx:.pipe.StepIndex@step;
        ];
        (step<(count[.pipe.StepIndex]-1));
        [
            idx:.pipe.StepIndex@step;
            nevents:flip[.pipe.EventBatch@idx];
            
            / feature:FeatureBatch@thresh;
            // should add a common offset to actions before inserting them into
            // the events.
            // TODO offset
            // TODO 
            aevents:.adapter.Adapt[.pipe.Adapter][time] each actions; 
            newEvents: .engine.ProcessEvents[(nevents,aevents)];

            .state.InsertResultantEvents[newEvents];
        ];
        [
            .pipe.EventBatch:select time, intime, kind, cmd, datum by grp:5 xbar `second$time from .pipe.events where time within ();
            .pipe.StepIndex:key .pipe.EventBatch;
            / .pipe.FeatureBatch:select time, intime, kind, cmd, datum by grp:5 xbar `second$time from events;
        ]
    ];
    };