
\d .pipe

\l ../../lcl/ev

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

// SIMPLE DERIVE STEP RATE
Advance :{[step;actions]
    $[(step<(count[.pipe.StepIndex]-1));[
        idx:StepIndex@step;
        nevents:EventBatch@idx;
        / feature:FeatureBatch@thresh;
        // should add a common offset to actions before inserting them into
        // the events.
        aevents:.adapter.Adapt[.pipe.Adapter][time] each actions; 

    ];
    [
        .pipe.EventBatch:select time, intime, kind, cmd, datum by grp:5 xbar `second$time from .pipe.events where time within[];
        .pipe.StepIndex:key .pipe.EventBatch;
        / .pipe.FeatureBatch:select time, intime, kind, cmd, datum by grp:5 xbar `second$time from events;
    ]};