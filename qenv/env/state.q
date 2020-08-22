
\l util.q
\d .state

// State specifically represents a set of events that are derived from the engine


// TODO prioritized experience replay
// TODO train test split with batches of given length (Hindsight experience replay/teacher student curriculum)
maxLvls:20;
DefaultInstrumentId:0;

filt: {x!y[x]};


// Singleton State and Lookback Buffers
// =====================================================================================>
// The lookback buffers attempt to build a realistic representation of what the
// agent will percieve in a real exchange.


// ACCOUNT
// ----------------------------------------------------------------------------------------------->

// The following tables maintain a local state buffer 
// representative of what the agent will see when
// interacting with a live exchange. 
AccountEventHistory: (
    [accountId : `long$(); time : `datetime$()]
    balance             : `long$();
    available           : `long$();
    frozen              : `long$();
    maintMargin         : `long$()
    );
accountCols:cols .state.AccountEventHistory;

// INVENTORY
// ----------------------------------------------------------------------------------------------->

// Maintains a historic and current record of the 
// positions (Inventory) each agent has held and
// subsequently provides agent specific details
// therin
InventoryEventHistory: (
    [accountId:  `long$();side: `symbol$();time : `datetime$()]
    amt                 :  `long$();
    realizedPnl         :  `long$();
    avgPrice            :  `long$(); // TODO check all exchanges have
    unrealizedPnl       :  `long$());
inventoryCols:cols .state.InventoryEventHistory;


// Return all open positions for an account
getOpenPositions              :{[aId]
    :(select from .state.InventoryEventHistory where accountId=accountId);
    };

getOpenPositionAmtBySide           :{[aId]
    :select sum currentQty by side from .state.InventoryEventHistory where accountId=aId;
    };

// ORDERS
// ----------------------------------------------------------------------------------------------->

// Maintains a historic and current record of orders
// that the engine has produced.
/ `.state.OrderEventHistory upsert (
/     []orderId:til 10;
/     accountId:10#1;
/     side:(5#`SELL),(5#`BUY);
/     price:(1000+til 5),(999-til 5);
/     otype:10#`LIMIT;
/     leaves:10#1000;
/     filled:10#1000;
/     limitprice:10#0;
/     stopprice:10#0;
/     status:10#`NEW;
/     time:10#.z.z;
/     isClose:10#0b;
/     trigger:10#`NIL);

/ `.state.OrderEventHistory upsert (
/    []orderId:(10+til 10);
/    accountId:10#1;
/    side:(5#`SELL),(5#`BUY);
/    price:(1000+til 5),(999-til 5);
/    otype:10#`LIMIT;
/    leaves:10#1000;
/    filled:10#1000;
/    limitprice:10#0;
/    stopprice:10#0;
/    status:10#`NEW;
/    time:10#.z.z;
/    isClose:10#0b;
/    trigger:10#`NIL);

OrderEventHistory: (
    [
        orderId:`long$();
        time:`datetime$()
    ]
    accountId       :   `long$();
    side            :   `symbol$();
    otype           :   `symbol$();
    price           :   `long$();
    leaves          :   `long$();
    filled          :   `long$();
    limitprice      :   `long$(); / multiply by 100
    stopprice       :   `long$(); / multiply by 100
    status          :   `symbol$();
    isClose         :   `boolean$();
    trigger         :   `symbol$();
    execInst        :   `symbol$());

CurrentOrders: (
    [orderId        :   `long$()]
    time            :   `datetime$();
    accountId       :   `long$();
    side            :   `symbol$();
    otype           :   `symbol$();
    price           :   `long$();
    leaves          :   `long$();
    filled          :   `long$();
    limitprice      :   `long$(); / multiply by 100
    stopprice       :   `long$(); / multiply by 100
    status          :   `symbol$();
    isClose         :   `boolean$();
    trigger         :   `symbol$();
    execInst        :   `symbol$());
ordCols:cols .state.OrderEventHistory;

// Get the current qtys at each order level
getCurrentOrderQtysByPrice        :{[accountId;numAskLvls;numBidLvls]
    :exec sum leaves by price from .state.OrderEventHisory 
        where accountId=accountId, state=`NEW`PARTIALLYFILLED, otype=`LIMIT;
    };

getLvlOQtysByPrice  :{[aId;s]
    :select dlt:sum leaves by price from .state.OrderEventHistory 
        where accountId=aId, status in `NEW`PARTIALFILLED, side=s, leaves>0;
    };


getOrders   :{
    select qty:sum leaves by price from .state.OrderEventHistory 
        where accountId=x, status in `NEW`PARTIALFILLED, side=`BUY, leaves>0;    
    };

genNextClOrdId  :{

    };

// DEPTH
// ----------------------------------------------------------------------------------------------->

/`.state.CurrentDepth upsert ([]price:(1000+til 20),(1000-til 20);side:(20#`SELL),(20#`BUY);size:40#1000)
CurrentDepth:(
    [price:`long$()]
    time:`datetime$();
    side:`symbol$();
    size:`long$());

// Maintains a historic record of depth snapshots
// with the amount of levels stored dependent upon
// the config for the specified from the engine 
// i.e. The depth has been directly affected by 
// the agent.
DepthEventHistory: (
    [price:`long$();time:`datetime$()]
    side:`symbol$();
    size:`int$());
depthCols:cols DepthEventHistory;

getLevelPrices          :{[s]
    :{$[x=`SELL;asc y;x=`BUY;desc y;`ERROR]}[s; (exec price from .state.CurrentDepth where side=s)]
    };

// TODO add error handling
getPriceAtLevel         :{[level;s]
    :getLevelPrices[s][level];
    };


// Non-Essential Datums
// ----------------------------------------------------------------------------------------------->

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
TradeEventHistory: (
    [tid:`long$(); time:`datetime$()]
    size            :   `long$();
    price           :   `long$();
    side            :   `symbol$());
tradeCols:cols TradeEventHistory;

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
MarkEventHistory: (
    [time            :   `datetime$()]
    markprice        :   `long$());
markCols:cols MarkEventHistory;

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
FundingEventHistory: (
    [time            :   `datetime$()]
    fundingrate      :   `long$();
    fundingtime      :   `datetime$());
fundingCols:cols FundingEventHistory;

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
LiquidationEventHistory: (
    [liqid:`long$(); time:`datetime$()]
    size            :   `long$();
    price           :   `long$();
    side            :   `symbol$());
liquidationCols:cols LiquidationEventHistory;

// TODO batching + 


// State Event Insertion
// =====================================================================================>
/ InventoryEventHistory: (
/     [accountId:  `long$();side: `symbol$();time : `datetime$()]
/     currentQty          :  `long$();
/     realizedPnl         :  `long$();
/     avgPrice            :  `long$(); // TODO check all exchanges have
/     unrealizedPnl       :  `long$());
// Recieves a table of events from the engine 
// and proceeds to insert them into the local historic buffer // TODO validation on events
// TODO liquidation, settlement, pricerange
InsertResultantEvents   :{[events]
    {[events]
        k:first events[`kind];
        c:first events[`cmd];

        events:flip[events];
        d:events[;`datum];
        t:events[`time];

        $[k=`DEPTH;[ // TODO delete from current depth
            l:flip[.state.depthCols!(d[;`price];t;d[;`side];0^d[;`size])];
            .qt.L:l;
            `.state.CurrentDepth upsert 1!l;
            `.state.DepthEventHistory upsert 2!l;
            delete from `.state.CurrentDepth where size=0; // TODO remove stratified orderbook
          ];
          k=`TRADE;[
              t:(
                [tid:d[;`tid];time:t]
                side:d[;`side];
                size:0^d[;`size];
                price:0^d[;`price]);
            `.state.TradeEventHistory upsert t;
          ];
          k=`MARK;[
            `.state.MarkEventHistory upsert (
                [time:t]
                markprice:d[;`markprice]);
          ];
          k=`FUNDING;[
            `.state.FundingEventHistory upsert (
                [time:t]
                fundingrate:d[;`fundingrate];
                fundingtime:d[;`fundingtime]);
          ];
          k=`LIQUIDATION;[ // TODO if delete remove from current
            `.state.LiquidationEventHistory upsert (
                [liqid:d[;`liqid]; time:t]
                side:d[;`side];
                price:d[;`price];
                size:0^d[;`size]);
          ]; 
          k=`ACCOUNT;
          [
            `.state.AccountEventHistory upsert ([
                accountId:d[;`accountId];
                time:t] 
                balance:0^d[;`balance];
                available:0^d[;`available];
                frozen:0^d[;`frozen];
                maintMargin:0^d[;`maintMargin]);
          ];
          k=`INVENTORY;
          [
            `.state.InventoryEventHistory upsert ([
                accountId:d[;`accountId];
                side:d[;`side];
                time:t] 
                amt:0^d[;`amt];
                realizedPnl:0^d[;`realizedPnl];
                avgPrice:0^d[;`avgPrice];
                unrealizedPnl:0^d[;`unrealizedPnl]);
          ];
          k=`ORDER;
          [
            o:flip[.state.ordCols!(d[;`orderId];t;
               d[;`accountId];
               d[;`side];
               d[;`otype];
               d[;`price];
               0^d[;`leaves];
               0^d[;`filled];
               0^d[;`limitprice];
               0^d[;`stopprice];
               `NEW^d[;`status];
               0b^d[;`isClose];
               `NIL^d[;`trigger];
               `NIL^d[;`execInst])];
            `.state.CurrentOrders upsert 1!o;
            `.state.OrderEventHistory upsert 2!o;
          ];
          ['INVALID_KIND]];
    } each 0!(`kind`cmd xgroup events); // TODO benchmark with peach and each
    };

// Feature Extraction and Derivation
// =====================================================================================>

FeatureBuffer   :();

// Agent specific observation functions
// --------------------------------------------------->

Piv:{[t;k;p;v]
    f:{[v;P]`${raze "_" sv x} each string raze P,'/:v};
    v:(),v; 
    k:(),k; 
    p:(),p;
    G:group flip k!(t:.Q.v t)k;
    F:group flip p!t p;
    key[G]!flip(C:f[v]P:flip value flip key F)!raze{[i;j;k;x;y]
        a:count[x]#x 0N;a[y]:x y;
        b:count[x]#0b;
        b[y]:1b;
        c:a i;
        c[k]:first'[a[j]@'where'[b j]];
        c
    }[I[;0];I J;J:where 1<>count'[I:value G]]/:\:[t v;value F]};

// TODO check if successful feature derive

// Efficiently returns the aggregated and normalised
// feature vector represenations of the agent state 
// and environment state for a set of agent ids. // CHANGE to FeatureVector
// https://code.kx.com/q/wp/trend-indicators/


relativeStrength:{[num;y]
        begin:num#0Nf;
        start:avg((num+1)#y);
        begin,start,{(y+x*(z-1))%z}\[start;(num+1)_y;num]};


rsiMain:{[close;n]
    diff:-[close;prev close];
    rs:relativeStrength[n;diff*diff>0]%relativeStrength[n;abs diff*diff<0];
    rsi:100*rs%(1+rs);
    rsi };

mfiMain:{[h;l;c;n;v]
            TP:avg(h;l;c);                    / typical price
            rmf:TP*v;                         / real money flow
            diff:deltas[0n;TP];               / diffs
            /money-flow leveraging func for RSI
            mf:relativeStrength[n;rmf*diff*diff>0]%relativeStrength[n;abs rmf*diff*diff<0];
            mfi:100*mf%(1+mf);                /money flow as a percentage
            mfi };

maDev:{[tp;ma;n]
    ((n-1)#0Nf),
        {[x;y;z;num] reciprocal[num]*sum abs z _y#x}'
        [(n-1)_tp-/:ma; n+l; l:til count[tp]-n-1; n] };

// TODO change to interval
CCI:{[high;low;close;n] 
    TP:avg(high;low;close);
    sma:mavg[n;TP];
    mad:maDev[TP;sma;n];
    reciprocal[0.015*mad]*TP-sma };


// TODO doesn't work
/ forceIndex:{[c;v;n]
/     forceIndex1:1_deltas[0nf;c]*v;
/     n#0nf,(n-1)_ema[2%1+n;forceIndex1] }

/ ohlc:update ForceIndex:forceIndex[close;volume;13] from ohlc;

//Ease of movement value -EMV
/h-high
/l-low
/v-volume
/s-scale
/n-num of periods
emv:{[h;l;v;s;n]
    boxRatio:reciprocal[-[h;l]]*v%s;
    distMoved:deltas[0n;avg(h;l)];
    (n#0nf),n _mavg[n;distMoved%boxRatio] };


//Price Rate of change Indicator (ROC)
/c-close
/n-number of days prior to compare
roc:{[c;n]
    curP:_[n;c];
    prevP:_[neg n;c];
    (n#0nf),100*reciprocal[prevP]*curP-prevP };


//null out first 13 days if 14 days moving avg
//Stochastic Oscillator
/h-high
/l-low
/n-num of periods
/c-close price
/o-open
stoOscCalc:{[c;h;l;n]
    lows:mmin[n;l];
    highs:mmax[n;h];
    (a#0n),(a:n-1)_100*reciprocal[highs-lows]*c-lows };

stoOcsK:{[c;h;l;n;k] (a#0nf),(a:n+k-2)_mavg[k;stoOscCalc[c;h;l;n]] };
stoOscD:{[c;h;l;n;k;d] (a#0n),(a:n+k+d-3)_mavg[d;stoOscK[c;h;l;n;k]] };


//Aroon Indicator
aroonFunc:{[c;n;f]
    m:reverse each a _'(n+1+a:til count[c]-n)#\:c;
    #[n;0ni],{x? y x}'[m;f] };

aroon:{[c;n;f] 100*reciprocal[n]*n-aroonFunc[c;n;f]};

/- aroon[tab`high;25;max]-- aroon up
/- aroon[tab`low;25;max]-- aroon down
aroonOsc:{[h;l;n] aroon[h;n;max] - aroon[l;n;min]};

signal:{ema[2%10;x]};
macd:{[x] ema[2%13;x]-ema[2%27;x]};

/ tradeFuncs:`lowPr`highPr`tcnt`avgPr`vwap`volatility`totalReturn`volume`dollarVol`open`close`twap`twas`avgSz`minSz`maxSz`startTime`endTime!((min;`tp);(max;`tp);(count;`tp);(avg;`tp);(wavg;`ts;`tp);(volatility;`tp);(totalReturn;`tp);(sum;`ts);(dollarVol;`ts;`tp);(first;`tp);(last;`tp);(tw;`time;`tp);(tw;`time;`ts);(avg;`ts);(min;`ts);(max;`ts);(min;`time);(max;`time))
/ quoteFuncs:`minAp`maxAp`minBp`maxBp`qcnt`avgSprd`maxSprd`minSprd`twAsk`twBid`twSprd!((min;`ap);(max;`ap);(min;`bp);(max;`bp);(count;`ap);(avg;(-;`ap;`bp));(max;(-;`ap;`bp));(min;(-;`ap;`bp));(tw;`time;`ap);(tw;`time;`bp);(tw;`time;(-;`ap;`bp)))

getOhlcFeatures :{[]
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
            by (1 xbar `minute$time) from .state.TradeEventHistory;

        ohlc:update 
            sma10:mavg[10;close], 
            sma20:mavg[20;close], 
            ema12:ema[2%13;close], 
            ema26:ema[2%27;close], 
            macd:macd[close] 
            from ohlc;
        
        ohlc:update signal:signal[macd] from ohlc;

        ohlc:update rsi:rsiMain[close;14] from ohlc;

        ohlc:update mfi:mfiMain[high;low;close;6;volume], avtp:avg(high;low;close) from ohlc;

        ohlc:update mfi:mfiMain[high;low;close;6;volume] from ohlc;

        ohlc:update cci:CCI[high;low;close;14] from ohlc;

        ohlc:update sma:mavg[20;avtp],sd:mdev[20;avtp] from ohlc;

        ohlc:update up:sma+2*sd,down:sma-2*sd from ohlc;

        ohlc:update EMV:emv[high;low;volume;1000000;14] from ohlc;

        ohlc:update ROC:roc[close;10] from ohlc;

        ohlc: update
            sC:stoOscCalc[close;high;low;5],
            sk:stoOscK[close;high;low;5;2],
            stoOscD[close;high;low;5;2;3] from ohlc;

        ohlc:update
            aroonUp:aroon[high;25;max],
            aroonDown:aroon[low;25;min],
            aroonOsc:aroonOsc[high;low;25] from ohlc;

        // Pivot and combine per accountId

        / ohlc:Piv[ohlc;`time;`side;`high`low`open`close`volume`msize`hsize`lsize`num];
        ohlc: value last (0^(`time`time _ ohlc));
    };

getPeriodSplit  :{

    };

getOBFeatures   :{

        ob update avg(bestBid,bestAsk) from .state.DepthEventHistory;
    };

// TODO get orderbook features

GetFeatures    :{[accountIds] // TODO configurable window size
        windowsize:100;
        / interval: 

        // TODO add liquidation as feature.

        // TODO add account id to feature vector
        pobs: raze raze'[( 
            10#0;
            exec last markprice from .state.MarkEventHistory;
            exec last fundingrate from .state.FundingEventHistory;
            value flip select[-5] price from .state.TradeEventHistory where side=`BUY; // TODO fill 0's
            value flip select[-5] price from .state.TradeEventHistory where side=`SELL;
            value flip select[-5] size from .state.TradeEventHistory where side=`BUY;
            value flip select[-5] size from .state.TradeEventHistory where side=`SELL;
            value flip select[5] size from `price xasc .state.CurrentDepth where side=`BUY;
            value flip select[5] size from `price xdesc .state.CurrentDepth where side=`SELL
        )];

        // TODO do uj
        oobs: (
            select sum leaves by accountId,price from .state.CurrentOrders 
                where otype=`LIMIT, status in `NEW`PARTIALFILLED, side=`SELL;
            select sum leaves by accountId,price from .state.CurrentOrders 
                where otype=`LIMIT, status in `NEW`PARTIALFILLED, side=`BUY;
        );

        select last balance, last available, last frozen, last maintMargin by accountId from .state.AccountEventHistory where accountId in accountIds;
        select last amt, last realizedPnl, last avgPrice, last unrealizedPnl by accountId,side from .state.InventoryEventHistory where accountId in accountIds;

        // if count feature buffer
        `.state.FeatureBuffer upsert obs;

        // TODO count by account id
        / $[(count .schema.FeatureBuffer)>maxBufferSize;]; // TODO make max buffer size configurable
        // TODO fill forward + normalize
        :.ml.minmaxscaler[-100#.state.FeatureBuffer];
    };


// Reward Extraction and Derivation
// =====================================================================================>

sortino  :{

    };

GetRewards  :{[accountIds] // TODO configurable window size
    windowsize:100

    wnRet:r:
        // TODO fill zeros etc.
        0!select 
        returns:1_deltas[realizedPnl] 
        by accountId 
        from select[-100] 
            last realizedPnl 
            by 1 xbar `minute$time, 
            accountId from .state.InventoryEventHistory;

    };