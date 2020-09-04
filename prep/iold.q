

// Where trades do not decrease book price declare/place iceberg order
bask:`dlt`intime`side _ bask
q)x:(select dlt:sum size by 1 xbar `second$time from trd where side=1) pj (select dlt:sum{d:1_deltas x; d[where[d<0]]}size by 1 xbar `second$time from bask)
bask:select from book where side=-1, price=(min;price) fby time
q)x:(select fll:sum tsize by price,time from trd where side=1) uj (select dlt:sum[size-prev size] by price,time from bask)
mxt:first[(min((select max utc_time from trade);(select max utc_time from orderbook)))`utc_time]
mxt:first[(min((select max utc_time from trade);(select max utc_time from depth)))`utc_time]

q)bask:enlist[`intime] _ bask

book:update dlt:{1_deltas x}size by price, side from book
book:`time xasc book
trd:`time xasc trd
x:`time xasc x;
q)select from x where fll<>abs[dlt]
q)select fll, dlt from x where abs[dlt]>0,fll>0 // returns about 99 in 399839
x:^x

// enumerate the instances of orderbook change with respect to the last trade
// add a column to shift 1 forward the depth before the trade occurred
q)y:update f:{sums(((<>) prior x) and (x <> 0))}fll from `time xasc x

)y:select sum fll, sum {min[x,0]}dlt, last size by f from update f:{sums(((<>) prior x) and (x <> 0))}fll from `time xasc x
q)select from (update dlt:size-prev[size] from select fll, last'[size] from y where fll>0) where fll>abs[dlt]
q)y:select sum fll, dlt:sum[{min[x,0]}dlt], dlt2:$[count[size]>0;raze[last[size]]-raze[last[prev size]];0], last[size] by f from update f:{sums(((<>) prior x) and (x <> 0))}fll from `time xasc x
)x:(select fll:sum tsize by price,time from trd where side=1) uj (select dlt:sum[size-prev size],size by price,time from bask)
q)book:select from depth where utc_time>(max[utc_time]-`minute$30)

q)x:(select by price,time from trd where side=1) uj (select by price,time from bask)
q)book:flip `uid`time`intime`side`price`size!raze each flip (deriveBook'[select from depth where utc_time>(mxt-`minute$30)]);
q)bask:select from (delete from (flip `uid`time`intime`side`price`size!flip raze'[raze'[book]]) where type'[side]=101h) where side=-1, price=(min;price) fby uid
flip `time`intime`side`price`size!raze'[flip trd]
q)trd:deriveTrade'[select from trade where utc_time>(mxt-`minute$30)]

q)x:(select fll:sum size by price,time from trd where side=1) uj (select by price,time from bask)

q)x:update f:{sums(((<>) prior x) and ((x <> 0) and not[null[x]]))}fll from `time xasc x

q)x:delete intime,uid,side from x
q)x:`time xasc ((select fll:sum size by price,time from trd where side=1) uj (select by price,time from bask))
q)bask:select from (delete from (flip `uid`time`intime`side`price`size!flip raze'[raze'[book]]) where type'[side]=101h) where side=-1, price=(min;price) fby time

// select first depth before and after trade at given trade price level