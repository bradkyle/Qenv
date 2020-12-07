

// Stores Common logic for all events

// TODO setup in seperate process?

/*******************************************************
/ error kind enumerations



/*******************************************************
/ event enumerations

.common.event.EventKind   :(
    `depth,                    
    `trade,                    
    `mark,                     
    `settlement,               
    `funding,                  
    `pricelimit,               
    `liquidation,              
    `neworderreq,              
    `neworderbatchreq,         
    `amendorderreq,            
    `amendorderbatchreq,       
    `cancelorderreq,           
    `cancelorderbatchreq,      
    `cancelallordersreq,       
    `withdrawreq,              
    `depositreq,               
    `leverageupdatereq,        
    `neworderres,              
    `neworderbatchres,         
    `amendorderres,            
    `amendorderbatchres,       
    `cancelorderres,           
    `cancelorderbatchres,      
    `cancelallordersres,       
    `withdrawres,              
    `depositres,               
    `leverageupdateres,        
    `signal1,                  
    `signal2,                  
    `signal3,                  
    `signal4,                  
    `signal5,                  
    `signal6,                  
    `signal7,                  
    `signal8,                  
    `signal9,                  
    `signal10,                 
    `signal11,                 
    `signal12,                 
    `signal13,                 
    `signal14,                 
    `signal15,                 
    `signal16,                 
    `signal17,                 
    `signal18,                 
    `signal19,                 
    `signal20);

// USING MANUAL LIST FOR REFERENCABILITY 
.common.event.EVENTKIND:( // TODO update kinds throughout
        0; // DEPTH
        1; // TRADE
        2; // MARK
        3; // LIQUIDATION
        4; // FUNDING
        5; // SETTLEMENT
        6; // ACCOUNT
        7; // INVENTORY
        8; // NEW ORDER
        9; // AMEND ORDER
        10; // CANCEL ORDER
        11; // CANCEL ALL ORDERS
        12; // PRICELIMIT
        13; // WITHDRAW
        14; // DEPOSIT
        15; // INSTRUMENT
        16; // EXECUTION
        17; // UPDATE LEVERAGE
        18; // ERROR 
        19 // SIGNAL
        );

/ `NEW:0,`UPDATE:1,`DELETE:2,`FAILED:3
.common.event.EVENTCMD      : (0;1;2;3;4);


/*******************************************************
/ Datum Construction

/*******************************************************
/ Event LOGIC

// TODO move to global
// The Event table acts as a buffer for all Event that occur within
// the given environment step, this allows for unilateral event post/pre
// processing after the environment state has progressed i.e. .common.event.Adding lag
// .common.event.Adding "dropout" and randomization etc. it has the .common.event.Added benifit of 
// simplifying (removing) nesting/recursion within the engine. 
// Drawbacks may include testability?
// The Event table is used exclusively within the engine and is not used
// by for example the state.
// Acts like a kafka queue/pubsub.
.common.event.Event  :([] // TODO .common.event.Add failure to table
    time        :`datetime$();
    kind        :`symbol$();
		datum       :();
		aId         :`long$());
// TODO set table attributes


.common.event.COLS                   :`eid`time`cmd`kind`datum;
.common.event.DCOLS                  :.common.event.COLS!.common.event.COLS;
// Time delay / formatting functionality
.common.event.addDelaysByKind        :{[e]
        // todo check if kind is in config
        e[`time]:`datetime$(e[`time]) + (.conf.c[`delays] . e[`kind]);
        :e
        };

