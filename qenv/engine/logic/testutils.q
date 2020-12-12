

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
.util.testutils.makeDefaultsRecords  :{[tab;cl;vl] // TODO inter with actual cols
    r:.util.NullRowDict[tab];
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
.util.testutils.makeOrder          :{[cl;vl]
    $[count[vl]>0;.util.testutils.makeDefaultsRecords[`.engine.model.order.Order;cl;vl];()]
    };

// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeAccount        :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.engine.model.account.Account;cl;vl]
    };


// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeInventory     :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.engine.model.inventory.Inventory;cl;vl]
    };


// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeInstrument     :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.engine.model.instrument.Instrument;cl;vl]
    };


// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeEvent          :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.common.event.Event;cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeRisktier       :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.engine.model.risktier.Risktier;cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeFeetier        :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.engine.model.feetier.Feetier;cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeFill           :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.engine.model.fill.Fill;cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeWithdraw :{[cl;vl]
    .util.testutils.makeDefaultsRecords[([] time:`datetime$(); aId:`long$(); iId:`long$(); wit:`long$());cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeDeposit :{[cl;vl]
    .util.testutils.makeDefaultsRecords[([] time:`datetime$(); aId:`long$(); iId:`long$(); dep:`long$());cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeLeverage :{[cl;vl]
    .util.testutils.makeDefaultsRecords[([] time:`datetime$(); aId:`long$(); iId:`long$(); lev:`long$());cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeFunding :{[cl;vl]
    .util.testutils.makeDefaultsRecords[([] time:`datetime$(); iId:`long$(); fundingrate:`long$());cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeMark :{[cl;vl]
    .util.testutils.makeDefaultsRecords[([] time:`datetime$(); iId:`long$(); markprice:`long$());cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeSettlement :{[cl;vl]
    .util.testutils.makeDefaultsRecords[([] time:`datetime$(); iId:`long$());cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeLevel :{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.engine.model.orderbook.Orderbook;cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeTake :{[cl;vl]
    .util.testutils.makeDefaultsRecords[([] time:`datetime$(); aId:`long$(); iId:`long$() side:`long$());cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeLiquidation:{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.engine.model.liquidation.Liquidation;cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeRiskTier:{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.engine.model.risktier.RiskTier;cl;vl]
    };

/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeFeeTier:{[cl;vl]
    .util.testutils.makeDefaultsRecords[`.engine.model.feetier.FeeTier;cl;vl]
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
    .util.table.dropAll[(`.engine.model.order.Order`.engine.model.orderbook.Orderbook,
                `.engine.model.instrument.Instrument`.engine.model.account.Account,
                `.engine.model.inventory.Inventory)];
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

  

.engine.model.risktier.RiskTier,:flip `rtid`mxamt`mmr`imr`maxlev!flip[(
    (0; 50000;       0.004;    0.008;    125);
    (1; 250000;      0.005;    0.01;     100);
    (2; 1000000;     0.01;     0.02;     50);
    (3; 5000000;     0.025;    0.05;     20);
    (4; 20000000;    0.05;     0.1;      10);
    (5; 50000000;    0.1;      0.20;     5);
    (6; 100000000;   0.125;    0.25;     4);
    (7; 200000000;   0.15;     0.333;    3);
    (8; 500000000;   0.25;     0.50;     2);
    (9; 500000000;   0.25;     1.0;      1))]; 

.engine.model.feetier.FeeTier,:flip `ftid`vol`mkrfee`tkrfee`wdrawfee`dpstfee`wdlim!flip[(
    (0; 50;      0.0006;    0.0006;    0f;  0f; 600);
    (1; 500;     0.00054;   0.0006;    0f;  0f; 600);
    (2; 1500;    0.00048;   0.0006;    0f;  0f; 600);
    (3; 4500;    0.00042;   0.0006;    0f;  0f; 600);
    (4; 10000;   0.00042;   0.00054;   0f;  0f; 600);
    (5; 20000;   0.00036;   0.00048;   0f;  0f; 600);
    (6; 40000;   0.00024;   0.00036;   0f;  0f; 600);
    (7; 80000;   0.00018;   0.000300;  0f;  0f; 600);
    (8; 150000;  0.00012;   0.00024;   0f;  0f; 600))];                             //  