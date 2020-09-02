
/ )s:string[til[count[sig]]]
/ ){`$("sig",x)}'[s] // change sig lbl sig_1_1 etc.
/ ){`$("bd",x)}'[string[til[5]]]
/ ){`$("blq_",x)}'[string[cols liq@1]]
/ ){`$("slq_",x)}'[string[cols liq@-1]]

/ use < for ascending, > for descending // TODO fills
// TODO max lookback time
.obs.derive: { // TODO make faster?

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

            // Last Trade Features
            lastprice:last[.state.TradeEventHistory]`price;
            buys:select[5;>time] price, size from .state.TradeEventHistory where side=1, time>(max[time]-`minute$1); 
            sells:select[5;>time] price, size from .state.TradeEventHistory where side=-1, time>(max[time]-`minute$1); 

            // OHLC candles
            ohlc:0!select 
                num:count size, 
                high:max price, 
                low: min price, 
                open: first price, 
                close: last price, 
                volume: sum size, 
                msize: avg size, 
                hsize: max size,
                time: max time, 
                lsize: min size 
                by (1 xbar `minute$time) from .state.TradeEventHistory where time>(max[time]-`minute$20);

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

            //Current Orders Features // todo grp by side?
            bord:?[.state.CurrentOrders;.util.cond.isActiveAccLimit[1;bidprices;til[5]];`accountId`price!`accountId`price;enlist[`leaves]!enlist[(sum;`leaves)]];
            aord:?[.state.CurrentOrders;.util.cond.isActiveAccLimit[-1;askprices;til[5]];`accountId`price!`accountId`price;enlist[`leaves]!enlist[(sum;`leaves)]]; // get i instead of price
            bord:.util.Piv[0!bord;`accountId;`price;`leaves];
            aord:.util.Piv[0!aord;`accountId;`price;`leaves];

            // Inventory Features (add conditional accountId)
            invn:0^(?[.state.CurrentInventory;();`accountId`side!`accountId`side;()]);
            invn:.util.Piv[0!invn;`accountId;`side;`amt`realizedPnl`unrealizedPnl];

            // Account Features
            acc:0^(?[.state.CurrentAccount;();enlist[`accountId]!enlist[`accountId];`balance`available`frozen`maintMargin!`balance`available`frozen`maintMargin]);

            // Join Features by account
            fea:0!((uj) over (acc;invn;aord;bord));

            fea[.obs.sigCols]:sig;
            fea[.obs.depthCols]:(bidsizefracs,asksizefracs);
            fea[.obs.bliqCols]:value[liq@1];
            fea[.obs.sliqCols]:value[liq@-1]; 
    };
  

/
Feature Forecasters TODO iceberg detection!
    - XGBOOST(bidsizes,asksizes,bidprices,askprices) -> midPrice;
    - XGBOOST(bidsizes,asksizes,bidprices,askprices,high,
        low,open,close,volume,msize,hsize) -> midPrice;
    - SVN(bidsizes,asksizes,bidprices,askprices) -> midPrice;
    - SVN(bidsizes,asksizes,bidprices,askprices,high,
        low,open,close,volume,msize,hsize) -> midPrice;
\

GetObservations :{[]
    $[

    ]};