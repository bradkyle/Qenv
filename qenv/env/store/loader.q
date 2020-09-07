
// Reset 
.loader.Reset       :{[config]

    .loader.LookForwardSize:config`lookForwardSize;
    .loader.batchSize:config`batchSize;

    .Q.D // partitions
    .Q.P

    // .Q.MAP??


    };


.loader.Ingress     :{[config]
    select from .store.events where 
    };