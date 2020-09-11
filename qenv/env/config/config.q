

// Derives Config from a json representation
// and then validates the values contained therin
// before returning a parsed representation to the
// environment
.config.ParseConfig      :{[conf]
    // Parse Config from json 
    conf:.j.k[raze conf];

    // Validation
    // todo json schema
    // todo python json config

    };

