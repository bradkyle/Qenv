
tab[`resp]: .j.k each tab[`resp];



// orderbook
{[ob]

    list:{[u]
        time:u[`resp][`data][`timestamp];
        a:flip u[`resp][`data][`asks][0];
        b:flip u[`resp][`data][`bids][0];
        :((10#`S),(10#`B);`int$((a[0],b[0])*100);20#"Z"$time;20#"Z"$u[`utc_time];`int$(a[1],b[1]));
    };
    lsts:list each ob;
    `book upsert ([side:raze[lsts[;0]];price:raze[lsts[;1]];time:raze[lsts[;2]]] intime:raze[lsts[;3]]; size:raze[lsts[;4]]) / = 2044 (258499)    
}

// trades
/
pid      | "f3c48ba2-2d52-4a2e-b234-043d7d27e290"
source   | "bitmexagentxbtusd"
inst     | `xbtusd
chan     | `trade
resp     | `table`action`data!("trade";"insert";+`timestamp`symbol`side`size`price`tickDirection`trdMatchID`grossValue`homeNotional`foreignNotional!(,"2020-06-10T11:29:06.105Z";,"XBTUSD";,"Buy";,10f;,9746f;,"PlusTick";,"8dc378cd-57b3-98fb-e50a-3f25d236c444";,102610f;,0.0010261;,10f))
time     | 1.591789e+09
timestamp| 1.591789e+09
utc_time | "2020-06-10 11:29:06.216479"
cid      | "trade"
aid      | "xbtusd"
\
{[trades] // todo fix
    list:{d:x[`resp][`data];:(`$d[`side]; `int$(d[`price]*100); "Z"$d[`timestamp]; "Z"$x[`utc_time]; `int$d[`size])}
    lsts: list each trades;
   `trade upsert ([side:raze[lsts[;0]];price:raze[lsts[;1]];time:raze[lsts[;2]]] intime:raze[lsts[;3]]; size:raze[lsts[;4]]) /\t = 2044s (258499)    
}


/ {`book upsert recs[x]} each orderbook far too long
/ \t `book upsert ([side:raze[lsts[;0]];price:raze[lsts[;1]];time:raze[lsts[;2]]] intime:raze[lsts[;3]]; size:raze[lsts[;4]]) = 2044 (258499)
/ {d:x[`resp][`data];:([side:`$d[`side]; time:"Z"$d[`timestamp]; price:`int$(d[`price]*10)] intime:"Z"$x[`utc_time]; size:`int$d[`size])}

{[ins]
    list:{d:x[`resp][`data];$[`markPrice in cols d;:(1b;("Z"$d[`timestamp];"Z"$x[`utc_time];`int$(d[`markPrice]*100)));:(0b;())]}
    i: list each ins;
    lsts:i[;1] where[i[;0]]
   `mark upsert ([time:raze[lsts[;0]]] intime:raze[lsts[;1]]; price:raze[lsts[;2]]);  
}

{[fnd]
    list:{d:x[`resp][`data];:("Z"$d[`timestamp];"Z"$x[`utc_time];d[`fundingRate])}
    lsts: list each ins;
   `funding upsert ([time:raze[lsts[;0]]; intime:raze[lsts[;1]]]; fundingRate:raze[lsts[;2]]);  
}