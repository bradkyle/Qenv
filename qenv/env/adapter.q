\d .adapter
\l state.q
\l util.q
// Adapters
// =====================================================================================>

/*******************************************************
/ adapter enumerations
ADAPTERTYPE :   (`MARKETMAKER;        
                `DUALBOX;          
                `SIMPLEBOX;    
                `DISCRETE);   

// TODO move into state

/
The adapter module serves to represent a set of logic
that converts an action of a given shape and magniude
to a set of events that serve to convert or transition
the current environment agent state to the desired
environment agent state.
\

// 
// TODO implement macro actions!

// TODO create functionality for requesting state when there is none

// Event Creation Utilities
// --------------------------------------------------->

MakeActionEvent :{[kind;time;datum]
    :`time`intime`kind`cmd`datum!(time;time;kind;`NEW;datum);
    };


MakeActionEventC :{[kind;cmd;time;datum]
    :`time`intime`kind`cmd`datum!(time;time;kind;cmd;datum);
    };

// Creates a simple market order event for the
// respective agent
createMarketOrderEvent      :{[accountId;time;size;side]
    :MakeActionEvent[time;`CANCEL_ALL_ORDERS;(accountId;side;size)];
    };

// Creates an event that cancels all open orders for
// a given agent.
createCancelAllOrdersEvent  :{[accountId;time]
    :MakeActionEvent[time;`CANCEL_ALL_ORDERS;(accountId)];
    };

createDepositEvent  :{[accountId;amt;time]
    :MakeActionEvent[time;`DEPOSIT;(accountId; amt)];
    };

createWithdrawEvent  :{[accountId;amt;time]
    :MakeActionEvent[time;`WITHDRAW;(accountId; amt)];
    };

// Generates a set of events that represent
// the placement of orders at a set of levels
// represented as a list
createOrderAtLevel     :{[level;side;size;accountId;reduceOnly;time]
    price: .state.getPriceAtLevel[level;side];
    o:`price`clId`instrumentId`accountId`side`otype`size`reduceOnly!(
        price;
        .state.genNextClOrdId[];
        .state.DefaultInstrumentId;
        accountId;
        side;
        `LIMIT;
        size;
        reduceOnly
    );
    :MakeActionEvent[`ORDER;time;o];
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
makerSide   :{[aId;lvls;sizes;s;time]
    p:.state.getPriceAtLevel[lvls;s];
    c:.state.getLvlOQtysByPrice[aId;s];
    dlt: neg[c] + (1!([]price:p;dlt:sizes));
    j:ej[`price;dlt;`price xgroup `time xdesc (select orderId,leaves by price, time from .state.OrderEventHistory where side=s)];
    
    amd:flip `orderId`size!flip raze[{flip (raze[x[`orderId]]; 1_Clip[(+\) raze[x[`dlt]],raze[x[`leaves]]])}each j where j[`dlt]<0];
    nord: select price,dlt,side from j where dlt>0;    
    :(amd;nord);
    };

// TODO test for 1, 0 count lvl etc
makerDelta : {[aId;time;limitSize;buyLvls;sellLvls]
    a:makerSide[aId;sellLvls;count[enlist sellLvls]#limitSize;`SELL;time];
    b:makerSide[aId;buyLvls;count[enlist buyLvls]#limitSize;`BUY;time];

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

// Creates a set of events neccessary to transition
// the current positions to closed positions using
// market orders for a specific agent
createFlattenEvents          :{[aId; time]
    openQty:.state.getOpenPositionAmtBySide[aId];
    :({.adapter.createMarketOrderEvent[
        x;y;z[`currentQty]
        ]}[aId;time] each openQty);
    };  

// Creates a set of order events that transition the current
// open order events to a new set that satisfies the distribution
// provided TODO make better.
createOrderEventsFromDist   :{[accountId;time;dist;side]
    
    };

// Creates a set of market order events that satisfy the provided
// distribution.
createMarketOrderEventsFromDist :{[]

    };


// Creates a set of stop orders that oppose the 
// current position accoutding to a certain loss
// fraction, if the current orders that are open
// do not have correct price, size they are either
// cancelled or amended depending on the configuration.
createNaiveStopEvents  :{[aId;loss;time]
    openQty:.state.getOpenPositionAmtBySide[aId];
    {
        0n;
    }[aId;loss;time] each openInv;
    };


// Action Adapters
// ---------------------------------------------------------------------------------------->
adapters : (`.adapter.ADAPTERTYPE$())!();

// Simply places orders at best bid/ask
adapters[`DISCRETE]     :{[action;accountId]
    penalty:0f;
    $[action=0;
        [:(();penalty+:.global.Encouragement)]; // TODO change from global to state config ()
        action=1;
        createOrderEventsFromDist[accountId;time;0.05;`BUY];
        action=2;
        createOrderEventsFromDist[accountId;time;0.05;`SELL];
        action=3;
        createMarketOrderEventsFromDist[accountId;time;0.05;`BUY];
        action=4;
        createMarketOrderEventsFromDist[accountId;time;0.05;`SELL];
        action=5;
        createFlattenEvents[accountId;time];
        []];
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
adapters[`MARKETMAKER]   :{[time;action] // TODO refactor to shorter
    a:action[0];
    aId:action[1];
    limitSize: 8;
    marketSize: 10;
    makerFn:makerDelta[aId;time;limitSize];
    takerFn:createMarketOrderEvent[aId;time;marketSize];
    res: $[
        a=0;
        [0N]; // TODO derive config from account?
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
        createFlattenEvents[];
        a=17;
        takerFn[`BUY];
        a=18;
        takerFn[`SELL];
        a=19;
        createCancelAllOrdersEvent[]; // TODO add more
        [:0N]];
    
    :res;
    };

// Converts a scalar action representing a target state
// to which the agent will effect a transition into
// its representative amalgamation of events by way
// of an adapter.
Adapt :{[adapterType; time; actions]
    :adapters[adapterType] each actions;
    };