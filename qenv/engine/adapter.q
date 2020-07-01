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

getPriceAtLevel               :{[level;side;]
     from last .schema.DepthHistory
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
    events,:.global.MakeOrderEvent[side;price;size];
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
    events,:[]
};  

// Creates an event that cancels all open orders for
// a given agent.
createCancelAllOrdersEvent  :{[]
    events:();
    events,:.global.MakeCancelAllOrdersEvent[];
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
adapters : (`ADAPTERTYPE$()) ! ()

// Simply places orders at best bid/ask
adapters[`DISCRETE]     :{[action;accountId]
    events:();
    penalty:0f;
    $[
        action=0;
        [penalty+=.global.Encouragement]; // HOLD event agent does nothing
        action=1;
        [
            res = createOrderEventsFromDist[0.05;`BUY];
            events,:res[0];
            penalty+: res[1]; 
        ];
        action=2;
        [
            res = createOrderEventsFromDist[0.05;`SELL]; // indicative of 0.05 * max position i.e. 5%
            events,:res[0];
            penalty+: res[1]; 
        ];
        action=3;
        [
            res = createMarketOrderEventsFromDist[0.05;`BUY];
            events,:res[0];
            penalty+: res[1]; 
        ];
        action=4;
        [
            res = createMarketOrderEventsFromDist[0.05;`SELL];
            events,:res[0];
            penalty+: res[1]; 
        ];
        action=5;
        [
            res = createFlattenEvents[];
            events,:res[0];
            penalty+: res[1]; 
        ];
        [];
    ]
};

// SIMBLEBOX generates the set of actions that
// will transition an agent with positions 
// representing the current distribution
// to the desired distribution.
adapters[`SIMPLEBOX]  :{[action;accountId]
    // TODO
};

// DUALBOX adapter derives the set of actions
// that would transition an agent from the 
// current position to the desired one.
adapters[`DUALBOX]      :{[action;accountId]
    // TODO
};

// LVLDELTAS adapter derives the set of events
// that will transition an agent from the 
// current distribution of orders per lvl
// to the desired distribution of orders
// per lvl given the current state of the
// agent and the level of aggregation, 
// number of levels configured for agent.
adapters[`LVLDELTAS]    :{[action;accountId]
    // TODO
};

// TODO remove redundancy
adapters[`MARKETMAKER]   :{[action;accountId]
    events:();
    penalty:0f;
    limitSize: 8;
    marketSize: 10;
    $[
        action=0;
        [penalty+=.global.Encouragement]; // TODO derive config from account?
        action=1;
        [
            res = createOrderEventsAtLevels[0;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[4;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=2;
        [
            res = createOrderEventsAtLevels[0;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[9;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=3;
        [
            res = createOrderEventsAtLevels[0;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[14;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=4;
        [
            res = createOrderEventsAtLevels[4;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[0;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=5;
        [
            res = createOrderEventsAtLevels[4;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[4;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=6;
        [
            res = createOrderEventsAtLevels[4;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[9;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=7;
        [
            res = createOrderEventsAtLevels[4;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[14;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=8;
        [
            res = createOrderEventsAtLevels[9;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[0;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=9;
        [
            res = createOrderEventsAtLevels[9;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[4;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=10;
        [
            res = createOrderEventsAtLevels[9;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[9;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=11;
        [
            res = createOrderEventsAtLevels[9;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[14;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=12;
        [
            res = createOrderEventsAtLevels[14;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[0;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=13;
        [
            res = createOrderEventsAtLevels[14;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[4;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=14;
        [
            res = createOrderEventsAtLevels[14;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[9;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=15;
        [
            res = createOrderEventsAtLevels[14;`SELL;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];

            res = createOrderEventsAtLevels[14;`BUY;limitSize;accountId];
            events,:res[0];
            penalty+: res[1];
        ];
        action=16;
        [
            res = createFlattenEvents[];
            events,:res[0];
            penalty+: res[1]; 
        ];
        action=17;
        [
            res = createMarketOrderEvent[`BUY;marketSize];
            events,:res[0];
            penalty+: res[1];
        ];
        action=18;
        [
            res = createMarketOrderEvent[`SELL;marketSize];
            events,:res[0];
            penalty+: res[1];
        ];
        action=19;
        [
            res = createCancelAllOrdersEvent[];
            events,:res[0];
            penalty+: res[1];
        ]; // TODO add more
        [] // TODO errors
    ];
    :(events; penalty;)
};

Adapt               :{[adapterType; action; accountId]
    :adapters[adapterType] [action;accountId];
};