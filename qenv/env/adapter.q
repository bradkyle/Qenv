\l state.q
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

MakeActionEvent :{[accountId;kind;time;datum]
    :`time`intime`kind`cmd`datum!();
    };

// TODO add error handling
getPriceAtLevel         :{[level;side]
    :(select price from .state.CurrentDepth where side=side)[level][`price]
    };

// Return all open positions for an account
getOpenPositions              :{[accountId]
    :(select from .state.InventoryEventHistory where accountId=accountId)
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
    :MakeActionEvent[`];
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
    ]}[accountId;time] each (openQty where[openQty[`currentQty]>0])
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

    }[accountId;loss;time] each openInv;
    };


// Action Adapters
// --------------------------------------------------->
adapters : (`.state.ADAPTERTYPE$())!();

// Simply places orders at best bid/ask
adapters[`DISCRETE]     :{[action;accountId]
    
    penalty:0f;
    $[
        action=0;
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

makerBuySell : {[accountId;time;limitSize;buyLvl;sellLvl]
    
    currentBidQtyByPrice:0;
    currentAskQtyByPrice:0;
    targetBidQtyByPrice:0;
    targetAskQtyByPrice:0;

    bidDeltas:targetBidQtyByPrice - currentBidQtyByPrice;
    askDeltas:targetAskQtyByPrice - currentAskQtyByPrice;

     
    
    
    };

// TODO remove redundancy
adapters[`MARKETMAKER]   :{[action;accountId]

    penalty:0f;
    limitSize: 8;
    marketSize: 10;
    makerFn:makerBuySell[accountId;time;limitSize];
    takerFn:createMarketOrderEvent[accountId;time;marketSize];
    res: $[
        action=0;
        [:(();penalty+:.global.Encouragement)]; // TODO derive config from account?
        action=1;
        makerFn[];
        action=2;
        makerFn[];
        action=3;
        makerFn[];
        action=4;
        makerFn[];
        action=5;
        makerFn[];
        action=6;
        makerFn[];
        action=7;
        makerFn[];
        action=8;
        makerFn[];
        action=9;
        makerFn[];
        action=10;
        makerFn[];
        action=11;
        makerFn[];
        action=12;
        makerFn[];
        action=13;
        makerFn[];
        action=14;
        makerFn[];
        action=15;
        makerFn[];
        action=16;
        createFlattenEvents[];
        action=17;
        takerFn[`BUY];
        action=18;
        takerFn[`SELL];
        action=19;
        createCancelAllOrdersEvent[]; // TODO add more
        [:0N]];
    
    :(penalty;res);
    };

// Converts a scalar action representing a target state
// to which the agent will effect a transition into
// its representative amalgamation of events by way
// of an adapter.
Adapt :{[adapterType; action; accountId]
    :adapters[adapterType] [action;accountId];
    };