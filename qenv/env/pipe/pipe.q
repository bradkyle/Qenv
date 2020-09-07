

// TODO move to pipe
// TODO remove repeated logic


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

.pipe.createSetupEvents             :{

    };

// TODO event source
// TODO random starting balance 
// Reset 
.pipe.Reset       :{[config]

    .pipe.fwdSize:config`fwdSize; // The 
    .pipe.batchSize:config`batchSize; // The size of the batches in minutes

    if[not[`BatchIndex in key `.loader];[
        .pipe.BatchIndex:select i:max i, t:max time by .pipe.batchSize xbar `minute$time from .pipe.events;
    ]];
    // .Q.MAP??
    
    k:config`batchKind;
    nextBatch:$[
        k=0;.pipe.getChronologicalIngressBatch[];
        k=1;.pipe.getRandomIngressBatch[];
        k=2;.pipe.getCurriculumIngressBatch[];
        .pipe.getRandomIngressBatch[]];

    // TODO if not chronological 
    // delete all events from ingress events

    .pipe.ingress.Event upsert (
        select time, intime, kind, cmd, datum 
        from .pipe.EventSource 
        where time within value[nextBatch`start`end]);

    // Create starting balance etc.
    .pipe.ingress.Event upsert .pipe.createSetupEvents[];

    };

// TODO add random deposits/withdraws from the account
.pipe.Next     :{[step]


    };


.pipe.Reset   :{
    .pipe.ingress.Event:.event.Event;
    .pipe.egress.Event:.event.Event;
    };