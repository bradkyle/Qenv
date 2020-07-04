
\l order.q
\l engine.q
\l util.q
\d .state
/ TODO config
/ rebalancefreq       : `long$();
/ maxBalanceRebalance : `long$();
/ withrawFreq         : `long$();
/ minBalanceWithdraw  : `long$();
/ doneBalance         : `long$();
/ maxNumSteps         : `long$();
/ totalSteps          : `long$();
/ rewardKind          : `.state.REWARDKIND$();
/ lookBackSize        : `long$();
/ outageFreq          : `long$();
/ outageMaxLength     : `long$();
/ outageMinLength     : `long$();
/ outageMU            : `float$();
/ outageSigma         : `float$();

CurrentStep: 0;
StepTime: .z.z;

// Singleton State and Lookback Buffers
// =====================================================================================>
// The lookback buffers attempt to build a realistic representation of what the
// agent will percieve in a real exchange.

// The following tables maintain a local state buffer 
// representative of what the agent will see when
// interacting with a live exchange. 
AccountEventHistory: (
    [accountId          : `long$()]
    balance             : `float$();
    available           : `float$();
    frozen              : `float$();
    margin              : `float$()
    );

// Maintains a historic and current record of the 
// positions (Inventory) each agent has held and
// subsequently provides agent specific details
// therin
InventoryEventHistory: (
    accountId           :  `long$();
    side                :  `.inventory.POSITIONSIDE$();
    currentQty          :  `long$();
    realizedPnl         :  `long$();
    unrealizedPnl       :  `long$()
    );

// Maintains a historic and current record of orders
// that the engine has produced.
OrderEventHistory: (
    [orderId        :   `long$()]
    accountId       :   `long$();
    side            :   `.order.ORDERSIDE$();
    otype           :   `.order.ORDERTYPE$();
    leaves          :   `long$();
    filled          :   `long$();
    limitprice      :   `long$(); / multiply by 100
    stopprice       :   `long$(); / multiply by 100
    status          :   `.order.ORDERSTATUS$();
    time            :   `datetime$();
    isClose         :   `boolean$();
    trigger         :   `.order.STOPTRIGGER$();
    execInst        :   `.order.EXECINST$()
    );

// Maintains a historic record of depth snapshots
// with the amount of levels stored dependent upon
// the config for the specified from the engine 
// i.e. The depth has been directly affected by 
// the agent.
DepthEventHistory: (
    time            :   `datetime$()
    );

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
TradeEventHistory: (
    size            :   `float$();
    price           :   `float$();
    side            :   `.order.ORDERSIDE$();
    time            :   `datetime$()
    );

// TODO batching + 

// Maintains a lookback buffer of 
// aggregations of state including
// state that has not been modified 
// by the engine per accountId
// sorted by time for which normalization
// and feature scaling that requires more
// than a single row can be done. 
FeatureBuffer: (

    );

InsertResultantEvents   :{[events]

    k:event[`kind];
    $[
        k=`DEPTH;
        [
            `.state.DepthEventHistory insert ()
        ];
        k=`TRADE;
        [
            `state.TradeEventHistory insert ();
        ];
        k=`ACCOUNT_UPDATE;
        [
            // if account does not exsit
            $[event[`datum][`accountId] in .state.AccountEventHistory;
             [
                update from `state.AccountEventHistory;
             ];
             [

             ]
            ]
        ];
        k=`ORDER_UPATE`NEW_ORDER`ORDER_DELETED;
        [
            $[event[`datum][`orderId] in .state.OrderEventHistory;
                [
                    update from `state.OrderEventHistory;
                ];
                [
                    
                ]
            ]
        ]; 
        k=`INVENTORY_UPDATE;
        [
            $[event[`datum][`inventoryId] in .state.InventoryEventHistory;
                [
                   `.state.InventoryEventHistory insert ();
                ];
                [
                    
                ]
            ]
            
        ]
    ];
    };

// Adapters
// =====================================================================================>

/*******************************************************
/ adapter enumerations
ADAPTERTYPE :   (`MARKETMAKER;        
                `DUALBOX;          
                `SIMPLEBOX;    
                `DISCRETE);   

REWARDKIND  :   (`SORTINO;
                 `VANILLA);   


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
adapters : (`.state.ADAPTERTYPE$())!();

// Simply places orders at best bid/ask
adapters[`DISCRETE]     :{[action;accountId]
    events:();
    penalty:0f;
    $[
        action=0;
        [penalty+:.global.Encouragement]; // HOLD event agent does nothing
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
adapters[`MARKETMAKER]   :{[action;accountId]
    events:();
    penalty:0f;
    limitSize: 8;
    marketSize: 10;
    $[
        action=0;
        [penalty+:.global.Encouragement]; // TODO derive config from account?
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
        [:0N] // TODO errors
    ];
    :(events; penalty)
    };

Adapt               :{[adapterType; action; accountId]
    :adapters[adapterType] [action;accountId];
    };

// Exposed State Logic
// =====================================================================================>

/
The state module utilizes historic lookback buffers to
represent the state thate an agent would recieve when 
subscribed to an exchange.
TODO move adapters into here
\

// Agent specific result functions
// --------------------------------------------------->

// Efficiently returns the aggregated and normalised
// feature vector represenations of the agent state 
// and environment state for a set of agent ids.
getFeatureVectors    :{[accountIds]

        // TODO add long term prediction features.

        // TODO add account id to feature vector
        `.schema.FeatureBuffer upsert raze(
            value 1_last depth;
            last mark.mark_price;
            last funding.funding_rate;
            last trades.price;
            value 1_last account;
            value last piv[0!update time:max time from select num:count size, high:max price, low: min price, open: first price, close: last price, volume: sum size, msize: avg size, hsize: max size, lsize: min size by side from source_trades where time>= max time - `minute$5;`time;`side;`high`low`open`close`volume`msize`hsize`lsize`num];
            value last piv[0!update time:max source_trades.time from select high:max price, low: min price, open: first price, close: last price, volume: sum size, msize: avg size, hsize: max size, lsize: min size by side from source_trades where {x|next x}/[100;time=max time];`time;`side;`high`low`open`close`volume`msize`hsize`lsize];
            value exec sum leaves, avg price from orders where ordtyp=`limit, status=`new, side=`buy;
            value exec sum leaves, avg price from orders where ordtyp=`limit, status=`new, side=`sell;
            value exec sum leaves, max price from orders where ordtyp=`stop_market, status=`new, side=`buy;
            value exec sum leaves, min price from orders where ordtyp=`stop_market, status=`new, side=`sell; 
            value exec last amount, last average_entry_price, last leverage, last realised_pnl, last unrealised_pnl from positions where side=`long;
            value exec last amount, last average_entry_price, last leverage, last realised_pnl, last unrealised_pnl from positions where side=`short
        );
        // TODO count by account id
        / $[(count .schema.FeatureBuffer)>maxBufferSize;]; // TODO make max buffer size configurable
        // TODO fill forward + normalize
        :.ml.minmaxscaler[-100#.schema.FeatureBuffer];
    };

// Returns the resultant rewards for a set of agent
// ids based upon the configuration set i.e.
// sortino ratio etc.
getResultantRewards  :{[accountIds] // TODO apply given reward function by agent specified reward function.
    select deltas last amount by accountId, (`date$time) + 1 xbar `minute$time from account where time >= `minute$rewardLookbackMinutes // TODO make reward lookback minutes configurable
    };

// Secondary state functions
// --------------------------------------------------->

// Uses a preset query to derive a set of events
// that represent the progression of state on
// an exchange, thereafter the events are parsed
// into the forms defined by the models after which
// they are returned.
nextEvents   :{[step] // TODO changes in depth due to trades still persist only when agent order do change?
        :(
            select from .schema.SourceDepth where step=step; // returns the set of depth updates (including trades) that happen.
            select from .schema.SourceTrades where step=step; // returns the set of trades (not made by the agent) in period
            select from .schema.SourceMarks where step=step; // returns the set of mark price updates that occur in the period
            select from .schema.SourceFundings where step=step; // returns the set of funding events that occur in the period
        );
    };

// Derives a set of events that would constitute
// the transition of state of the exchange BEFORE
// THE ACTIONS TOOK PLACE.
// Appending the actions to the events to be processed.
derive  :{[actions;time]
    events: ();
    events,: nextEvents[.state.CurrentStep]; // Utilizes a global variable to denote the current step.
    // sample a probability space of request time
    events,: .adapter.Adapt [] [accountId;action;time;meanWait;stdWait]; // TODO make work
    :events; //TODO implement penalty
    };


// Inserts the step wise events recieved (back)
// from the engine and adds them to their 
// respective table before deriving a feature
// vector and resultant reward for each agent
// participating in the environment.
advance :{[events;accountIds]
    InsertResultantEvents[events] // TODO try catch etc.
    featureVectors: getFeatureVector[accountIds]; // TODO parrellelize
    .state.CurrentStep+:1;
    :featureVectors;
    };


// Main Callable functions
// --------------------------------------------------->

Config      :{[]


    };

// Derives a dictionary of info pertaining to the agents
// individually and those that are global.
Info        :{[accountIds]

    };

// Resets the state for all agents for whom 
// ids have been included into the ids parameter
Reset       :{[accountIds] // TODO make into accountConfigs
    events:();
    // Reset public singletons
    .state.CurrentStep:0; // TODO include buffer i.e. set current step to 10
    .state.StepTime: exec from .schema.PrimaryStepInfo where step=0; // returns the current step info i.e. time, loadshedding prob etc.
    
    // Derive the primary set of events derived from exchange
    events,:nextEvents[.state.CurrentStep]; // TODO derive actual events from datums
    // TODO reset accounts inventory orders instrument

    :advance[events;accountIds];
    };

// Carries out a step in the exchange environment
// It generates a set of events for each action
// given its time and sets a given offset for 
// each event therin before sending the action to
// the engine.
// It will thereafter advance the state and return
// the next observations, rewards, done and info
// for each agent
Step    :{[actions]
    // TODO format actions

    // TODO actions as a tuple of account id and action: derive account ids from actions.
    events:derive[actions];

    // The engine produces a set of new events.
    newEvents: .engine.ProcessEventBatch[events];

    obs:  advance[newEvents;accountIds];

    // Generates a set of resultant rewards based on the config
    // of each agent, the rewards are returned as a table indexed
    // by the respective accountIds
    rewards: getResultantReward[accountIds]; // TODO parrellelize

    // Derive the current info for the
    // entire engine and for each subsequent
    // account referenced in accountIds
    // Returns a table of Info indexed by accountId
    info: Info[accountIds];

    :(uj)over(obs;rewards;info);
    };