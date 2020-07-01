the purpose of the pipe is to turn the updates recieved from the exchange into a set of cohesive
unilaterally processible events that can be used in the simulation engine

 
"""
Loads data from kdb table into parquet files
"""
from fastparquet import write
import argparse
from qpython import qconnection


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Query remote kdb+ instance')
    parser.add_argument('-ho', '--host', help='interface to listen to', default='35.223.102.237')
    parser.add_argument('-po', '--port', default=5005, type=int, help='port to bind to')
    parser.add_argument('-in', '--interval', help='interface to listen to', type=str, default='0D00:05:00')
    parser.add_argument('-fn', '--filename', help='The name of the parquet file to write the dataframe to', default='10minlong_5secshort')
    parser.add_argument('-pa', '--path', help='The path of the data directory', default='./data/')
    args = parser.parse_args()

    with qconnection.QConnection(host=args.host, port=args.port, pandas=True) as q:
        data = q.sendSync("""
        interval:0D00:00:05;
        long_interval:0D00:10:00;
        piv:{[t;k;p;v]f:{[v;P]`${raze "_" sv x} each string raze P,'/:v};v:(),v; k:(),k; p:(),p;G:group flip k!(t:.Q.v t)k;F:group flip p!t p;key[G]!flip(C:f[v]P:flip value flip key F)!raze{[i;j;k;x;y]a:count[x]#x 0N;a[y]:x y;b:count[x]#0b;b[y]:1b;c:a i;c[k]:first'[a[j]@'where'[b j]];c}[I[;0];I J;J:where 1<>count'[I:value G]]/:\:[t v;value F]};
        trds:0!select first_price:first price, last_price:last price, mean_size:avg size, volume:sum size, min_price:min price, max_price:max price by time:1 xbar interval xbar date+time, exch, sym from trades;
        bstrds:0!select last_price:last price, min_price:min price, max_price:max price, mean_size:avg size, volume:sum size by time:1 xbar interval xbar date+time, exch, sym, side from trades;
        ltrds:0!select lfirst_price:first price, llast_price:last price, lmean_size:avg size, lvolume:sum size, lmin_price:min price, lmax_price:max price by time:1 xbar long_interval xbar date+time, exch, sym from trades;
        dpths:0!select min_size:min size, last_price:last price, last_size: last size by time:1 xbar interval xbar date+time, exch, sym, side, lvl from depths;
        frts:0!select last funding_rate by time:1 xbar interval xbar date+time, exch, sym from funding_rates;
        mrkps:0!select first_mark_price:first mark_price, last_mark_price:last mark_price, max_mark_price:max mark_price, min_mark_price:min mark_price by time:1 xbar interval xbar date+time, exch, sym from mark_prices;
        trds:piv[`trds;`time;`exch`sym;`first_price`last_price`mean_size`min_price`max_price`volume];
        ltrds:piv[`ltrds;`time;`exch`sym;`lfirst_price`llast_price`lmean_size`lmin_price`lmax_price`lvolume];
        bstrds:piv[`bstrds;`time;`exch`sym`side;`last_price`mean_size`min_price`max_price`volume];
        dpths:piv[`dpths;`time;`exch`sym`side`lvl;`min_size`last_price`last_size];
        frts:piv[`frts;`time;`exch`sym;`funding_rate];
        mrkps:piv[`mrkps;`time;`exch`sym;`first_mark_price`last_mark_price`max_mark_price`min_mark_price];
        (uj)over(trds;bstrds;ltrds;dpths;frts;mrkps)
        """) 
        write(args.path+args.filename+".parquet", data)
        print(data.head())
        print(list(data.columns))
        print(data.describe())
        print(len(data))

[
"timestamp",
"volume24h",                     
"impactBidPrice",                
"bidPrice",                      
"markPrice",                     
"openInterest",                  
"askPrice",                      
"homeNotional24h",               
"totalTurnover",                 
"fairPrice",                     
"prevTotalVolume",               
"volume",                        
"indicativeSettlePrice",         
"turnover24h",                   
"vwap",                          
"prevPrice24h",                  
"fairBasis",                     
"prevTotalTurnover",             
"turnover",                      
"lastPrice",                     
"totalVolume",                   
"lastPriceProtected",            
"openValue",                     
"lastChangePcnt",                
"midPrice",                      
"foreignNotional24h",            
"impactAskPrice",                
"impactMidPrice",                
]