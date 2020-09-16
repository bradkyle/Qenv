


/*******************************************************
/ order enumerations

/ `BUY:0,`SELL:1;
.pipe.common.ORDERSIDE     : (1;-1);

// USING MANUAL LIST FOR REFERENCABILITY 
.pipe.common.ORDERKIND:(
        0; // MARKET
        1; // LIMIT
        2; // STOP_MARKET
        3; // STOP_LIMIT
        4; // HIDDEN
        5; // ICEBERG
        6; // REMAINDERLIMIT
        7 // PEGGED
        );

// USING MANUAL LIST FOR REFERENCABILITY 
.pipe.common.ORDERSTATUS:(
        0; // NEW
        1; // PARTIAL
        2; // FILLED
        3; // UNTRIGGERED
        4; // TRIGGERED
        5; // FAILED
        6 // CANCELLED
        );

// USING MANUAL LIST FOR REFERENCABILITY 
.pipe.common.TIMEINFORCE:(
        0; // NIL
        1; // GOODTILCANCEL
        2; // IMMEDIATEORCANCEL
        3 // FILLORKILL
        );

// USING MANUAL LIST FOR REFERENCABILITY 
.pipe.common.STOPTRIGGER:(
        0; // NIL
        1; // LAST
        2; // MARK
        3 // INDEX
        );


// USING MANUAL LIST FOR REFERENCABILITY 
.pipe.common.EXECINST:(
        0; // NIL
        1; // PARTICIPATEDONTINITIATE
        2; // ALLORNONE
        3 // REDUCEONLY
        );

/*******************************************************
/ INSTRUMENT ENUMERATIONS

// USING MANUAL LIST FOR REFERENCABILITY 
.pipe.common.CONTRACTKIND:(
        0; // LINEAR
        1; // INVERSE
        2 // QUANTO
        );

// USING MANUAL LIST FOR REFERENCABILITY 
.pipe.common.INSTRUMENTSTATE:(
        0; // ONLINE
        1; // DOWN
        2; // ROLLBACK
        3 // MAINTENENCE
        );

/*******************************************************
/ PIPE WINDOWING ENUMERATIONS

// USING MANUAL LIST FOR REFERENCABILITY 
.pipe.common.WINDOWKIND:(
        0; // LINEAR
        1; // INVERSE
        2 // QUANTO
        );

/*******************************************************
/ ACCOUNT & INVENTORY ENUMERATIONS

/ `CROSS:0,`ISOLATED:1;
.pipe.common.MARGINTYPE      : (0;1);

/ `ACTIVE:0,`BLOCKED:1;
.pipe.common.ACCOUNTSTATE    : (0;1);

/ `ACTIVE:0,`LIQUIDATE:1;
.pipe.common.POSITIONSTATE   : (0;1);

/ `HEDGED:0,`COMBINED:1;
.pipe.common.POSITIONTYPE    : (0;1);

/ `SHORT:-1,`BOTH:0,`LONG:1
.pipe.common.POSITIONSIDE    : (-1;0;1);

// TODO create combined table.
