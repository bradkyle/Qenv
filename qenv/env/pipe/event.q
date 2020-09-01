\d .event

// TODO setup in seperate process?

/*******************************************************
/ error kind enumerations
ERRCODES :();


/*******************************************************
/ event enumerations

// USING MANUAL LIST FOR REFERENCABILITY 
EVENTKIND:(
        0; // DEPTH
        1; // TRADE
        2; // MARK
        3; // LIQUIDATION
        4; // FUNDING
        5; // SETTLEMENT
        6; // ACCOUNT
        7; // INVENTORY
        8; // ORDER
        9; // PRICELIMIT
        10; // WITHDRAW
        11; // DEPOSIT
        12; // INSTRUMENT
        13; // EXECUTION
        14; // LEVERAGE
        15; // ERROR 
        16 // SIGNAL
        );

/ `NEW:0,`UPDATE:1,`DELETE:2,`FAILED:3
EVENTCMD      : (0;1;2;3;4);


/*******************************************************
/ order enumerations

/ `BUY:0,`SELL:1;
ORDERSIDE     : (0;1);

// USING MANUAL LIST FOR REFERENCABILITY 
ORDERKIND:(
        0; // MARKET
        1; // LIMIT
        2; // STOP_MARKET
        3; // STOP_LIMIT
        4; // HIDDEN
        5; // ICEBERG
        6; // REMAINDERLIMIT
        7 // PEGGED
        );

// USING MANUAL LIST FOR REFERENCABILITY 
ORDERSTATUS:(
        0; // NEW
        1; // PARTIAL
        2; // FILLED
        3; // UNTRIGGERED
        4; // TRIGGERED
        5; // FAILED
        6 // CANCELLED
        );

// USING MANUAL LIST FOR REFERENCABILITY 
ORDERSTATUS:(
        0; // NEW
        1; // PARTIAL
        2; // FILLED
        3; // UNTRIGGERED
        4; // TRIGGERED
        5; // FAILED
        6 // CANCELLED
        );

// USING MANUAL LIST FOR REFERENCABILITY 
TIMEINFORCE:(
        0; // NIL
        1; // GOODTILCANCEL
        2; // IMMEDIATEORCANCEL
        3 // FILLORKILL
        );

// USING MANUAL LIST FOR REFERENCABILITY 
STOPTRIGGER:(
        0; // NIL
        1; // LAST
        2; // MARK
        3 // INDEX
        );

/*******************************************************
/ INSTRUMENT ENUMERATIONS

// USING MANUAL LIST FOR REFERENCABILITY 
CONTRACTKIND:(
        0; // LINEAR
        1; // INVERSE
        2 // QUANTO
        );

// USING MANUAL LIST FOR REFERENCABILITY 
INSTRUMENTSTATE:(
        0; // ONLINE
        1; // DOWN
        2; // ROLLBACK
        3 // MAINTENENCE
        );


/*******************************************************
/ ACCOUNT & INVENTORY ENUMERATIONS

/ `CROSS:0,`ISOLATED:1;
MARGINTYPE      : (0;1);

/ `ACTIVE:0,`BLOCKED:1;
ACCOUNTSTATE    : (0;1);

/ `ACTIVE:0,`LIQUIDATE:1;
POSITIONSTATE   : (0;1);

/ `HEDGED:0,`COMBINED:1;
POSITIONTYPE    : (0;1);

/ `NEW:0,`UPDATE:1,`DELETE:2,`FAILED:3
POSITIONSIDE    : (0;1;2;3;4);

// TODO create combined table.

/*******************************************************
/ Datum Construction

/*******************************************************
/ Events LOGIC

// TODO move to global
// The events table acts as a buffer for all events that occur within
// the given environment step, this allows for unilateral event post/pre
// processing after the environment state has progressed i.e. .pipe.event.Adding lag
// .pipe.event.Adding "dropout" and randomization etc. it has the .pipe.event.Added benifit of 
// simplifying (removing) nesting/recursion within the engine. 
// Drawbacks may include testability?
// The events table is used exclusively within the engine and is not used
// by for example the state.
// Acts like a kafka queue/pubsub.
eventCount:0;
Events  :( // TODO .pipe.event.Add failure to table
    time        :`datetime$();
    cmd         :`long$();
    kind        :`long$();
    datum       :());

// .pipe.event.Adds an event to the Events table.
.pipe.event.AddEvent   : {[time;cmd;kind;datum] // TODO .pipe.event.Add better validation
        $[not (type time)=-15h;[.logger.Err["Invalid event time"]; :0b];]; //
        $[not (cmd in .event.EVENTCMD);[.logger.Err["Invalid event cmd"]; :0b];]; // TODO default
        $[not (kind in .event.EVENTKIND);[.logger.Err["Invalid event kind"]; :0b];];
        $[not (type datum)=99h;[.logger.Err["Invalid datum"]; :0b];]; // should error if not dictionary
        / if[not] //validate datum 
        .event.Events,:(time;cmd;kind;datum);
        };

// Creates an action i.e. a mapping between
// a agent/account Id and its respective
// vector target distribution and/or adapter
// that conforms to a generaliseable dictionary 
.pipe.event.AddFailure   : {[time;kind;msg]
        if[not (type time)~15h; 'INVALID_TIME]; //TODO fix
        if[not (kind in .event.ERRCODES); 'INVALID_ERRORCODE];
        .event.Events,:(time;3;15;datum);
        };

// Retrieves all events from the Events table and then
// deletes/drops them all before reverting the eventCount and
// returning the events (As a table?)
.pipe.event.PopEvents               :{
        e: .event.Event;
        delete from `.event.Events;
        e
        };

ECOLS                   :`time`cmd`kind`datum;


// Event Construction Utils
// ---------------------------------------------------------------------------------------->
// The following functions will derive obligatory fields
// pertaining to the specific datums from the dictionary
// passed to them.


/*******************************************************
/ Private Creation Utils

.pipe.event.AddPlaceOrderEvent     :{[order;time]

        };

.pipe.event.AddPlaceBatchEvent     :{[orders;time]

        };

.pipe.event.AddCancelOrderEvent    :{[order;time]

        };

.pipe.event.AddCancelBatchEvent    :{[orders;time]

        };

.pipe.event.AddCancelAllEvent      :{[order;time]

        };

.pipe.event.AddAmendOrderEvent     :{[order;time]

        };

.pipe.event.AddWithdrawEvent       :{[withdraw;time]

        };

.pipe.event.AddDepositEvent        :{[deposit;time]

        };

/*******************************************************
/ MarketData event Construction

.pipe.event.AddDepthEvent          :{[depth;time]

        };

.pipe.event.AddTradeEvent          :{[trade;time]

        };

.pipe.event.AddMarkEvent           :{[mark;time]

        };

.pipe.event.AddFundingEvent        :{[funding;time]

        };

.pipe.event.AddOrderCancelEvent    :{[order;time]

        };

.pipe.event.AddOrderUpdateEvent    :{[order;time]

        };

.pipe.event.AddNewOrderEvent       :{[order;time]

        };

.pipe.event.AddAccountEvent        :{[account;time]

        };

.pipe.event.AddInventoryEvent      :{[account;time]

        };

.pipe.event.AddFailureEvent        :{[failure;time]

        };

