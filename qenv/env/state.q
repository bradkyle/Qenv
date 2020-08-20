
\l util.q
\d .state


// TODO prioritized experience replay
// TODO train test split with batches of given length (Hindsight experience replay/teacher student curriculum)
maxLvls:20;


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
    balance             : `float$();
    available           : `float$();
    frozen              : `float$();
    maintMargin         : `float$()
    );


// INVENTORY
// ----------------------------------------------------------------------------------------------->

// Maintains a historic and current record of the 
// positions (Inventory) each agent has held and
// subsequently provides agent specific details
// therin
InventoryEventHistory: (
    [inventoryId : `long$();time : `datetime$()]
    accountId           :  `long$();
    side                :  `symbol$();
    currentQty          :  `long$();
    realizedPnl         :  `long$();
    avgPrice            :  `long$(); // TODO check all exchanges have
    unrealizedPnl       :  `long$());


// Return all open positions for an account
getOpenPositions              :{[accountId]
    :(select from .state.InventoryEventHistory where accountId=accountId);
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
    [orderId        :   `long$()]
    accountId       :   `long$();
    side            :   `symbol$();
    otype           :   `symbol$();
    price           :   `long$();
    leaves          :   `long$();
    filled          :   `long$();
    limitprice      :   `long$(); / multiply by 100
    stopprice       :   `long$(); / multiply by 100
    status          :   `symbol$();
    time            :   `datetime$();
    isClose         :   `boolean$();
    trigger         :   `symbol$();
    execInst        :   `symbol$());


// Get the current qtys at each order level
getCurrentOrderQtysByPrice        :{[accountId;numAskLvls;numBidLvls]
    :exec sum leaves by price from .state.OrderEventHisory 
        where accountId=accountId, state=`NEW`PARTIALLYFILLED, otype=`LIMIT;
    };


getOrders   :{
    select qty:sum leaves by price from .state.OrderEventHistory 
        where accountId=x, status in `NEW`PARTIALFILLED, side=`BUY, leaves>0;    
    };


// DEPTH
// ----------------------------------------------------------------------------------------------->

/`.state.CurrentDepth upsert ([]price:(1000+til 20),(1000-til 20);side:(20#`SELL),(20#`BUY);size:40#1000)
CurrentDepth:(
    [price:`long$()]
    side:`symbol$();
    size:`long$());

// Maintains a historic record of depth snapshots
// with the amount of levels stored dependent upon
// the config for the specified from the engine 
// i.e. The depth has been directly affected by 
// the agent.
DepthEventHistory: (
    time:`datetime$();
    intime:`datetime$();
    side:`symbol$();
    price:`int$();
    size:`int$());


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
    size            :   `float$();
    price           :   `float$();
    side            :   `symbol$();
    time            :   `datetime$());

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
MarkEventHistory: (
    size            :   `float$();
    price           :   `float$();
    side            :   `symbol$();
    time            :   `datetime$());

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
FundingEventHistory: (
    size            :   `float$();
    price           :   `float$();
    side            :   `symbol$();
    time            :   `datetime$());

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
LiquidationEventHistory: (
    size            :   `float$();
    price           :   `float$();
    side            :   `symbol$();
    time            :   `datetime$());

// TODO batching + 

// Maintains a lookback buffer of 
// aggregations of state including
// state that has not been modified 
// by the engine per accountId
// sorted by time for which normalization
// and feature scaling that requires more
// than a single row can be done. 
/ FeatureBuffer   :(

/     );

// The step buffer maintains a set of observation ids,
// rewards, info etc for prioritized experience replay
// diagnostics etc.
/ StepBuffer  :(

/     );

// Recieves a table of events from the engine 
// and proceeds to insert them into the local historic buffer
InsertResultantEvents   :{[events]
    {[event]
        k:event[`kind];
        t:event[`time];
        $[k=`DEPTH;
          [`.state.DepthEventHistory insert (.state.depthCols!(event[`datum][.state.depthCols])];
          k=`TRADE;
          [`.state.TradeEventHistory upsert (.state.tradeCols!(event[`datum][.state.tradeCols]))];
          k=`ACCOUNT;
          [`.state.AccountEventHistory upsert (.state.accountCols!(event[`datum][.state.accountCols]))];
          k=`INVENTORY;
          [`.state.InventoryEventHistory upsert (.state.inventoryCols!(event[`datum][.state.inventoryCols]))];
          k=`ORDER;
          [`.state.AccountEventHistory upsert (.state.orderCols!(event[`datum][.state.orderCols]))]; 
          k=`LIQUIDATION;
          [`.state.LiquidationHistory upsert (.state.inventoryCols!(event[`datum][.state.inventoryCols]))]; 
          [0N]];
    } each events;
    };

Advance :{[]

    };