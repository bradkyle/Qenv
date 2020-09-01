

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
/  @param x (Order) The orders that are to be checked
/  @param y (Case) The params that are being checked 
/  @param z (Case) The case that the assertions belong to
.util.testutils.checkOrders         :{
        if[count[x]>0;[
            eOrd:.util.testutils.makeOrders[x;y];
            rOrd: select from .order.Order where clId in eOrd[`clId];
            .qt.A[count];=;count[rOrd];"order count";y];
            .qt.A[(y#0!rOrd);~;(y#0!eOrd);"orders";y];
            ]];
    };

.uti.testutils.checkDepth           :{

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


