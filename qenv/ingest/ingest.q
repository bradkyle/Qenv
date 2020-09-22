



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
.ingest.getFirstIngressBatch         :{
    $[[`BatchIndex in key `.loader];[
        .ingest.BatchIndex@rand count[.ingest.BatchIndex]
    ];'BATCHINDEX_UNSET];
    };

// 
.ingest.getCurriculumIngressBatch      :{
    $[[`BatchIndex in key `.loader];[

    ];'BATCHINDEX_UNSET];
    };

// 
.ingest.getChronologicalIngressBatch  :{
    $[[`BatchIndex in key `.loader];[
        $[[`CurrentBatch in key `.loader];[
            .ingest.BatchIndex@(.ingest.CurrentBatch mod count[.ingest.BatchIndex])
        ];'CURRENTBATCH_UNSET];
    ];'BATCHINDEX_UNSET];
    };

// 
.ingest.getRandomIngressBatch         :{
    $[[`BatchIndex in key `.loader];[
        .ingest.BatchIndex@rand count[.ingest.BatchIndex]
    ];'BATCHINDEX_UNSET];
    };

.ingest.Run         :{[]
    // TODO assert path exists
    // TODO assert 

    system ("l ", path);

    // Check if the Batch index which in 
    if[not[`BatchIndex in key `.ingest];[
        .ingest.BatchIndex:select i:max i, t:max time by .ingest.batchSize xbar `minute$time from .ingest.events;
    ]];
    };
