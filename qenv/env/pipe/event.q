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
/ Datum Construction

/*******************************************************
/ Event LOGIC

// TODO move to global
// The Event table acts as a buffer for all Event that occur within
// the given environment step, this allows for unilateral event post/pre
// processing after the environment state has progressed i.e. .pipe.event.Adding lag
// .pipe.event.Adding "dropout" and randomization etc. it has the .pipe.event.Added benifit of 
// simplifying (removing) nesting/recursion within the engine. 
// Drawbacks may include testability?
// The Event table is used exclusively within the engine and is not used
// by for example the state.
// Acts like a kafka queue/pubsub.
eventCount:0;
Event  :( // TODO .pipe.event.Add failure to table
    time        :`datetime$();
    cmd         :`long$();
    kind        :`long$();
    datum       :());

// .pipe.event.Adds an event to the Event table.
.pipe.event.AddEvent   : {[time;cmd;kind;datum] // TODO .pipe.event.Add better validation
        $[not (type time)=-15h;[.logger.Err["Invalid event time"]; :0b];]; //
        $[not (cmd in .event.EVENTCMD);[.logger.Err["Invalid event cmd"]; :0b];]; // TODO default
        $[not (kind in .event.EVENTKIND);[.logger.Err["Invalid event kind"]; :0b];];
        $[not (type datum)=99h;[.logger.Err["Invalid datum"]; :0b];]; // should error if not dictionary
        / if[not] //validate datum 
        .event.Event,:(time;cmd;kind;datum);
        };

// Creates an action i.e. a mapping between
// a agent/account Id and its respective
// vector target distribution and/or adapter
// that conforms to a generaliseable dictionary 
.pipe.event.AddFailure   : {[time;kind;msg]
        if[not (type time)~15h; 'INVALID_TIME]; //TODO fix
        if[not (kind in .event.ERRCODES); 'INVALID_ERRORCODE];
        .event.Event,:(time;3;15;datum);
        };

// Retrieves all Event from the Event table and then
// deletes/drops them all before reverting the eventCount and
// returning the Event (As a table?)
.pipe.event.PopEvents               :{
        e: .pipe.event.Event;
        ![`.pipe.event.Event;();0b;`symbol$()]
        e};

.pipe.event.COLS                   :`time`cmd`kind`datum;


// Event Construction Utils
// ---------------------------------------------------------------------------------------->
// The following functions will derive obligatory fields
// pertaining to the specific datums from the dictionary
// passed to them.


/*******************************************************
/ Private Creation Utils

.pipe.event.AddPlaceOrderEvent     :{[order;time] // TODO make valid for multiple
        .pipe.event.AddEvent[time;0;8;order];
        };

.pipe.event.AddPlaceBatchEvent     :{[orders;time]
        .pipe.event.AddEvent[time;0;8;orders];
        };

.pipe.event.AddCancelOrderEvent    :{[order;time]
        .pipe.event.AddEvent[time;2;8;order];
        };

.pipe.event.AddCancelBatchEvent    :{[orders;time]
        .pipe.event.AddEvent[time;2;8;orders];
        };

.pipe.event.AddCancelAllEvent      :{[order;time]
        .pipe.event.AddEvent[time;2;8;orders]; // TODO
        };

.pipe.event.AddAmendOrderEvent     :{[order;time]
        .pipe.event.AddEvent[time;1;8;order]; // TODO        
        };

.pipe.event.AddAmendBatchEvent     :{[orders;time]
        .pipe.event.AddEvent[time;1;8;orders]; // TODO        
        };

.pipe.event.AddWithdrawEvent       :{[withdraw;time]
        .pipe.event.AddEvent[time;0;10;withdraw]; // TODO        
        };

.pipe.event.AddDepositEvent        :{[deposit;time]
        .pipe.event.AddEvent[time;0;11;deposit]; // TODO        
        };

/*******************************************************
/ MarketData event Construction

.pipe.event.AddDepthEvent          :{[depth;time]
        .pipe.event.AddEvent[time;1;0;depth]; // TODO        
        };

.pipe.event.AddTradeEvent          :{[trade;time]
        .pipe.event.AddEvent[time;0;1;trade]; // TODO        
        };

.pipe.event.AddMarkEvent           :{[mark;time]
        .pipe.event.AddEvent[time;1;2;mark]; // TODO        
        };

.pipe.event.AddFundingEvent        :{[funding;time]
        .pipe.event.AddEvent[time;0;4;funding]; // TODO        
        };

.pipe.event.AddOrderCancellledEvent    :{[order;time]
        .pipe.event.AddEvent[time;2;8;order]; // TODO        
        };

.pipe.event.AddOrderUpdatedEvent    :{[order;time]
        .pipe.event.AddEvent[time;1;8;order]; // TODO        
        };      

.pipe.event.AddOrderCreatedEvent       :{[order;time]
        .pipe.event.AddEvent[time;0;8;order]; // TODO        
        };

.pipe.event.AddAccountEvent        :{[account;time]
        .pipe.event.AddEvent[time;1;6;account]; // TODO        
        };

.pipe.event.AddInventoryEvent      :{[inventory;time]
        .pipe.event.AddEvent[time;1;7;inventory]; // TODO        
        };

.pipe.event.AddFailureEvent        :{[failure;time]
        .pipe.event.AddEvent[time;0;15;failure]; // TODO        
        };

