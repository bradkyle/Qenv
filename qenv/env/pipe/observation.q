
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
sumasksizes:sum asksizes;
bidsizes:bids`size;
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
    - last trades sides (0=`SHORT; 1=`LONG)
\

/
Mark Price Features
    - last mark price
    - basis
    - ema
\

/
Funding Features
    - current funding price
    - next funding price
    - funding time countdown
\

/
Order Features
    - one hot level has orders
    - order leaves by level
    - order leaves list
    - order price list
\

/
Account Features
    - last balance
    - last available
    - last maintMargin
\

/
Inventory Features
    - last unrealized Pnl
    - last realizedPnl
    - last avgPrice
\

/
Liquidation Features
    - last unrealized Pnl
    - last realizedPnl
    - last avgPrice
\

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