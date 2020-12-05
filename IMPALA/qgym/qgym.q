.qgym.episode_step:0;

.qgym.init:{[]
  .qgym.filePath:{x -3+count x} value .z.s;
  slash:$[.z.o like "w*";"\\";"/"];
  .qgym.basePath:slash sv -1_slash vs .qgym.filePath;
  if[not `p in key `;system"l ",getenv[`QHOME],slash,"p.q"];
  .p.e"import sys";
  .p.e "sys.path.append(\"",ssr[;"\\";"\\\\"] .qgym.basePath,"\")";
  .qgym.py.lib:.p.import`qgym;
  };

.qgym.init[];

.qgym.Step   :{[action] .qgym.py.lib[`:step][action]` };
 
.qgym.Reset               :{ .qgym.py.lib[`:reset][]` };
 
.qgym.Close               :{ .qgym.py.lib[`:close][]` };

.qgym.Run                 :{[params]
    // TODO assert path exists
    // TODO assert that path is splayed
    // store event count store event index
    system ("p ",getenv[`PORT]);
    show system("p");
    / $[();system ("l ",params[`path]);'INVALID_PATH];

    // log start and finish
    // log number of events
    // log channels
    };

// Run
// -------------------------------------------------------------------------------------->

params:.Q.opt .z.X

.qgym.Run[params]; 