\cd ../util/
\l indicators.q
\cd ../state/

/ )s:string[til[count[sig]]]
/ ){`$("sig",x)}'[s] // change sig lbl sig_1_1 etc.
/ ){`$("bd",x)}'[string[til[5]]]
/ ){`$("blq_",x)}'[string[cols liq@1]]
/ ){`$("slq_",x)}'[string[cols liq@-1]]
/ )raze{5#x}'[til[5]], )25#til[5]

/ .state.lookback:30;
/ .obs.sliqCols:`slq_avp`slq_avs`slq_hs`slq_ls`slq_lp`slq_hp;
/ .obs.bliqCols:`blq_avp`blq_avs`blq_hs`blq_ls`blq_lp`blq_hp;
/ .obs.bdfCols:{`$("bdf",x)}'[string[til[5]]];
/ .obs.adfCols:{`$("adf",x)}'[string[til[5]]];
/ .obs.bdpCols:{`$("bdp",x)}'[string[til[5]]];
/ .obs.adpCols:{`$("adp",x)}'[string[til[5]]];
/ .obs.sigCols:{`$x}'[raze'[flip(25#enlist"sig_";string[raze{5#x}'[til[5]]];"_";string[25#til[5]])]];
/ .obs.ohlcCols:(`num`high`low`open`close`volume`msize`hsize,
/                `lsize`sma10`sma20`ema12`ema26`macd`rsi`mfi,
/                `avtp`cci`sma`sd`up`down`EMV`ROC);
/ .obs.auxDCols:(`midprice`spread`sumasks`sumbids);

// TODO bid orders at exponential intervals!, 
// TODO place orders at exponential intervals! 
// TODO cancel orders outside of bounds
// TODO executions.

// TODO hourly/30 minute signals
// TODO make larger i.e. 256-512 features
// TODO move into c

// TODO xgboost predictor etc.
// TODO longer term candlestic features
// TODO executions
// TODO fractional differentiation
// TODO strategies signals
// TODO different observation derivation methods
// TODO flatten 5m 15m 30m candles etc. for longer trend indication.
// TODO add longer trend candle predictors for hour, 15 min, 30 min etc trained on historical data
// TODO signals from other exchanges etc.
// TODO include request time and delay etc as a feature
// TODO create multi-scale features i.e. (5 seconds, 1 minute, 15 minute, 60 minute, 6 hours etc.)

// XGBOOST
// https://towardsdatascience.com/forecasting-stock-prices-using-xgboost-a-detailed-walk-through-7817c1ff536a
// https://medium.com/@hsahu/stock-prediction-with-xgboost-a-technical-indicators-approach-5f7e5940e9e3
// https://www.kaggle.com/mtszkw/using-xgboost-for-stock-trend-prices-prediction
// https://medium.com/swlh/stock-price-prediction-xgboost-1fce6cbd24d7
// https://www.datacamp.com/community/news/forecasting-markets-using-extreme-gradient-boosting-xgboost-dpiwyu0ag65
// http://gonzalopla.com/predicting-stock-exchange-prices-with-machine-learning/

// Prophet
// https://towardsdatascience.com/time-series-forecasting-predicting-stock-prices-using-facebooks-prophet-model-9ee1657132b5

// LSTM
// https://www.datacamp.com/community/tutorials/lstm-python-stock-market


/
Feature Forecasters TODO iceberg detection!
    - XGBOOST(bidsizes,asksizes,bidprices,askprices) -> midPrice;
    - XGBOOST(bidsizes,asksizes,bidprices,askprices,high,
        low,open,close,volume,msize,hsize) -> midPrice;
    - SVN(bidsizes,asksizes,bidprices,askprices) -> midPrice;
    - SVN(bidsizes,asksizes,bidprices,askprices,high,
        low,open,close,volume,msize,hsize) -> midPrice;
\

/ q).ml.minmaxscaler[raze'[ first value `accountId xgroup (flip (c!(0!.state.FeatureBuffer)[c]))]]
/ )f1:first `accountId xgroup (flip (c!(0!.state.FeatureBuffer)[c]))
/ .ml.minmaxscaler[raze'[f1]]
// q)o:0^`float$(first[`accountId xgroup .state.FeatureBuffer][c])
// last flip 0f^.ml.minmaxscaler[o]
// q).state.FeatureBuffer,:{x+:x*({rand 0.0001}'[til count[x]]);x}'[fea]
// q)first last'[flip'[.ml.minmaxscaler'[{raze'[x]}'[`accountId xgroup (enlist[`step] _ (`step xasc 0!.state.FeatureBuffer))]]]]
// q)first [{raze'[x]}'[{c:(cols[x] except `accountId`step);x[c]+:x[c]*({rand 0.0001}'[til count[x[c]]]);x}'[fea]]]

// Feature Sets
// =====================================================================================================>

.state.obs.PublicFeatureSet   :{[fn;size;step]
    x:size#0f;
    :fn[]
    };

// Expects a table to be return that has
// accountId as the index 
.state.obs.PrivateFeatureSet  :{[fn;size;aIds;step] // size is features per account row
    x:size#0f;
    :fn[aIds]
    };

.state.obs.SignalFeatureSet   :{[fn;size;sIds;step] // TODOs
    x:size#0f;
    :fn[sIds]
    };

.state.obs.JoinFeatureV        :{[pfea;xfea]
    fea:0!((uj) over xfea[;0]);
    n:sum pfea[;1];
    fea[til n]:raze[pfea[;0]];
    :fea;
    };

// Private Feature Sets
// ===============================================================>

// Account Feature Sets
// ----------------------------------------->

.state.obs.feature.account.0        :.state.obs.PrivateFeatureSet[{
    acc:0^(?[
        .state.CurrentAccount;();
        enlist[`accountId]!enlist[`accountId];
        (`balance`available`frozen`maintMargin!`balance`available`frozen`maintMargin)
    ]);
    :acc;
    };4];


// Inventory Feature Sets
// ----------------------------------------->

.state.obs.feature.inventory.0      :.state.obs.PrivateFeatureSet[{[aIds]
        // All Inventory
        invn:?[`.state.CurrentInventory;enlist(in;`accountId;aIds);0b;()];
        invn:.util.Piv[0!invn;`accountId;`side;`amt`realizedPnl`unrealizedPnl];
        // TODO derive approx liquidation price  
        :invn;
    };9];   

.state.obs.feature.inventory.1      :.state.obs.PrivateFeatureSet[{[aIds]
        // Long and short only
        invn:?[`.state.CurrentInventory;((in;`accountId;aIds);(in;`side;(-1;1)));0b;()];
        invn:.util.Piv[0!invn;`accountId;`side;`amt`realizedPnl`unrealizedPnl];
        // TODO derive approx liquidation price  
        :invn;
    };6];   

.state.obs.feature.inventory.2      :.state.obs.PrivateFeatureSet[{[aIds]
        // Both only
        invn:?[`.state.CurrentInventory;((in;`accountId;aIds);(=;`side;0));0b;()];
        invn:.util.Piv[0!invn;`accountId;`side;`amt`realizedPnl`unrealizedPnl];
        // TODO derive approx liquidation price  
        :invn;
    };3];   

// Order Feature Sets
// ----------------------------------------->

// TODO derivation by accountId // TODO testing
.state.obs.feature.order.0          :.state.obs.PrivateFeatureSet[{[aIds]
        // Bucketed limit order features
        bap:.state.bestAskPrice[];
        bbp:.state.bestBidPrice[];
        ticksize:0.1;
        bucketsize:2;
        num:10;
        ap:.state.adapter.superlinearPriceDistribution[bap;bucketsize;ticksize;num;-1];
        bp:.state.adapter.superlinearPriceDistribution[bbp;bucketsize;ticksize;num;1];
        aord:.state.limitLeavesByBucket[aIds;ap;-1]; // price descending asks // todo change to batch!
        bord:.state.limitLeavesByBucket[aIds;bp;1]; // price ascending bids 

        f:`accountId`bkt`side`reduce`price`mprice`xprice`leaves!();
        f[`accountId]:(44#0),(44#1);
        f[`bkt]:88#til 11;
        f[`reduce]:88#((22#0b),(22#1b));
        f[`side]:88#((11#-1),(11#1));
        f[`price]:88#asc[distinct[raze ap]]; // TODO add bp
        fea:`accountId`bkt`side`reduce xkey flip[.util.Filt[`accountId`bkt`side`reduce`price;f]];
        fea:0^((uj) over (fea;aord;bord));
        fea:.util.Piv[0!fea;`accountId;`bkt`side`reduce;`leaves];
        // todo frac
        // TODO add more features        
        :fea
    };44];


// Execution Feature Sets
// ----------------------------------------->


// Public Feature Sets
// ===============================================================>

// Depth Feature Sets
// ----------------------------------------->

.state.obs.features.depth.0         :.state.obs.PublicFeatureSet[{
            // Derives the set of features that pertain to the current bucketed prices
            bap:.state.bestAskPrice[];
            bbp:.state.bestBidPrice[];
            ticksize:0.1;
            bucketsize:2;
            num:10;
            ap:.state.adapter.exponentialPriceDistribution[bap;bucketsize;ticksize;num;-1];
            bp:.state.adapter.exponentialPriceDistribution[bbp;bucketsize;ticksize;num;1];
            asks:.state.bucketedDepth[ap;-1]; // price descending asks // todo
            bids:.state.bucketedDepth[bp;1]; // price ascending bids
            .state.obs.test.bids:bids;
            .state.obs.test.asks:asks;
            f:`bkt`side`price`mprice`xprice`size!();
            f[`bkt]:22#til 11;
            f[`side]:22#((11#-1),(11#1));
            f[`price]:22#asc[distinct[raze .state.obs.test.ap]]; // TODO add bp
            fea:`bkt`side xkey flip[.util.Filt[`bkt`side`price;f]];  
            fea:0^((uj) over (fea;asks;bids));
            .state.obs.test.fea:fea;
            :(0!.state.obs.test.fea)`size; // TODO add better features, filter where not in buckets
            / bestask:min asks;
            / bestbid:max bids;
            / asksizes:asks`size;
            / askprices:asks`price;
            / sumasksizes:sum asksizes;
            / bidsizes:bids`size;
            / bidprices:bids`price;
            / sumbidsizes:sum bidsizes;
            / bestbidsize:bestbid`size;
            / bestasksize:bestask`size;
            / bestaskprice:bestask`price;
            / bestbidprice:bestbid`price;
            / midprice:avg[bestaskprice,bestbidprice];
            / spread:(-/)(bestaskprice,bestbidprice);
            / bidsizefracs:bidsizes%sumbidsizes;
            / asksizefracs:asksizes%sumasksizes;
            / depthfrac:sumbidsizes%sumasksizes;
            / :raze[(
            /     bidsizefracs, // num
            /     asksizefracs, // num
            /     depthfrac, // num
            /     spread, // 1
            /     midprice, // 1
            /     bestaskprice, // 1
            /     bestbidprice, // 1
            /     bestasksize, // 1
            /     bestbidsize // 1
            / )];
    };22];

// TODO depth history

// Trade Feature Sets
// -----------------------------------------> // TODO better modularity

// TODO add more
.state.obs.features.trade.0         :.state.obs.PublicFeatureSet[{
        buys:select[100;>time] price, size from .state.TradeEventHistory where side=1, time>(max[time]-`minute$5); // todo remove
        sells:select[100;>time] price, size from .state.TradeEventHistory where side=-1, time>(max[time]-`minute$5); // todo remove
        :raze[(
            count[buys];
            count[sells];
            avg[5#buys`price];
            avg[15#buys`price];
            avg[30#buys`price];
            avg[buys`price];
            max[5#buys`price];
            max[15#buys`price];
            max[30#buys`price];
            max[buys`price];
            min[5#buys`price];
            min[15#buys`price];
            min[30#buys`price];
            min[buys`price];
            last[buys`price];
            avg[5#sells`price];
            avg[15#sells`price];
            avg[30#sells`price];
            avg[sells`price];
            max[5#sells`price];
            max[15#sells`price];
            max[30#sells`price];
            max[sells`price];
            min[5#sells`price];
            min[15#sells`price];
            min[30#sells`price];
            min[sells`price];
            last[sells`price];
            avg[5#buys`size];
            avg[15#buys`size];
            avg[30#buys`size];
            avg[buys`size];
            max[5#buys`size];
            max[15#buys`size];
            max[30#buys`size];
            max[buys`size];
            min[5#buys`size];
            min[15#buys`size];
            min[30#buys`size];
            min[buys`size];
            last[buys`size];
            sum[buys`size]; 
            avg[5#sells`size];
            avg[15#sells`size];
            avg[30#sells`size];
            avg[sells`size];
            max[5#sells`size];
            max[15#sells`size];
            max[30#sells`size];
            max[sells`size];
            min[5#sells`size];
            min[15#sells`size];
            min[30#sells`size];
            min[sells`size];
            last[sells`size];
            sum[sells`size]
        )];
    };56];


// OHLC Feature Sets
// -----------------------------------------> // TODO better modularity
// TODO different time periods
.state.obs.features.ohlc.0         :.state.obs.PublicFeatureSet[{
        ohlc:0!select 
            num:count size, 
            high:max price, 
            low: min price, 
            open: first price, 
            close: last price, 
            volume: sum size, 
            msize: avg size, 
            hsize: max size,
            lsize: min size 
            by (1 xbar `minute$time) from .state.TradeEventHistory where time>(max[time]-`minute$21);

        ohlc:update 
            sma10:mavg[10;close], // TODO impl C
            sma20:mavg[20;close], 
            ema12:ema[2%13;close], 
            ema26:ema[2%27;close], 
            macd:macd[close] 
            from ohlc;

        ohlcCount:count[ohlc];

        $[ohlcCount>6;[
            ohlc:update mfi:mfiMain[high;low;close;6;volume], avtp:avg(high;low;close) from ohlc;
        ];[ohlc:update mfi:0f from ohlc]];

        $[ohlcCount>10;[
            ohlc:update ROC:roc[close;10] from ohlc;
        ];[ohlc:update ROC:0f from ohlc]];

        $[ohlcCount>14;[            
            ohlc:update rsi:rsiMain[close;14] from ohlc;
            ohlc:update cci:CCI[high;low;close;14] from ohlc;
            ohlc:update EMV:emv[high;low;volume;1000000;14] from ohlc;
        ];[ohlc:update cci:0f, EMV:0f, rsi:0f from ohlc]];

        $[ohlcCount>20;[
            ohlc:update sma:mavg[20;avtp],sd:mdev[20;avtp] from ohlc;
            ohlc:update up:sma+2*sd,down:sma-2*sd from ohlc;
        ];[ohlc:update sma:0f,sd:0f,up:0f,down:0f from ohlc]];
        
        ohlc:`time _ last ohlc;
        :raze value ohlc;
    };24];

// Mark Feature Sets
// ----------------------------------------->

.state.obs.features.mark.0          :.state.obs.PublicFeatureSet[{
        // Mark Price Features
        markprice:((last[.state.MarkEventHistory]`markprice) | 0f);
        lastprice:((last[.state.TradeEventHistory]`price) | 0f);
        basis:lastprice-markprice;
        raze[(
            markprice;
            basis
        )]
    };2];

// Funding Feature Sets
// ----------------------------------------->

.state.obs.features.funding.0       :.state.obs.PublicFeatureSet[{
        funding:last[.state.FundingEventHistory];
        countdown:.util.TimeDiffMin[funding`fundingtime;.state.WaterMark]; // TODO get delta in time
        .state.obs.test.funding:funding;
        raze[(
            (funding[`fundingrate]  | 0f);
            (countdown | 0f)
        )]
    };2];

// Liquidation Feature Sets
// ----------------------------------------->

.state.obs.features.liquidation.0   :.state.obs.PublicFeatureSet[{
        // Liquidation Features 
        // last 5 mins of liquidations
        liq:select 
            avp:avg price, 
            avs:avg size, 
            hs:max size, 
            ls:min size, 
            lp:min price, 
            hp:max price by side from .state.LiquidationEventHistory where time>(max[time]-`minute$5);

        :raze value flip (enlist[`side] _ 0!liq);
    };12];

// Signal Feature Sets
// ----------------------------------------->
// TODO create one with mean etc. (lookback window allows for long term features)
.state.obs.features.signal.0        :.state.obs.SignalFeatureSet[{[sIds]
        //Signal Features 
        // derives a 5 row lookback window for each feature provided
        sig:select -5#sigvalue by sigid from 
            (select last sigvalue by 
                1 xbar `minute$time, sigid 
                from .state.SignalEventHistory 
                where time>(max[time]-`minute$5)
            ) where sigid in sIds;
        :raze value[sig]`sigvalue;
    };25];

.state.obs.features.signal.0        :.state.obs.SignalFeatureSet[{[sIds]
        //Signal Features 
        // derives a 1 row lookback window for each feature provided
        sig:select -5#sigvalue by sigid from 
            (select last sigvalue by 
                1 xbar `minute$time, sigid 
                from .state.SignalEventHistory 
                where time>(max[time]-`minute$1)
            ) where sigid in sIds;
        :raze value[sig]`sigvalue;
    };5];


// Logic
// =====================================================================================================>

// TODO ffea (forecasting)
/ use < for ascending, > for descending // TODO fills
// TODO max lookback time // TODO 
.obs.derive: {[step;aIds] // TODO make faster? // TODO fill values with blanks (0f), make faster
    pfea:( // public feature vector
    .state.obs.features.depth.0[step],
    .state.obs.features.trade.0[step],
    .state.obs.features.mark.0[step],
    .state.obs.features.funding.0[step],
    .state.obs.features.liquidation.0[step]
    / .state.obs.features.signal.0[step]
    );

    xfea:(); // private feature vectors
    xfea:.state.obs.feature.account.0[aIds;step];
    xfea:xfea uj .state.obs.feature.inventory.0[aIds;step];
    xfea:xfea uj .state.obs.feature.order.0[aIds;step];
    xfea:0!({raze'[x]}'[xfea]);
    xfea[`$string'[til count[pfea]]]:pfea;
    xfea[`step]:step;
    xfea
    };
  
// TODO join fea set

 
// GetObs derives a feature vector from the current state which it
// then fills and removes inf etc from.
// it then checks if the state Feature Buffer has been initialized
// with the respective feature columns, or else it initializes it.
// when the feature buffer is set up it will proceed to upsert the 
// features into the Feature buffer. It then calls .ml.minmax scaler
// to normalize the given features (FOR EACH ACCOUNT) such that the
// observations can be passed back to the agents etc.
/  @param step     (Long) The current environment step
/  @param aIds     (Long) The accountIds for which to get observations.
/  @return         (List) The normalized observation vector for each 
/                         account
/ cols[fea] except `accountId // TODO make more efficient, move to C etc
.obs.GetObs :{[step;lookback;aIds]
    fea:.obs.derive[step;aIds];
    if[((step=0) or (count[.state.FeatureBuffer]<count[aIds]));[
            // If the env is on the first step then generate 
            // a lookback buffer (TODO with decreasing noise?)
            // backwards (randomized fill of buffer)
            {x[`step]-:y;x:`accountId`step xkey x;x:0f^`float$(x);.state.FeatureBuffer,:{x+:x*rand 0.001;x}x}[fea]'[til[lookback]];
    ]];
    fea:`accountId`step xkey fea;
    fea:0f^`float$(fea);
    .state.FeatureBuffer,:fea;
   :last'[flip'[.ml.minmaxscaler'[{raze'[x]}'[`accountId xgroup (enlist[`step] _ (`step xasc 0!.state.FeatureBuffer))]]]]
    / :last'[flip'[{raze'[x]}'[`accountId xgroup (enlist[`step] _ (`step xasc 0!.state.FeatureBuffer))]]]
    };

