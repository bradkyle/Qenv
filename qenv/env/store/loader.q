
// TODO move to pipe
// TODO remove repeated logic

// 
.loader.getCurriculumIngressBatchEvents      :{
    $[[`BatchIndex in key `.loader];[

    ];'BATCHINDEX_UNSET];
    };

// 
.loader.getChronologicalIngressBatchEvents  :{
    $[[`BatchIndex in key `.loader];[
        $[[`CurrentBatch in key `.loader];[
            .loader.BatchIndex@(.loader.CurrentBatch mod count[.loader.BatchIndex])
        ];'CURRENTBATCH_UNSET];
    ];'BATCHINDEX_UNSET];
    };

// 
.loader.getRandomIngressBatchEvents         :{
    $[[`BatchIndex in key `.loader];[
        .loader.BatchIndex@rand count[.loader.BatchIndex]
    ];'BATCHINDEX_UNSET];
    };


// Reset 
.loader.Reset       :{[config]

    .loader.fwdSize:config`fwdSize; // The 
    .loader.batchSize:config`batchSize; // The size of the batches in minutes

    .Q.D // partitions
    .Q.P

    if[not[`BatchIndex in key `.loader];[
        .loader.BatchIndex:select i:max i, t:max time by .loader.batchSize xbar `minute$time from .loader.events;
    ]];
    // .Q.MAP??



    };


.loader.Ingress     :{[time]


    };