
// Reset 
.loader.Reset       :{[config]

    .loader.LookForwardSize:config`lookForwardSize;
    .loader.batchSize:config`batchSize;

    .Q.D // partitions
    .Q.P

    // .Q.MAP??


    };


.loader.Ingress     :{[config]
    select i:max i, t:max time by 30 xbar `minute$time from events
    };