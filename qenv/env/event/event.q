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
        5; // LIQUIDATION
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
CONTRACTTYPE:(
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
/ Ingress event Construction

MakePlaceOrderEvent     :{[order;time]

        };

MakePlaceBatchEvent     :{[orders;time]

        };

MakeCancelOrderEvent    :{[order;time]

        };

MakeCancelBatchEvent    :{[orders;time]

        };

MakeCancelAllEvent      :{[order;time]

        };

MakeAmendOrderEvent     :{[order;time]

        };

MakeWithdrawEvent       :{[withdraw;time]

        };

MakeDepositEvent        :{[deposit;time]

        };

/*******************************************************
/ MarketData event Construction

MakeDepthEvent          :{[depth;time]

        };

MakeTradeEvent          :{[trade;time]

        };

MakeMarkEvent           :{[mark;time]

        };

MakeFundingEvent        :{[funding;time]

        };

MakeOrderUpdateEvent    :{[order;time]

        };

MakeNewOrderEvent       :{[order;time]

        };

MakeAccountEvent        :{[account;time]

        };

MakeFailureEvent        :{[failure;time]

        };

/*******************************************************
/ Datum Construction

/*******************************************************
/ Events LOGIC

// TODO move to global
// The events table acts as a buffer for all events that occur within
// the given environment step, this allows for unilateral event post/pre
// processing after the environment state has progressed i.e. adding lag
// adding "dropout" and randomization etc. it has the added benifit of 
// simplifying (removing) nesting/recursion within the engine. 
// Drawbacks may include testability?
// The events table is used exclusively within the engine and is not used
// by for example the state.
// Acts like a kafka queue/pubsub.
eventCount:0;
Events  :( // TODO add failure to table
    [eventId    :`long$()]
    time        :`datetime$();
    cmd         :`.event.EVENTCMD$();
    kind        :`.event.EVENTKIND$();
    datum       :());

// Adds an event to the Events table.
AddEvent   : {[time;cmd;kind;datum] // TODO make better validation
        $[not (type time)=-15h;[.logger.Err["Invalid event time"]; :0b];]; //
        $[not (cmd in .event.EVENTCMD);[.logger.Err["Invalid event cmd"]; :0b];]; // TODO default
        $[not (kind in .event.EVENTKIND);[.logger.Err["Invalid event kind"]; :0b];];
        $[not (type datum)=99h;[.logger.Err["Invalid datum"]; :0b];]; // should error if not dictionary
        / if[not] //validate datum 
        `.event.Events upsert (eventId:(eventCount+:1);time:time;cmd:cmd;kind:kind;datum:datum);
        };

// Creates an action i.e. a mapping between
// a agent/account Id and its respective
// vector target distribution and/or adapter
// that conforms to a generaliseable dictionary 
AddFailure   : {[time;kind;msg]
        if[not (type time)~15h; 'INVALID_TIME]; //TODO fix
        if[not (kind in .event.ERRCODES); 'INVALID_ERRORCODE];
        `.event.Events upsert (eventId:(eventCount+:1);time:time;cmd:3;kind:15;datum:msg);
        };

// Retrieves all events from the Events table and then
// deletes/drops them all before reverting the eventCount and
// returning the events (As a table?)
PopEvents     :{e: .event.Event;delete from `.event.Events;:e};