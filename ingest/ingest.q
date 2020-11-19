
    // select a random episode from ingest server 
    .env.Episode:rand .env.GetEpisodes[
        .conf.c[`ingest;`start];
        .conf.c[`ingest;`end]];
// Get Next Events 
// =====================================================================================>

// TODO move to trainer
.env.GetEpisodes :{[start;end]
    h:neg hopen master;    
    h(("getEpisodes";start;end);"")
    };

.env.Advance :{[master;ep;kinds;start;end]
    h:neg hopen master;    
    h(("getNextBatch";kinds;ep;start;end);"")
    };
