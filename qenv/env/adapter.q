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

MakeActionEvent :{[agentId;kind;time]
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
createMarketOrderEvent      :{[accountId;time;size]

    };

// Creates an event that cancels all open orders for
// a given agent.
createCancelAllOrdersEvent  :{[accountId]
    :MakeActionEvent[accountId;`CANCEL_ALL_ORDERS];
    };

// Creates a set of events neccessary to transition
// the current positions to closed positions using
// market orders for a specific agent
createFlattenEvents          :{[accountId; time]
    openQty:select sum currentQty by side from .state.InventoryEventHistory;
    {createMarketOrderEvent[
        x;y;z[`currentQty]
    ]}[accountId;time] each (openQty where[openQty[`currentQty]>0])
    };  

createOrderEventsFromDist   :{[]

    };

createMarketOrderEventsFromDist :{[]

    };

createDepositEvent  :{[accountId;amt]
    :MakeActionEvent[accountId;`DEPOSIT;amt];
    };

createWithdrawEvent  :{[accountId;amt]
    :MakeActionEvent[accountId;`WITHDRAW;amt];
    };

// Creates a set of stop orders that oppose the 
// current position accoutding to a certain loss
// fraction, if the current orders that are open
// do not have correct price, size they are either
// cancelled or amended depending on the configuration.
createNaiveStopEvents  :{[accountId;loss]

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
        createOrderEventsFromDist[0.05;`BUY];
        action=2;
        createOrderEventsFromDist[0.05;`SELL];
        action=3;
        createMarketOrderEventsFromDist[0.05;`BUY];
        action=4;
        createMarketOrderEventsFromDist[0.05;`SELL];
        action=5;
        createFlattenEvents[];
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

makerBuySell : {[accountId;buyLvl;sellLvl;limitSize;accountId]
    
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
    res: $[
        action=0;
        [:(();penalty+:.global.Encouragement)]; // TODO derive config from account?
        action=1;
        makerBuySell[];
        action=2;
        makerBuySell[];
        action=3;
        makerBuySell[];
        action=4;
        makerBuySell[];
        action=5;
        makerBuySell[];
        action=6;
        makerBuySell[];
        action=7;
        makerBuySell[];
        action=8;
        makerBuySell[];
        action=9;
        makerBuySell[];
        action=10;
        makerBuySell[];
        action=11;
        makerBuySell[];
        action=12;
        makerBuySell[];
        action=13;
        makerBuySell[];
        action=14;
        makerBuySell[];
        action=15;
        makerBuySell[];
        action=16;
        createFlattenEvents[];
        action=17;
        createMarketOrderEvent[`BUY;marketSize];
        action=18;
        createMarketOrderEvent[`SELL;marketSize];
        action=19;
        createCancelAllOrdersEvent[]; // TODO add more
        [:0N]];
    
    :res;
    };

// Converts a scalar action representing a target state
// to which the agent will effect a transition into
// its representative amalgamation of events by way
// of an adapter.
Adapt :{[adapterType; action; accountId]
    :adapters[adapterType] [action;accountId];
    };