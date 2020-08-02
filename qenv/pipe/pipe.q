
\d .pipe

\l ../../lcl/ev

// Source Event Tables
// =====================================================================================>


StepIndex:();
EventBatch:();
FeatureBatch:();

tnum:0;
// step rate i.e. by number of events, by interval, by number of events within interval, by number of events outside interval. 

// batching/episodes and episode randomization/replay buffer.

// get daily 


SetBatch: {[]
    EventBatch:0; 
    };

// SIMPLE DERIVE STEP RATE
Derive :{[step;batchSize]
    $[(step<(.pipe.tnum-1));[
        thresh:StepIndex@step;
        nevents:EventBatch@thresh;
        / feature:FeatureBatch@thresh;
        
    ];
    [
        .pipe.EventBatch:select time, intime, kind, cmd, datum by grp:5 xbar `second$time from .pipe.events where time within[];
        .pipe.StepIndex:key .pipe.EventBatch;
        / .pipe.FeatureBatch:select time, intime, kind, cmd, datum by grp:5 xbar `second$time from events;
    ]};