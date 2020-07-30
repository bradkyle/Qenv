\l ../engine/event.q
\l ../../lcl/db

/ .parser.Parse[trade;":./data/bitmex";.bitmex.tradeParser;10000];
 
// LOAD bitmex events
bp:"/home/kx/qenv/lcl/data/bitmexxbtusdevents";
.parser.Parse[trade;bp;.bitmex.tradeParser;10000];
.parser.Parse[orderbook;bp;.bitmex.bookParser;10000];
.parser.Parse[instrument;bp;.bitmex.markParser;100];
.parser.Parse[funding;bp;.bitmex.fundingParser;10];

// LOAD binance events
bp:"/home/kx/qenv/lcl/data/binancefuturesevents";
.parser.Parse[trade;bp;.binance.tradeParser;10000];
.parser.Parse[depth;bp;.binance.bookParser;10000];
.parser.Parse[markprice;bp;.binance.markParser;10000];
.parser.Parse[markprice;bp;.binance.fundingParser;10000];

/ // LOAD huobi events
/ bp:"/home/kx/qenv/lcl/data/houbidmevents";
/ .parser.Parse[trade;bp;.huobi.tradeParser;10000];
/ .parser.Parse[depthstep;bp;.okex.bookParser;10000];
/ .parser.Parse[depthsizehighfreq;bp;.okex.bookParser;10000];
/ .parser.Parse[markprice;bp;.huobi.markParser;10000];
/ .parser.Parse[markprice;bp;.huobi.fundingParser;10000];

/ bp:"/home/kx/qenv/lcl/data/okexevents";
/ .parser.Parse[tradedetail;bp;.okex.tradeParser;10000];
/ .parser.Parse[markprice;bp;.okex.markParser;10000];
/ .parser.Parse[markprice;bp;.okex.fundingParser;10000];