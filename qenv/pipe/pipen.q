\l qtpy.q

p:"/home/kx/qenv/lcl/mnt/lcl/";
// read by day, sid
writePath:{h:hopen `:./db/par.txt;neg[h] x;hclose h;show x;};

getPaths  :{
  paths:string[.qtpy.walkDirs[first y]];
  :(paths where[paths like "*",x,"*"]);  
  };

/ {writePath["/" sv (first system["pwd"];"data";x)]} each string inst
/ inst:exec distinct inst from t
getAndPersist   :{[p]
      show p;
      tab:.qparquet.getDataset[p];
      tab:update source:`$source, inst:`$inst, chan:`$chan, utc_time:"Z"$utc_time, utc_day:`date$("Z"$utc_time), resp:.j.k each resp from tab;
      tab:delete pid,time,timestamp,sid,aid,cid from tab;      
      tab:(0!(`utc_day`source`inst`chan xgroup tab));
      {
        path:(` sv `:./data/,(x[`source],x[`inst],`$string[x[`utc_day]]),x[`chan],`$"");
        path upsert .Q.en[`:db;] flip[x];
        show path;
      } peach tab; 
      {
        writePath["/" sv (first system["pwd"];"data";string x[`source];string x[`inst])];
      } each (distinct select source,inst from tab);
    };

sst:"sid=huobifuturesagent";
paths:distinct {(sst vs x)[0],sst} each getPaths[sst;p]
/ getAndPersist peach paths;
show paths;

// TODO run tests on resultant data
// TODO order events by time!!!