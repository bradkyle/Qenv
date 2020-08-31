\d .event

// TODO setup in seperate process?

/*******************************************************
/ error kind enumerations
ERRCODES :();

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

// TODO create combined table.

/*******************************************************
/ Ingress event Construction

MakePlaceOrderEvent   :{[depth]

        };

MakePlaceBatchEvent   :{[depth]

        };

MakeCancelOrderEvent   :{[depth]

        };

MakeCancelBatchEvent   :{[depth]

        };

MakeCancelAllEvent      :{[depth]

        };

MakeAmendOrderEvent   :{[depth]

        };

MakeWithdrawEvent :{[order]

        };

MakeDepositEvent  :{[account]

        };

/*******************************************************
/ MarketData event Construction

MakeDepthEvent   :{[depth]

        };

MakeTradeEvent   :{[trade]

        };

MakeMarkEvent      :{[mark]

        };

MakeFundingEvent    :{[funding]

        };

MakeOrderEvent   :{[order]

        };

MakeAccountEvent  :{[account]

        };

MakeFailureEvent   :{[failure]

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