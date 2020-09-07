


// All events returning from the engine are 
// stored here, selections based upon temporal 
// offsets representing delays in compute etc.
// can be 

.pipe.egress.Event:.event.Event;

// Selects all events that occurred 
.pipe.egress.GetEgressEvents               :{
        e: .pipe.egress.Event; // TODO better selection methodology
        ![`.pipe.egress.Event;();0b;`symbol$()] // Test this vs resest
        e};

// Return the set of events that would have occured 
.pipe.egress.PopEgressEvents               :{

        };

.pipe.egress.AddEvent              :{[event] // TODO validate
        .pipe.egress.Event,:(time;cmd;kind;datum);
    };

.pipe.egress.AddBatch               :{[events] // TODO validate
        .pipe.egress.Event,;events;
    };

/*******************************************************
/ MarketData event Construction

.pipe.egress.AddDepthEvent          :{[depth;time]
        .pipe.egress.AddEvent[time;1;0;depth]; // TODO        
        };

.pipe.egress.AddTradeEvent          :{[trade;time]
        .pipe.egress.AddEvent[time;0;1;trade]; // TODO        
        };

.pipe.egress.AddMarkEvent           :{[mark;time]
        .pipe.egress.AddEvent[time;1;2;mark]; // TODO        
        };

.pipe.egress.AddFundingEvent        :{[funding;time]
        .pipe.egress.AddEvent[time;0;4;funding]; // TODO        
        };

.pipe.egress.AddOrderCancellledEvent    :{[order;time]
        .pipe.egress.AddEvent[time;2;8;order]; // TODO        
        };

.pipe.egress.AddOrderUpdatedEvent    :{[order;time]
        .pipe.egress.AddEvent[time;1;8;order]; // TODO        
        };      

.pipe.egress.AddOrderCreatedEvent       :{[order;time]
        .pipe.egress.AddEvent[time;0;8;order]; // TODO        
        };

.pipe.egress.AddAccountEvent        :{[account;time]
        .pipe.egress.AddEvent[time;1;6;account]; // TODO        
        };

.pipe.egress.AddInventoryEvent      :{[inventory;time]
        .pipe.egress.AddEvent[time;1;7;inventory]; // TODO        
        };

.pipe.egress.AddFailureEvent        :{[failure;time]
        .pipe.egress.AddEvent[time;0;15;failure]; // TODO        
        };

