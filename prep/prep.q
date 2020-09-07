
.okex.sizeMultiplier:1;
.okex.priceMultiplier:100;
.okex.tab:7;
.pipe.okex.uid:0;
mode:{where max[c]=c:count each d:group x}

deriveBook:{[u]
        r:u[`resp];
        d:first r[`data];
        time:"Z"$d[`timestamp];
        a:"F"$(r[`data][`asks][0]); 
        b:"F"$(r[`data][`bids][0]); // TODO if count is greater than one.
        ca:count[a];
        cb:count[b];
        cab:ca+cb; 
        :$[(ca>0) and (cb>0);
          (cab#time;cab#u[`utc_time];((ca#-1),(cb#1));`long$((a[;0],b[;0])*.okex.priceMultiplier);`long$((a[;1],b[;1])));
          ca>0;
          (ca#time;ca#u[`utc_time];(ca#-1);`long$(a[;0]*.okex.priceMultiplier);`long$(a[;1]));
          cb>0;
          (cb#time;cb#u[`utc_time];(cb#1);`long$(b[;0]*.okex.priceMultiplier);`long$(b[;1]));
        ];   
    };

deriveTrade:{
        d:x[`resp][`data][0]; 
        :("Z"$d[`timestamp]; x[`utc_time];$[d[`side]~"sell"; -1; 1];`long$(("F"$d[`price])*.okex.priceMultiplier);`long$(("F"$d[`size])*.okex.sizeMultiplier));
    };

mxt:first[(min((select max utc_time from trade);(select max utc_time from depth)))`utc_time]

trd:flip `time`intime`side`price`size!raze'[flip deriveTrade'[select from trade where utc_time>(mxt-`minute$30)]];
bok:flip `time`intime`side`price`size!raze each flip (deriveBook'[select from depth where utc_time>(mxt-`minute$30)]);
bok:{raze'[first'[x]]}'[bok]; / flip raze'[raze'[book]]
delete from `bok where type'[price]<>7h or type'[size]<>7h or type'[side]<>7h
bok:flip[cols[bok]!(flip raze'[raze'[{raze'[first'[x]]}'[bok]]])]
bok:`time xasc bok;

select sum size, by time,neg[side],price from trd; 

delete from `bok where type'[price]<>7h or type'[size]<>7h or type'[side]<>7h

// Select the first prior depth level for a given trade prior to 
// its time and and its price and the first depth level after its
// execution time at the given price. if the change in size is
// larger than or equal to the delta in the size caused by the trade
// then there was naively no iceberg order there before the trade
// if the change in size was smaller than the trade size then the
// level had iceberg orders equal to the difference in magnitude 
// between the expected size and the actual size (this can be randomized)
// if necessary.

trd:enlist[`intime] _ trd;
bok:enlist[`intime] _ bok;
trd[`side]:neg[trd`side];
trd:`time`side`price`tsize xcol trd;

x:bok uj trd;


select tsize, prev[size] from x where tsize>0;