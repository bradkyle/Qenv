

l: `long$x
z:.z.z;
sc:{x+(`second$y)};
sz:sc[z];
dts:{(`date$x)+(`second$x)};
dtz:{dts[sc[x;y]]}[z]
doz:`date$z;
dozc:{x+y}[doz];

// Mock generation and checking utils
// -------------------------------------------------------------->

// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeMockParams     :{[ref;args]
    
    };       


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.uil.testutils.checkMockParams      :{

    };


// Make Test Data Utils
// -------------------------------------------------------------->


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeDefaultsRecord  :{[ref;cl;vl]
    r:.util.NullRowDict[ref];
    r[cl]:vl;
    r
    };

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
.util.testutils.makeOrderBooks      :{[]

    };


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeOrders          :{[]

    };


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeAccounts        :{[]

    };


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeInventories     :{[]

    };


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeInstruments     :{[]

    };


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeEvents          :{[]

    };

// Check Utils
// -------------------------------------------------------------->


// Checks that the .order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkOrders         :{ // TODO if provided orders are not table
        eOrd:$[type[x]=99h;x;.util.testutils.makeOrders[x;z]]
        if[count[eOrd]>0;[
            rOrd: select from .order.Order where clId in eOrd[`clId];
            .qt.A[count];=;count[rOrd];"order count";y]; // TODO check
            .qt.A[(y#0!rOrd);~;(y#0!eOrd);"orders";y]; // TODO check
            ]];
    };


// Checks that the .order.OrderBook table matches the OrderBook
// that are provided.
/  @param x (OrderBook/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.uti.testutils.checkDepth           :{
        eBook:$[type[x]=99h;x;.util.testutils.makeOrderBook[x;z]]
        if[count[eBook]>0;[
            rBook:.order.OrderBook;
            .qt.A[count];=;count[rBook];"orderBook lvl count";y]; // TODO check
            .qt.A[(y#0!rBook);~;(y#0!eBook);"ordersBook";y]; // TODO check
            ]];
    };

// Checks that the .instrument.Instrument table matches the Instrument
// that are provided.
/  @param x (Instrument/List) The instrument that is to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.uti.testutils.checkInstrument         :{
        eIns:$[type[x]=99h;x;.util.testutils.makeInstruments[x;z]]
        if[count[eIns]>0;[
            rIns:.instrument.Instrument;
            .qt.A[count];=;count[rIns];"instrument count";y]; // TODO check
            .qt.A[(y#0!rIns);~;(y#0!eIns);"instrument";y]; // TODO check
            ]];
    };

// Checks that the .pipe.event.Event table matches the events
// that are provided.
/  @param x (Events/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkEvents         :{
        eEvents:$[type[x]=99h;x;.util.testutils.makeEvents[x;z]]
        if[count[eEvents]>0;[
            rEvents:.pipe.event.Event;
            .qt.A[count];=;count[rEvents];"event count";y]; // TODO check
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
        eAcc:$[type[x]=99h;x;.util.testutils.makeAccounts[x;z]]
        if[count[eAcc]>0;[
            rAcc:.account.Account;
            .qt.A[count];=;count[rAcc];"account count";y]; // TODO check
            .qt.A[(y#0!rAcc);~;(y#0!eAcc);"account";y]; // TODO check
            ]];
    };

// Checks that the .account.Inventory table matches the inventory
// that are provided.
/  @param x (Inventory/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkInventory       :{
        eInv:$[type[x]=99h;x;.util.testutils.makeInvounts[x;z]]
        if[count[eInv]>0;[
            rInv:.account.Inventory;
            .qt.A[count];=;count[rInv];"inventory count";y]; // TODO check
            .qt.A[(y#0!rInv);~;(y#0!eInv);"inventory";y]; // TODO check
            ]];
    };


// Checks that the .liquidation.Liquidation table matches the liquidations
// that are provided.
/  @param x (Inventory/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkLiquidation       :{
        eInv:$[type[x]=99h;x;.util.testutils.makeLiquidation[x;z]]
        if[count[eInv]>0;[
            rInv:.account.Account;
            .qt.A[count];=;count[rInv];"liqudidation count";y]; // TODO check
            .qt.A[(y#0!rInv);~;(y#0!eInv);"liquidation";y]; // TODO check
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

// Default function that runs before each Unit test etc.
.util.testutils.defaultBeforeEach     :{

    };

// Default function that runs after each Unit test etc.
.util.testutils.defaultAfterEach      :{

    };    


// Make random event utils
// -------------------------------------------------------------->

.util.testutils.genRandomTrades        :{

    };

.util.testutils.genRandomDepths        :{

    };

.util.testutils.genRandomInventory     :{

    };

.util.testutils.genRandomAccount       :{

    };

.util.testutils.genRandomOrders        :{

    };

.util.testutils.genRandomMarks        :{

    };

.util.testutils.genRandomOrders        :{

    };


.util.testutils.genRandomEvent        :{

    };

// Random Engine Generation
// -------------------------------------------------------------->

.util.testutils.genRandomEngine      :{

    };


// Random State Generation
// -------------------------------------------------------------->

.util.testutils.genRandomState      :{

    };


// Table Setup logic
// -------------------------------------------------------------->


.util.testutils.setupOrderbook      :{

    };

.util.testutils.setupOrders         :{

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