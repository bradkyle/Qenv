

// TODO move to pipe
// TODO remove repeated logic


// Probabalistic choice
// @n: number of choices
// @k: count of choices
// @p: probability spread
PChoice :{[n;k;p]k?raze ("j"$p*10 xexp max count each("."vs'string p)[;1])#'til n};


// 
.pipe.getCurriculumIngressBatchEvents      :{
    $[[`BatchIndex in key `.loader];[

    ];'BATCHINDEX_UNSET];
    };

// 
.pipe.getChronologicalIngressBatchEvents  :{
    $[[`BatchIndex in key `.loader];[
        $[[`CurrentBatch in key `.loader];[
            .pipe.BatchIndex@(.pipe.CurrentBatch mod count[.pipe.BatchIndex])
        ];'CURRENTBATCH_UNSET];
    ];'BATCHINDEX_UNSET];
    };

// 
.pipe.getRandomIngressBatchEvents         :{
    $[[`BatchIndex in key `.loader];[
        .pipe.BatchIndex@rand count[.pipe.BatchIndex]
    ];'BATCHINDEX_UNSET];
    };


// Reset 
.pipe.Reset       :{[config]

    .pipe.fwdSize:config`fwdSize; // The 
    .pipe.batchSize:config`batchSize; // The size of the batches in minutes

    .Q.D // partitions
    .Q.P

    if[not[`BatchIndex in key `.loader];[
        .pipe.BatchIndex:select i:max i, t:max time by .pipe.batchSize xbar `minute$time from .pipe.events;
    ]];
    // .Q.MAP??
    
    $[]


    };


.pipe.Ingress     :{[step]


    };


.pipe.Reset   :{
    .pipe.ingress.Event:.event.Event;
    .pipe.egress.Event:.event.Event;
    };