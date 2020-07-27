\l qparquet.q 
\l qtpy.q

basePath:"/home/kx/qenv/lcl/mnt/lcl/436768776d1d4b9ea142bbafae1554a1/utc_day=20200726/sid=binancefuturesagent";

write:{
 t:.Q.en[dst] update sym:`p#sym from `sym xasc y;
 $[count dsp;
  (` sv dsp,(`$"d",string dspx),`$x) set t;
  (` sv dst,`$x) set t];}


getAndPersist   :{[dds;sds] write[0;"/data/";.qparquet.getDataset[string[sds]]]};

// TODO change to peach
getAndPersist["data"] each .qtpy.walkDirs[basePath]