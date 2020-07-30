
// all events should follow the format time, intime, kind, cmd datum...

// DEPTHS
bookLvlOnlyDeltas:{[rows]
    derive:{[u]
        time:u[`resp][`data][`timestamp]; // should use this as ingress time
        a:flip u[`resp][`data][`asks][0];
        b:flip u[`resp][`data][`bids][0]; // should use utctime as egress time.
        :(((til 10),(til 10));20#"Z"$time;20#u[`utc_time];((10#`SELL),(10#`BUY));`int$((a[0],b[0])*100);`int$(a[1],b[1]));
    };
    x:derive each rows;
    x:flip `lvl`time`intime`side`price`size!raze each flip x; 
    x:update dlt:{1_deltas x}size by lvl, side from x;
    x:x where[x[`dlt]<>0]; 
    cx:count x;
    :flip `time`intime`kind`cmd`datum!(x[;1];x[;2];cx#`DEPTH;cx#`UPDATE;(x[;3 +til 3]));
    };

/ // DEPTHS
/ bookParser:{[rows]
/     kind:`DEPTH;
/     cmd:`UPDATE;
/     derive:{[u]
/         time:u[`resp][`data][`timestamp]; // should use this as ingress time
/         a:flip u[`resp][`data][`asks][0];
/         b:flip u[`resp][`data][`bids][0]; // should use utctime as egress time.
/         :(20#"Z"$time;20#u[`utc_time];((10#`S),(10#`B));`int$((a[0],b[0])*100);`int$(a[1],b[1]));
/     }; // side, price, time, intime, size
/     x:derive each rows;
/     x:flip raze each flip x; 
/     cy:count first y;
/     // time;intime;kind;cmd;side;price;size
/     :eventCols!(y[0];y[1];cy#kind;cy#cmd;y[2];y[3];y[4]);
/     };

// derive diffs

// TRADES
tradeParser:{[rows] // todo fix
    derive:{d:x[`resp][`data];:("Z"$d[`timestamp]; count[d]#x[`utc_time]; upper `$d[`side]; `int$(d[`price]*100); `int$d[`size])};
    x: derive each rows;
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
    :flip `time`intime`kind`cmd`datum!(x[;0];x[;1];cx#`MARK;cx#`UPDATE;(x[;2]));
    };

// FUNDING
// todo make faster
fundingParser:{[rows]
    kind:`FUNDING;
    cmd:`UPDATE;
    derive:{d:x[`resp][`data];:("Z"$d[`timestamp];x[`utc_time];d[`fundingRate])};
    x: derive each rows;
    cx:count x;
    :flip `time`intime`kind`cmd`datum!(x[;0];x[;1];cx#`FUNDING;cx#`UPDATE;(x[;2]));
    };

// .Q.ind[trade;til 5]