"""
Loads data from kdb table into parquet files
"""
from fastparquet import write
import argparse
from qpython import qconnection

interval = str(10)
num_lvls = 10


o = []
for s in ['ask', 'bid']:
    for i in range(10):
        for a in ['size', 'price']:
            for t in ['last', 'min']:
                n = s+str(i)+"_"+a
                o.append(t+"_"+n+":"+t+" "+n)

book_qry = ", ".join(o)
qry = """
piv:{[t;k;p;v]f:{[v;P]`${raze "_" sv x} each string raze P,'/:v};v:(),v; k:(),k; p:(),p;G:group flip k!(t:.Q.v t)k;F:group flip p!t p;key[G]!flip(C:f[v]P:flip value flip key F)!raze{[i;j;k;x;y]a:count[x]#x 0N;a[y]:x y;b:count[x]#0b;b[y]:1b;c:a i;c[k]:first'[a[j]@'where'[b j]];c}[I[;0];I J;J:where 1<>count'[I:value G]]/:\:[t v;value F]};
trds:select first_price:first price, last_price:last price, mean_size:avg size, volume:sum size, min_price:min price, max_price:max price by time: """ +interval+ """ xbar `second$time from trades;
bstrds:0!select last_price:last price, min_price:min price, max_price:max price, mean_size:avg size, volume:sum size by time: """ +interval+ """ xbar `second$time, side from trades;
dpths:select """ +book_qry+ """ by time: """ +interval+ """ xbar `second$time from orderbook;     

bstrds:piv[`bstrds;`time;`side;`last_price`mean_size`min_price`max_price`volume];

(lj)over(trds;bstrds;dpths)
"""
print(qry)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Query remote kdb+ instance')
    parser.add_argument('-ho', '--host', help='interface to listen to', default='localhost')
    parser.add_argument('-po', '--port', default=5050, type=int, help='port to bind to')
    parser.add_argument('-pa', '--path', help='The path of the data directory', default='../lcl/data/')
    args = parser.parse_args()

    with qconnection.QConnection(host=args.host, port=args.port, pandas=True) as q:
        data = q.sendSync(qry)
        write(args.path+"data"+".parquet", data)
        print(data.head())
        print(list(data.columns))
        print(data.describe())
        print(len(data))

# min_size:min size, last_price:last price, last_size: last size
# bstrds:piv[`orderbook;`time;`side;`last_price`mean_size`min_price`max_price`volume];
# select dlt:sum deltas bid0_size by time: 1 xbar `second$time from orderbook
# select deltas bid0_size by time: 1 xbar `second$time from orderbook
# x:update delta:{0,1_deltas x}ask0_size from orderbook
# x:update {0,1_deltas x}ask0_size, {0,1_deltas x}ask1_size from orderbook

# select size by time, price, side from orderbook where side = `ask