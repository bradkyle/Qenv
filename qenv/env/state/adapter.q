
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
.state.adapter.uniBucketOrders                          :{[]

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
.state.adapter.expBucketOrders                          :{[]

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
.state.adapter.logBucketOrders                          :{[]

    };


// Stop Creation
// ---------------------------------------------------------------------------------------->
// Should use the expected next state inventory
// to derive a set of stops that serve to protect
// the inventory from wild swings in the price and
// subsequently the unrealized pnl.

// Naive stop placement
// Simply places a single stop order for each corresponding
// position at a given loss fraction of the positions value
// (unrealized pnl).
.state.adapter.naiveStops                               :{
    // 1%avgprice
    };

// Uniform staggered stop placement
// Places a uniform set of for instance 5 stop orders at 
// equidistant price points in relation to the current
// mark price up to the final maximum loss fraction
.state.adapter.uniStops                                 :{

    };   

// Exponential stop placement
// Places a set of stops that exponentially increase in
// magnitude away from the current price to a given 
// maximum loss fraction
.state.adapter.expStops                                 :{

    };

// Logarithmic stop placement
// Places a set of stops that logarithmically increase in
// magnitude away from the current price to a given maximum
// loss fraction.
.state.adapter.logStops                                 :{

    };

// ATR stop placement 


// Temporal Order Utilities (used in macro actions)
// ---------------------------------------------------------------------------------------->

// Creates a set of uniform orders placed in future
// time i.e. given a step of 1s it will add a 
// order to the pipe ingress queue every 2 seconds
// with the total amount being specified and a look
// forward period thus the amount is derived.
.state.adapter.createUniTemporalOrders                  :{

    };

// Creates a set of orders at a random interval and
// at a random amount such that the total target amount
// becomes replete within a given time period
.state.adapter.createRandTemporalOrders                 :{

    };

// Flattening Utils
// ---------------------------------------------------------------------------------------->

// Creates the set of market orders that will serve to 
// flatten the current active amount of the given inventory.
.state.adapter.createFlattenSideMarketOrders            :{

    };

// Creates the set of market orders that will serve to 
// flatten the current active amount of all inventories for
// a given account.
.state.adapter.createFlattenAllMarketOrders             :{

    };

// Creates the set of limit orders that will serve to 
// flatten the current active amount of the given inventory.
// it will be assumed that the orders will be placed at the
// best price/bucket.
.state.adapter.createFlattenSideLimitOrders             :{

    };

// Creates the set of limit orders that will serve to 
// flatten the current active amount of all inventories for
// a given account.
// it will be assumed that the orders will be placed at the
// best price/bucket.
.state.adapter.createFlattenAllLimitOrders              :{

    };


// General Order Placement Utilities
// ---------------------------------------------------------------------------------------->

// 
staticOrderSizeStepper                                  :{[]

    };


// 
createLevelLimitOrdersStaticSize                        :{[]

    };

createLevelLimitOrdersDynamicSize                       :{[]

    };

createBucketLimitOrdersStaticSize                       :{[]

    };

createBucketLimitOrdersDynamicSize                      :{[]

    };

createLevelIcebergOrdersStaticSize                      :{[]

    };

createLevelIcebergOrdersDynamicSize                     :{[]

    };

createBucketIcebergOrdersStaticSize                     :{[]

    };

createBucketIcebergOrdersDynamicSize                    :{[]

    };


// Macro Action Utilities
// ---------------------------------------------------------------------------------------->

// Creates a set of actions dispersed in time that represent
// a macro action
.state.adapter.constructMacroAction                     :{

    };

// Action Adapter Mapping // TODO convert to batch
// ---------------------------------------------------------------------------------------->


// DISCRETE ACTIONS
.state.adapter.DiscreteAdapter                          :{};

// TENLEVEL             
.state.adapter.TenLevelAdapter                          :{};

// FIVELEVEL                
.state.adapter.FiveLevelAdapter                         :{};

// EXPBUCKET                
.state.adapter.ExpBucketAdapter                         :{};

// LOGBUCKET                
.state.adapter.LogBucketAdapter                         :{};

// UNIBUCKET                
.state.adapter.UniBucketAdapter                         :{};




// Main Adapt Function
// ---------------------------------------------------------------------------------------->

// Converts a scalar action representing a target state
// to which the agent will effect a transition into
// its representative amalgamation of events by way
// of an adapter.
.state.adapter.Adapt :{[adapterType; time; actions]
    :.state.adapter.mapping[adapterType] each actions;
    };