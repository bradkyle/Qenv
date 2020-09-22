
// TODO smaller ping orders and hidden orders!
// Allow for strategies like bursts on market orders
// constant sniffers etc.
// create iceberg orders etc.
// TODO increasing distribution (exp, log, normal) (bucketed/levelled)
// TODO decreasing distribution (exp, log, normal) (bucketed/levelled)
// TODO flat distribution   (bucketed/levelled)


// Amount distribution logic
// ---------------------------------------------------------------------------------------->
t1:{1+til[x]}
t2:{2+til[x]}
frac:{x%sum[xs]};
ramfrac:{};

// Given a total amount and the number of groups in which to distribute
// the order quantities return the increasing linear distribution of
// qty for the given set of groups in order.
.state.adapter.increasingLinearDistribution                     :{[amt;num;lotsize]
        l:t1[num]:
        .state.adapter.ramfrac[l;amt;lotsize]
    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the decreasing linear distribution of
// qty for the given set of groups in order.
.state.adapter.decreasingLinearDistribution                     :{[amt;num;lotsize]
        l:reverse t1[num];
        .state.adapter.ramfrac[l;amt;lotsize]
    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the increasing linear distribution of
// qty for the given set of groups in order.
.state.adapter.increasingSuperLinearDistribution                :{[amt;num;lotsize]
        l:t1[num]*t1[num];
        .state.adapter.ramfrac[l;amt;lotsize]
    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the decreasing linear distribution of
// qty for the given set of groups in order.
.state.adapter.decreasingSuperLinearDistribution                :{[amt;num;lotsize]
        l:t1[num]*t1[num];
        .state.adapter.ramfrac[l;amt;lotsize]
    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the increasing exponential distribution of
// qty for the given set of groups in order.
.state.adapter.increasingExponentialDistribution                :{[amt;num;lotsize]
        l:exp t1[num];
        .state.adapter.ramfrac[l;amt;lotsize]
    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the decreasing exponential distribution of
// qty for the given set of groups in order.
.state.adapter.decreasingExponentialDistribution                :{[amt;num;lotsize]
        l:reverse exp t1[num];
        .state.adapter.ramfrac[l;amt;lotsize]
    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the increasing logarithmic distribution of
// qty for the given set of groups in order.
.state.adapter.increasingLogarithmicDistribution                :{[amt;num;lotsize]
        l:log t2[num];
        .state.adapter.ramfrac[l;amt;lotsize]
    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the decreasing logarithmic distribution of
// qty for the given set of groups in order.
.state.adapter.decreasingLogarithmicDistribution                :{[amt;num;lotsize]
        l:reverse log t2[num];
        .state.adapter.ramfrac[l;amt;lotsize]
    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the normal distribution of
// qty for the given set of groups in order.
.state.adapter.normalDistribution                               :{[amt;num;lotsize]
        l:0;
        .state.adapter.ramfrac[l;amt;lotsize]
    };

// Given a total amount and the number of groups in which to distribute
// the order quantities return the flat distribution of
// qty for the given set of groups in order.
.state.adapter.flatDistribution                                 :{[amt;num;lotsize]
        l:num#1;
        .state.adapter.ramfrac[l;amt;lotsize]
    };


// Price Distribution Utilities
// ---------------------------------------------------------------------------------------->

// Generates a set of buckets according to
// a uniform distribution of price throughout the
// orderbook .i.e: (0,2),(2,4),(4,6),(6,8) etc.
/  @param mnprice  (Long) The minimum price at which the distribution should start
/  @param ticksize (Long) The minimum interval (can be aggregated) of price allowed 
/  @param num      (Long) The number of levels to generate 
/  @return         (List[Long]) The uniformal price distribution.
.state.adapter.uniformalPriceDistribution                      :{[mnprice;ticksize;num;isignum]
        mnprice+((2*til[num];2*t1[num])*ticksize) // Derive the distribution of prices
    };

// Generates a set of buckets according to
// a superlinear distribution of price throughout the
// orderbook .i.e: (0,1),(1,2),(2,4),(4,8) etc.
/  @param mnprice  (Long) The minimum price at which the distribution should start
/  @param ticksize (Long) The minimum interval (can be aggregated) of price allowed 
/  @param num      (Long) The number of levels to generate 
/  @return         (List[Long]) The superlinear price distribution.
.state.adapter.superlinearPriceDistribution                    :{[mnprice;ticksize;num;isignum]
        mnprice+((xexp[t1[num];2];xexp[t2[num];2])*ticksize)
    };

// Generates a set of buckets according to
// a exponential distribution of price throughout the
// orderbook .i.e: (0,1),(1,2),(2,4),(4,8) etc.
/  @param mnprice  (Long) The minimum price at which the distribution should start
/  @param ticksize (Long) The minimum interval (can be aggregated) of price allowed 
/  @param num      (Long) The number of levels to generate 
/  @return         (List[Long]) The exponential price distribution.
.state.adapter.exponentialPriceDistribution                    :{[mnprice;ticksize;num;isignum]
        mnprice+((exp[t1[num]];exp[t2[num]])*ticksize)
    };

// Generates a set of buckets according to
// a uniform distribution of price throughout the
// orderbook .i.e: (0,4),(4,8),(8,10),(10,11) etc.
/  @param mnprice  (Long) The minimum price at which the distribution should start
/  @param ticksize (Long) The minimum interval (can be aggregated) of price allowed 
/  @param num      (Long) The number of levels to generate 
/  @return         (List[Long]) The logarithmic price distribution.
.state.adapter.logarithmicPriceDistribution                    :{[mnprice;ticksize;num;isignum]
        mnprice+((log[t1[num];log[t2[num]]])*ticksize)        
    };    


.state.adapter.getBuckets                                       :{[]

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
.state.adapter.createNaiveStops                       :{[aId;num;mxfrac]
    lprice:.state.deriveLiquidationPrice[aId];
    mprice:.state.deriveMarkPrice[];
    };

// Uniform staggered stop placement
// Places a uniform set of for instance 5 stop orders at 
// equidistant price points in relation to the current
// mark price up to the final maximum loss fraction
.state.adapter.createUniformStops                     :{[aId;num;mxfrac]
    lprice:.state.deriveLiquidationPrice[aId];

    };   

// Exponential stop placement
// Places a set of stops that exponentially increase in
// magnitude away from the current price to a given 
// maximum loss fraction
.state.adapter.createExponentialStops                 :{[aId;num;mxfrac]
    lprice:.state.deriveLiquidationPrice[aId];

    };

// Logarithmic stop placement
// Places a set of stops that logarithmically increase in
// magnitude away from the current price to a given maximum
// loss fraction.
.state.adapter.createLogarithmicStops                 :{[aId;num;mxfrac]
    lprice:.state.deriveLiquidationPrice[aId];
    
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
    'nyi
    };

// Creates a set of orders at a random interval and
// at a random amount such that the total target amount
// becomes replete within a given time period
.state.adapter.createRandomTemporalOrders               :{[]
    'nyi
    };

// Flattening Utils
// ---------------------------------------------------------------------------------------->

// Creates the set of market orders that will serve to 
// flatten the current active amount of the given inventory.
.state.adapter.createFlattenSideMarketOrders            :{[aId;side]
    ivn:.state.getSideOpenInventory[aId;side];
    nside:neg[side];

    };

// Creates the set of market orders that will serve to 
// flatten the current active amount of all inventories for
// a given account.
.state.adapter.createFlattenAllMarketOrders             :{[aId]
    ivn:.state.getOpenInventory[aId];
    };

// Creates the set of limit orders that will serve to 
// flatten the current active amount of the given inventory.
// it will be assumed that the orders will be placed at the
// best price/bucket.
.state.adapter.createFlattenSideLimitOrders             :{[]
    'nyi
    };

// Creates the set of limit orders that will serve to 
// flatten the current active amount of all inventories for
// a given account.
// it will be assumed that the orders will be placed at the
// best price/bucket.
.state.adapter.createFlattenAllLimitOrders              :{[]
    'nyi
    };


// Iceberg/Hidden order Utils
// ---------------------------------------------------------------------------------------->



// General Order Placement Utilities
// ---------------------------------------------------------------------------------------->

// Bins a given quantity into an appropriate amount given the current
// balance/available balance and the amount given as a bin size.
.state.adapter.staticOrderSizeStepper                           :{[]

    };

// Derives the delta between the current outstanding/leaves
// order quantity at a given price level and the static target
// "desired" order quantity at that price level and generates
// the set of amend/new/cancel order requests that need to take
// place in order to ameliarate the difference.
.state.adapter.createLevelLimitOrdersDeltaProvided              :{[buyamts;sellamts;num]
        sellprices:.state.getLvlPrices[-1;count[sellamts]];
        buyprices:.state.getLvlPrices[1;count[buyamts]];

        // Derive current variables
        cselldistrib:.state.getLvlsQty[sellpricebuckets;-1;aId];
        cbuydistrib:.state.getLvlsQty[buypricebuckets;1;aId];

        // Derive bucket deltas
        dltselldistrib:sellamts-cselldistrib;
        dltbuydistrib:buyamts-cbuydistrib;
    };

// Derives the delta between the current outstanding/leaves
// order quantity at a given price level and the static target
// "desired" order quantity at that price level and generates
// the set of amend/new/cancel order requests that need to take
// place in order to ameliarate the difference.
.state.adapter.createLevelLimitOrdersDeltaDistribution         :{[buyamt;sellamt;distkind;num]
        // Derive target variabless
        sellprices:.state.getLvlPrices[-1;num];
        buyprices:.state.getLvlPrices[1;num];
        tselldistrib:.state.adapter.getAmtDistribution[distkinds[0];amts[0];num;-1];
        tbuydistrib:.state.adapter.getAmtDistribution[distkinds[1];amts[1];num;1];

        // Derive current variables
        cselldistrib:.state.getLvlsQty[sellpricebuckets;-1;aId];
        cbuydistrib:.state.getLvlsQty[buypricebuckets;1;aId];

        // Derive bucket deltas
        dltselldistrib:tselldistrib-cselldistrib;
        dltbuydistrib:tbuydistrib-cbuydistrib;
    };

// Derives the delta between the current outstanding/leaves
// order quantity at a given price level and the static target
// "desired" order quantity at that price level and generates
// the set of amend/new/cancel order requests that need to take
// place in order to ameliarate the difference.
.state.adapter.createBucketLimitOrdersDeltaProvided            :{[bucketkind;buyamts;sellamts]
        sellpricebuckets:.state.adapter.getBuckets[bucketkind;count[sellamts]];
        buypricebuckets:.state.adapter.getBuckets[bucketkind;count[buyamts]];

        // Derive current state
        cselldistrib:.state.getBucketedQty[sellpricebuckets;-1;aId];
        cbuydistrib:.state.getBucketedQty[buypricebuckets;1;aId];

        // Derive bucket deltas
        dltselldistrib:sellamts-cselldistrib;
        dltbuydistrib:buyamts-cbuydistrib;
    };

// Derives the delta between the current outstanding/leaves
// order quantity at a given price level and the static target
// "desired" order quantity at that price level and generates
// the set of amend/new/cancel order requests that need to take
// place in order to ameliarate the difference.
// Bucketing order qty's prevents needless order update requests
// that inevitably occur in volatile markets.
.state.adapter.createBucketLimitOrdersDeltaDistribution         :{[aId;num;bucketkind;amts;distkinds]
        // Derive target states
        sellpricebuckets:.state.adapter.getBuckets[bucketkind;num];
        buypricebuckets:.state.adapter.getBuckets[bucketkind;num];
        tselldistrib:.state.adapter.getAmtDistribution[distkinds[0];amts[0];num;-1];
        tbuydistrib:.state.adapter.getAmtDistribution[distkinds[1];amts[1];num;1];
        
        // Derive current state
        cselldistrib:.state.getBucketedQty[sellpricebuckets;-1;aId];
        cbuydistrib:.state.getBucketedQty[buypricebuckets;1;aId];

        // Derive bucket deltas
        dltselldistrib:tselldistrib-cselldistrib;
        dltbuydistrib:tbuydistrib-cbuydistrib;
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

// TODO HEDGED PATHFINDER

// COMBINED PATHFINDER                
.state.adapter.CombinedPathFinder       :{[encouragement;time;accountId;a]
        numBuckets:10;

        // Creates a set of post only market orders at given levels.
        limitfn:.state.adapter.createBucketLimitOrdersDeltaDistribution[
            accountId;numBuckets;.state.adapter.superlinearPriceDistribution]; 

        marketfn:.state.adapter.createMarketOrder[];
        
        // Creates a 
        macromarketfn:.state.adapter.constructMacroAction[
            .state.adapter.createMarketOrder;
            ];

        // Creates the set of events that will serve to flatten
        // the current outstanding positions of the agent
        flatfn::.state.adapter.createFlattenAllMarketOrders[
            accountId];

        $[a=0;[penalty+:encouragement];
          a=1; limitfn[();()];                      // sell only very aggressive;
          a=2; limitfn[();()];                      // sell only aggressive;
          a=3; limitfn[();()];                      // sell only moderate;
          a=4; limitfn[();()];                      // sell only conservative;
          a=5; limitfn[();()];                      // sell/buy very aggressive
          a=6; limitfn[();()];                      // sell/buy aggressive
          a=7; limitfn[();()];                      // sell/buy moderate
          a=8; limitfn[();()];                      // sell/buy conservative
          a=9; limitfn[();()];                      // buy/sell conservative
          a=10;limitfn[();()];                      // buy/sell moderate
          a=11;limitfn[();()];                      // buy/sell aggressive
          a=12;limitfn[();()];                      // buy/sell very aggressive
          a=13;limitfn[();()];                      // buy only conservative; 
          a=14;limitfn[();()];                      // buy only moderate;
          a=15;limitfn[();()];                      // buy only aggressive
          a=16;limitfn[();()];                      // buy only very aggressive
          a=17;marketfn[];                          // moderate sell market
          a=18;marketfn[];                          // moderate buy market
          a=19;marketfn[];                          // aggressive buy market
          a=20;marketfn[];                          // aggressive sell market
          a=21:macromarketfn[(5;10;0.01)];          // conservative macro market sell
          a=22:macromarketfn[(5;10;0.01)];          // conservative macro market buy
          a=23:macromarketfn[(5;10;0.01)];          // moderate macro market sell
          a=24;macromarketfn[(5;10;0.01)];          // moderate macro market buy
          a=25;macromarketfn[(5;10;0.01)];          // aggressive macro market sell
          a=26;macromarketfn[(5;10;0.01)];          // aggressive macro market buy
          a=27;macromarketfn[(5;10;0.01)];          // very aggressive macro market sell
          a=28;macromarketfn[(5;10;0.01)];          // very aggressive macro market buy
          a=29;flatfn[];                            // flatten position with market orders
          'INVALID_ACTION];
    };


// Main Adapt Function
// ---------------------------------------------------------------------------------------->

// Converts a scalar action representing a target state
// to which the agent will effect a transition into
// its representative amalgamation of events by way
// of an adapter. // TODO pair with state account repr
.state.adapter.Adapt :{[adapterType; encouragement; time; actions]
        .state.adapter.CombinedPathFinder[encouragement;time]'[actions[;0];actions[;1]];
    };