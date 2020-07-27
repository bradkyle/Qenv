.qtpy.init:{[]
  .qtpy.filePath:{x -3+count x} value .z.s;
  slash:$[.z.o like "w*";"\\";"/"];
  .qtpy.basePath:slash sv -1_slash vs .qtpy.filePath;
  if[not `p in key `;system"l ",getenv[`QHOME],slash,"p.q"];
  .p.e"import sys";
  .p.e "sys.path.append(\"",ssr[;"\\";"\\\\"] .qtpy.basePath,"\")";
  .qtpy.py.lib:.p.import`qtpy;
  };

.qtpy.init[];

.qtpy.walkFiles:{[path]
    `$(.qtpy.py.lib[`:walkFiles][path]`)
    };

.qtpy.walkDirs:{[path]
    `$(.qtpy.py.lib[`:walkDirs][path]`)
    };