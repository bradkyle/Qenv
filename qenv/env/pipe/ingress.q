
// All events being pushed into the engine are 
// stored here, selections based upon temporal 
// offsets representing delays in compute etc.
// can be 

.pipe.ingress.Event:.pipe.event.Event;

.pipe.ingress.AddEvent              :{[event]
        .pipe.event.eventCount+:count[event];
        .pipe.ingress.Event,:(time;cmd;kind;datum);
    };

.pipe.ingress.AddBatch               :{[events]
        ecount:count[events`time];
        events[`eid]:(.pipe.event.eventCount + til ecount);
        .pipe.event.eventCount+:ecount;       
        .pipe.ingress.Event,:flip events;
    };

/*******************************************************
/ Ingress Creation Utils

.pipe.ingress.AddPlaceOrderEvent     :{[order;time] // TODO make valid for multiple
        // TODO check size etc        
        .pipe.ingress.AddEvent[time;0;8;order];
        };

.pipe.ingress.AddPlaceBatchEvent     :{[orders;time]
        // TODO check size etc        
        .pipe.ingress.AddEvent[time;0;8;orders];
        };

.pipe.ingress.AddCancelOrderEvent    :{[order;time]
        // TODO check size etc        
        .pipe.ingress.AddEvent[time;2;8;order];
        };

.pipe.ingress.AddCancelBatchEvent    :{[orders;time]
        // TODO check size etc
        .pipe.ingress.AddEvent[time;2;8;orders];
        };

.pipe.ingress.AddCancelAllEvent      :{[order;time]
        // TODO check size etc        
        .pipe.ingress.AddEvent[time;2;8;orders]; // TODO
        };

.pipe.ingress.AddAmendOrderEvent     :{[order;time]
        // TODO check size etc        
        .pipe.ingress.AddEvent[time;1;8;order]; // TODO        
        };

.pipe.ingress.AddAmendBatchEvent     :{[orders;time]
        // TODO check size etc
        .pipe.ingress.AddEvent[time;1;8;orders]; // TODO        
        };

.pipe.ingress.AddWithdrawEvent       :{[withdraw;time]
        // TODO check size etc
        .pipe.ingress.AddEvent[time;0;10;withdraw]; // TODO        
        };

.pipe.ingress.AddDepositEvent        :{[deposit;time]
        // TODO check size etc
        .pipe.ingress.AddEvent[time;0;11;deposit]; // TODO        
        };

