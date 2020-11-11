
np:.p.import`numpy
 
.conf.sEnv                       :{[]

    };

// Wraps a static config varaible 
.conf.Static                   :{[x]
    :{x}[x]
    };

// Wraps a static interval variable
.conf.StaticInterval            :{
    'nyi;
    };

// Returns a function that randomly selects a value
// from the provided opts.
.conf.RandomSelect              :{[opts]
    :{first[1?x]}[opts]
    };

// Returns a function that generates a random value
// that falls within a a given range range 
.conf.RandomWithin              :{[high;low]
    :{a:rand[x-y];y+a}[high;low]
    };

// Returns a function that generates a duration
// that falls within a range
.conf.RandomDurationWithin      :{[high;low;unit]
    :{a:rand x-y;z$(y+a)}[high;low;unit]
    };

// Returns a function that samples a normal distribution
// and selects the argmax index of the opts
.conf.NDSelect   :{[mu;sigma;opts]
    'nyi
    };

// Returns a function that samples a normal distribution
// and converts the result into a timespan value // TODO check
.conf.NDTimespan :{[mu;sigma]
    :{`timespan$(first[np[`:random.normal;mu;sigma;1]`])}
    };

// Wraps a given configuration 
// namespace with given namespace
// methods to update its state.
.conf.Config        :{[tbl]


    };

// Wraps a given multi configuration 
// namespace with given namespace
// methods to update its state.
.conf.MultiConfig    :{[tbl]


    };

// Getting and setting cache methods
// ------------------------------------------------------------------->

// retrieves the cached value of 
// a given config
.conf.c             :{[]

    };

// retrieves the dict representation of 
// the cached config
.conf.cd             :{

    };

// retrieves the table representation of 
// the cached config
.conf.ct             :{[]

    };


// Reloading and returning methods
// ------------------------------------------------------------------->