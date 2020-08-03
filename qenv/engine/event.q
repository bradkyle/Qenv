\d .event

// TODO setup in seperate process?

/*******************************************************
/ error kind enumerations
ERRORKIND   :   ( 
            `INVALID_ORDER_TYPE;
            `INVALID_ORDER_SIDE;
            `INVALID_ORDER_TICK_SIZE;
            `INVALID_TIMEINFORCE;
            `INVALID_EXECINST;
            `INVALID_ORDER_PRICE;
            `INVALID_ACCOUNTID;
            `INVALID_ORDER_SIZE;
            `PARTICIPATE_DONT_INITIATE;
            `NO_LIQUIDITY);

// REQUEST_KIND refers to the type of 
// 
REQUESTKIND : (
        `PLACE_ORDER;
        `PLACE_BATCH_ORDER;
        `CANCEL_ORDER;
        `CANCEL_BATCH_ORDER;
        `CANCEL_ALL_ORDERS;
        `AMEND_ORDER;
        `AMEND_BATCH_ORDER;
        `LEVERAGE_UPDATE;
        `DEPOSIT;
        `WITHDRAW);

INGRESSKIND :(
        `DEPTH;
        `TRADE;
        `FUNDING;
        `MARK;
        `SETTLEMENT;
        `LIQUIDATION;
        `PRICERANGE), REQUESTKIND;

EGRESSKIND :(
        `ORDER;
        `INVENTORY;
        `ACCOUNT;
        `INSTRUMENT;
        `AGENT_FORCED_CLOSE_ORDERS;
        `AGENT_LIQUIDATED;
        `LIQUIDATION);

/ event kind enumerations
EVENTKIND    :  INGRESSKIND,EGRESSKIND;

// TODO functions for making evens

EVENTCMD      :   `NEW`UPDATE`DELETE`FAILED;

// TODO create combined table.

/*******************************************************
/ Datum Construction

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

MakeWithdrawEvent :{[order]

        };

MakeDepositEvent  :{[account]

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
        cmd:(`.event.EVENTCMD$cmd);
        kind:(`.event.EVENTKIND$kind);
        / if[not] //validate datum 
        `.event.Events upsert (eventId:(eventCount+:1);time:time;cmd:cmd;kind:kind;datum:datum);
        };

// Creates an action i.e. a mapping between
// a agent/account Id and its respective
// vector target distribution and/or adapter
// that conforms to a generaliseable dictionary 
AddFailure   : {[time;kind;msg]
        if[not (type time)=-15h; :0b]; //TODO fix
        if[not (kind in .event.ERRORKIND); :0b];
        if[not (kind in .event.ERRORKIND); :0b]; // TODO update msg 
        `.event.Events upsert (eventId:(eventCount+:1);time:time;cmd:`FAILED;kind:`FAILED_REQUEST;datum:msg);
        };

// Retrieves all events from the Events table and then
// deletes/drops them all before reverting the eventCount and
// returning the events (As a table?)
PopEvents     :{[]
        e: .event.Event;
        delete from `.event.Events;
        :e
        };