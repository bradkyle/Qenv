\d .bitmex
// all events should follow the format time, intime, kind, cmd datum...

sizeMultiplier:1;
priceMultiplier:100;

// DEPTHS
// TODO detect hidden/iceberg orders
bookParser:{[rows]
    deriveBook:{[u]
        time:u[`resp][`data][`timestamp]; // should use this as ingress time
        a:flip u[`resp][`data][`asks][0];
        b:flip u[`resp][`data][`bids][0]; // should use utctime as egress time.
        :(20#(.pipe.bitmex.uid+:1);20#"Z"$time;20#u[`utc_time];((10#-1),(10#1));`int$((a[0],b[0])*100);`int$(a[1],b[1]));
    };
    x:deriveBook each rows;
    x:flip `uid`time`intime`side`price`size!raze each flip x; 
    x:update dlt:{1_deltas x}size by price, side from x; // TODO insufficient approximation
    x:x where[x[`dlt]<>0]; 
    cx:count x;
    x:flip value flip x;
    :flip `time`intime`kind`cmd`datum!(x[;0];x[;1];cx#`DEPTH;cx#`UPDATE;enlist each x[;2 +til 3]);
    };

// TRADES zzss TODO check many
// q)x: deriveTrade each .Q.ind[trade;til 100000]
/ )flip `time`intime`side`price`size!raze each flip x
// q)    deriveTrade:{d:x[`resp][`data];:("Z"$d[`timestamp]; count[d]#x[`utc_time];?[(`$d[`side])~`Sell;count[d]#-1;count[d]#1]; `int$(d[`price]*100); `int$d[`size])};
// q)x:flip `time`intime`side`price`tsize!raze each flip x
tradeParser:{[rows] // todo fix
    deriveTrade:{d:x[`resp][`data];:("Z"$d[`timestamp]; count[d]#x[`utc_time];?[(`$d[`side])=`Sell;count[d]#-1;count[d]#1]; `int$(d[`price]*100); `int$d[`size])};
    x: deriveTrade each rows;
    x:flip raze each flip x;
    cx:count x;
    :flip `time`intime`kind`cmd`datum!(x[;0];x[;1];cx#`TRADE;cx#`NEW;(x[;2+til 3]));
    };

// MARK
markParser:{[rows]
    derive:{d:x[`resp][`data];$[`markPrice in cols d;:(1b;("Z"$d[`timestamp]; x[`utc_time];`int$(d[`markPrice]*100)));:(0b;())]};
    x: derive each rows;
    x:x[;1] where[x[;0]];
    cx:count x;
    :flip `time`intime`kind`cmd`datum!(raze x[;0];x[;1];cx#`MARK;cx#`UPDATE;enlist each x[;2]);
    };

// FUNDING
// todo make faster
fundingParser:{[rows]
    kind:`FUNDING;
    cmd:`UPDATE;
    derive:{d:x[`resp][`data];:("Z"$d[`timestamp];x[`utc_time];d[`fundingRate])}; // TODO next funding time
    x: derive each rows;
    cx:count x;
    :flip `time`intime`kind`cmd`datum!(x[;0];x[;0];cx#`FUNDING;cx#`UPDATE;enlist each x[;2]);
    };

// .Q.ind[trade;til 5]