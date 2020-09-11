
// TODO c modules, Python modules, J Modules, C++ modules, Rust Modules, Extern Q modules, extern Tests

.rq.MODKIND: `CODE`UNIT`INTEGRATION`BENCH`EXTERN;
.rq.MODSTATE: `LOADED`READY`EXCLUDED;

.rq.modcount :0;
.rq.Mod      :(
    [mId    :   `long$()]
    kind    :  `.rq.MODKIND$();
    state   :  `.rq.MODSTATE$();
    path    :  `symbol$();
    deps    :  ());

// Adds a code module to the Module table such that a dependency tree
// can be constructed and the modules can be loaded in order thereafter
// without conflicts or missing dependencies.
// Automatically labels modules with CODE;
/  @param mname     (String/Symbol) A string or symbol label of the module
/  @param mpath     (String) the path from the mod.q file to the file of the module 
/  @param mdeps    (List[String/Symvol]) The list of module dependencies this module has.
.rq.M        :{[mname; mpath; mdeps]
    .rq.Mod,:();
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
    .rq.Mod,:();
    };

// TODO naive implementation make better
// Constructs the dependency tree of modules, loading root modules i.e. modules
// on which the majority depend on and work up the dependency tree, creating
// a ordered list of modules to load in sequence.
/  @param ipath     (String/Symbol) The initial path from which to find mod.q files
/  @param mkinds    (.rq.MODKIND) The allowed module kinds that should be loaded.
.rq.Require  :{[ipath; mkinds]
    dirs:();
    mods:();

    walk:{

        p:key y;
        qfiles:p where[{all[".q" in string[x]]}'[p]];
        mfiles:qfiles where[{all["mod" in string[x]]}'[qfiles]];
        dirs:p where[{all[not["." in string[x]]}'[p]]];
        
        // TODO count before
        $[count[dirs]>0;:(.z.s[x]'[ny]);:x];
        };

    };

// Excludes a set of modules based on specified attributes
/  @param mname     (String/Symbol) The names of modules to be excluded.
/  @param mpath     (String/Symbol) The paths of modules to be excluded
/  @param mkinds    (.rq.MODKIND) The mkinds of modules to be excluded.
.rq.Exclude  :{[mnames;mpaths;mkinds]

    };   


// TODO Mod, TestMod
