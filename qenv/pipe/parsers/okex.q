\d .okex

sizeMultiplier:1;
priceMultiplier:100;


bookParser:{[ob]
    derive:{[u]
        r:u[`resp];
        d:first r[`data];
        time:"Z"$d[`timestamp];
        a:"F"$(r[`data][`asks][0]); 
        b:"F"$(r[`data][`bids][0]); // TODO if count is greater than one.
        ca:count[a];
        cb:count[b];
        cab:ca+cb; 
        $[(ca>0) and (cb>0);
          :(cab#time;cab#u[`utc_time];((ca#`SELL),(cb#`BUY));`int$((a[;0],b[;0])*.okex.priceMultiplier);`int$((a[;1],b[;1])));
          ca>0;
          :(ca#time;ca#u[`utc_time];(ca#`SELL);`int$(a[;0]*.okex.priceMultiplier);`int$(a[;1]));
          cb>0;
          :(cb#time;cb#u[`utc_time];(cb#`BUY);`int$(b[;0]*.okex.priceMultiplier);`int$(b[;1]));
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
        d:x[`resp][`data][0]; 
        :("Z"$d[`timestamp]; x[`utc_time];$[d[`side]~"sell"; `SELL; `BUY];`int$(("F"$d[`price])*.okex.priceMultiplier);`int$(("F"$d[`size])*.okex.sizeMultiplier));
    };
    x: derive each u;
    x:flip raze each flip x;
    cx:count x;
    :flip `time`intime`kind`cmd`datum!(x[;0];x[;1];cx#`TRADE;cx#`NEW;(x[;2+til 3]));
    };

markParser:{[u]
    derive:{
        d:x[`resp][`data][0]; 
        :("Z"$d[`timestamp]; x[`utc_time];`int$(("F"$d[`mark_price])*.okex.priceMultiplier));
    };
    x: derive each u;
    x:flip raze each flip x;
    cx:count x;
    :flip `time`intime`kind`cmd`datum!(x[;0];x[;1];cx#`MARK;cx#`UPDATE;enlist each x[;2]);
    };

fundingParser:{[u]
    derive:{
        d:x[`resp][`data][0]; 
        :(x[`utc_time]; x[`utc_time]; "F"$d[`funding_rate]);
    };
    x: derive each u;
    x:flip raze each flip x;
    cx:count x;
    :flip `time`intime`kind`cmd`datum!(x[;0];x[;1];cx#`FUNDING;cx#`UPDATE;enlist each x[;2]);
    };
