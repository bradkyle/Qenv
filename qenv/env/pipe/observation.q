
/
The observation module contains logic to construct observation construction
functionality.
\
// .stateTest.genRandomState[100000;.z.z;250];

c : (`long$())!(); // TODO change to subset of supported types.

Aggregators :(

    );

Register:{

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
sumasksizes:sum ask`size;
sumbidsizes:sum bids`size;
bestbidsize:bestbid`size;
bestasksize:bestask`size;
bestaskprice:bestask`price;
bestbidprice:bestbid`price;
midprice:avg[bestaskprice,bestbidprice];
spread:(-/)(bestaskprice,bestbidprice);
bidsizefracs:(bids`size)%(sum(bids`size));
asksizefracs:(asks`size)%(sum(asks`size));

/
OrderBookHistory Features:                                              
    - bidsizediffer                             
    - asksizediffer                            
    - bidsizedifferfracs                            
    - asksizedifferfracs 
\
// TODO but very slow.

/
Candlestick/Trade Features
    - num (frac/log/nil) (buy/sell/both)                                                     
    - high (frac/log/nil) (buy/sell/both)                                                   
    - low (frac/log/nil) (buy/sell/both)                                                    
    - open (frac/log/nil) (buy/sell/both)                                                   
    - close (frac/log/nil) (buy/sell/both)                                                  
    - volume (frac/log/nil) (buy/sell/both)                                                 
    - msize (frac/log/nil) (buy/sell/both)                                                  
    - hsize (frac/log/nil) (buy/sell/both)                                                  
    - lsize (frac/log/nil) (buy/sell/both)                                                  
    - vwap (frac/log/nil) (buy/sell/both)                                                   
    - sma (frac/log/nil) (buy/sell/both)                                                    
    - ema (frac/log/nil) (buy/sell/both)                                                    
    - macd (frac/log/nil) (buy/sell/both)                                                   
    - signal (frac/log/nil) (buy/sell/both)                                                 
    - rsi (frac/log/nil) (buy/sell/both)                                                    
    - mfi (frac/log/nil) (buy/sell/both)                                                    
    - avtp (frac/log/nil) (buy/sell/both)                                                   
    - cci (frac/log/nil) (buy/sell/both)                                                    
    - sma (frac/log/nil) (buy/sell/both)                                                    
    - sd (frac/log/nil) (buy/sell/both)                                                 
    - up (frac/log/nil) (buy/sell/both)                                                 
    - down (frac/log/nil) (buy/sell/both)                                                   
    - emv (frac/log/nil) (buy/sell/both)                                                    
    - roc (frac/log/nil) (buy/sell/both)                                                    
    - sc (frac/log/nil) (buy/sell/both)                                                 
    - sk (frac/log/nil) (buy/sell/both)                                                 
    - stoosc (frac/log/nil) (buy/sell/both)                                                 
    - aroonup (frac/log/nil) (buy/sell/both)                                                    
    - aroondown (frac/log/nil) (buy/sell/both)                                                  
    - aroonosc (frac/log/nil) (buy/sell/both)                                                   
    - bbh (frac/log/nil) (buy/sell/both)                                                    
    - bbl (frac/log/nil) (buy/sell/both)                                                    
    - bbm (frac/log/nil) (buy/sell/both)                                                    
    - bbhi (frac/log/nil) (buy/sell/both)                                                   
    - bbli (frac/log/nil) (buy/sell/both)                                                   
    - kstsig (frac/log/nil) (buy/sell/both)                                                 
    - fidx (frac/log/nil) (buy/sell/both)                                                   
    - nvi (frac/log/nil) (buy/sell/both)                                                    
\

/ num:count size
/ high:max price
/ low: min price 
/ open: first price 
/ close: last price 
/ volume: sum size 
/ msize: avg size 
/ hsize: max size
/ time: max time 
/ lsize: min size

/ mavg

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
Signal Features (External)
    - binance open interest
    - binance notional value
    - binance top trader acc long frac
    - binance top trader acc short frac
    - binance top trader pos long frac
    - binance top trader pos short frac 
    - binance long frac
    - binance short frac
    - okex open interest
    - okex notional value
    - okex top trader acc long frac
    - okex top trader acc short frac
    - okex top trader pos long frac
    - okex top trader pos short frac 
    - okex long frac
    - okex short frac
    - tweet sentiment
    - okex midprice
    - binance bidprice
    - coinbase midprice
    - coinbase last 5 trades
    - coinbase last price
\

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