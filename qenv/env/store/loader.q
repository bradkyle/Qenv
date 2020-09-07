

.loader.getChronologicalBatch       :{
    if[not[`BatchIndex in key `.loader];[

    ]];
    };

.loader.getCurriculumBatch          :{
    if[not[`BatchIndex in key `.loader];[

    ]];
    };

.loader.getRandomBatch              :{
    if[not[`BatchIndex in key `.loader];[

    ]];
    };


// Reset 
.loader.Reset       :{[config]

    .loader.fwdSize:config`fwdSize; // The 
    .loader.batchSize:config`batchSize; // The size of the batches in minutes

    .Q.D // partitions
    .Q.P

    // 

    if[not[`BatchIndex in key `.loader];[
        .loader.BatchIndex:select i:max i, t:max time by .loader.batchSize xbar `minute$time from .loader.events;
    ]];
    // .Q.MAP??


    };


.loader.Ingress     :{[time]


    };