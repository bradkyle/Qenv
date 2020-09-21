

// TODO move to pipe
// TODO remove repeated logic
// TOOD cross validation batching

.pipe.CONF:();

// Probabalistic choice
// @n: number of choices
// @k: count of choices
// @p: probability spread
PChoice :{[n;k;p]k?raze ("j"$p*10 xexp max count each("."vs'string p)[;1])#'til n};



/ csi:count[.env.StepIndex];
/ nevents:flip[.env.EventBatch@idx];
/ idx:.env.StepIndex@step;
/ // Insert a set of initial events indicative of the state 
/ // before the first step into the state buffer for "Priming"
/ nevents:raze flip'[value[.env.PrimeBatchNum#.env.EventBatch]]; 


/ // Set the current Event batch to exclude the event batches
/ // used in the priming of the state.
/ .env.EventBatch:(.env.PrimeBatchNum)_(.env.EventBatch); // Shift events
/ .env.StepIndex:(.env.PrimeBatchNum)_(.env.StepIndex); // Shift events

// TODO get first Ingress Batch (for testing purposes)
.pipe.getFirstIngressBatch         :{
    $[[`BatchIndex in key `.loader];[
        .pipe.BatchIndex@rand count[.pipe.BatchIndex]
    ];'BATCHINDEX_UNSET];
    };

// 
.pipe.getCurriculumIngressBatch      :{
    $[[`BatchIndex in key `.loader];[

    ];'BATCHINDEX_UNSET];
    };

// 
.pipe.getChronologicalIngressBatch  :{
    $[[`BatchIndex in key `.loader];[
        $[[`CurrentBatch in key `.loader];[
            .pipe.BatchIndex@(.pipe.CurrentBatch mod count[.pipe.BatchIndex])
        ];'CURRENTBATCH_UNSET];
    ];'BATCHINDEX_UNSET];
    };

// 
.pipe.getRandomIngressBatch         :{
    $[[`BatchIndex in key `.loader];[
        .pipe.BatchIndex@rand count[.pipe.BatchIndex]
    ];'BATCHINDEX_UNSET];
    };

// TODO event source
// TODO random starting balance 
// Reset 
// Derive the initial state from the
// engine and derive deposit events etc
.pipe.Reset       :{[config]

    / .pipe.CONF;

    .pipe.fwdSize:config`fwdSize; // The 
    .pipe.batchSize:config`batchSize; // The size of the batches in minutes

    // Check if the Batch index which in 
    if[not[`BatchIndex in key `.ingest];[
        .pipe.BatchIndex:select i:max i, t:max time by .pipe.batchSize xbar `minute$time from .pipe.events;
    ]];
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