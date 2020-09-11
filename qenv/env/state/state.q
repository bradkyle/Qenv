\d .state

// State specifically represents a set of events that are derived from the engine
// TODO max history size

// TODO house state in its own process
// TODO prioritized experience replay
// TODO train test split with batches of given length (Hindsight experience replay/teacher student curriculum)

// COMMON COUNTERS
// =====================================================================================>
maxLvls:20;
DefaultInstrumentId:0;
.state.clOrdCount:0;
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
    amt                 :  `long$();
    realizedPnl         :  `long$();
    avgPrice            :  `long$(); // TODO check all exchanges have
    unrealizedPnl       :  `long$());
.state.inventoryCols:cols .state.InventoryEventHistory;
.state.CurrentInventory: `accountId`side xkey .state.InventoryEventHistory;

// Return all open positions for an account
.state.openInventory :{?[`.state.CurrentInventory;]};

// Return the amt of each inventory by side for account
.state.amtBySide     :{?[`.state.CurrentInventory;]};

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

// Get the current qtys at each order level
// .util.cond.isActiveAccountOrder
.state.ordQtyByPrice :{?[`.order.CurrentOrders]};

// Get the sum of the outstanding order qtys for each
// level by price
.state.lvlQtyByPrice :{?[`.order.CurrentOrders]};

// Derive the sum of the leaves qty/outstanding qty of
// orders for each price bucket provided for a specified
// agent. i.e.
// e.g. exponent price buckets:(0,1);(2,4),(5,10),(11,22)
// e.g. uniform price buckets:(0,1);(2,3),(4,5),(5,6)
.state.deriveBucketedQty  :{};

// Derive the set of limit orders that have drifted 
// outside of the observation bounds of the agent 
// such that they can be for instance cancelled.
.state.outBoundsOrders    :{};

// DEPTH
// ----------------------------------------------------------------------------------------------->

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

.state.derivelvlPrices            :{?[]};

// TODO add error handling
.state.derivePriceAtLvl           :{?[]};

.state.deriveBucketedPrices       :{};

.state.derivePriceAtBucket        :{?[]};

// Non-Essential Datums
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

.state.InsertEvents :{
    {
        k:x`kind;
        r:x`datum;
        $[
            k=0;[
                / .state.DepthEventHistory,:r;
                .state.CurrentDepth,:r;
            ]; // DEPTH
            k=1;[.state.TradeEventHistory,:r]; // TRADE
            k=2;[.state.MarkEventHistory,:r]; // MARK
            k=3;[.state.LiquidationEventHistory,:r]; // LIQUIDATION
            k=4;[.state.FundingEventHistory,:r]; // FUNDING
            k=5;[.state.SettlementHistory,:r]; // SETTLEMENT
            k=6;[
                / .state.AccountEventHistory,:r;
                .state.CurrentAccount,:r; 
            ]; // ACCOUNT
            k=7;[
                / .state.InventoryEventHistory,:r;
                .state.CurrentInventory,:r;
            ]; // INVENTORY
            k=8;[
                / .state.OrderEventHistory,:r;
                .state.CurrentOrders,:r; 
            ]; // ORDER
            k=9;[.state.PriceLimitHistory,:r]; // PRICELIMIT
            k=16;[.state.SignalEventHistory,:r]; // SIGNAL
            'INVALID_EVENT_KIND
        ];
    }'[0!(`kind xgroup x)];
    };


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

Reset :{[config]
    .util.table.dropAll[(`.state.AccountEventHistory,
            `.state.InventoryEventHistory,
            `.state.OrderEventHistory,
            `.state.CurrentDepth,
            `.state.DepthEventHistory,
            `.state.TradeEventHistory,
            `.state.MarkEventHistory,
            `.state.FundingEventHistory,
            `.state.LiquidationEventHistory,
            `.state.FeatureBuffer)];

    .state.FeatureBuffer:();

    // TODO setup features 
    };