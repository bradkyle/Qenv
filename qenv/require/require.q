
// TODO c modules, Python modules, J Modules, C++ modules, Rust Modules, Extern Q modules, extern Tests

.rq.MODKIND: `CODE`UNIT`INTEGRATION`BENCH`EXTERN;

.rq.Mod      :(

    );

// Adds a code module to the Module table such that a dependency tree
// can be constructed and the modules can be loaded in order thereafter
// without conflicts or missing dependencies.
// Automatically labels modules with CODE;
/  @param mname     (String/Symbol) A string or symbol label of the module
/  @param mpath     (String) the path from the mod.q file to the file of the module 
/  @param mdeps    (List[String/Symvol]) The list of module dependencies this module has.
.rq.M        :{[mname; mpath; mdeps]

    };

// Require Unit Test Module
// Adds a unit tesst module to the Module table such that a dependency tree
// can be constructed and the modules can be loaded in order thereafter
// without conflicts or missing dependencies.
// Automatically labels modules with UNIT;
/  @param mname     (String/Symbol) A string or symbol label of the module
/  @param mpath     (String) the path from the mod.q file to the file of the module 
/  @param mdeps    (List[String/Symvol]) The list of module dependencies this module has.
.rq.UM       :{[mname; mpath; mdeps]

    };

.rq.Require  :{[ipath; mkinds]

    };

.rq.Exclude  :{

    };   


// TODO Mod, TestMod
