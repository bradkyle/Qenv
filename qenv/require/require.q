
// TODO c modules, Python modules, J Modules, C++ modules, Rust Modules, Extern Q modules, extern Tests

.rq.MODKIND: `CODE`UNIT`INTEGRATION`BENCH`EXTERN;
.rq.MODSTATE: `LOADED`READY`EXCLUDED;

.rq.modcount :0;
.rq.Mod      :(
    [mname    :   `symbol$(); mId: `long$()]
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
    // validate mndame
    // validate mpath
    // validate mdeps
    
    .rq.Mod,:(mname;(.rq.modcount+:1);`.rq.MODKIND$`CODE;`.rq.MODSTATE$`READY;mpath;mdeps);
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
    // validate mndame
    // validate mpath
    // validate mdeps

    .rq.Mod,:(mname;(.rq.modcount+:1);`.rq.MODKIND$`UNIT;`.rq.MODSTATE$`READY;mpath;mdeps);
    };

// TODO if directory walk if mod.q simple load
// TODO naive implementation make better
// Constructs the dependency tree of modules, loading root modules i.e. modules
// on which the majority depend on and work up the dependency tree, creating
// a ordered list of modules to load in sequence.
/  @param ipath     (String/Symbol) The initial path from which to find mod.q files
/  @param mkinds    (.rq.MODKIND) The allowed module kinds that should be loaded.
.rq.Require  :{[ipath; mkinds]

    // Load Modules into Scope
    // ------------------------------------------------------------------>
    .rq.basePath:ipath;

    // Recursive function that
    // walks up the tree of directories to find all
    // mod files
    walk:{
        // List all files in the 
        // directory
        p:key y;

        // Derive all q files from directory
        qfiles:p where[{all[".q" in string[x]]}'[p]];
        
        // Find all mod files in directory
        mfiles:qfiles where[{all["mod" in string[x]]}'[qfiles]];
        
        // Get all sub directories in the directory // TODO naive
        dirs:p where[{all[not["." in string[x]]}'[p]]];
        
        ny:0;
        nz:0;

        // if there are any subdirectories in the
        // current directory loop through all of them
        // providing the absolute path to them and 
        // append the results to x, if no more subdirectories
        // exist, return x (the resultant absolute paths to mod 
        // all mod files)  
        $[count[dirs]>0;:(.z.s[x]'[ny]);:x];
        };

    mpaths:walk[.rq.basePath];
    {system ("l ", x)}'[mpaths]; // TODO error handling


    // Build dependency graph from modules
    // ------------------------------------------------------------------>
    mds:();

    // Load all modules in order of increasing dependency of prior
    // ------------------------------------------------------------------>

    // Sort dependencies

    // Load by order

    };

// Excludes a set of modules based on specified attributes
/  @param mname     (String/Symbol) The names of modules to be excluded.
/  @param mpath     (String/Symbol) The paths of modules to be excluded
/  @param mkinds    (.rq.MODKIND) The mkinds of modules to be excluded.
.rq.Exclude  :{[mnames;mpaths;mkinds]
    update state:`.rq.MODSTATE$`EXCLUDED where (mId in mnames) or (path in mpaths) or (kind in mkinds);
    };   


// TODO Mod, TestMod
