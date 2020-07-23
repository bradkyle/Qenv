


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

getPriceAtLevel               :{[level;side]
    // TODO
    };

getOpenPositions              :{[accountId]

    };

getCurrentOrderLvlDist        :{[numAskLvls;numBidLvls]
    
    };

// Generates a set of events that represent
// the placement of orders at a set of levels
// represented as a list
createOrderEventsAtLevel     :{[level;side;size;accountId]
    events:();
    price: getPriceAtLevel[level;side];
    events:events,.global.MakeOrderEvent[side;price;size];
    :events;
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
createMarketOrderEvent      :{[]

    };

// Creates a set of events neccessary to transition
// the current positions to closed positions using
// market orders for a specific agent
createFlattenEvents          :{[accountId]
    events:();
    positions: getOpenPositions[accountId];
    
    $[side=`SELL;`BUY;`SELL]
    abs currentQty
    events:events,[]
    };  

// Creates an event that cancels all open orders for
// a given agent.
createCancelAllOrdersEvent  :{[]
    events:();
    events:events,.global.MakeCancelAllOrdersEvent[];
    :events;
    };

createOrderEventsFromDist   :{[]

    };

createMarketOrderEventsFromDist :{[]

    };

createDepositEvent  :{[]

    };

createWithdrawEvent  :{[]

    };

createNaiveStopEvents  :{[]

    };


// Action Adapters
// --------------------------------------------------->
adapters : (`.state.ADAPTERTYPE$())!();

// Simply places orders at best bid/ask
adapters[`DISCRETE]     :{[action;accountId]
    events:();
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
        [];
    ]
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

makerBuySell : {[buyLvl;sellLvl;limitSize;accountId]
    res:();
    res,:createOrderEventsAtLevels[0;`SELL;limitSize;accountId];
    res,:createOrderEventsAtLevels[4;`BUY;limitSize;accountId];
    :res:
    };

// TODO remove redundancy
adapters[`MARKETMAKER]   :{[action;accountId]
    events:();
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
        [:0N] // TODO errors
    ];
    :res;
    };

// Converts a scalar action representing a target state
// to which the agent will effect a transition into
// its representative amalgamation of events by way
// of an adapter.
Adapt :{[adapterType; action; accountId]
    :adapters[adapterType] [action;accountId];
    };