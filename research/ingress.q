
// All events being pushed into the engine are 
// stored here, selections based upon temporal 
// offsets representing delays in compute etc.
// can be 

.ingress.event.eventCount:0;
.ingress.Event:.common.event.Event;

// Todo add time delay
.ingress.AddEvent              :{[event]
        .common.event.eventCount+:count[event];
        .ingress.Event,:(time;cmd;kind;datum);
    };

// Todo add time delays
.ingress.AddBatch               :{[events]
        ecount:count[events`time];
        events[`eid]:(.common.event.eventCount + til ecount);
        .common.event.eventCount+:ecount;  
        events:.common.event.addDelaysByKind[events];
        events[`time]:`datetime$(events[`time]);
        .ingress.Event,:$[type[events]=99h;flip events;events];
    };
 

/*******************************************************
/ Ingress Creation Utils

.ingress.AddPlaceOrderEvent     :{[order;time] // TODO make valid for multiple
        // TODO check size etc        
        .ingress.AddEvent[time;0;8;order];
        };

.ingress.AddPlaceBatchEvent     :{[orders;time]
        // TODO check size etc        
        .ingress.AddEvent[time;0;8;orders];
        };

.ingress.AddCancelOrderEvent    :{[order;time]
        // TODO check size etc        
        .ingress.AddEvent[time;2;8;order];
        };

.ingress.AddCancelBatchEvent    :{[orders;time]
        // TODO check size etc
        .ingress.AddEvent[time;2;8;orders];
        };

.ingress.AddCancelAllEvent      :{[order;time]
        // TODO check size etc        
        .ingress.AddEvent[time;2;8;orders]; // TODO
        };

.ingress.AddAmendOrderEvent     :{[order;time]
        // TODO check size etc        
        .ingress.AddEvent[time;1;8;order]; // TODO        
        };

.ingress.AddAmendBatchEvent     :{[orders;time]
        // TODO check size etc
        .ingress.AddEvent[time;1;8;orders]; // TODO        
        };

.ingress.AddWithdrawEvent       :{[withdraw;time]
        // TODO check size etc
        .ingress.AddEvent[time;0;10;withdraw]; // TODO        
        };

.ingress.AddDepositEvent        :{[deposit;time]
        // TODO check size etc
        .ingress.AddEvent[time;0;11;deposit]; // TODO        
        };

/*******************************************************
/ Ingress Selection/Filtering Utils


// 1) enlist(Time <= Time + StepFreqTime)
// 2) enlist(Index <= Index + StepFreqIndex)
// 3) ((Time <= Time + StepFreqTime);(Index <= Index + StepFreqIndex))
.ingress.getIngressCond  :{$[
        x=0;enlist(<=;`time;(+;`time;`second$5)); // todo pass in time from conf
        x=1;();
        x=3;();
        'INVALID_INGRESS_COND]};

// enlist(<=;`time;)
// enlist(<=;`i;)
// ((<=;`i;);(<=;`time;)) 

// Returns the set of events that would occur in the given step 
// of the agent action.
.ingress._GetIngressEvents   :{[step;windowkind] // TODO should select next batch according to config
    econd:.ingress.getIngressCond[windowkind];
    events:?[`.ingress.Event;econd;0b;()];
    .ingress.test.events:events;
    ![`.ingress.Event;enlist(=;`eid;key[events]`eid);0b;`symbol$()];
    value events
    };

// Simply uses the first window kind 
.ingress.GetIngressEvents    :{[x;y].ingress._GetIngressEvents[x;0]}; 
