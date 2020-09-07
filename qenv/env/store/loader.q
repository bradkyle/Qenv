
// Reset 
.loader.Reset       :{[config]

    .loader.LookForwardSize:config`lookForwardSize;
    .loader.batchSize:config`batchSize;

    .Q.D // partitions
    .Q.P

    // Check if batch index has been set
    select i:max i, t:max time by 30 xbar `minute$time from events;

    // .Q.MAP??


    };


.loader.Ingress     :{[time]


    };