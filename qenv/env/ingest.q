

// Specifies a client that queries
// the event ingest server for events which allows 
// for multiple agent pool's to query data without
// incurring race conditions etc.

// Use watermark or event index
.ingest.watermark  :0;
.ingest.h:hopen `::5001;

.ingest.Advance     :{[port;windowkind;forward]
        // Select from ingest where 
        events:.ingest.h(".ingest.GetBatch[",string[.ingest.watermark],";",string[forward],"]")
        .pipe.ingress.AddBatch[events];
    };