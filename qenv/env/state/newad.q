
// TODO smaller ping orders and hidden orders!


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
// limit price in the bucket
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
// limit price in the bucket
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
// limit price in the bucket
.state.adapter.logBucketOrders      :{[]

    };


// Stop Creation
// ---------------------------------------------------------------------------------------->

// Naive stop placement
.state.adapter.naiveStops   :{

    };

// Uniform staggered stop placement
.state.adapter.uniStops     :{

    };   

// Exponential stop placement
.state.adapter.expStops     :{

    };

// Exponential stop placement
.state.adapter.logStops     :{

    };

// ATR stop placement 


// Temporal Limit Utilities (used in macro actions)
// ---------------------------------------------------------------------------------------->

.state.adapter.createUniTemporalLimitOrders      :{

    };

.state.adapter.createRandTemporalLimitOrders     :{

    };

// Temporal Market Utilities (used in macro actions)
// ---------------------------------------------------------------------------------------->

.state.adapter.createUniTemporalMarketOrders      :{

    };

.state.adapter.createRandTemporalMarketOrders     :{

    };


// Flattening Utils
// ---------------------------------------------------------------------------------------->

.state.adapter.createFlattenSideOrders             :{

    };


.state.adapter.createFlattenAllOrders             :{

    };