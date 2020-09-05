\d .event

// TODO setup in seperate process?

/*******************************************************
/ error kind enumerations
ERRCODES :(
        
        );


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
.pipe.event.ValidateEvent   : {[time;cmd;kind;datum] // TODO .pipe.event.Add better validation
        $[not (type time)=-15h;[.logger.Err["Invalid event time"]; :0b];]; //
        $[not (cmd in .event.EVENTCMD);[.logger.Err["Invalid event cmd"]; :0b];]; // TODO default
        $[not (kind in .event.EVENTKIND);[.logger.Err["Invalid event kind"]; :0b];];
        $[not (type datum)=99h;[.logger.Err["Invalid datum"]; :0b];]; // should error if not dictionary
        / if[not] //validate datum 
        };


.pipe.event.COLS                   :`time`cmd`kind`datum;

