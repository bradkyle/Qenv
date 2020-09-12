



// Sentiment
twitter sentiment
    - sliding window 5 min, 

// Make features creates a set of features/table of features
// that are unilateraly applicable accross logic spaces i.e. 
// tweets, coinbase depth and trades, binance depth and trades, 
// openInterest, buy/long sentiment, tickers etc.

/
OrderBookHistory Features:                                              
    - bidsizediffer                             
    - asksizediffer                            
    - bidsizedifferfracs                            
    - asksizedifferfracs 
\
// TODO but very slow.

/ hourly/ 30 minutes
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
    - binance 
        - mid price
        - last price
        - avg price
        - avg size
        - skew
    - coinbase 
        - mid price
        - last price
        - avg price
        - avg size
        - skew
    - huobi futures weekly
        - last price
        - avg price
        - mid price
        - avg size
        - skew
    - huobi futures biweekly
        - last price
        - avg price
        - mid price
        - avg size
        - skew
    - huobi futures quarterly
        - last price
        - avg price
        - mid price
        - avg size (buy/sell)
        - skew
    - huobi futures biquarterly
        - last price
        - avg price
        - mid price
        - skew
        - ratio