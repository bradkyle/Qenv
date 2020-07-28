\l qparquet.q 
\l qtpy.q

bp:first read0[`:path.txt];

writePath:{h:hopen `:./db/par.txt;neg[h] x;hclose h;};

paths: string[.qtpy.walkDirs[bp]]
paths:(paths where[paths like "*aid=*"])  
/ sds: first paths;
getAndPersist : {[sds]
  a:"/" vs sds;
  a:({"=" vs x} each (a where[a like "*=*"]))[;1]; 
  path: `$(":./data/",("/" sv (a 1 0 3)),"/");
  dbname:a 1;
  tab:.qparquet.getDataset[sds];
  tab:delete pid,time,timestamp from tab;
  tab:update inst:`$inst, chan:`$chan, inst:`$inst, "Z"$utc_time, resp:.j.k peach resp from tab;
  path set .Q.en[`:db;] tab;
  writePath["/" sv (first system["pwd"];"data";dbname)];
  };

getAndPersist each paths;