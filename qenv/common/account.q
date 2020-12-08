




/*******************************************************
/ order enumerations

/ `BUY:0,`SELL:1;
.common.account.ORDERSIDE     : (1;-1);

// USING MANUAL LIST FOR REFERENCABIsLITY 
.common.account.ORDERKIND:(
        0; // MARKET
        1; // LIMIT
        2; // STOP_MARKET
        3; // STOP_LIMIT
        4; // HIDDEN
        5; // ICEBERG
        6; // REMAINDERLIMIT
        7 // PEGGED
        );

// orders that are not inserted into 
// the orderbook
.common.order.ALGOORDERKINDS:(
        2; // STOP_MARKET
        3; // STOP_LIMIT
        6; // REMAINDERLIMIT
        7 // PEGGED
        );

// USING MANUAL LIST FOR REFERENCABILITY 
.common.account.ORDERSTATUS:(
        0; // NEW
        1; // PARTIAL
        2; // FILLED
        3; // UNTRIGGERED
        4; // TRIGGERED
        5; // FAILED
        6 // CANCELLED
        );

// USING MANUAL LIST FOR REFERENCABILITY 
.common.account.TIMEINFORCE:(
        0; // NIL
        1; // GOODTILCANCEL
        2; // IMMEDIATEORCANCEL
        3 // FILLORKILL
        );

// USING MANUAL LIST FOR REFERENCABILITY 
.common.account.STOPTRIGGER:(
        0; // NIL
        1; // LAST
        2; // MARK
        3 // INDEX
        );


// USING MANUAL LIST FOR REFERENCABILITY 
.common.account.EXECINST:(
        0; // NIL
        1; // PARTICIPATEDONTINITIATE
        2; // ALLORNONE
        3 // REDUCEONLY
        );

/*******************************************************
/ INSTRUMENT ENUMERATIONS

// USING MANUAL LIST FOR REFERENCABILITY 
.common.account.CONTRACTKIND:(
        0; // LINEAR
        1; // INVERSE
        2 // QUANTO
        );

// USING MANUAL LIST FOR REFERENCABILITY 
.common.account.INSTRUMENTSTATE:(
        0; // ONLINE
        1; // DOWN
        2; // ROLLBACK
        3 // MAINTENENCE
        );

/*******************************************************
/ PIPE WINDOWING ENUMERATIONS

// USING MANUAL LIST FOR REFERENCABILITY 
.common.account.WINDOWKIND:(
        0; // LINEAR
        1; // INVERSE
        2 // QUANTO
        );

/*******************************************************
/ ACCOUNT & INVENTORY ENUMERATIONS

/ `CROSS:0,`ISOLATED:1;
.common.account.MARGINTYPE      : (0;1);

/ `ACTIVE:0,`BLOCKED:1;
.common.account.ACCOUNTSTATE    : (0;1);

/ `ACTIVE:0,`LIQUIDATE:1;
.common.account.POSITIONSTATE   : (0;1);

/ `HEDGED:0,`COMBINED:1;
.common.account.POSITIONTYPE    : (0;1);

/ `SHORT:-1,`BOTH:0,`LONG:1
.common.account.POSITIONSIDE    : (-1;0;1);

// TODO create combined table.
