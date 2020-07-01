

interval:0D00:00:05;
select last_price:last price, mean_size:avg size by time:1 xbar interval xbar date+time, exch, sym from trades;