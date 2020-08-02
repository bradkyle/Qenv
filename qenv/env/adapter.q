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

// Event Creation Utilities
// --------------------------------------------------->

MakeActionEvent :{[kind;time;datum]
    :`time`intime`kind`cmd`datum!(time;time;kind;`NEW;datum);
    };

getLevelPrices          :{[s]
    :{$[x=`SELL;asc y;x=`BUY;desc y;`ERROR]}[s; (exec price from .state.CurrentDepth where side=s)]
    };

// TODO add error handling
getPriceAtLevel         :{[level;s]
    :getLevelPrices[s][level];
    };

// Return all open positions for an account
getOpenPositions              :{[accountId]
    :(select from .state.InventoryEventHistory where accountId=accountId);
    };

// Get the current qtys at each order level
getCurrentOrderQtysByPrice        :{[accountId;numAskLvls;numBidLvls]
    :exec sum leaves by price from .state.OrderEventHisory 
        where accountId=accountId, state=`NEW`PARTIALLYFILLED, otype=`LIMIT;
    };

// Generates a set of events that represent
// the placement of orders at a set of levels
// represented as a list
createOrderEventsAtLevel     :{[level;side;size;accountId]
    
    price: getPriceAtLevel[level;side];
    / :MakeActionEvent[`];
    };

// Generates a set of events that represent
// the placement of orders at a set of levels
// represented as a list
createOrderEventsByTargetDist :{[targetAskDist;targetBidDist]
    currentDist: getCurrentOrderLvlDist[count targetAskDist; count targetBidDist];
    currentPrices: getCurrentLvlPrices[count targetAskDist; count targetBidDist];
    askDeltas: targetAskDist - currentDist[0];
    bidDeltas: targetBidDist - currentDist[1];
    
    };

// Generates a set of events that represent
// the placement of orders at a set of levels
// represented as a list
createOrderEventsByLevelDeltas :{[lvlDeltas]

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

// Creates a set of events neccessary to transition
// the current positions to closed positions using
// market orders for a specific agent
createFlattenEvents          :{[accountId; time]
    openQty:select sum currentQty by side from .state.InventoryEventHistory where accountId=accountId;
    {createMarketOrderEvent[
        x;y;z[`currentQty]
        ]}[accountId;time] each (openQty where[openQty[`currentQty]>0]);
    };  

createOrderEventsFromDist   :{[accountId;time;dist;side]

    };

createMarketOrderEventsFromDist :{[]

    };

createDepositEvent  :{[accountId;amt;time]
    :MakeActionEvent[time;`DEPOSIT;(accountId; amt)];
    };

createWithdrawEvent  :{[accountId;amt;time]
    :MakeActionEvent[time;`WITHDRAW;(accountId; amt)];
    };

// Creates a set of stop orders that oppose the 
// current position accoutding to a certain loss
// fraction, if the current orders that are open
// do not have correct price, size they are either
// cancelled or amended depending on the configuration.
createNaiveStopEvents  :{[accountId;loss;time]
    openInv:select by side from .state.InventoryEventHistory where accountId=accountId, abs[currentQty]>0;
    {
        0n;
    }[accountId;loss;time] each openInv;
    };


// Action Adapters
// --------------------------------------------------->
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

// TODO change to fraction
/ first `price xgroup select orderId,leaves by price, side, time from .state.OrderEventHistory
/ ej[`price;bdlt;`price xgroup select orderId,leaves by price, asc time from .state.OrderEventHistory where side=`BUY]
/ ej[`price;bdlt;`price xgroup `time xdesc select orderId,leaves by price, time from .state.OrderEventHistory where side=`BUY]

getOrders   :{select qty:sum leaves by price from .state.OrderEventHistory where accountId=x, status in `NEW`PARTIALFILLED, side=`BUY, leaves>0}

// TODO add logic for reducing order count when neccessary
// TODO testing
makerSide   :{[aId;lvls;sizes;side;time]
    p:.adapter.getPriceAtLevel[lvls;side];
    c:select dlt:sum leaves by price from .state.OrderEventHistory where accountId=aId, status in `NEW`PARTIALFILLED, side=`BUY, leaves>0;
    dlt: neg[c] + (1!([]price:p;dlt:sizes));
    j:ej[`price;dlt;`price xgroup `time xdesc select orderId,leaves by price, time from .state.OrderEventHistory where side=side];
    
    amd:flip `orderId`size!flip raze[{flip (raze[x[`orderId]]; 1_Clip[(+\) raze[x[`dlt]],raze[x[`leaves]]])}each j where j[`dlt]<0];
    nord: select price,dlt from j where dlt>0;    
    :(amd;nord);
    };

makerBuySell : {[aId;time;limitSize;buyLvls;sellLvls]
    
    a:makerSide[aId;sellLvls;count[sellLvls]#limitSize;`SELL;time];
    b:makerSide[aId;buyLvls;count[buyLvls]#limitSize;`BUY;time];

    // Create batched requests
    reqs,:{.adapter.MakeActionEvent[`AMEND_BATCH_ORDER;x;]}[time] each `req xgroup ({}(a[0],b[0]));
    reqs,:{.adapter.MakeActionEvent[`PLACE_BATCH_ORDER;x;]}[time] each `req xgroup ({}(a[1],b[1]));
    :reqs;
    };


// TODO remove redundancy
adapters[`MARKETMAKER]   :{[time;action]
    a:action[0];
    aId:action[1];
    limitSize: 8;
    marketSize: 10;
    makerFn:makerBuySell[aId;time;limitSize];
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
Adapt :{[adapterType; actions]
    :adapters[adapterType] each actions;
    };