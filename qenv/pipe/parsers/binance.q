
tab[`resp]: .j.k each tab[`resp];

ts:1970.01.01+0D00:00:00.001*;

sizeMultiplier:1000;
priceMultiplier:100;

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
