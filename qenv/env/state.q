
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
    :select dlt:sum leaves by price from .state.OrderEventHistory where accountId=aId, status in `NEW`PARTIALFILLED, side=s, leaves>0;
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
    [liqid:`long$();time:`datetime$()]
    size            :   `long$();
    price           :   `long$();
    side            :   `symbol$());
liquidationCols:cols LiquidationEventHistory;

// TODO batching + 


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
getFeatureVectors    :{[accountIds]
        windSize:100;

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
            by side, 1 xbar `minute$time
            from .state.TradeEventHistory;

        ohlc:Piv[ohlc;`time;`side;`high`low`open`close`volume`msize`hsize`lsize`num];

        .qt.OHLC:ohlc;
        .qt.T:.state.TradeEventHistory;

        // TODO add long term prediction features.

        // TODO add account id to feature vector
        obs: raze(
            exec size from .state.CurrentDepth;
            value last ohlc;
            exec last markprice from .state.MarkEventHistory;
            exec last fundingrate from .state.FundingEventHistory;
            exec last price from .state.TradeEventHistory;
            value exec sum leaves, avg price from .state.CurrentOrders where otype=`LIMIT, status in `NEW`PARTIALFILLED, side=`SELL;
            value exec sum leaves, avg price from .state.CurrentOrders where otype=`LIMIT, status in `NEW`PARTIALFILLED, side=`BUY
        );

        .qt.O:obs;
        // if count feature buffer
        `.state.FeatureBuffer upsert obs;

        // TODO count by account id
        / $[(count .schema.FeatureBuffer)>maxBufferSize;]; // TODO make max buffer size configurable
        // TODO fill forward + normalize
        :.ml.minmaxscaler[-100#.state.FeatureBuffer];
    };


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
          ];
          k=`TRADE;[
              t:(
                [tid:d[;`tid];time:t]
                side:d[;`side];
                size:0^d[;`size];
                price:0^d[;`price]);
            .qt.T:t;
            .qt.D:d;
            show d;
            .qt.K:k;
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
                [liqId:`long$(); time:t]
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
