
// all events should follow the format time, intime, kind, cmd datum...

Piv:{[t;k;p;v]
    f:{[v;P]`${raze "_" sv x} each string raze P,'/:v};
    v:(),v; 
    k:(),k; 
    p:(),p;
    G:group flip k!(t:.Q.v t)k;
    F:group flip p!t p;
    key[G]!flip(C:f[v]P:flip value flip key F)!raze{[i;j;k;x;y]
        a:count[x]#x 0N;a[y]:x y;
        b:count[x]#0b;
        b[y]:1b;
        c:a i;
        c[k]:first'[a[j]@'where'[b j]];
        c
    }[I[;0];I J;J:where 1<>count'[I:value G]]/:\:[t v;value F]};

bookLvlDeltas:{[rows]
    derive:{[u]
        time:u[`resp][`data][`timestamp]; // should use this as ingress time
        a:flip u[`resp][`data][`asks][0];
        b:flip u[`resp][`data][`bids][0]; // should use utctime as egress time.
        :(((til 10),(til 10));20#"Z"$time;20#u[`utc_time];((10#`S),(10#`B));`int$((a[0],b[0])*100);`int$(a[1],b[1]));
    };
    x:derive each rows;
    y:raze each (x[;0];x[;1];x[;2];x[;3];x[;4];x[;5]);
    j:flip(`lvl`time`intime`side`price`size!y);
    / j:Piv[`i;`time;`lvl`side;`price`size];
    j:update dlt:{1_deltas x}size by lvl, side from j;
    j:j where[j[`dlt]<>0];
    j[`kind]:`DEPTH;
    j[`cmd]:`UPDATE;
    :j;
    };

bookLvlEvents :{[rows]
    :flip bookLvlDeltas[rows][`time`intime`kind`cmd`side`price`size];
    };

// DEPTHS
bookParser:{[rows]
    kind:`DEPTH;
    cmd:`UPDATE;
    derive:{[u]
        time:u[`resp][`data][`timestamp]; // should use this as ingress time
        a:flip u[`resp][`data][`asks][0];
        b:flip u[`resp][`data][`bids][0]; // should use utctime as egress time.
        :(20#"Z"$time;20#u[`utc_time];((10#`S),(10#`B));`int$((a[0],b[0])*100);`int$(a[1],b[1]));
    }; // side, price, time, intime, size
    x:derive each rows;
    y:raze each (x[;0];x[;1];x[;2];x[;3];x[;4]);
    cy:count first y;
    // time;intime;kind;cmd;side;price;size
    :(y[0];y[1];cy#kind;cy#cmd;y[2];y[3];y[4]);
    };

// derive diffs

// TRADES
tradeParser:{[rows] // todo fix
    kind:`TRADE;
    cmd:`NEW;
    derive:{d:x[`resp][`data];:(`$d[`side]; `int$(d[`price]*100); "Z"$d[`timestamp]; count[d]#x[`utc_time]; `int$d[`size])};
    x: derive each rows;
    y:raze each (x[;0];x[;1];x[;2];x[;3];x[;4]);
    cy:count first y;
    :(y[0];y[1];cy#kind;cy#cmd;y[2];y[3];y[4]);
    };

// MARK
markParser:{[rows]
    kind:`MARK;
    cmd:`UPDATE;
    derive:{d:x[`resp][`data];$[`markPrice in cols d;:(1b;("Z"$d[`timestamp]; x[`utc_time];`int$(d[`markPrice]*100)));:(0b;())]};
    i: derive each rows;
    x:i[;1] where[i[;0]];
    cx:count x;
    :(y[0];y[1];cy#kind;cy#cmd;y[2];y[3];y[4]);
    :(cx#kind;cx#cmd;raze each (x[;0];x[;1];x[;2])); 
    };

// FUNDING
// todo make faster
fundingParser:{[rows]
    kind:`FUNDING;
    cmd:`UPDATE;
    derive:{d:x[`resp][`data];:("Z"$d[`timestamp];x[`utc_time];d[`fundingRate])};
    x: derive each rows;
    cx:count x;
    :(cx#kind;cx#cmd;raze each (x[;0];x[;1];x[;2])); 
    };

// .Q.ind[trade;til 5]