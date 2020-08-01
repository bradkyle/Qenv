
\l ../../lcl/ev
// Source Event Tables
// =====================================================================================>

EventBatch:();
FeatureBatch:();

// step rate i.e. by number of events, by interval, by number of events within interval, by number of events outside interval. 

// batching/episodes and episode randomization/replay buffer.

genBatch: {[]
    EventBatch:0; 
    };

Derive :{[step;batchSize]
    thresh:T;
    nevents:EventBatch@thresh;
    feature:FeatureBatch@thresh;
    
    
    };