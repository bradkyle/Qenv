\d .huobi

ts:1970.01.01+0D00:00:00.001*;

sizeMultiplier:1;
priceMultiplier:100;

bookParser:{[ob]
    derive:{[u]
        r:u[`resp];
        d:r[`tick];
        time:`datetime$(.huobi.ts `long$d[`ts]);
        a:flip[d[`asks]]; 
        b:flip[d[`bids]]; // TODO if count is greater than one.
        $[count a>0;[a:flip a;ca:count a];ca:0];
        $[count b>0;[b:flip b;cb:count b];cb:0];
        cab:ca+cb;
        $[(ca>0) and (cb>0);
          :(cab#time;cab#u[`utc_time];((ca#`SELL),(cb#`BUY));`int$((a[;0],b[;0])*.huobi.priceMultiplier);`int$((a[;1],b[;1])*.huobi.sizeMultiplier));
          ca>0;
          :(ca#time;ca#u[`utc_time];(ca#`SELL);`int$(a[;0]*.huobi.priceMultiplier);`int$(a[;1]*.huobi.sizeMultiplier));
          cb>0;
          :(cb#time;cb#u[`utc_time];(cb#`BUY);`int$(b[;0]*.huobi.priceMultiplier);`int$(b[;1]*.huobi.sizeMultiplier));
        ];   
    };
    x:derive each ob;
    x:flip `time`intime`side`price`size!raze each flip x;
    x:update dlt:{1_deltas x}size by price, side from `time xasc x;
    cx:count x;
    x:flip value flip x;
    :flip `time`intime`kind`cmd`datum!(x[;0];x[;1];cx#`DEPTH;cx#`UPDATE;(x[;2 +til 3]));
    };

// TODO check many
tradeParser:{[u]
    derive:{
        d:x[`resp][`tick][`data];
        :{
        :(`datetime$(.huobi.ts `long$y[`ts]); x;$[y[`direction]~"sell"; `SELL; `BUY];`int$(y[`price]*.huobi.priceMultiplier);`int$(y[`amount]*.huobi.sizeMultiplier));
        }[x[`utc_time]] each d;
    };
    x: raze[derive each u];
    x:flip raze each flip x;
    cx:count x;
    :flip `time`intime`kind`cmd`datum!(x[;0];x[;1];cx#`TRADE;cx#`NEW;(x[;2+til 3]));
    };


// TODO get mark price and funding for huobi

/ / {`book upsert recs[x]} each orderbook far too long
/ / \t `book upsert ([side:raze[lsts[;0]];price:raze[lsts[;1]];time:raze[lsts[;2]]] intime:raze[lsts[;3]]; size:raze[lsts[;4]]) = 2044 (258499)
/ / {d:x[`resp][`data];:([side:`$d[`side]; time:"Z"$d[`timestamp]; price:`int$(d[`price]*10)] intime:"Z"$x[`utc_time]; size:`int$d[`size])}

/ {[ins]
/     list:{d:x[`resp][`data];$[`markPrice in cols d;:(1b;("Z"$d[`timestamp];"Z"$x[`utc_time];`int$(d[`markPrice]*100)));:(0b;())]}
/     i: list each ins;
/     lsts:i[;1] where[i[;0]]
/    `mark upsert ([time:raze[lsts[;0]]] intime:raze[lsts[;1]]; price:raze[lsts[;2]]);  
/ }

/ {[fnd]
/     list:{d:x[`resp][`data];:("Z"$d[`timestamp];"Z"$x[`utc_time];d[`fundingRate])}
/     lsts: list each ins;
/    `funding upsert ([time:raze[lsts[;0]]; intime:raze[lsts[;1]]]; fundingRate:raze[lsts[;2]]);  
/ }

// TODO index load