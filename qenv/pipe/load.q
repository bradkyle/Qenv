\l qparquet.q 
\l qtpy.q

basePath:"/home/kx/qenv/lcl/mnt/lcl/436768776d1d4b9ea142bbafae1554a1/utc_day=20200726/sid=binancefuturesagent";

getAndPersist   :{[dds;sds] (`$(":",dds,"/")) set .qparquet.getDataset[string[sds]]};

// TODO change to peach
getAndPersist["data"] each .qtpy.walkDirs[basePath]