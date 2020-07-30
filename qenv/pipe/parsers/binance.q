\d .binance

ts:1970.01.01+0D00:00:00.001*;

sizeMultiplier:1000;
priceMultiplier:100;

bookParser:{[ob]
    derive:{[u]
        r:u[`resp];
        d:r[`data];
        time:`datetime$(.binance.ts `long$d[`T]);
        a:"F"$(flip[u[`resp][`data][`a]]); 
        b:"F"$(flip[u[`resp][`data][`b]]); // TODO if count is greater than one.
        $[count a>0;[a:flip a;ca:count a];ca:0];
        $[count b>0;[b:flip b;cb:count b];cb:0];
        cab:ca+cb;
        $[(ca>0) and (cb>0);
          :(cab#time;cab#u[`utc_time];((ca#`SELL),(cb#`BUY));`int$((a[;0],b[;0])*.binance.priceMultiplier);`int$((a[;1],b[;1])*.binance.sizeMultiplier));
          ca>0;
          :(ca#time;ca#u[`utc_time];(ca#`SELL);`int$(a[;0]*.binance.priceMultiplier);`int$(a[;1]*.binance.sizeMultiplier));
          cb>0;
          :(cb#time;cb#u[`utc_time];(cb#`BUY);`int$(b[;0]*.binance.priceMultiplier);`int$(b[;1]*.binance.sizeMultiplier));
        ];   
    };
    x:derive each ob;
    x:flip `time`intime`side`price`size!raze each flip x;
    x:update dlt:{1_deltas x}size by price, side from `time xasc x;
    cx:count x;
    x:flip value flip x;
    :flip `time`intime`kind`cmd`datum!(x[;1];x[;2];cx#`DEPTH;cx#`UPDATE;(x[;3 +til 3]));
    };

tradeParser:{[u]
    derive:{
        d:x[`resp][`data];
        time:`datetime$(.binance.ts `long$d[`T]);
        :(time; x[`utc_time];$[d[`m]; `SELL; `BUY];`int$(("F"$d[`p])*.binance.priceMultiplier);`int$(("F"$d[`q])*.binance.sizeMultiplier));
    };
    x: derive each u;
    x:flip raze each flip x;
    cx:count x;
    :flip `time`intime`kind`cmd`datum!(x[;0];x[;1];cx#`TRADE;cx#`NEW;(x[;2+til 3]));
    };

markParser:{[u]
    derive:{
        d:x[`resp][`data];
        time:`datetime$(.binance.ts `long$d[`T]);
        :(time; x[`utc_time]; `int$(("F"$d[`p])*.binance.priceMultiplier));
    };
    x: derive each u;
    x:flip raze each flip x;
    cx:count x;
    :flip `time`intime`kind`cmd`datum!(x[;0];x[;1];cx#`MARK;cx#`UPDATE;x[;2]);
    };

fundingParser:{[u]
    derive:{
        d:x[`resp][`data];
        time:`datetime$(.binance.ts `long$d[`T]);
        :(time; x[`utc_time];"F"$d[`r]); // TODO next funding time
    };
    x: derive each u;
    x:flip raze each flip x;
    cx:count x;
    :flip `time`intime`kind`cmd`datum!(x[;0];x[;1];cx#`MARK;cx#`UPDATE;x[;2]);
    };
