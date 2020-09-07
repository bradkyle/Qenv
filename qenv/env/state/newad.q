
// TODO smaller ping orders and hidden orders!
// Allow for strategies like bursts on market orders
// constant sniffers etc.
// create iceberg orders etc.

// Bucketed Limit Order Creation
// ---------------------------------------------------------------------------------------->

// Generates a set of order levels according to
// a uniform distribution of buckets throughout the
// orderbook .i.e: (0,2),(2,4),(4,6),(6,8) etc.
// Deltas will be derived by summing the total leaves
// of the orders in each bucket and attributing the
// qty delta between the current state and the target
// state therin.
// Buckets can thereafter be referenced simply by a 
// given action mapping i.e. 1: (0,2)
// Orders are then placed at the foremost marketable 
// limit price in the bucket.
.state.adapter.uniBucketOrders      :{[]

    };

// Generates a set of order levels according to
// a exponential distribution of buckets throughout the
// orderbook .i.e: (0,1),(1,2),(2,4),(4,8) etc.
// Deltas will be derived by summing the total leaves
// of the orders in each bucket and attributing the
// qty delta between the current state and the target
// state therin.
// Buckets can thereafter be referenced simply by a 
// given action mapping i.e. 1: (0,1)
// Orders are then placed at the foremost marketable 
// limit price in the bucket.
.state.adapter.expBucketOrders      :{[]

    };

// Generates a set of order levels according to
// a exponential distribution of buckets throughout the
// orderbook .i.e: (0,4),(4,8),(8,10),(10,11) etc.
// Deltas will be derived by summing the total leaves
// of the orders in each bucket and attributing the
// qty delta between the current state and the target
// state therin.
// Buckets can thereafter be referenced simply by a 
// given action mapping i.e. 1: (0,4)
// Orders are then placed at the foremost marketable 
// limit price in the bucket.
.state.adapter.logBucketOrders      :{[]

    };


// Stop Creation
// ---------------------------------------------------------------------------------------->

// Naive stop placement
// Simply places a single stop order for each corresponding
// position at a given loss fraction of the positions value
// (unrealized pnl).
.state.adapter.naiveStops   :{
    // 1%avgprice
    };

// Uniform staggered stop placement
// Places a uniform set of for instance 5 stop orders at 
// equidistant price points in relation to the current
// mark price up to the final maximum loss fraction
.state.adapter.uniStops     :{

    };   

// Exponential stop placement
// Places a set of stops that exponentially increase in
// magnitude away from the current price to a given 
// maximum loss fraction
.state.adapter.expStops     :{

    };

// Logarithmic stop placement
// Places a set of stops that logarithmically increase in
// magnitude away from the current price to a given maximum
// loss fraction.
.state.adapter.logStops     :{

    };

// ATR stop placement 


// Temporal Limit Utilities (used in macro actions)
// ---------------------------------------------------------------------------------------->

// 
.state.adapter.createUniTemporalLimitOrders      :{

    };

// 
.state.adapter.createRandTemporalLimitOrders     :{

    };

// Temporal Market Utilities (used in macro actions)
// ---------------------------------------------------------------------------------------->

// 
.state.adapter.createUniTemporalMarketOrders      :{

    };

// 
.state.adapter.createRandTemporalMarketOrders     :{

    };


// Flattening Utils
// ---------------------------------------------------------------------------------------->

// 
.state.adapter.createFlattenSideOrders             :{

    };

// 
.state.adapter.createFlattenAllOrders             :{

    };


// Macro Action Utilities
// ---------------------------------------------------------------------------------------->


// 
.state.adapter.generateMacroAction             :{

    };



// Macro Action Utilities
// ---------------------------------------------------------------------------------------->
