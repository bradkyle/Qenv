// TODO move to pipe
// TODO remove repeated logic
// TOOD cross validation batching

.pipe.CONF:();

// TODO event source
// TODO random starting balance 
// Reset 
// Derive the initial state from the
// engine and derive deposit events etc
.pipe.Reset       :{[config] // TODO mutex on read of db?

    / .pipe.CONF;

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