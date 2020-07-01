
select [-1] by time from depth
select [-1] by time, side from positions; //TODO
select [-1] by time from account;
select [-1] funding_rate from funding
select [-1] mark_price from mark
abc:{(`$"fea",/:string til y)}[3;count amn]!enlist amn
xbt:0^((count amn;0N)#amn)

time: (`date$time) + 1 xbar `second$time
0!select first_price:first price, last_price:last price, mean_size:avg size, volume:sum size, min_price:min price, max_price:max price by time:1 xbar interval xbar time, exch, sym from trades;
0!select last_price:last price, min_price:min price, max_price:max price, mean_size:avg size, volume:sum size by time:1 xbar interval xbar time, exch, sym, side from trades;

(uj)over(trds;bstrds;ltrds;dpths;frts;mrkps)