\l qparquet.q 
\l qtpy.q

basePath:"/home/kx/qenv/lcl/mnt/lcl/436768776d1d4b9ea142bbafae1554a1/utc_day=20200726/sid=binancefuturesagent";

write:{

  `:/path/to/dbroot/splay/ upsert .Q.en[] z;
  }


getAndPersist   :{[dds;sds]  
  a:"/" vs sds;
  a:({"=" vs x} each (a where[a like "*=*"]))[;1];
  dest: .Q.dd[`$(":",dds);`$a];
  show dest;
  dir: (":" vs (string dest))[1];
  show dir;
  show ("mkdir ", dir);
  dest upsert .Q.en[`$(":",dds)] .qparquet.getDataset[sds];
  };


paths: (string .qtpy.walkDirs[basePath])

// TODO change to peach
getAndPersist["data"] peach (paths where[paths like "*aid=*"])  