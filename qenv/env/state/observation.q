
/
The observation module contains logic to construct observation construction
functionality.
\
// .stateTest.genRandomState[100000;.z.z;250];

c : (`long$())!(); // TODO change to subset of supported types.

operatorCount:0;
Operators:(
    [operatorId : `long$()]
    ref         :`symbol$();
    tab         :`symbol$();
    deps        :();
    func        :();
    isroot      :`boolean();
    inputshape  :`long$();
    outputshape :`long$());

Register:{[table;deps;func]

    };

/
CurrentOrderBook Features:                      
    - bidsizelist                            
    - bidpricelist                          
    - asksizelist                            
    - askpricelist      
    - bestbid                            
    - bestask                            
    - midprice                               
    - spread                           
    - bidsizefracs                            
    - asksizefracs                               
\
/ use < for ascending, > for descending
asks:select[-5;>price] price, size from .state.CurrentDepth where side=`SELL; // price descending asks
bids:select[-5;<price] price, size from .state.CurrentDepth where side=`BUY; // price ascending bids
bestask:min asks;
bestbid:min bids;
asksizes:asks`size;
askprices:asks`price;
sumasksizes:sum asksizes;
bidsizes:bids`size;
bidprices:bids`price;
sumbidsizes:sum bidsizes;
bestbidsize:bestbid`size;
bestasksize:bestask`size;
bestaskprice:bestask`price;
bestbidprice:bestbid`price;
midprice:avg[bestaskprice,bestbidprice];
spread:(-/)(bestaskprice,bestbidprice);
bidsizefracs:bidsizes%sumbidsizes;
asksizefracs:asksizes%sumasksizes;

/
Last Trades Features:
    - last trades sizes
    - last trades sides (0=`SHORT; 1=`LONG) // ROOT = TRADE
\
lastprice:last[.state.TradeEventHistory]`price;
buys:select[5;>time] price, size from .state.TradeEventHistory where side=`BUY;
sells:select[5;>time] price, size from .state.TradeEventHistory where side=`SELL;
/ sells:select[5;>time] price, size from .state.TradeEventHistory where side=`SELL; todo both candle

/
Mark Price Features
    - last mark price
    - last basis
    - -5#mark price
    - -5#basis
\
markprice:last[.state.MarkEventHistory]`markprice;
basis:lastprice-markprice;

/
Funding Features
    - current funding price
    - next funding price
    - funding time countdown
\
funding:last[.state.FundingEventHistory]`fundingrate;

/
Order Features
    - one hot level has orders
    - order leaves by level
    - order leaves list
    - order price list
\

/ ?[.state.CurrentOrders;.cond.isActiveLimit[bidprices;0];0b;`price]; // SELLS
/ ?[.state.CurrentOrders;.cond.isActiveLimit[bidprices;1];0b;`price]; // BUYS

exec leaves from 0^(select leaves from .state.CurrentOrders where price in raze[ap], otype=`LIMIT, status in `NEW`PARTIALFILLED, side=`SELL);
exec leaves from 0^(select leaves from .state.CurrentOrders where price in raze[ap], otype=`LIMIT, status in `NEW`PARTIALFILLED, side=`SELL)

/
Account Features
    - last balance
    - last available
    - last maintMargin 

Inventory Features
    - last unrealized Pnl
    - last realizedPnl
    - last avgPrice
\
(select by accountId from .state.CurrentAccount 
    uj Piv[0!select by accountId,side from .state.CurrentInventory;`accountId;`side;`amt`realizedPnl`avgPrice`unrealizedPnl]);

/
Liquidation Features
    - liquidation prices
    - 
    - last avgPrice
\
shortliq:select[5;>time] price, size from .state.LiquidationEventHistory where side=`BUY;
longliq:select[5;>time] price, size from .state.LiquidationEventHistory where side=`SELL;

/ 
Signal Feautures
    - avg sigvalue
    - last sigvalue
\
signal:select last sigvalue by 1 xbar `minute$time,sigid from .state.SignalEventHistory;

/
Feature Forecasters TODO iceberg detection!
    - XGBOOST(bidsizes,asksizes,bidprices,askprices) -> midPrice;
    - XGBOOST(bidsizes,asksizes,bidprices,askprices,high,
        low,open,close,volume,msize,hsize) -> midPrice;
    - SVN(bidsizes,asksizes,bidprices,askprices) -> midPrice;
    - SVN(bidsizes,asksizes,bidprices,askprices,high,
        low,open,close,volume,msize,hsize) -> midPrice;
\

// Compiles feature functions into observation
Construct       :{[]

    };



GetObservations :{[]
    $[

    ]};