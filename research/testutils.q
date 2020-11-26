
l: `long$
z:.z.z;
sc:{x+(`second$y)};
sn:{x-(`second$y)};
sz:sc[z];
snz:sn[z];
dts:{(`date$x)+(`second$x)};
dtz:{dts[sc[x;y]]}[z]
doz:`date$z;
dozc:{x+y}[doz];


// TODO fix comments
// TODO pipe utils, ingress, egress etc.

// Error checking utils
// -------------------------------------------------------------->

.util.testutils.checkErr            :{[fn;args;err;case]
        $[count[err]>0;[
            .qt.AT[fn; args; err; ""; case];
        ];[
            :fn[args];
        ]];
    };

// Mock generation and checking utils
// -------------------------------------------------------------->

// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeMockParams     :{[ref;args]
    
    };       


// TODO add additional logic
// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkMock           :{[x;y;z]
        .qt.MA[x;y[0];y[1];y[2];z];
    };


// Make Test Data Utils
// -------------------------------------------------------------->

// TODO make default Events

// The following function takes a reference to a table,
// and a set of columns (cl) and values (vl).
// It generates a null row, if the value count is greater
// than 1 it repeats the row x times and fills the respective
// columns provided by cl with the respective values provided
// by vl
/  @param ref (Symbol) The symbol reference to the table
/  @param cl (List[Symbol]) The list of symbols indicating columns
/  @param vl (List[List[Any]]) The list of lists to populate with. 
.util.testutils.makeDefaultsRecords  :{[ref;cl;vl] // TODO inter with actual cols
    r:.util.NullRowDict[ref];
    cvl:count[vl]; 
    :$[cvl>1;[rx:(cvl#enlist[r]);rx[cl]:flip[vl];:rx];[r[cl]:first[vl];:r]]};

// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeDepthUpdates    :{[]

    };


// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeOrderBook      :{[cl;vl]
    $[count[vl]>0;.util.testutils.makeDefaultsRecords[`.engine.model.orderbook.OrderBook;cl;vl];()]
    };


// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeOrders          :{[cl;vl]
    $[count[vl]>0;.util.testutils.makeDefaultsRecords[`.engine.model.order.Order;cl;vl];()]
    };

// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeAccounts        :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.engine.model.account.Account;cl;vl]
    };


// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeInventories     :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.engine.model.inventory.Inventory;cl;vl]
    };


// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeInstruments     :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.engine.model.instrument.Instrument;cl;vl]
    };


// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeEvents          :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.common.event.Event;cl;vl]
    };

// Check Utils
// -------------------------------------------------------------->


// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils._checkOrders         :{[cl;vl;case] // TODO if provided orders are not table
        $[count[vl]>0;[
            eOrd:$[type[vl] in (99 98h);vl;.util.testutils.makeOrders[vl;cl]];
            if[count[eOrd]>0;[
                cl:$[count[cl]>0;cl;cols[eOrd]];
                .order.test.eOrd:eOrd;
                eord:.[0!;enlist eOrd;eOrd];
                if[count[eOrd]>count[first eOrd];eOrd:enlist eOrd]; // TODO fix bad
                rOrd: select from .engine.model.order.Order where orderId in ((),eOrd[`orderId]);
                .order.test.rOrd:rOrd;
                .qt.A[count[rOrd];=;count[eOrd];"order count";case]; // TODO check
                .qt.A[(cl#0!rOrd);~;(cl#eOrd);"orders";case]; // TODO check
                ]];
            ];[]];
    };
.util.testutils.checkOrders:.util.testutils._checkOrders[()];

// Checks that the .engine.model.orderbook.OrderBook table matches the OrderBook
// that are provided.
/  @param x (OrderBook/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils._checkDepth           :{[cl;vl;case]
        $[count[vl]>0;[
            eBook:$[type[vl]=99h;vl;.util.testutils.makeOrderBook[vl;cl]];
            if[count[eBook]>0;[
                cl:$[count[cl]>0;cl;cols[eBook]];
                rBook:.engine.model.orderbook.OrderBook;
                // TODO order
                .qt.A[count[eBook];=;count[rBook];"orderBook lvl count";case]; // TODO check
                .qt.A[(cl#0!rBook);~;(cl#0!eBook);"orderBook";case]; // TODO check
            ]];
        ];[]];
    };
.util.testutils.checkDepth:.util.testutils._checkDepth[()];

// Checks that the .engine.model.instrument.Instrument table matches the Instrument
// that are provided.
/  @param x (Instrument/List) The instrument that is to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkInstrument         :{
        eIns:$[type[x]=99h;x;.util.testutils.makeInstruments[x;z]];
        if[count[eIns]>0;[
            rIns:.engine.model.instrument.Instrument;
            .qt.A[count[eIns];=;count[rIns];"instrument count";y]; // TODO check
            .qt.A[(y#0!rIns);~;(y#0!eIns);"instrument";y]; // TODO check
            ]];
    };

// Checks that the .common.event.Event table matches the events
// that are provided.
/  @param x (Events/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkEvents         :{
        eEvents:$[type[x]=99h;x;.util.testutils.makeEvents[x;z]];
        if[count[eEvents]>0;[
            rEvents:.common.event.Event;
            .qt.A[count[eEvents];=;count[rEvents];"event count";y]; // TODO check
            .qt.A[(y#0!rEvents);~;(y#0!eEvents);"event";y]; // TODO check
            ]];
    };

// TODO test account
// Checks that the .engine.model.account.Account table matches the accounts
// that are provided.
/  @param x (Account/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkAccount       :{
        eAcc:$[type[x]=99h;x;.util.testutils.makeAccounts[x;z]];
        if[count[eAcc]>0;[
            rAcc:.engine.model.account.Account;
            .qt.A[count[eAcc];=;count[rAcc];"account count";y]; // TODO check
            .qt.A[(y#0!rAcc);~;(y#0!eAcc);"account";y]; // TODO check
            ]];
    };

// Checks that the .engine.model.inventory.Inventory table matches the inventory
// that are provided.
/  @param x (Inventory/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkInventory       :{
        eInv:$[type[x]=99h;x;.util.testutils.makeInvounts[x;z]];
        if[count[eInv]>0;[
            rInv:.engine.model.inventory.Inventory;
            .qt.A[count[eInv];=;count[rInv];"inventory count";y]; // TODO check
            .qt.A[(y#0!rInv);~;(y#0!eInv);"inventory";y]; // TODO check
            ]];
    };


// Checks that the .liquidation.Liquidation table matches the liquidations
// that are provided.
/  @param x (Inventory/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkLiquidation       :{
        eLiq:$[type[x]=99h;x;.util.testutils.makeLiquidation[x;z]];
        if[count[eLiq]>0;[
            rLiq:.liqudidation.Liquidation;
            .qt.A[count[eLiq];=;count[rLiq];"liqudidation count";y]; // TODO check
            .qt.A[(y#0!rLiq);~;(y#0!eLiq);"liquidation";y]; // TODO check
            ]];
    };


.util.testutils.checkStateTable     :{
    'NOTIMPLEMENTED
    };


// Common Reset/Teardown Functions
// -------------------------------------------------------------->

// Resets the all the tables used in the engine.
.util.testutils.resetEngineTables      :{
    .util.table.dropAll[(`.engine.model.order.Order`.engine.model.orderbook.OrderBook,
                `.engine.model.instrument.Instrument`.engine.model.account.Account,
                `.inventory.Inventory`.event.Event)];
    };

// Resets all the tables used in maintaining State
.util.testutils.resetStateTables      :{
    .util.table.dropAll[(`.state.AccountEventHistory,
            `.state.InventoryEventHistory,
            `.state.OrderEventHistory,
            `.state.CurrentDepth,
            `.state.DepthEventHistory,
            `.state.TradeEventHistory,
            `.state.MarkEventHistory,
            `.state.FundingEventHistory,
            `.state.LiquidationEventHistory)];
    };



// Default function that runs before each Unit test etc.
.util.testutils.defaultBeforeEach               :{};

// Default function that runs after each Unit test etc.
.util.testutils.defaultAfterEach                :{};

.util.testutils.defaultEngineHooks             :(
    {
        .util.testutils.resetEngineTables[];
        / .engine.model.account.Account,:.util.testutils.defaultAccounts;
        / .engine.model.instrument.Instrument,:.util.testutils.defaultInstrument;
    };
    {
        .qt.RestoreMocks[];
        .util.testutils.resetEngineTables[];
    };{};{});


.util.testutils.defaultPipeHooks                :({};{};{};{});

.util.testutils.defaultContractHooks            :({};{};{};{});

// Make random event utils
// -------------------------------------------------------------->

.util.testutils.genTrades        :{

    };

.util.testutils.genOrderBook    :{
    0^.util.testutils.makeOrderBook[
        `price`side`size`vqty;
        ({(1000-x;$[(x<25);-1;1];100;100)}'[til[50]])]
    };

.util.testutils.genInventory     :{

    };

.util.testutils.genAccount       :{
    0^.util.testutils.makeAccounts[
        `accountId`balance`available;
        ({(x;100;100)}'[til[3]])]
    };

.util.testutils.genMarks        :{
    0^.util.testutils.makeAccounts[
        `accountId`balance`available;
        ({(x;100;100)}'[til[3]])]
    };

.util.testutils.genInstrument           :{
    .util.testutils.makeInstruments[
        `instrumentId`faceValue`maxLeverage;
        ({(x;1;100)}'[til 2])]
    };   

.util.testutils.genOrders        :{
       .util.testutils.makeOrders[
        `orderId`accountId`instrumentId`price`side`leaves`offset`reduce`time`status`otype`size;
        ({(x;(`.engine.model.account.Account!$[(x mod 2)=0;0;1]);
            (`.engine.model.instrument.Instrument!0);
            floor[1000-(x%3)];$[(x<25);-1;1];100;
            (((x+2) mod 3)*110);
            0b;
            .tz;0;1;100)
        }'[til[50]])]
    };


.util.testutils.genEvents        :{
    
    .util.testutils.makeEvents[`time`intime`kind`cmd`datum;()]
    };

// Random Engine Generation
// -------------------------------------------------------------->

.util.testutils.genRandomEngine      :{

    };



// Table Setup logic
// -------------------------------------------------------------->


.util.testutils.setupOrderbook      :{
    if[count[x]>0;[.engine.model.orderbook.OrderBook,:(0^x)]];
    };

.util.testutils.setupDepth:.util.testutils.setupOrderbook;

.util.testutils.setupOrders         :{
    if[count[x]>0;[
        .engine.model.order.Order,:{ 
            x[`reduce]:`boolean$(x[`reduce]);
            x}(0^x);
        ]];
        .engine.model.order.ordercount:count .engine.model.order.Order;
    };

.util.testutils.setupAccount        :{
    
    };

.util.testutils.setupInventory      :{

    };

.util.testutils.setupInstrument     :{

    };

.util.testutils.setupLiquidation    :{

    };

.util.testutils.setupState          :{

    };


// More default utils
// -------------------------------------------------------------->

.util.testutils.defaultAccounts:.util.testutils.genAccount[];
.util.testutils.defaultAccount:first .util.testutils.defaultAccounts;
.util.testutils.defaultAccountID:.util.testutils.defaultAccount`accountId;
.util.testutils.defaultInstruments:.util.testutils.genInstrument[];
.util.testutils.defaultInstrument:first .util.testutils.defaultInstruments;
.util.testutils.defaultInstrumentID:.util.testutils.defaultInstrument`instrumentId;
.util.testutils.defaultRiskTier:.common.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f;
        1000000     0.01     0.02     50f;
        5000000     0.025    0.05     20f;
        20000000    0.05     0.1      10f;
        50000000    0.1      0.20     5f;
        100000000   0.125    0.25     4f;
        200000000   0.15     0.333    3f;
        500000000   0.25     0.50     2f;
        500000000   0.25     1.0      1f
    )];

.util.testutils.defaultFeeTier: .common.instrument.NewFeeTier[(
        50      0.0006    0.0006    0  0 600f;
        500     0.00054   0.0006    0  0 600f;
        1500    0.00048   0.0006    0  0 600f;
        4500    0.00042   0.0006    0  0 600f;
        10000   0.00042   0.00054   0  0 600f;
        20000   0.00036   0.00048   0  0 600f;
        40000   0.00024   0.00036   0  0 600f;
        80000   0.00018   0.000300  0  0 600f;
        150000  0.00012   0.00024   0  0 600f
    )];


// More default utils
// -------------------------------------------------------------->
.util.testutils.revertOrderBook     :{
    delete from `.engine.model.orderbook.OrderBook;
    };

.util.testutils.revertOrders        :{
    delete from `.engine.model.order.Order;
    };  

.util.testutils.revertAccount       :{
    delete from `.engine.model.account.Account;
    };

.util.testutils.revertInventory     :{
    delete from `.engine.model.inventory.Inventory;
    };

.util.testutils.revertInstrument    :{
    delete from `.engine.model.instrument.Instrument;
    };

  

.engine.model.instrument.test.riskCols:`mxamt`mmr`imr`maxlev;
.engine.model.instrument.test.riskTiers               : flip[.engine.model.instrument.test.riskCols!flip[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f;
        1000000     0.01     0.02     50f;
        5000000     0.025    0.05     20f;
        20000000    0.05     0.1      10f;
        50000000    0.1      0.20     5f;
        100000000   0.125    0.25     4f;
        200000000   0.15     0.333    3f;
        500000000   0.25     0.50     2f;
        500000000   0.25     1.0      1f)]];



// Services
// ------------------------------------------------------->
.engine.model.instrument.test.Instrument            :(
        [instrumentId           : enlist 0];
        state                   : enlist 0;
				contractType       		  : enlist 0;

        // Price limit values 
        upricelimit             : enlist 1000;
        lpricelimit             : enlist 100;

        // Min/Max values
        minPrice             : enlist 0;  
        maxPrice             : enlist 100000;
        minSize              : enlist 0;
        maxSize              : enlist 1000000000;

        // Tick, lot and face size
        tickSize             : enlist 1;
        lotSize              : enlist 1;
        faceValue            : enlist 1;
        
        // Multipliers 
        priceMultiplier      : enlist 100;
        sizeMultiplier       : enlist 1000;

        // UpdatedPublicValues 
        bestBidPrice         : enlist 500;
        bestAskPrice         : enlist 501;
        lastPrice            : enlist 500;
        midPrice             : enlist 500;
        markPrice            : enlist 500;
        hasLiquidityBuy      : enlist 1b;
        hasLiquiditySell     : enlist 1b
        
        // Funding 

        // Settlement

        
    );

.engine.model.orderbook.test.OrderBook           :(
    [price      :enlist 0]     // price
    side        :enlist 0;  // side
    qty         :enlist 0; // data qty
    hqty        :enlist 0; // hidden qty  (only for data depth updates)
    iqty        :enlist 0; // iceberg qty (only for agent orders)
    vqty        :enlist 0);

// Visible qty (including order qty)=(qty+displayqty)
.engine.model.account.test.Account                 :(
    [accountId          : enlist 0] 
    balance             : enlist 0; 
    available           : enlist 0;
    frozen              : enlist 0;

    // Private Behavior Settings 
    initMarginReq       : enlist 0f; 
    maintMarginReq      : enlist 0f;
    
    // Public Behavior settings
    marginType          : enlist 0; 
    positionType        : enlist 0; 
    leverage            : enlist 1; 
    
    // Order Margin & Premium Values
    orderMargin         : enlist 0; 
    openBuyQty          : enlist 0; 
    openBuyLoss         : enlist 0; 
    openBuyValue        : enlist 0; 
    openBuyMargin       : enlist 0; 
    openSellLoss        : enlist 0; 
    openSellValue       : enlist 0; 
    openSellQty         : enlist 0; 
    openSellMargin      : enlist 0; 
    openLoss            : enlist 0; 
    openOrderValue      : enlist 0; 

    // Position Margin & Pnl Values
    posMargin           : enlist 0; 
    longMargin          : enlist 0; 
    shortMargin         : enlist 0; 
    valueInMarket       : enlist 0; 

    // Accumultators
    depositAmount       : enlist 0; 
    depositCount        : enlist 0; 
    withdrawAmount      : enlist 0; 
    withdrawCount       : enlist 0; 
    shortFundingCost    : enlist 0; 
    longFundingCost     : enlist 0; 
    totalFundingCost    : enlist 0; 
    totalLossPnl        : enlist 0; 
    totalGainPnl        : enlist 0; 
    selfFillCount       : enlist 0; 
    selfFillVolume      : enlist 0; 
    monthVolume         : enlist 0; 

    // PNL
    realizedPnl         : enlist 0; 
    realizedGrossPnl    : enlist 0; 
    unrealizedPnl       : enlist 0; 
    unrealizedGrossPnl  : enlist 0; 
    
    // Foreign table keys
    instrument          :  enlist 0;
    long                :  enlist 0;
    short               :  enlist 0;
    both                :  enlist 0
    );  

.engine.model.inventory.test.Inventory               :(
        [
            accountId    :   enlist 0;
            side         :   enlist 0 
        ]
        amt                      : enlist 5; 
				avgPrice                 : enlist 5; 
				execCost                 : enlist 5; 
        leverage                 : enlist 0; 
        margin                   : enlist 0; 
        isignum                  : enlist 1
    );
