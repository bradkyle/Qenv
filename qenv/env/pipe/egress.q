


// All events returning from the engine are 
// stored here, selections based upon temporal 
// offsets representing delays in compute etc.
// can be 

.pipe.egress.Event:.event.Event;


// Retrieves all Event from the Event table and then
// deletes/drops them all before reverting the eventCount and
// returning the Event (As a table?)
.pipe.egress.GetEgressEvents               :{
        e: .pipe.egress.Event; // TODO better selection methodology
        ![`.pipe.egress.Event;();0b;`symbol$()] // Test this vs resest
        e};

.pipe.egress.AddEvent              :{[event]
        .pipe.egress.Event,:(time;cmd;kind;datum);
    };

.pipe.egress.AddBatch               :{[events]

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

