\d .bitmex
// all events should follow the format time, intime, kind, cmd datum...

sizeMultiplier:1;
priceMultiplier:100;

// DEPTHS
bookParser:{[rows]
    derive:{[u]
        time:u[`resp][`data][`timestamp]; // should use this as ingress time
        a:flip u[`resp][`data][`asks][0];
        b:flip u[`resp][`data][`bids][0]; // should use utctime as egress time.
        :(20#"Z"$time;20#u[`utc_time];((10#`SELL),(10#`BUY));`int$((a[0],b[0])*100);`int$(a[1],b[1]));
    };
    x:derive each rows;
    x:flip `time`intime`side`price`size!raze each flip x; 
    x:update dlt:{1_deltas x}size by price, side from x;
    x:x where[x[`dlt]<>0]; 
    cx:count x;
    x:flip value flip x;
    :flip `time`intime`kind`cmd`datum!(x[;1];x[;2];cx#`DEPTH;cx#`UPDATE;enlist each x[;3 +til 3]);
    };

// TRADES zzss TODO check many
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