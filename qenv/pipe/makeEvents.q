

event:(
  time    :  `datetime$()
  kind    :  `.event.EVENTKIND$();
  cmd     :  `.event.EVENTCMD$();
  datum   :  ();  
  );

// DEPTHS
{[rows]
    kind:`.event.EVENTKIND$()`DEPTH;
    cmd:`.event.EVENTCMD$()`UPDATE;
    derive:{[u]
        time:u[`resp][`data][`timestamp]; // should use this as ingress time
        a:flip u[`resp][`data][`asks][0];
        b:flip u[`resp][`data][`bids][0]; // should use utctime as egress time.
        :((10#`S),(10#`B);`int$((a[0],b[0])*100);20#"Z"$time;20#"Z"$u[`utc_time];`int$(a[1],b[1]));
    };
    events:raze[derive each rows];
    `events upsert ([side:raze[lsts[;0]];price:raze[lsts[;1]];time:raze[lsts[;2]]] intime:raze[lsts[;3]]; size:raze[lsts[;4]]) / = 2044 (258499)    
}

// TRADES
{[rows] // todo fix
    derive:{d:x[`resp][`data];:(`$d[`side]; `int$(d[`price]*100); "Z"$d[`timestamp]; "Z"$x[`utc_time]; `int$d[`size])}
    lsts: derive each rows;
   `trade upsert ([side:raze[lsts[;0]];price:raze[lsts[;1]];time:raze[lsts[;2]]] intime:raze[lsts[;3]]; size:raze[lsts[;4]]) /\t = 2044s (258499)    
}

// MARK
{[rows]
    derive:{d:x[`resp][`data];$[`markPrice in cols d;:(1b;("Z"$d[`timestamp];"Z"$x[`utc_time];`int$(d[`markPrice]*100)));:(0b;())]}
    i: derive each rows;
    lsts:i[;1] where[i[;0]]
   `mark upsert ([time:raze[lsts[;0]]] intime:raze[lsts[;1]]; price:raze[lsts[;2]]);  
}

// FUNDING
{[rows]
    derive:{d:x[`resp][`data];:("Z"$d[`timestamp];"Z"$x[`utc_time];d[`fundingRate])}
    lsts: derive each rows;
   `funding upsert ([time:raze[lsts[;0]]; intime:raze[lsts[;1]]]; fundingRate:raze[lsts[;2]]);  
}

events: processBitmex each `chan xgroup select from data where source=`bitmexagentxbtusd, inst=`xbtusd;