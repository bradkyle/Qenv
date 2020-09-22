

// TODO move to pipe
// TODO remove repeated logic
// TOOD cross validation batching

.pipe.CONF:();

// TODO event source
// TODO random starting balance 
// Reset 
// Derive the initial state from the
// engine and derive deposit events etc
.pipe.Reset       :{[config] // TODO mutex on read of db?

    / .pipe.CONF;

    // .Q.MAP??
    
    // Get the next ingress batch based on the
    // configuration provided
    k:config`batchKind;
    nextBatch:$[
        k=0;.pipe.getChronologicalIngressBatch[];
        k=1;.pipe.getRandomIngressBatch[];
        k=2;.pipe.getCurriculumIngressBatch[];
        k=3;.pipe.getFirstIngressBatch[];
        .pipe.getFirstIngressBatch[]];

    // TODO if not chronological 
    // delete all events from ingress events

    // 
    / .pipe.ingress.Event:.event.Event;
    / .pipe.egress.Event:.event.Event; // nextbatch

    .pipe.ingress.Event,:?[.pipe.EventSource;();0b;()];


    };


// Event Cond Derivation Utils
// ---------------------------------------------------------------------------------------->

// 1) enlist(Time <= Time + StepFreqTime)
// 2) enlist(Index <= Index + StepFreqIndex)
// 3) ((Time <= Time + StepFreqTime);(Index <= Index + StepFreqIndex))
getIngressCond  :{$[x=0;();x=1;();x=3;();'INVALID_INGRESS_COND]};

// 1) enlist(Time <= ((Time + StepFreqTime)-Req time?))
// 2)
// 3)
getEgressCond   :{$[x=0;();x=1;();x=3;();'INVALID_EGRESS_COND]};


// Main Extraction Utils
// ---------------------------------------------------------------------------------------->

// enlist(<=;`time;)
// enlist(<=;`i;)
// ((<=;`i;);(<=;`time;)) 

// Returns the set of events that would occur in the given step 
// of the agent action.
.pipe._GetIngressEvents   :{[step;windowkind] // TODO should select next batch according to config
    econd:.pipe.getEgressCond[windowkind];
    events:?[`.pipe.ingress.Event;econd;0b;()];
    ![`.pipe.ingress.Event;enlist(=;`eid;events`eid);0b;`symbol$()];
    events
    };

.pipe.GetIngressEvents    :{.pipe._GetIngressEvents[x;.pipe.CONF`windowkind]};

//
.pipe._GetEgressEvents     :{[step;windowkind]
    econd:.pipe.getEgressCond[windowkind];
    events:?[`.pipe.egress.Event;econd;0b;()];
    ![`.pipe.egress.Event;enlist(=;`eid;events`eid);0b;`symbol$()];
    events
    };

.pipe.GetEgressEvents     :{.pipe._GetEgressEvents[x;.pipe.CONF`windowkind]};