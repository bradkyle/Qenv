// DEPTHS
bookParser:{[rows]
    kind:`DEPTH;
    cmd:`UPDATE;
    derive:{[u]
        time:u[`resp][`data][`timestamp]; // should use this as ingress time
        a:flip u[`resp][`data][`asks][0];
        b:flip u[`resp][`data][`bids][0]; // should use utctime as egress time.
        :((10#`S),(10#`B);`int$((a[0],b[0])*100);20#"Z"$time;20#u[`utc_time];`int$(a[1],b[1]));
    }; // side, price, time, intime, size
    x:derive each rows;
    :`side`price`time`intime`size!(raze each (x[;0];x[;1];x[;2];x[;3];x[;4]));
    };

// TRADES
tradeParser:{[rows] // todo fix
    kind:`TRADE;
    cmd:`NEW;
    derive:{d:x[`resp][`data];:(`$d[`side]; `int$(d[`price]*100); "Z"$d[`timestamp]; count[d]#x[`utc_time]; `int$d[`size])};
    x: derive each rows;
    :`side`price`time`intime`size!(raze each (x[;0];x[;1];x[;2];x[;3];x[;4])); 
    };

// MARK
markParser:{[rows]
    kind:`MARK;
    cmd:`UPDATE;
    derive:{d:x[`resp][`data];$[`markPrice in cols d;:(1b;("Z"$d[`timestamp]; x[`utc_time];`int$(d[`markPrice]*100)));:(0b;())]};
    i: derive each rows;
    x:i[;1] where[i[;0]];
    :`time`intime`mark!(raze each (x[;0];x[;1];x[;2])); 
    };

// FUNDING
fundingParser:{[rows]
    kind:`FUNDING;
    cmd:`UPDATE;
    derive:{d:x[`resp][`data];:("Z"$d[`timestamp];x[`utc_time];d[`fundingRate])};
    x: derive each rows;
    :`time`intime`funding!(raze each (x[;0];x[;1];x[;2])); 
    };

// .Q.ind[trade;til 5]