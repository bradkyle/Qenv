


// All events being pushed into the engine are 
// stored here, selections based upon temporal 
// offsets representing delays in compute etc.
// can be 

.pipe.ingress.Event:.event.Event;


// Retrieves all Event from the Event table and then
// deletes/drops them all before reverting the eventCount and
// returning the Event (As a table?)
.pipe.event.GetIngressEvents               :{
        e: .pipe.ingress.Event;
        ![`.pipe.ingress.Event;();0b;`symbol$()]
        e};

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

