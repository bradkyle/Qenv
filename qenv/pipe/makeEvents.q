/ \l ../engine/event.q
/ \l ../../lcl/db
\l ./parsers/bitmex.q
\l ./parsers/binance.q
\l ./parsers/okex.q
\l ./parsers/huobi.q
\l ./parsers/parser.q
/home/thorad/Core/Projects/Qenv/qenv/pipe/parsers/bitmex.q
/ .parser.Parse[trade;":./data/bitmex";.bitmex.tradeParser;10000];
// LOAD bitmex events
/ \l ../../lcl/data/bitmexagentxbtusd/xbtusd
/ bp:":/home/kx/qenv/lcl/events/bitmexxbtusd";
/ .parser.Parse[trade;bp;.bitmex.tradeParser;10000];
/ .parser.Parse[orderbook;bp;.bitmex.bookParser;10000];
/ .parser.Parse[instrument;bp;.bitmex.markParser;100];
/ .parser.Parse[funding;bp;.bitmex.fundingParser;10];
/ delete from `.;
/ \cd /home/kx/qenv/qenv/pipe

// LOAD binance events
/ \l ../../lcl/data/binancefuturesagent/bchusdt
/ bp:":/home/kx/qenv/lcl/events/binancebtcusdt";
/ .parser.Parse[trade;bp;.binance.tradeParser;10000];
/ .parser.Parse[depth;bp;.binance.bookParser;10000];
/ .parser.Parse[markprice;bp;.binance.markParser;10000];
/ .parser.Parse[markprice;bp;.binance.fundingParser;10000];
/ delete from `.;
/ \cd /home/kx/qenv/qenv/pipe

/ // LOAD okex events
/ \l ../../lcl/data/okexagent/btcusdswap
/ bp:":/home/kx/qenv/lcl/events/okexbtcusdswap";
/ / .parser.Parse[trade;bp;.okex.tradeParser;10000];
/ .parser.Parse[depth;bp;.okex.bookParser;10000];
/ .parser.Parse[markprice;bp;.okex.markParser;10000];
/ .parser.Parse[fundingrate;bp;.okex.fundingParser;10000];
/ delete from `.;
/ \cd /home/kx/qenv/qenv/pipe


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