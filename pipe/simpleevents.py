"""
Loads data from kdb table into parquet files
"""
from fastparquet import write
import argparse
from qpython import qconnection

qryd ="""
piv:{[t;k;p;v]f:{[v;P]`${raze "_" sv x} each string raze P,'/:v};v:(),v; k:(),k; p:(),p;G:group flip k!(t:.Q.v t)k;F:group flip p!t p;key[G]!flip(C:f[v]P:flip value flip key F)!raze{[i;j;k;x;y]a:count[x]#x 0N;a[y]:x y;b:count[x]#0b;b[y]:1b;c:a i;c[k]:first'[a[j]@'where'[b j]];c}[I[;0];I J;J:where 1<>count'[I:value G]]/:\:[t v;value F]};
orderbook:orderbook where not orderbook~'prev orderbook
x:update dlt:{0,1_deltas x}size by price, side from orderbook;
x:0!select last size, sum dlt by time, side, price, level from x where dlt<>0;

y: piv[`y;`time;`side;`qty`price];

y:0!select qty:sum size by time, side, price from trades where time < max x.time, time > min x.time;
y:update side:`ask from y where side=`Buy;
y:update side:`bid from y where side=`Sell;
f:`price`time;
w:((x.time - deltas x.time)+`time$1; x.time);
o:wj[w;f;x;(y;(sum;`Buy_qty);(sum;`Sell_qty))];
o
"""

# bstrds:piv[`bstrds;`time;`side;`last_price`mean_size`min_price`max_price`volume];
# select from x where level=0, side=`ask, dlt<>0
# c:select by window:1 xbar `second$time, side, price, level from o

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Query remote kdb+ instance')
    parser.add_argument('-ho', '--host', help='interface to listen to', default='localhost')
    parser.add_argument('-po', '--port', default=5050, type=int, help='port to bind to')
    parser.add_argument('-pa', '--path', help='The path of the data directory', default='../lcl/data/')
    args = parser.parse_args()

    with qconnection.QConnection(host=args.host, port=args.port, pandas=True) as q:
        data = q.sendSync(qryd)
        write(args.path+"data1.parquet", data)
        print(data.head())
        print(list(data.columns))
        print(data.describe())
        print(len(data))