

// Derives Config from a json representation
// and then validates the values contained therin
// before returning a parsed representation to the
// environment
.config.ParseConfig      :{[conf]

    // Use Python validator
    conf:.config.validation.Validate[conf];

    // Parse Config from json 
    .j.k[raze conf]
    };

