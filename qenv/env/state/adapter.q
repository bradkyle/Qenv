
// TODO smaller ping orders and hidden orders!
// Allow for strategies like bursts on market orders
// constant sniffers etc.
// create iceberg orders etc.
// TODO increasing distribution (exp, log, normal) (bucketed/levelled)
// TODO decreasing distribution (exp, log, normal) (bucketed/levelled)
// TODO flat distribution   (bucketed/levelled)

t1:{1+til[x]}
t2:{2+til[x]}
frac:{x%sum[xs]};
rfrac:{};

// Amount distribution logic
// ---------------------------------------------------------------------------------------->

// Given a total amount and the number of groups in which to distribute
// the order quantities return the increasing linear distribution of
// qty for the given set of groups in order.
.state.increasingLinearDistribution                     :{[amt;num;lotsize]
        l:t1[num]:

    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the decreasing linear distribution of
// qty for the given set of groups in order.
.state.decreasingLinearDistribution                     :{[amt;num;lotsize]
        l:reverse t1[num];

    };


// Given a total amount and the number of groups in which to distribute
// the order quantities return the increasing linear distribution of
// qty for the given set of groups in order.
.state.increasingSuperLinearDistribution                :{[amt;num;lotsize]
        l:t1[num]*t1[num]:

    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the decreasing linear distribution of
// qty for the given set of groups in order.
.state.decreasingSuperLinearDistribution                :{[amt;num;lotsize]
        l:t1[num]*t1[num]:

    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the increasing exponential distribution of
// qty for the given set of groups in order.
.state.increasingExponentialDistribution                :{[amt;num;lotsize]
        l:exp t1[num];

    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the decreasing exponential distribution of
// qty for the given set of groups in order.
.state.decreasingExponentialDistribution                :{[amt;num;lotsize]
        l:reverse exp t1[num];

    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the increasing logarithmic distribution of
// qty for the given set of groups in order.
.state.increasingLogarithmicDistribution                :{[amt;num;lotsize]
        l:log t2[num];

    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the decreasing logarithmic distribution of
// qty for the given set of groups in order.
.state.decreasingLogarithmicDistribution                :{[amt;num;lotsize]
        l:reverse log t2[num];

    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the normal distribution of
// qty for the given set of groups in order.
.state.normalDistribution                               :{[amt;num;lotsize]
        l:0;
    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the flat distribution of
// qty for the given set of groups in order.
.state.flatDistribution                                 :{[amt;num;lotsize]
        l:num#1;
    };


// Price Distribution Utilities
// ---------------------------------------------------------------------------------------->

// Generates a set of buckets according to
// a uniform distribution of price throughout the
// orderbook .i.e: (0,2),(2,4),(4,6),(6,8) etc.
.state.uniformalPriceDistribution                       :{[mxprice;mnprice;ticksize;num]

    };

// Generates a set of buckets according to
// a exponential distribution of price throughout the
// orderbook .i.e: (0,1),(1,2),(2,4),(4,8) etc.
.state.exponentialPriceDistribution                     :{[mxprice;mnprice;ticksize;num]

    };

// Generates a set of buckets according to
// a uniform distribution of price throughout the
// orderbook .i.e: (0,4),(4,8),(8,10),(10,11) etc.
.state.logarithmicPriceDistribution                     :{[mxprice;mnprice;ticksize;num]

    };    



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
.state.adapter.uniformalBucketOrders                     :{[]

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
.state.adapter.exponentialBucketOrders                   :{[]

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
.state.adapter.logarithmicBucketOrders                   :{[]
    
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
.state.adapter.naiveStops                              :{[]
    // 1%avgprice
    };

// Uniform staggered stop placement
// Places a uniform set of for instance 5 stop orders at 
// equidistant price points in relation to the current
// mark price up to the final maximum loss fraction
.state.adapter.uniformStops                            :{[]

    };   

// Exponential stop placement
// Places a set of stops that exponentially increase in
// magnitude away from the current price to a given 
// maximum loss fraction
.state.adapter.exponentialStops                        :{[]

    };

// Logarithmic stop placement
// Places a set of stops that logarithmically increase in
// magnitude away from the current price to a given maximum
// loss fraction.
.state.adapter.logarithmicStops                        :{[]

    };

// ATR stop placement 


// Temporal Order Utilities (used in macro actions)
// ---------------------------------------------------------------------------------------->

// Creates a set of uniform orders placed in future
// time i.e. given a step of 1s it will add a 
// order to the pipe ingress queue every 2 seconds
// with the total amount being specified and a look
// forward period thus the amount is derived.
.state.adapter.createUniformTemporalOrders              :{[]

    };

// Creates a set of orders at a random interval and
// at a random amount such that the total target amount
// becomes replete within a given time period
.state.adapter.createRandomTemporalOrders               :{[]

    };

// Flattening Utils
// ---------------------------------------------------------------------------------------->

// Creates the set of market orders that will serve to 
// flatten the current active amount of the given inventory.
.state.adapter.createFlattenSideMarketOrders            :{[]

    };

// Creates the set of market orders that will serve to 
// flatten the current active amount of all inventories for
// a given account.
.state.adapter.createFlattenAllMarketOrders             :{[]

    };

// Creates the set of limit orders that will serve to 
// flatten the current active amount of the given inventory.
// it will be assumed that the orders will be placed at the
// best price/bucket.
.state.adapter.createFlattenSideLimitOrders             :{[]

    };

// Creates the set of limit orders that will serve to 
// flatten the current active amount of all inventories for
// a given account.
// it will be assumed that the orders will be placed at the
// best price/bucket.
.state.adapter.createFlattenAllLimitOrders              :{[]

    };


// General Order Placement Utilities
// ---------------------------------------------------------------------------------------->

// Bins a given quantity into an appropriate amount given the current
// balance/available balance and the amount given as a bin size.
.state.staticOrderSizeStepper                           :{[]

    };

// Derives the delta between the current outstanding/leaves
// order quantity at a given price level and the static target
// "desired" order quantity at that price level and generates
// the set of amend/new/cancel order requests that need to take
// place in order to ameliarate the difference.
.state.createLevelLimitOrdersStaticSizeByDelta          :{[]

    };

// Derives the delta between the current outstanding/leaves
// order quantity at a given price level and the static target
// "desired" order quantity at that price level and generates
// the set of amend/new/cancel order requests that need to take
// place in order to ameliarate the difference.
.state.createLevelLimitOrdersDynamicSizeByDelta         :{[]

    };

// Derives the delta between the current outstanding/leaves
// order quantity at a given price level and the static target
// "desired" order quantity at that price level and generates
// the set of amend/new/cancel order requests that need to take
// place in order to ameliarate the difference.
.state.createBucketLimitOrdersStaticSizeByDelta         :{[]

    };

// Derives the delta between the current outstanding/leaves
// order quantity at a given price level and the static target
// "desired" order quantity at that price level and generates
// the set of amend/new/cancel order requests that need to take
// place in order to ameliarate the difference.
.state.createBucketLimitOrdersDynamicSizeByDelta        :{[]

    };

// Derives the delta between the current outstanding/leaves
// order quantity at a given price level and the static target
// "desired" order quantity at that price level and generates
// the set of amend/new/cancel order requests that need to take
// place in order to ameliarate the difference.
.state.createLevelIcebergOrdersStaticSizeByDelta        :{[]

    };

// Derives the delta between the current outstanding/leaves
// order quantity at a given price level and the static target
// "desired" order quantity at that price level and generates
// the set of amend/new/cancel order requests that need to take
// place in order to ameliarate the difference.
.state.createLevelIcebergOrdersDynamicSizeByDelta       :{[]

    };

// Derives the delta between the current outstanding/leaves
// order quantity at a given price level and the static target
// "desired" order quantity at that price level and generates
// the set of amend/new/cancel order requests that need to take
// place in order to ameliarate the difference.
.state.createBucketIcebergOrdersStaticSizeByDelta       :{[]

    };

// Derives the delta between the current outstanding/leaves
// order quantity at a given price level and the static target
// "desired" order quantity at that price level and generates
// the set of amend/new/cancel order requests that need to take
// place in order to ameliarate the difference.
.state.createBucketIcebergOrdersDynamicSizeByDelta      :{[]

    };


// Macro Action Utilities
// ---------------------------------------------------------------------------------------->
// Macro actions are useful when it is assumed that the agent has an effect on what
// the market percieves. .i.e. if there is 1000 market sell orders taking place
// this might indicate others to sell as well perhaps playing into an iceberg limit
// order. This behavior is obviousely complex and as such should be relegated to later
// stages of development.

// Creates a set of actions dispersed in time that represent
// a macro action
.state.adapter.constructMacroAction                    :{[]
    'nyi
    };

// Action Adapter Mapping // TODO convert to batch, descriptions
// ---------------------------------------------------------------------------------------->


// DISCRETE ACTIONS
.state.adapter.DiscreteAdapter                          :{[accountId;a]
        $[a=0;[];
          a=1;[];
          a=2;[];
          a=3;[];
          a=4;[];
          'INVALID_ACTION];
    };

// TENLEVEL             
.state.adapter.TenLevelAdapter                          :{[accountId;a]
        $[a=0;[];
          a=1;[];
          a=2;[];
          a=3;[];
          a=4;[];
          'INVALID_ACTION];
    };

// FIVELEVEL                
.state.adapter.FiveLevelAdapter                         :{[accountId;a]
        $[a=0;[];
          a=1;[];
          a=2;[];
          a=3;[];
          a=4;[];
          'INVALID_ACTION];
    };

// EXPBUCKET                
.state.adapter.ExpBucketAdapter                         :{[accountId;a]
        $[a=0;[];
          a=1;[];
          a=2;[];
          a=3;[];
          a=4;[];
          'INVALID_ACTION];
    };

// LOGBUCKET                
.state.adapter.LogBucketAdapter                         :{[accountId;a]
        $[a=0;[];
          a=1;[];
          a=2;[];
          a=3;[];
          a=4;[];
          'INVALID_ACTION];
    };

// UNIBUCKET                
.state.adapter.UniBucketAdapter                         :{[accountId;a]
        $[a=0;[];
          a=1;[];
          a=2;[];
          a=3;[];
          a=4;[];
          'INVALID_ACTION];
    };

// EXPBUCKET                
.state.adapter.ExpBucketAdapterWithIcebergs             :{[accountId;a]
        $[a=0;[];
          a=1;[];
          a=2;[];
          a=3;[];
          a=4;[];
          'INVALID_ACTION];
    };

// LOGBUCKET                
.state.adapter.LogBucketAdapterWithIcebergs             :{[accountId;a]
        $[a=0;[];
          a=1;[];
          a=2;[];
          a=3;[];
          a=4;[];
          'INVALID_ACTION];
    };

// UNIBUCKET                
.state.adapter.UniBucketAdapterWithIcebergs             :{[accountId;a]
        $[a=0;[];
          a=1;[];
          a=2;[];
          a=3;[];
          a=4;[];
          'INVALID_ACTION];
    };

// Main Adapt Function
// ---------------------------------------------------------------------------------------->

// Converts a scalar action representing a target state
// to which the agent will effect a transition into
// its representative amalgamation of events by way
// of an adapter. // TODO pair with state account repr
.state.adapter.Adapt :{[adapterType; time; actions]
        {}'[];
    };