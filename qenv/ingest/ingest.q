

.pipe.fwdSize:config`fwdSize; // The 
.pipe.batchSize:config`batchSize; // The size of the batches in minutes

// Check if the Batch index which in 
if[not[`BatchIndex in key `.ingest];[
    .pipe.BatchIndex:select i:max i, t:max time by .pipe.batchSize xbar `minute$time from .pipe.events;
]];

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
