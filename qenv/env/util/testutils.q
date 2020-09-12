
\l util.q
\d .tu

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

// Mock generation and checking utils
// -------------------------------------------------------------->

// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeMockParams     :{[ref;args]
    
    };       


// TODO add additional logic
// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkMock           :{
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
    :$[cvl>1;[rx:(cvl#enlist[r]);rx[cl]:flip[vl];:rx];[r[cl]:vl;:r]]};

// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeDepthUpdates    :{[]

    };


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeOrderBook      :{[cl;vl]
    $[count[vl]>0;.util.testutils.makeDefaultsRecords[`.order.OrderBook;cl;vl];()]
    };


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeOrders          :{[cl;vl]
    $[count[vl]>0;.util.testutils.makeDefaultsRecords[`.order.Order;cl;vl];()]
    };


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeAccounts        :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.account.Account;cl;vl]
    };


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeInventories     :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.account.Inventory;cl;vl]
    };


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeInstruments     :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.instrument.Instrument;cl;vl]
    };


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeEvents          :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.pipe.event.Event;cl;vl]
    };

// Check Utils
// -------------------------------------------------------------->


// Checks that the .order.Order table matches the orders
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
                rOrd: select from .order.Order where clId in eOrd[`clId];
                .qt.A[count[eOrd];=;count[rOrd];"order count";case]; // TODO check
                .qt.A[(cl#0!rOrd);~;(cl#0!eOrd);"orders";case]; // TODO check
                ]];
            ];[]];
    };
.util.testutils.checkOrders:.util.testutils._checkOrders[()];

// Checks that the .order.OrderBook table matches the OrderBook
// that are provided.
/  @param x (OrderBook/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils._checkDepth           :{[cl;vl;case]
        $[count[vl]>0;[
            eBook:$[type[vl]=99h;vl;.util.testutils.makeOrderBook[vl;cl]];
            if[count[eBook]>0;[
                cl:$[count[cl]>0;cl;cols[eBook]];
                rBook:.order.OrderBook;
                .qt.A[count[eBook];=;count[rBook];"orderBook lvl count";case]; // TODO check
                .qt.A[(cl#0!rBook);~;(cl#0!eBook);"ordersBook";case]; // TODO check
            ]];
        ];[]];
    };
.util.testutils.checkDepth:.util.testutils._checkDepth[()];

// Checks that the .instrument.Instrument table matches the Instrument
// that are provided.
/  @param x (Instrument/List) The instrument that is to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkInstrument         :{
        eIns:$[type[x]=99h;x;.util.testutils.makeInstruments[x;z]];
        if[count[eIns]>0;[
            rIns:.instrument.Instrument;
            .qt.A[count[eIns];=;count[rIns];"instrument count";y]; // TODO check
            .qt.A[(y#0!rIns);~;(y#0!eIns);"instrument";y]; // TODO check
            ]];
    };

// Checks that the .pipe.event.Event table matches the events
// that are provided.
/  @param x (Events/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkEvents         :{
        eEvents:$[type[x]=99h;x;.util.testutils.makeEvents[x;z]];
        if[count[eEvents]>0;[
            rEvents:.pipe.event.Event;
            .qt.A[count[eEvents];=;count[rEvents];"event count";y]; // TODO check
            .qt.A[(y#0!rEvents);~;(y#0!eEvents);"event";y]; // TODO check
            ]];
    };

// TODO test account
// Checks that the .account.Account table matches the accounts
// that are provided.
/  @param x (Account/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkAccount       :{
        eAcc:$[type[x]=99h;x;.util.testutils.makeAccounts[x;z]];
        if[count[eAcc]>0;[
            rAcc:.account.Account;
            .qt.A[count[eAcc];=;count[rAcc];"account count";y]; // TODO check
            .qt.A[(y#0!rAcc);~;(y#0!eAcc);"account";y]; // TODO check
            ]];
    };

// Checks that the .account.Inventory table matches the inventory
// that are provided.
/  @param x (Inventory/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkInventory       :{
        eInv:$[type[x]=99h;x;.util.testutils.makeInvounts[x;z]];
        if[count[eInv]>0;[
            rInv:.account.Inventory;
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
    .util.table.dropAll[(`.order.Order`.order.OrderBook,
                `.instrument.Instrument`.account.Account,
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


.util.testutils.defaultAccounts:.util.testutils.genAccount[];
.util.testutils.defaultInstrument:.util.testutils.genInstrument[];

// Default function that runs before each Unit test etc.
.util.testutils.defaultBeforeEach               :{};

// Default function that runs after each Unit test etc.
.util.testutils.defaultAfterEach                :{};

.util.testutils.defaultEngineHooks              :(
    {
        .util.testutils.resetEngineTables[];
        .account.Account,:.util.testutils.defaultAccounts;
        .instrument.Instrument,:.util.testutils.defaultInstrument;
    };
    {
        .util.testutils.resetEngineTables[];
    };{};{});

.util.testutils.defaultStateHooks               :({};{};{};{});

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
        ({(x;(`.account.Account!$[(x mod 2)=0;0;1]);
            (`.instrument.Instrument!0);
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


// Random State Generation
// -------------------------------------------------------------->

// TODO make defaults to events
.util.testutils.setUniformState      :{
    .state.CurrentAccount,:.util.testutils.makeDefaultsRecords[
        `.state.CurrentAccount;
        `accountId`time`balance`available;
        {(x;.tu.z;10;10)}'[til 5]];
    .state.CurrentInventory,:.util.testutils.makeDefaultsRecords[
        `.state.CurrentInventory;
        `accountId`side`amt`realizedPnl`avgPrice`unrealizedPnl;
        {((x mod 5);(x mod 3);0;0;0;0)}'[til 15]];
    .state.CurrentOrders,:.util.testutils.makeDefaultsRecords[
         `.state.CurrentOrders;
         `orderId`accountId`side`otype`price`leaves`status`reduce;
        {(x;(x mod 5);$[(x<250);-1;1];1;floor[1000-(x%10)];100;0;(1h$first[1?(1 0)]))}'[til 500]];
    .state.CurrentDepth,:.util.testutils.makeDefaultsRecords[
         `.state.CurrentDepth;
         `price`time`side`size;
        {(floor[1000-(x%2)];.tu.z;$[(x<50);-1;1];100)}'[til 100]];
    .state.TradeEventHistory,:.util.testutils.makeDefaultsRecords[
         `.state.TradeEventHistory;
         `tid`time`size`price`side;
        {(x;(.tu.snz rand 10000);100;floor[1000-(rand 50)];$[(x<5000);-1;1])}'[til 10000]];
    .state.MarkEventHistory,:.util.testutils.makeDefaultsRecords[
         `.state.MarkEventHistory;
         `time`markprice;
        {(snz rand 10000;floor[1000-(x%2)])}'[til 1000]];
    .state.FundingEventHistory,:.util.testutils.makeDefaultsRecords[
         `.state.FundingEventHistory;
         `time`fundingrate`fundingtime;
        {((snz rand 10000);first[1?0.001 0.002 0.003];(snz rand 1000))}'[til 50]];
    .state.LiquidationEventHistory,:.util.testutils.makeDefaultsRecords[
         `.state.LiquidationEventHistory;
         `liqid`time`size`price`side;
        {(x;(snz rand 1000);first[1?100 200 300];floor[1000-(rand 50)];$[(x<250);-1;1])}'[til 500]];
    .state.SignalEventHistory,:.util.testutils.makeDefaultsRecords[
         `.state.SignalEventHistory;
         `sigid`time`sigvalue;
        {(rand 50;(snz rand 5000);rand 1f)}'[til 5000]];
    };


.util.testutils.genRandomStateH      :{
    .util.testutils.makeDefaultsRecords[`.state.AccountEventHistory;cl;vl]
    };

// Table Setup logic
// -------------------------------------------------------------->


.util.testutils.setupOrderbook      :{
    if[count[x]>0;[.order.OrderBook,:(0^x)]];
    };

.util.testutils.setupDepth:.util.testutils.setupOrderbook;

.util.testutils.setupOrders         :{
    if[count[x]>0;[
        .order.Order,:{
            show .account.Account;
            show x[`accountId];
            show x;
            x[`accountId]:(`.account.Account!(x[`accountId]));
            x[`instrumentId]:(`.instrument.Instrument!(x[`instrumentId]));
            x[`reduce]:`boolean$(x[`reduce]);
            x}(0^x);
        ]];
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


// Main Param Generation utils
// -------------------------------------------------------------->