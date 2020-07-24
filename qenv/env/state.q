
\l order.q
\l engine.q
\l util.q
\d .state


// TODO prioritized experience replay
// TODO train test split with batches of given length (Hindsight experience replay/teacher student curriculum)

// Singleton State and Lookback Buffers
// =====================================================================================>
// The lookback buffers attempt to build a realistic representation of what the
// agent will percieve in a real exchange.

// The following tables maintain a local state buffer 
// representative of what the agent will see when
// interacting with a live exchange. 
AccountEventHistory: (
    [accountId          : `long$()]
    balance             : `float$();
    available           : `float$();
    frozen              : `float$();
    maintMargin         : `float$();
    time                : `datetime$()
    );
accountCols:`accountId`balance`available`frozen`maintMargin`time;

// Maintains a historic and current record of the 
// positions (Inventory) each agent has held and
// subsequently provides agent specific details
// therin
InventoryEventHistory: (
    accountId           :  `long$();
    side                :  `.inventory.POSITIONSIDE$();
    currentQty          :  `long$();
    realizedPnl         :  `long$();
    unrealizedPnl       :  `long$();
    time                : `datetime$()
    );
inventoryCols:`accountId`side`currentQty`realizedPnl`unrealizedPnl`time;

// Maintains a historic and current record of orders
// that the engine has produced.
OrderEventHistory: (
    [orderId        :   `long$()]
    accountId       :   `long$();
    side            :   `.order.ORDERSIDE$();
    otype           :   `.order.ORDERTYPE$();
    leaves          :   `long$();
    filled          :   `long$();
    limitprice      :   `long$(); / multiply by 100
    stopprice       :   `long$(); / multiply by 100
    status          :   `.order.ORDERSTATUS$();
    time            :   `datetime$();
    isClose         :   `boolean$();
    trigger         :   `.order.STOPTRIGGER$();
    execInst        :   `.order.EXECINST$();
    time                : `datetime$()
    );

// Maintains a historic record of depth snapshots
// with the amount of levels stored dependent upon
// the config for the specified from the engine 
// i.e. The depth has been directly affected by 
// the agent.
DepthEventHistory: (
    time            :   `datetime$();
    
    );

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
TradeEventHistory: (
    size            :   `float$();
    price           :   `float$();
    side            :   `.order.ORDERSIDE$();
    time            :   `datetime$()
    );
tradeCols:`size`price`side`time;

// TODO batching + 

// Maintains a lookback buffer of 
// aggregations of state including
// state that has not been modified 
// by the engine per accountId
// sorted by time for which normalization
// and feature scaling that requires more
// than a single row can be done. 
FeatureBuffer   :(

    );

// The step buffer maintains a set of observation ids,
// rewards, info etc for prioritized experience replay
// diagnostics etc.
StepBuffer  :(

    );

// Recieves a table of events from the engine 
// and proceeds to insert them into the local historic buffer
InsertResultantEvents   :{[events]
    {[event]
        k:event[`kind];
        event[`datum][`time]:event[`time]
        $[
            k=`DEPTH;
            [
                `.state.DepthEventHistory insert () // TODO
            ];
            k=`TRADE;
            [`.state.TradeEventHistory upsert (.state.tradeCols!(event[`datum][.state.tradeCols]))];
            k=`ACCOUNT_UPDATE;
            [`.state.AccountEventHistory upsert (.state.accountCols!(event[`datum][.state.accountCols]))];
            k=`INVENTORY_UPDATE;
            [`.state.AccountEventHistory upsert (.state.inventoryCols!(event[`datum][.state.inventoryCols]))];
            k=`ORDER_UPATE`NEW_ORDER`ORDER_DELETED;
            [`.state.AccountEventHistory upsert (.state.inventoryCols!(event[`datum][.state.inventoryCols]))]; 
        ];
    } each events;
    };


