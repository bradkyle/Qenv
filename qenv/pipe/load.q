\l qparquet.q 
\l qtpy.q

getPaths  :{
  bp:read0[`:path.txt];
  paths:string[.qtpy.walkDirs[first bp]];
  :(paths where[paths like "*aid=*"]);  
  };

getPathsBp  :{[bp]
  paths:string[.qtpy.walkDirs[first bp]];
  :(paths where[paths like "*aid=*"]);  
  };

writePath:{h:hopen `:./db/par.txt;neg[h] x;hclose h;};

getPathParams :{[path]
  a:"/" vs path;
  a:({"=" vs x} each (a where[a like "*=*"]))[;1]; 
  :a;
  };

/ sds: first paths;
getAndPersist : {[sds]
  show sds;
  a: getPathParams[sds];
  path: `$(":./data/",("/" sv (a 1 0 3)),"/");
  dbname:a 1;
  tab:.qparquet.getDataset[sds];
  tab:delete pid,time,timestamp from tab;
  tab:update inst:`$inst, chan:`$chan, inst:`$inst, "Z"$utc_time, resp:.j.k peach resp from tab;
  path upsert .Q.en[`:db;] tab; //todo check that is not overwriting 
  writePath["/" sv (first system["pwd"];"data";dbname)];
  show path;
  };
/ show paths;

getAndPersistGrp  : {[paths]
  show paths;
  getAndPersist each paths;
  };

getAndPersistPeach  :{[paths]
  paths:`grp xgroup flip[`pth`grp!(paths;getPathParams each paths)];
  {getAndPersistGrp[x[`pth]]} peach paths;
  };
 
/ getAndPersist each paths;