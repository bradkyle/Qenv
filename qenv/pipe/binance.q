
tab[`resp]: .j.k each tab[`resp];

ts:1970.01.01+0D00:00:00.001*;

{[ob]
    list:{[u]
        r:u[`resp];
        d:r[`data];
        time:`datetime$(ts d[`timestamp]);
        a:"F"$(flip[ob[`resp][`data][`a]]); 
        b:"F"$(flip[ob[`resp][`data][`b]]);
        ca:count a;
        cb:count b;
        a:flip a;
        b:flip b;
        cab: ca+cb;
        :((ca#`S),(cb#`B);`int$((a[0],$b[0])*100);cab#"Z"$time;cab#"Z"$u[`utc_time];`int$((a[1],b[1])*1000));
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
{[trades]
    list:{d:x[`resp][`data];:(`$d[`side];`int$(("F"$d[`price])*100);  "Z"$d[`timestamp]; "Z"$x[`utc_time];"I"$d[`size])}
    lsts: list each trades;
   `trade upsert ([side:raze[lsts[;0]];price:raze[lsts[;1]];time:raze[lsts[;2]]] intime:raze[lsts[;3]]; size:raze[lsts[;4]]) /\t = 2044s (258499)    
}

{[ins]
    list:{d:x[`resp][`data];:("Z"$d[`timestamp];"Z"$x[`utc_time];`int$(("F"$d[`mark_price])*100))}
    lsts: list each ins;
   `mark upsert ([time:raze[lsts[;0]]] intime:raze[lsts[;1]]; price:raze[lsts[;2]]);  
}

{[fnd]
    list:{d:x[`resp][`data];:("Z"$d[`funding_time];"F"$d[`funding_rate];"Z"$x[`utc_time])}
    lsts: list each ins;
   `funding upsert :([time:raze[lsts[;0]]] intime:raze[lsts[;3]]; fundingRate:raze[lsts[;1]]);   
}