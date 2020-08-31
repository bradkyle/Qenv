
// 
groupBy: enlist[`accountId]!enlist `accountId;
`balance`available`frozen`m

/

OrderBook Features:
    - midprice
    - bidsize list
    - bidprice list
    - asksize list
    - askprice list
    - spread
    - best bid
    - best ask
    - bidsize fracs
    - asksize fracs

Candlestick Features
    - num (frac/log/nil)
    - high (frac/log/nil)
    - low (frac/log/nil)
    - open (frac/log/nil)
    - close (frac/log/nil)
    - volume (frac/log/nil)
    - msize (frac/log/nil)
    - hsize (frac/log/nil)
    - lsize (frac/log/nil)
    - vwap5 (frac/log/nil)
    - vwap10 (frac/log/nil)
    - sma10 (frac/log/nil)
    - sma20 (frac/log/nil)
    - ema12 (frac/log/nil)
    - ema26 (frac/log/nil)
    - macd (frac/log/nil)
    - signal (frac/log/nil)
    - rsi (frac/log/nil)
    - mfi (frac/log/nil)
    - avtp (frac/log/nil)
    - cci (frac/log/nil)
    - sma (frac/log/nil)
    - sd (frac/log/nil)
    - up (frac/log/nil)
    - down (frac/log/nil)
    - emv (frac/log/nil)
    - roc (frac/log/nil)
    - sc (frac/log/nil)
    - sk (frac/log/nil)
    - stoosc (frac/log/nil)
    - aroonup (frac/log/nil)
    - aroondown (frac/log/nil)
    - aroonosc (frac/log/nil)
    - bbh (frac/log/nil)
    - bbl (frac/log/nil)
    - bbm (frac/log/nil)
    - bbhi (frac/log/nil)
    - bbli (frac/log/nil)
    - kstsig (frac/log/nil)
    - fidx (frac/log/nil)
    - nvi (frac/log/nil)

Mark Price Features
    - last mark price
    - basis
    - ema

Funding Features
    - current funding price
    - next funding price
    - funding time countdown

Order Features
    - one hot level has orders
    - order leaves by level
    - order leaves list
    - order price list

Account Features
    - last balance
    - last available
    - last maintMargin

Inventory Features
    - last unrealized Pnl
    - last realizedPnl
    - last avgPrice

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

Feature Forecasters TODO iceberg detection!
    - XGBOOST(
        bidsizes,
        asksizes,
        bidprices,
        askprices) -> midPrice
    - XGBOOST(
        bidsizes,
        asksizes,
        bidprices,
        askprices,
        high,
        low,
        open,
        close,
        volume,
        msize,
        hsize) -> midPrice
    - SVN(
        bidsizes,
        asksizes,
        bidprices,
        askprices) -> midPrice
    - SVN(
        bidsizes,
        asksizes,
        bidprices,
        askprices,
        high,
        low,
        open,
        close,
        volume,
        msize,
        hsize) -> midPrice

\
GetObservations :{[]
    $[

    ];

    };