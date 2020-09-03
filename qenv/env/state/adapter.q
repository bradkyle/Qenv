\l state.q
// Adapters
// =====================================================================================>

/*******************************************************
/ adapter enumerations
.state.adapter.ADAPTERTYPE :
                (
                    `MARKETMAKER;        
                    `DUALBOX;          
                    `SIMPLEBOX; // TODO
                    `DISCRETE; // TODO
                    `LVLDELTAS; // TODO
                    `MACRO // TODO
                );   

// TODO move into state

/
The adapter module serves to represent a set of logic
that converts an action of a given shape and magniude
to a set of events that serve to convert or transition
the current environment agent state to the desired
environment agent state.
\

// TODO create functionality for requesting state when there is none

// Event Creation Utilities
// --------------------------------------------------->

// Generates a set of events that represent
// the placement of orders at a set of levels
// represented as a list
.state.adapter.createOrderAtLevel     :{[level;side;size;accountId;reduceOnly;time]
    price: .state.getPriceAtLevel[level;side];
    o:`price`clId`instrumentId`accountId`side`otype`size`reduceOnly!(
        price;
        .state.genNextClOrdId[];
        .state.DefaultInstrumentId;
        accountId;
        side;
        `LIMIT;
        size;
        reduceOnly);
    :.event.MakePlaceOrderEvent[time;o];
    };


// TODO change to fraction
/ first `price xgroup select orderId,leaves by price, side, time from .state.OrderEventHistory
/ ej[`price;bdlt;`price xgroup select orderId,leaves by price, asc time from .state.OrderEventHistory where side=`BUY]
/ ej[`price;bdlt;`price xgroup `time xdesc select orderId,leaves by price, time from .state.OrderEventHistory where side=`BUY]

// TODO add logic for reducing order count when neccessary
// TODO testing
// @aid: accountId
// @lvls: levels ascending from spread
// @sizes: target sizes
// @s: side
.state.adapter.makerSide   :{[aId;lvls;sizes;s;time]
    p:.state.getPriceAtLevel[lvls;s];
    c:.state.getLvlOQtysByPrice[aId;s];
    dlt: neg[c] + (1!([]price:p;dlt:sizes));
    j:ej[`price;dlt;`price xgroup `time xdesc (select orderId,leaves by price, time from .state.OrderEventHistory where side=s)];
    
    amd:flip `orderId`size!flip raze[{flip (raze[x[`orderId]]; 1_Clip[(+\) raze[x[`dlt]],raze[x[`leaves]]])}each j where j[`dlt]<0];
    nord: select price,dlt,side from j where dlt>0;    
    :(amd;nord);
    };

// TODO test for 1, 0 count lvl etc, // TODO exp / log drift
.state.adapter.makerDelta : {[aId;time;limitSize;buyLvls;sellLvls]
    a:.state.adapter.makerSide[aId;sellLvls;count[enlist sellLvls]#limitSize;`SELL;time];
    b:.state.adapter.makerSide[aId;buyLvls;count[enlist buyLvls]#limitSize;`BUY;time];

    // Group amend [ask,bid;max count per req]
    // assumes amend to 0 cancels order
    // TODO add participate don't initiate
    amd:{x[`i]:{floor[x%y]}[til count[x];y];:`i xgroup x}[(a[0],b[0]);10];
    nord:{x[`i]:{floor[x%y]}[til count[x];y];x[`otype]:`LIMIT;:`i xgroup x}[(a[1],b[1]);10];

    // Create batched requests
    reqs:();
    reqs,:{.adapter.MakeActionEvent[`AMEND_BATCH_ORDER;x;flip[y]]}[time] each amd;
    reqs,:{.adapter.MakeActionEvent[`PLACE_BATCH_ORDER;x;flip[y]]}[time] each nord;
    :reqs;
    };

// TODO Pricing schemas not based on other orders placed in book
// (2 xexp til 10) clip at 1, then derive price
// floor[(2 xlog (1+til 10))*4] 
// floor[10%(1.5*(1+til 10))]%10

// Creates a set of events neccessary to transition
// the current positions to closed positions using
// market orders for a specific agent
.state.adapter.createFlattenEvents          :{[aId; time]
    openQty:.state.getOpenPositionAmtBySide[aId];
    :({.adapter.createMarketOrderEvent[
        x;y;z[`currentQty]
        ]}[aId;time] each openQty);
    };  

// Creates a set of order events that transition the current
// open order events to a new set that satisfies the distribution
// provided TODO make better.
.state.adapter.createOrderEventsFromDist   :{[accountId;time;dist;side]
    
    };

// Creates a set of market order events that satisfy the provided
// distribution.
.state.adapter.createMarketOrderEventsFromDist :{[]

    };

// Stop Event Utilities
// ---------------------------------------------------------------------------------------->
// Should use the expected next state inventory
// to derive a set of stops that serve to protect
// the inventory from wild swings in the price and
// subsequently the unrealized pnl.

// Creates a set of stop orders that oppose the 
// current position accoutding to a certain loss
// fraction, if the current orders that are open
// do not have correct price, size they are either
// cancelled or amended depending on the configuration.
.state.adapter.createNaiveStops  :{[aId;loss;time]
    openInv:.state.getOpenPositions[aId];
    {
        0n;
    }[aId;loss;time] each openInv;
    };

// Creates the set of stop orders that oppose the
// current position according to a certain loss fraction
// 
.state.adapter.createStaggeredStops  :{[aId;loss;num;time]
    openInv:.state.getOpenPositions[aId];
    {
        0n;
    }[aId;loss;time] each openInv;
    };

// Creates a set of stop orders that oppose the 
// current position accoutding to a certain loss
// fraction, if the current orders that are open
// do not have correct price, size they are either
// cancelled or amended depending on the configuration.
.state.adapter.createExpStaggeredStops  :{[aId;loss;num;time]
    openInv:.state.getOpenPositions[aId];
    {
        0n;
    }[aId;loss;time] each openInv;
    };




// Action Adapter Mapping
// ---------------------------------------------------------------------------------------->

.state.adapter.mapping : (`.state.adapter.ADAPTERTYPE$())!();

// Simply places orders at best bid/ask
// action should be of type long
.state.adapter.mapping[`DISCRETE]     :{[action;accountId]
    penalty:0f;
    ordFn:.state.adapter.createOrderEventsFromDist[accountId;time];
    mktFn:.state.adapter.createMarketOrderEventsFromDist[accountId;time]
    $[action=0;
        [:(();penalty+:.global.Encouragement)]; // TODO change from global to state config ()
        action=1;
        mktFn[0.05;`BUY];
        action=2;
        mktFn[accountId;time;0.05;`SELL];
        action=3;
        mktFn[0.05;`BUY];
        action=4;
        mktFn[0.05;`SELL];
        action=5;
        .state.adapter.createFlattenEvents[accountId;time];
        'INVALID_ACTION];
    };

// SIMBLEBOX generates the set of actions that
// will transition an agent with positions 
// representing the current distribution
// to the desired distribution.
/ adapters[`SIMPLEBOX]  :{[action;accountId]
    // TODO
    / };

// DUALBOX adapter derives the set of actions
// that would transition an agent from the 
// current position to the desired one.
/ adapters[`DUALBOX]      :{[action;accountId]
    // TODO
    / };

// LVLDELTAS adapter derives the set of events
// that will transition an agent from the 
// current distribution of orders per lvl
// to the desired distribution of orders
// per lvl given the current state of the
// agent and the level of aggregation, 
// number of levels configured for agent.
/ adapters[`LVLDELTAS]    :{[action;accountId]
    // TODO
    / };


// TODO remove redundancy
.state.adapter.mapping[`MARKETMAKER]   :{[time;action] // TODO refactor to shorter
    a:action[0];
    aId:action[1];
    limitSize: 8;
    marketSize: 10;
    makerFn:.state.adapter.makerDelta[aId;time;limitSize];
    takerFn:.state.adapter.createMarketOrderEvent[aId;time;marketSize];
    res: $[
        a=0;
        [:(();penalty+:.global.Encouragement)]; // TODO derive config from account?
        a=1;
        makerFn[0;4];
        a=2;
        makerFn[0;9];
        a=3;
        makerFn[0;14];
        a=4;
        makerFn[4;0];
        a=5;
        makerFn[4;4];
        a=6;
        makerFn[4;9];
        a=7;
        makerFn[4;14];
        a=8;
        makerFn[9;0];
        a=9;
        makerFn[9;4];
        a=10;
        makerFn[9;9];
        a=11;
        makerFn[9;14];
        a=12;
        makerFn[14;0];
        a=13;
        makerFn[14;4];
        a=14;
        makerFn[14;9];
        a=15;
        makerFn[14;14];
        a=16;
        .state.adapter.createFlattenEvents[];
        a=17;
        takerFn[`BUY];
        a=18;
        takerFn[`SELL];
        a=19;
        .state.adapter.createCancelAllOrdersEvent[]; // TODO add more
        'INVALID_ACTION];
    
    :res;
    };

// Converts a scalar action representing a target state
// to which the agent will effect a transition into
// its representative amalgamation of events by way
// of an adapter.
.state.adapter.Adapt :{[adapterType; time; actions]
    :.state.adapter.mapping[adapterType] each actions;
    };