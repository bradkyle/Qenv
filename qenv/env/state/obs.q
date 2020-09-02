

/ use < for ascending, > for descending
.obs.derive: {
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

            lastprice:last[.state.TradeEventHistory]`price;
            buys:select[5;>time] price, size from .state.TradeEventHistory where side=1; // TODO configurable depth
            sells:select[5;>time] price, size from .state.TradeEventHistory where side=-1; // TODO configurable depth

            markprice:last[.state.MarkEventHistory]`markprice;
            basis:lastprice-markprice;

            funding:last[.state.FundingEventHistory]`fundingrate;

            // TODO add accountId
            bord:?[.state.CurrentOrders;.util.cond.isActiveAccLimit[1;bidprices;til[5]];`accountId`price!`accountId`price;enlist[`leaves]!enlist[(sum;`leaves)]];
            aord:?[.state.CurrentOrders;.util.cond.isActiveAccLimit[-1;askprices;til[5]];`accountId`price!`accountId`price;enlist[`leaves]!enlist[(sum;`leaves)]];

            bliq:select[5;>time] price, size from .state.LiquidationEventHistory where side=1;
            sliq:select[5;>time] price, size from .state.LiquidationEventHistory where side=-1;

            //Todo signal

            // TODO where in ids
            invn:0^(?[.state.CurrentInventory;();`accountId`side!`accountId`side;()]);
            acc:0^(?[.state.CurrentAccount;();0b;()]);
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