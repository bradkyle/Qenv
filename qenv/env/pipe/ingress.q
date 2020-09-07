


// All events being pushed into the engine are 
// stored here, selections based upon temporal 
// offsets representing delays in compute etc.
// can be 

.pipe.ingress.Event:.event.Event;

.pipe.ingress.AddEvent              :{[event]
        .pipe.ingress.Event,:(time;cmd;kind;datum);
    };

.pipe.egress.AddBatch               :{[events]
        .pipe.ingress.Event,:events;
    };

/*******************************************************
/ Ingress Creation Utils

.pipe.ingress.AddPlaceOrderEvent     :{[order;time] // TODO make valid for multiple
        .pipe.ingress.AddEvent[time;0;8;order];
        };

.pipe.ingress.AddPlaceBatchEvent     :{[orders;time]
        .pipe.ingress.AddEvent[time;0;8;orders];
        };

.pipe.ingress.AddCancelOrderEvent    :{[order;time]
        .pipe.ingress.AddEvent[time;2;8;order];
        };

.pipe.ingress.AddCancelBatchEvent    :{[orders;time]
        .pipe.ingress.AddEvent[time;2;8;orders];
        };

.pipe.ingress.AddCancelAllEvent      :{[order;time]
        .pipe.ingress.AddEvent[time;2;8;orders]; // TODO
        };

.pipe.ingress.AddAmendOrderEvent     :{[order;time]
        .pipe.ingress.AddEvent[time;1;8;order]; // TODO        
        };

.pipe.ingress.AddAmendBatchEvent     :{[orders;time]
        .pipe.ingress.AddEvent[time;1;8;orders]; // TODO        
        };

.pipe.ingress.AddWithdrawEvent       :{[withdraw;time]
        .pipe.ingress.AddEvent[time;0;10;withdraw]; // TODO        
        };

.pipe.ingress.AddDepositEvent        :{[deposit;time]
        .pipe.ingress.AddEvent[time;0;11;deposit]; // TODO        
        };


/*******************************************************
/ Pop Events

// Selects all events that occurred 
.pipe.egress.GetIngressEvents               :{
        e: .pipe.egress.Event; // TODO better selection methodology
        ![`.pipe.egress.Event;();0b;`symbol$()] // Test this vs resest
        e};

// Return the set of events that would have occured 
.pipe.egress.PopIngressEvents               :{

        };