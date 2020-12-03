
// State specifically represents a set of events that are derived from the engine
// TODO max history size

// TODO house state in its own process
// TODO prioritized experience replay
// TODO train test split with batches of given length (Hindsight experience replay/teacher student curriculum)

// COMMON COUNTERS
// =====================================================================================>
.state.maxLvls:20;
.state.DefaultInstrumentId:0;
.state.clOrdCount:0;
.state.watermark:0N;
/ .state.genNextClOrdId  :.util.IncRet[`.state.clOrdCount];

// Singleton State and Lookback Buffers
// =====================================================================================>
// The lookback buffers attempt to build a realistic representation of what the
// agent will percieve in a real exchange.


// ACCOUNT
// ----------------------------------------------------------------------------------------------->

// The following tables maintain a local state buffer 
// representative of what the agent will see when
// interacting with a live exchange. 
.state.AccountEventHistory: (
    [accountId : `long$(); time : `datetime$()]
    balance             : `long$();
    available           : `long$();
    frozen              : `long$();
    maintMargin         : `long$());
.state.accountCols:cols .state.AccountEventHistory;
.state.CurrentAccount: `accountId xkey .state.AccountEventHistory;

// TODO liqudiation price?

// INVENTORY
// ----------------------------------------------------------------------------------------------->

// Maintains a historic and current record of the 
// positions (Inventory) each agent has held and
// subsequently provides agent specific details
// therin
.state.InventoryEventHistory: ( // TODO change side to long 1,2,3
    [accountId:  `long$();side: `long$();time : `datetime$()]
    isignum             :  `long$();
    amt                 :  `long$();
    realizedPnl         :  `long$();
    avgPrice            :  `long$(); // TODO check all exchanges have
    unrealizedPnl       :  `long$());
.state.inventoryCols:cols .state.InventoryEventHistory;
.state.CurrentInventory: `accountId`side xkey .state.InventoryEventHistory;

// Return all open positions for an account
.state.allOpenInventory            :{[aId]
    ?[`.state.CurrentInventory;enlist(=;`accountId;aId);0b;()]
    };

// Return all open positions for an account
.state.sideOpenInventory        :{[aId;side]
    ?[`.state.CurrentInventory;((=;`accountId;aId);(=;`side;side));0b;()]
    };

// Return the amt of each inventory by side 
// for each account account
.state.amtBySide                :{[aId;side] // TODO test
    raze[?[`.state.CurrentInventory;((=;`accountId;aId);(=;`side;side));();`amt]]
    };

.state.getShortAmt              :{[aId]
    amt:.state.amtBySide[aId;-1];
    $[count[amt]>0;amt;0f]
    };

.state.getLongAmt               :{[aId]
    amt:.state.amtBySide[aId;-1];
    $[count[amt]>0;amt;0f]
    };

// Liquidation 
// ------------------------------------------>

// TODO
// Returns the approximate price at which liquidation 
// of an account's inventory would have occurred
/ .state.getLiquidationPrice      :{[aId] // TODO
/     .util.contract.linear.LiquidationPrice[];
/     };

/ // Retrurns the price at which a given loss
/ // amount (upnl) would have occurred
/ .state.getPriceByLossAmt        :{[aId;] // TODO

/     };

/ // Returns the price at which a given loss
/ // fraction would have occurred
/ .state.getPriceByLossFraction   :{[aId;] // TODO

/     };

// ORDERS
// ----------------------------------------------------------------------------------------------->

.state.OrderEventHistory: (
    [orderId:`long$();time:`datetime$()]
    accountId       :   `long$();
    side            :   `long$(); // TODO change to long
    otype           :   `long$(); // TODO change to long
    price           :   `long$();
    leaves          :   `long$();
    limitprice      :   `long$(); / multiply by 100
    stopprice       :   `long$(); / multiply by 100
    status          :   `long$();
    reduce          :   `boolean$();
    trigger         :   `long$(); // TODO change to long
    execInst        :   `long$()); // TODO change to long
.state.ordCols:cols .state.OrderEventHistory;
.state.CurrentOrders: `orderId xkey .state.OrderEventHistory;

// Generates the next unique client order id
.state.genNextClOrdId               :{
    :(.state.clOrdCount+:1);
    };

// By Price Level
// ----------------------------------------------------------------------->

// Get the current qtys at each order level
// .util.cond.isActiveAccountOrder
.state.limitLeavesByPrice                :{[aId;side;prices]
    ?[`.state.CurrentOrders;(
        (=;`accountId;aId);
        (=;`side;side);
        (=;`otype;1);
        (in;`price;prices)
    );enlist[`price]!enlist[`price];(sum;`leaves)]
    };

// Get the current qtys at each order level
// .util.cond.isActiveAccountOrder
.state.stopLeavesByPrice                :{[aId;side;prices]
    ?[`.state.CurrentOrders;(
        (=;`accountId;aId);
        (=;`side;side);
        (in;`otype;(2 3));
        (in;`price;prices)
    );enlist[`price]!enlist[`price];(sum;`leaves)]
    };


// By Price Bucket
// ----------------------------------------------------------------------->

// Get the current qtys at each order level
// .util.cond.isActiveAccountOrder
// @param x: price buckets. // TODO active orders // TODO remove out of bounds orders
.state.limitLeavesByBucket              :{[aIds;bkts;side] // TODO join to orig bkts
    bkts:asc distinct raze bkts;

    grp:$[count[aIds]>0;[
        `accountId`bkt`side`reduce!(
            `accountId;
            (bin;bkts;($;9h;`price));
            `side;
            `reduce
        )
    ];[
        `bkt`side`reduce!(
            (bin;bkts;($;9h;`price));
            `side;
            `reduce)
    ]];
    ?[`.state.CurrentOrders;(
        ($[count[aIds]>0;in;=];`accountId;aIds);
        (=;`side;side);
        (=;`otype;1)
    );
    grp;
    enlist[`leaves]!enlist(sum;`leaves)]
    };

// Get the current qtys at each order level
// .util.cond.isActiveAccountOrder // TODO active orders
.state.stopLeavesByBucket              :{[aId;bkts;side] // TODO join to orig bucket
    bkts:asc distinct raze bkts;
    ?[`.state.CurrentOrders;(
        (=;`accountId;aId);
        (=;`side;side);
        (in;`otype;(2 3))
    );
    `bkt`side`reduce!(
        (bin;bkts;($;9h;`price));
        `side;
        `reduce
    );(sum;`leaves)]
    };


// DEPTH
// ----------------------------------------------------------------------------------------------->

// TODO simulate out of sync depth udates
// Maintains a historic record of depth snapshots
// with the amount of levels stored dependent upon
// the config for the specified from the engine 
// i.e. The depth has been directly affected by 
// the agent.
.state.DepthEventHistory: (
    [price:`long$();time:`datetime$()]
    side:`long$(); // change side to long
    size:`int$());
.state.depthCols:cols .state.DepthEventHistory;
.state.CurrentDepth: `price xkey .state.DepthEventHistory;
  
.state.bestAskPrice                :{
    ?[`.state.CurrentDepth;enlist(=;`side;-1);();(min;`price)]
    };

.state.bestBidPrice                :{
    ?[`.state.CurrentDepth;enlist(=;`side;1);();(max;`price)]
    };

.state.bestSidePrice                :{[side]
    $[side>0;.state.bestBidPrice[];.state.bestAskPrice[]]
    };

// Get the current qtys at each order level
// .util.cond.isActiveAccountOrder
// @param x: price buckets.
// Get the current qtys at each order level
// .util.cond.isActiveAccountOrder
// @param x: price buckets.
.state.bucketedDepth              :{[pbkts;side] // TODO join to orig bkts
    bkts:asc distinct raze pbkts;
    :(?[`.state.CurrentDepth;enlist(=;`side;side);
     `bkt`side!((bin;bkts;($;9h;`price));`side)
    ;enlist[`size]!enlist(sum;`size)]);
    };
    
// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
.state.ExecutionEventHistory: (
    [eid:`long$(); time:`datetime$()]
    accountId       :   `long$();
    size            :   `long$();
    price           :   `long$();
    side            :   `long$()); // TODO change side to long
.state.execCols:cols .state.ExecutionEventHistory;

// Trade History
// ----------------------------------------------------------------------------------------------->

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
.state.TradeEventHistory: (
    [tid:`long$(); time:`datetime$()]
    size            :   `long$();
    price           :   `long$();
    side            :   `long$()); // TODO change side to long
.state.tradeCols:cols .state.TradeEventHistory;

// Non-Essential Datums
// ----------------------------------------------------------------------------------------------->

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
.state.MarkEventHistory: (
    [time            :   `datetime$()]
    markprice        :   `long$());
.state.markCols:cols .state.MarkEventHistory;

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
.state.FundingEventHistory: (
    [time            :   `datetime$()]
    fundingrate      :   `float$();
    fundingtime      :   `datetime$());
.state.fundingCols:cols .state.FundingEventHistory;

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
.state.LiquidationEventHistory: (
    [liqid:`long$(); time:`datetime$()]
    size            :   `long$();
    price           :   `long$();
    side            :   `long$()); // todo change side to long
.state.liquidationCols:cols .state.LiquidationEventHistory;

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
.state.SignalEventHistory: (
    [sigid:`long$(); time:`datetime$()]
    sigvalue        :   `float$());

// TODO failure event history!
// TODO prune, execution event history
.state._InsertEvents :{ 
    / show .state.CurrentDepth;
    {
        k:x`kind;
        r:x`datum;
        $[
            k=`depth;[
                / .state.DepthEventHistory,:r;
                .state.CurrentDepth,:r;
            ]; // DEPTH
            k=`trade;[.state.TradeEventHistory,:r]; // TRADE
            k=`mark;[.state.MarkEventHistory,:r]; // MARK
            k=`liquidation;[.state.LiquidationEventHistory,:r]; // LIQUIDATION
            k=`funding;[.state.FundingEventHistory,:r]; // FUNDING
            k=`settlement;[.state.SettlementHistory,:r]; // SETTLEMENT
            k=`account;[
                .state.AccountEventHistory,:r;
                .state.CurrentAccount,:r; 
                // TODO pruning
            ]; // ACCOUNT
            k=`inventory;[
                / .state.InventoryEventHistory,:r;
                .state.CurrentInventory,:r;
            ]; // INVENTORY
            k=`order;[
                / .state.OrderEventHistory,:r;
                .state.CurrentOrders,:r; 
            ]; // ORDER
            k=`pricerange;[.state.PriceLimitHistory,:r]; // PRICELIMIT
            k=`fill;[.state.ExecutionEventHistory,:r]; // PRICELIMIT
            / k=15;[.state.FailureEventHistrory,:r]; // ERROR
            'INVALID_EVENT_KIND
        ];
    }'[0!(`kind xgroup x)];

    // watermark: select last time from events
    .state.watermark:max x`time;
    };

.state.InsertEvents: {@[.state._InsertEvents;x;show]};

// Feature Extraction and Derivation
// =====================================================================================>

// Is a list / Table that is used to hold
// a lookback buffer of aggregated features
// over which normalization can be done before
// passing the observations to the agent.
.state.FeatureBuffer   :();


// Reset State
// =====================================================================================>

// TODO persist episode state

.state.Reset :{[config]
    .util.table.dropAll[(`.state.AccountEventHistory,
            `.state.InventoryEventHistory,
            `.state.OrderEventHistory,
            `.state.CurrentDepth,
            `.state.DepthEventHistory,
            `.state.ExecutionEventHistory,
            `.state.TradeEventHistory,
            `.state.MarkEventHistory,
            `.state.FundingEventHistory,
            `.state.LiquidationEventHistory,
            `.state.FeatureBuffer)];

    .state.FeatureBuffer:();

    // TODO setup features 
    };
