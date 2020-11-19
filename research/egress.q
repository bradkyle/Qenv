
// All events returning from the engine are 
// stored here, selections based upon temporal 
// offsets representing delays in compute etc.
// can be 
.egress.event.eventCount:0;
.egress.Event:.common.event.Event;

// TODO add time delay
.egress.AddEvent              :{[event] // TODO validate
        .common.event.eventCount+:count[event];
        .egress.Event,:(time;cmd;kind;datum);
        };

// TODO add time delay to provided time
.egress.AddBatch               :{[events]
        ecount:count[events`time];
        events[`eid]:(.common.event.eventCount + til ecount);
        .common.event.eventCount+:ecount;  
        events[`time]:`datetime$(events[`time]);
        .egress.Event,:$[type[events]=99h;flip events;events];
    };

.egress.AddBatchFailure        :{[fails; errkind; errmsg]
        ecount:count[fails];
        .egress.test.fails:fails;
        fails[`datum]:{(x;y)}[errmsg]'[flip[fails`eid`kind`cmd`datum]];
        fails[`cmd]:errkind;
        fails[`kind]:15;
        .egress.test.fails1:fails;
        .egress.AddBatch[`eid`f _ fails];
        };

/*******************************************************
/ MarketData event Construction

.egress.AddDepthEvent          :{[depth;time]
        .egress.AddEvent[time;1;0;depth]; // TODO        
        };

.egress.AddTradeEvent          :{[trade;time]
        .egress.AddEvent[time;0;1;trade]; // TODO        
        };

.egress.AddMarkEvent           :{[mark;time]
        .egress.AddEvent[time;1;2;mark]; // TODO        
        };

.egress.AddSettlementEvent           :{[mark;time]
        .egress.AddEvent[time;1;2;mark]; // TODO        
        };

.egress.AddFundingEvent        :{[funding;time]
        .egress.AddEvent[time;0;4;funding]; // TODO        
        };

.egress.AddOrderCancellledEvent    :{[order;time]
        .egress.AddEvent[time;2;8;order]; // TODO        
        };

.egress.AddOrderUpdatedEvent    :{[order;time]
        .egress.AddEvent[time;1;8;order]; // TODO        
        };      

.egress.AddOrderCreatedEvent       :{[order;time]
        .egress.AddEvent[time;0;8;order]; // TODO        
        };

.egress.AddLiquidationEvent       :{[order;time]
        .egress.AddEvent[time;0;8;order]; // TODO        
        };

.egress.AddPriceLimitEvent       :{[order;time]
        .egress.AddEvent[time;0;8;order]; // TODO        
        };

.egress.AddAccountEvent        :{[account;time]
        .egress.AddEvent[time;1;6;account]; // TODO        
        };

.egress.AddInventoryEvent      :{[inventory;time]
        .egress.AddEvent[time;1;7;inventory]; // TODO        
        };

.egress.AddFailureEvent        :{[failure;time]
        .egress.AddEvent[time;0;15;failure]; // TODO        
        };


/*******************************************************
/ Egress Selection/Filtering Utils


// 1) enlist(Time <= Time + StepFreqTime)
// 2) enlist(Index <= Index + StepFreqIndex)
// 3) ((Time <= Time + StepFreqTime);(Index <= Index + StepFreqIndex))
.egress.getEgressCond  :{$[
        x=0;enlist(<=;`time;(+;`time;`second$5)); // todo pass in time
        x=1;();
        x=3;();
        'INVALID_INGRESS_COND]};

// enlist(<=;`time;)
// enlist(<=;`i;)
// ((<=;`i;);(<=;`time;)) 

// Returns the set of events that would occur in the given step 
// of the agent action.
.egress._GetEgressEvents   :{[step;windowkind] // TODO should select next batch according to config
    econd:.egress.getEgressCond[windowkind];
    events:?[`.egress.Event;econd;0b;()];
    .egress.test.events:events;
    ![`.egress.Event;enlist(=;`eid;key[events]`eid);0b;`symbol$()];
    value events
    };

.egress.GetEgressEvents     :{.egress._GetEgressEvents[x;0]};
