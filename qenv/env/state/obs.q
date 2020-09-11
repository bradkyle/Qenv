
/ )s:string[til[count[sig]]]
/ ){`$("sig",x)}'[s] // change sig lbl sig_1_1 etc.
/ ){`$("bd",x)}'[string[til[5]]]
/ ){`$("blq_",x)}'[string[cols liq@1]]
/ ){`$("slq_",x)}'[string[cols liq@-1]]
/ )raze{5#x}'[til[5]], )25#til[5]

.state.lookback:30;
.obs.sliqCols:`slq_avp`slq_avs`slq_hs`slq_ls`slq_lp`slq_hp;
.obs.bliqCols:`blq_avp`blq_avs`blq_hs`blq_ls`blq_lp`blq_hp;
.obs.bdfCols:{`$("bdf",x)}'[string[til[5]]];
.obs.adfCols:{`$("adf",x)}'[string[til[5]]];
.obs.bdpCols:{`$("bdp",x)}'[string[til[5]]];
.obs.adpCols:{`$("adp",x)}'[string[til[5]]];
.obs.sigCols:{`$x}'[raze'[flip(25#enlist"sig_";string[raze{5#x}'[til[5]]];"_";string[25#til[5]])]];
.obs.ohlcCols:(`num`high`low`open`close`volume`msize`hsize,
               `lsize`sma10`sma20`ema12`ema26`macd`rsi`mfi,
               `avtp`cci`sma`sd`up`down`EMV`ROC);
.obs.auxDCols:(`midprice`spread`sumasks`sumbids);

// TODO bid orders at exponential intervals!, 
// TODO place orders at exponential intervals! 
// TODO cancel orders outside of bounds
// TODO executions.

// TODO hourly/30 minute signals
// TODO 

// TODO xgboost predictor etc.
// TODO longer term candlestic features
// TODO executions
// TODO fractional differentiation
/ use < for ascending, > for descending // TODO fills
// TODO max lookback time
.obs.derive: {[step;aIds] // TODO make faster? // TODO fill values with blanks (0f), make faster

            // TODO order flow calculation, book activity etc.

            // Depth Features
            asks:select[-5;>price] price, size from .state.CurrentDepth where side=-1; // price descending asks
            bids:select[-5;<price] price, size from .state.CurrentDepth where side=1; // price ascending bids
            bestask:min asks;
            bestbid:max bids;
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
            depthfrac:sumbidsizes%sumasksizes;

            // Last Trade Features
            lastprice:last[.state.TradeEventHistory]`price;
            buys:select[5;>time] price, size from .state.TradeEventHistory where side=1, time>(max[time]-`minute$1); // todo remove
            sells:select[5;>time] price, size from .state.TradeEventHistory where side=-1, time>(max[time]-`minute$1); // todo remove
            
            // TODO hourly?

            // OHLC candles 0.10 ms/1000 (1 minute)
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
                by (1 xbar `minute$time) from .state.TradeEventHistory where time>(max[time]-`minute$20);

            ohlc:update 
                sma10:mavg[10;close], // TODO impl C
                sma20:mavg[20;close], 
                ema12:ema[2%13;close], 
                ema26:ema[2%27;close], 
                macd:macd[close] 
                from ohlc;

            ohlc:update rsi:rsiMain[close;14] from ohlc;

            ohlc:update mfi:mfiMain[high;low;close;6;volume], avtp:avg(high;low;close) from ohlc;

            ohlc:update cci:CCI[high;low;close;14] from ohlc;

            ohlc:update sma:mavg[20;avtp],sd:mdev[20;avtp] from ohlc;

            ohlc:update up:sma+2*sd,down:sma-2*sd from ohlc;

            ohlc:update EMV:emv[high;low;volume;1000000;14] from ohlc;

            ohlc:update ROC:roc[close;10] from ohlc;

            // Mark Price Features
            markprice:last[.state.MarkEventHistory]`markprice;
            basis:lastprice-markprice;

            // Funding Features
            funding:last[.state.FundingEventHistory]`fundingrate;

            // Liquidation Features // TODO ohlcs
            liq:select 
                avp:avg price, 
                avs:avg size, 
                hs:max size, 
                ls:min size, 
                lp:min price, 
                hp:max price by side from .state.LiquidationEventHistory where time>(max[time]-`minute$5);
            
            //Signal Features
            sig:select -5#sigvalue by sigid from (select last sigvalue by 1 xbar `minute$time,sigid from .state.SignalEventHistory where time>(max[time]-`minute$5)) where sigid in (til 5);
            sig:raze value[sig]`sigvalue;

            //Current Orders Features // todo grp by side? Grouping by increasing bucket spread mirroring the adapter action placement.
            bord:?[.state.CurrentOrders;.util.cond.isActiveAccLimit[1;bidprices;aIds];`accountId`price!`accountId`price;enlist[`leaves]!enlist[(sum;`leaves)]];
            aord:?[.state.CurrentOrders;.util.cond.isActiveAccLimit[-1;askprices;aIds];`accountId`price!`accountId`price;enlist[`leaves]!enlist[(sum;`leaves)]]; // get i instead of price
            bord:.util.Piv[0!bord;`accountId;`price;`leaves];
            aord:.util.Piv[0!aord;`accountId;`price;`leaves]; // TODO change to num rather

            // Inventory Features (add conditional accountId)
            invn:0^(?[.state.CurrentInventory;();`accountId`side!`accountId`side;()]);
            invn:.util.Piv[0!invn;`accountId;`side;`amt`realizedPnl`unrealizedPnl];

            // Account Features
            acc:0^(?[.state.CurrentAccount;();enlist[`accountId]!enlist[`accountId];`balance`available`frozen`maintMargin!`balance`available`frozen`maintMargin]);

            // Join Features by account
            fea:0!((uj) over (acc;invn;aord;bord));

            fea[.obs.sigCols]:sig;
            fea[.obs.bdfCols]:bidsizefracs;
            fea[.obs.adfCols]:asksizefracs;
            fea[.obs.bdpCols]:bidprices;
            fea[.obs.adpCols]:askprices;
            fea[.obs.bliqCols]:value[liq@1];
            fea[.obs.sliqCols]:value[liq@-1]; 
            fea[.obs.ohlcCols]:last[ohlc][.obs.ohlcCols];
            fea[`step]:step;
            {raze'[x]}'[fea] // TODO make better?
    };
  
// TODO join fea set

/
Feature Forecasters TODO iceberg detection!
    - XGBOOST(bidsizes,asksizes,bidprices,askprices) -> midPrice;
    - XGBOOST(bidsizes,asksizes,bidprices,askprices,high,
        low,open,close,volume,msize,hsize) -> midPrice;
    - SVN(bidsizes,asksizes,bidprices,askprices) -> midPrice;
    - SVN(bidsizes,asksizes,bidprices,askprices,high,
        low,open,close,volume,msize,hsize) -> midPrice;
\

 
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
    };


/ q).ml.minmaxscaler[raze'[ first value `accountId xgroup (flip (c!(0!.state.FeatureBuffer)[c]))]]
/ )f1:first `accountId xgroup (flip (c!(0!.state.FeatureBuffer)[c]))
/ .ml.minmaxscaler[raze'[f1]]
// q)o:0^`float$(first[`accountId xgroup .state.FeatureBuffer][c])
// last flip 0f^.ml.minmaxscaler[o]
// q).state.FeatureBuffer,:{x+:x*({rand 0.0001}'[til count[x]]);x}'[fea]
// q)first last'[flip'[.ml.minmaxscaler'[{raze'[x]}'[`accountId xgroup (enlist[`step] _ (`step xasc 0!.state.FeatureBuffer))]]]]
// q)first [{raze'[x]}'[{c:(cols[x] except `accountId`step);x[c]+:x[c]*({rand 0.0001}'[til count[x[c]]]);x}'[fea]]]