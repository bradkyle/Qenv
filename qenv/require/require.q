
// TODO c modules, Python modules, J Modules, C++ modules, Rust Modules, Extern Q modules, extern Tests

.rq.MODKIND: `CODE`UNIT`INTEGRATION`BENCH`EXTERN;
.rq.MODSTATE: `LOADED`READY`EXCLUDED;

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

// Constructs the dependency tree of modules, loading root modules i.e. modules
// on which the majority depend on and work up the dependency tree, creating
// a ordered list of modules to load in sequence.
/  @param ipath     (String/Symbol) The initial path from which to find mod.q files
/  @param mkinds    (.rq.MODKIND) The allowed module kinds that should be loaded.
.rq.Require  :{[ipath; mkinds]

    };

// Excludes a set of modules based on specified attributes
/  @param mname     (String/Symbol) The names of modules to be excluded.
/  @param mpath     (String/Symbol) The paths of modules to be excluded
/  @param mkinds    (.rq.MODKIND) The mkinds of modules to be excluded.
.rq.Exclude  :{[mnames;mpaths;mkinds]

    };   


// TODO Mod, TestMod
