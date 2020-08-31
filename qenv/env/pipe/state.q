\cd ../util/
\l util.q
\cd ../pipe/
\d .state

// State specifically represents a set of events that are derived from the engine
// TODO max history size

// TODO house state in its own process
// TODO prioritized experience replay
// TODO train test split with batches of given length (Hindsight experience replay/teacher student curriculum)
maxLvls:20;
DefaultInstrumentId:0;

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
    maintMargin         : `long$());
accountCols:cols .state.AccountEventHistory;
CurrentAccount: `accountId xkey .state.AccountEventHistory;

// INVENTORY
// ----------------------------------------------------------------------------------------------->

// Maintains a historic and current record of the 
// positions (Inventory) each agent has held and
// subsequently provides agent specific details
// therin
InventoryEventHistory: ( // TODO change side to long 1,2,3
    [accountId:  `long$();side: `symbol$();time : `datetime$()]
    amt                 :  `long$();
    realizedPnl         :  `long$();
    avgPrice            :  `long$(); // TODO check all exchanges have
    unrealizedPnl       :  `long$());
inventoryCols:cols .state.InventoryEventHistory;
CurrentInventory: `accountId`side xkey .state.InventoryEventHistory;


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
    side            :   `symbol$(); // TODO change to long
    otype           :   `symbol$(); // TODO change to long
    price           :   `long$();
    leaves          :   `long$();
    filled          :   `long$();
    limitprice      :   `long$(); / multiply by 100
    stopprice       :   `long$(); / multiply by 100
    status          :   `symbol$();
    isClose         :   `boolean$();
    trigger         :   `symbol$(); // TODO change to long
    execInst        :   `symbol$()); // TODO change to long

ordCols:cols .state.OrderEventHistory;
CurrentOrders: `orderId xkey .state.OrderEventHistory;
clOrdCount:0;

// Get the current qtys at each order level
getCurrentOrderQtysByPrice        :{[accountId;numAskLvls;numBidLvls]
    :exec sum leaves by price from .state.OrderEventHistory 
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

genNextClOrdId  :{.state.clOrdCount+:1;:.state.clOrdCount};

// DEPTH
// ----------------------------------------------------------------------------------------------->

// Maintains a historic record of depth snapshots
// with the amount of levels stored dependent upon
// the config for the specified from the engine 
// i.e. The depth has been directly affected by 
// the agent.
DepthEventHistory: (
    [price:`long$();time:`datetime$()]
    side:`symbol$(); // change side to long
    size:`int$());
depthCols:cols DepthEventHistory;
CurrentDepth: `price xkey .state.DepthEventHistory;

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
    side            :   `symbol$()); // TODO change side to long
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
    side            :   `symbol$()); // todo change side to long
liquidationCols:cols LiquidationEventHistory;

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
SignalEventHistory: (
    [sigid:`long$(); time:`datetime$()]
    sigvalue        :   `float$()
    );

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
// TODO change to non-dictionary updates
// TODO Feature Etc.
// TODO change to list
// TODO maximum drift of current depth, 
InsertResultantEvents   :{[events]
    {[events]
        k:first events[`kind];
        c:first events[`cmd];

        events:flip[events];
        d:events[;`datum];
        t:events[`time];

        $[k=`DEPTH;[ // TODO delete from current depth
            l:flip[.state.depthCols!(d[;`price];t;d[;`side];0^d[;`size])];
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
          k=`SIGNAL;[
            `.state.SignalEventHistory upsert (
                [sigid:d[;`sigid];time:t]
                sigvalue:d[;`sigvalue]);
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

// TODO store features in log to do reverse feature selection!
getOBFeatures   :{

        ob update avg(bestBid,bestAsk) from .state.DepthEventHistory;
    };

// TODO construct observation getter
// TODO register obs in order and parse them , register parsed result and use that in get observations


// TODO get orderbook features
// TODO volatility, standard deviation, etc.
// TODO testing etc.
GetObservations    :{[aids; windowsize; step] // TODO configurable window size
        / interval: 

        // TODO add liquidation as feature.
        bp:select[-5] price from .state.CurrentDepth where side=`BUY; // TODO fill 0's
        ap:select[-5] price from .state.CurrentDepth where side=`SELL;

        // TODO add account id to feature vector
        pobs: raze raze'[( 
            10#0;
            exec last markprice from .state.MarkEventHistory;
            exec last fundingrate from .state.FundingEventHistory;
            value flip bp; // TODO fill 0's
            value flip ap;
            value flip select[-5] size from .state.TradeEventHistory where side=`BUY;
            value flip select[-5] size from .state.TradeEventHistory where side=`SELL;
            value flip select[5] size from `price xasc .state.CurrentDepth where side=`BUY;
            value flip select[5] size from `price xdesc .state.CurrentDepth where side=`SELL
        )];

        // TODO do uj
        // select by accountId, price from .state.CurrentOrders where price in raze[ap], otype=`LIMIT, status in `NEW`PARTIALFILLED, side=`SELL
        oobs: raze(
            exec leaves from 0^(ap uj select leaves from .state.CurrentOrders where price in raze[ap], otype=`LIMIT, status in `NEW`PARTIALFILLED, side=`SELL);
            exec leaves from 0^(ap uj select leaves from .state.CurrentOrders where price in raze[ap], otype=`LIMIT, status in `NEW`PARTIALFILLED, side=`SELL)
        );

        ac:select last balance, last available, last frozen, last maintMargin by accountId from .state.AccountEventHistory where accountId in aids;
        ivn:Piv[0!select last amt, last realizedPnl, last avgPrice, last unrealizedPnl by accountId,side from .state.InventoryEventHistory where accountId in aids;`accountId;`side;`amt`realizedPnl`avgPrice`unrealizedPnl];

        aobs:0!(ac uj ivn);
        aobs[(`$string[til[count[pobs]]])]:pobs;
        obs:(`accountId,(`$string(til[count[cols[aobs]]-1]))) xcol 0!aobs;
        obs[`step]:step;

        // if count feature buffer
        `.state.FeatureBuffer upsert (`accountId`step xkey obs);

        // TODO count by account id
        / $[(count .schema.FeatureBuffer)>maxBufferSize;]; // TODO make max buffer size configurable
        // TODO fill forward + normalize
        :1!(0^select from ungroup(.ml.minmaxscaler'[`accountId xgroup .state.FeatureBuffer]) where step=1);
        // obs[`accountId]!value'[`accountId`step _ obs]
    };

PrimeFeatures   :{[]

    };


// Reset State
// =====================================================================================>

// TODO persist episode state

ResetAgents   :{[aids]
    delete from `.state.AccountEventHistory where accountId in aids;
    delete from `.state.InventoryEventHistory where accountId in aids;
    delete from `.state.OrderEventHistory where accountId in aids;
    delete from `.state.CurrentOrders where accountId in aids;
    delete from `.state.FeatureBuffer where accountId in aids;
    };

Reset :{[config]
    delete from `.state.AccountEventHistory;
    delete from `.state.InventoryEventHistory;
    delete from `.state.OrderEventHistory;
    delete from `.state.CurrentOrders;
    delete from `.state.TradeEventHistory;
    delete from `.state.MarkEventHistory;
    delete from `.state.FundingEventHistory;
    delete from `.state.LiquidationEventHistory;
    delete from `.state.FeatureBuffer;
    };