

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


// Checks that the .order.Order table matches the orders
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

.util.testutils.checkEvents         :{

    };

.util.testutils.checkAccounts       :{

    };

.util.testutils.checkInventory      :{

    };  

.util.testutils.checkLiquidation    :{

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


