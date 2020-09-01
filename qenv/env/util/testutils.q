

// Mock generation and checking utils
// -------------------------------------------------------------->

.util.testutils.makeMockParams      :{

    };       

.uil.testutils.checkMockParams      :{

    };


// Make Test Data Utils
// -------------------------------------------------------------->

.util.testutils.makeDepthUpdate     :{[]

    };

.util.testutils.makeOrderBook       :{[]

    };

.util.testutils.makeOrders          :{[]

    };

.util.testutils.makeAccounts        :{[]

    };

.util.testutils.makeInventories     :{[]

    };

.util.testutils.makeInstruments     :{[]

    };

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
            .qt.A[count];=;count[rAcc];"event count";y]; // TODO check
            .qt.A[(y#0!rAcc);~;(y#0!eAcc);"event";y]; // TODO check
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
            .qt.A[count];=;count[rInv];"event count";y]; // TODO check
            .qt.A[(y#0!rInv);~;(y#0!eInv);"event";y]; // TODO check
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
            .qt.A[count];=;count[rInv];"event count";y]; // TODO check
            .qt.A[(y#0!rInv);~;(y#0!eInv);"event";y]; // TODO check
            ]];
    };


.util.testutils.checkStateTable     :{

    };


// Common Reset/Teardown Functions
// -------------------------------------------------------------->

.util.testutils.resetEngineTables      :{

    };

.util.testutils.resetStateTables      :{

    };

.util.testutils.defaultBeforeEach     :{

    };

.util.testutils.defaultAfterEach      :{

    };    


// Make event utils
// -------------------------------------------------------------->

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


