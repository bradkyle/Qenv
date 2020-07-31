\l account.q
\l inventory.q
\l event.q
\l order.q
system "d .orderTest";
\l util.q
\cd ../quantest/
\l quantest.q 
\cd ../engine/


/ nxt:update qty:qty+(first 1?til 100) from select qty:last (datum[;0][;2]) by price:datum[;0][;1] from d where[(d[`datum][;0][;0])=`BUY]
/ nxt:exec qty by price from update qty:rand qty from select qty:last (datum[;0][;2]) by price:datum[;0][;1] from d where[(d[`datum][;0][;0])=`BUY]
/ .account.NewAccount[`accountId`other!1 2;.z.z]
randOrder:{[num;prices;oidstart]
    :(
        [
            price:`int$(num?prices); 
            orderId:`int$(oidstart+til num)
        ]
        accountId       : `int$(num#1);
        side            : num?(`.order.ORDERSIDE$`BUY;`.order.ORDERSIDE$`SELL);
        otype           : num#`.order.ORDERTYPE$`LIMIT;
        offset          : `int$(num?til 10000);
        timeinforce     : num#`.order.TIMEINFORCE$`NIL;
        size            : `int$(num?til 10000); / multiply by 100
        leaves          : `int$(num?til 10000);
        filled          : `int$(num?til 10000);
        limitprice      : `int$(num?til 10000); / multiply by 100
        stopprice       : `int$(num?til 10000); / multiply by 100
        status          : num#`.order.ORDERSTATUS$`NEW;
        time            : num#.z.z;
        isClose         : `boolean$(num?(1 0));
        trigger         : num#`.order.STOPTRIGGER$`NIL;
        execInst        : num#`.order.EXECINST$`NIL
    )
    };

defaultAfterEach: {
     delete from `.account.Account;
     delete from `.inventory.Inventory;
     delete from `.event.Events;
     .account.accountCount:0;
     .inventory.inventoryCount:0;
     .qt.RestoreMocks[];
    };

defaultBeforeEach: {
     .account.NewAccount[`accountId`other!1 2;.z.z];
     .account.NewAccount[`accountId`other!2 2;.z.z]
    };

test:.qt.Unit[
    ".order.processSideUpdate";
    {[c]
        p:c[`params];
        time:.z.z;
        eacc:p[`eaccount];
        einv:p[`einventory];
        ecols:p[`ecols];

        account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
        inventory:Sanitize[p[`inventory];.inventory.defaults[];.inventory.allCols];

        // Execute tested function
        x:p[`params];
        .account.execFill[account;inventory;x[`fillQty];x[`price];x[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        .qt.A[{x!y[x]}[cols eacc;acc];~;eacc;"account";c];
        .qt.A[{x!y[x]}[cols einv;invn];~;einv;"inventory";c];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Given a side update which consists of a table of price, time,",
    "size update the orderbook and the individual order offsets"];

//TODO make into array and addCases
.qt.AddCase[test;"simple ask update no agent orders or previous depth";deriveCaseParams[(
    ();();
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    )]];

.qt.AddCase[test;"single agent ask decreasing (delta less than offset)";deriveCaseParams[(
    ();
    genTestOrders[];
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    ()
    )]];

.qt.AddCase[test;"1 order at 1 level";deriveCaseParams[(
    ();
    genTestOrders[];
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    ()
    )]];

.qt.AddCase[test;"3 orders at 1 level";deriveCaseParams[(
    ();
    genTestOrders[];
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    ()
    )]];

.qt.AddCase[test;"1 order at 3 different levels and differing offsets";deriveCaseParams[(
    ();
    genTestOrders[];
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    ()
    )]];

.qt.AddCase[test;"3 orders of different quantities at 3 different levels and differing offsets";deriveCaseParams[(
    ();
    genTestOrders[];
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    ()
    )]];

.qt.AddCase[test;"mixed orders of different quantities at 3 different levels and differing offsets";deriveCaseParams[(
    ();
    genTestOrders[];
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    ()
    )]];

.qt.AddCase[test;"mixed orders of different quantities at 3 different levels and differing offsets: There are no non agent orders left";
    deriveCaseParams[(
    ();
    genTestOrders[];
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    ()
    )]];


.qt.AddCase[test;"depth update overlaps with current depth of opposing side";
    deriveCaseParams[(
    ();
    genTestOrders[];
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    ()
    )]];


.qt.AddCase[test;"depth update does not conform to tick size";
    deriveCaseParams[(
    ();
    genTestOrders[];
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    ()
    )]];

.qt.AddCase[test;"depth update does not conform to lot size";
    deriveCaseParams[(
    ();
    genTestOrders[];
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    ()
    )]];


.qt.AddCase[test;"agent offsets are zero and update is less than agent order size";
    deriveCaseParams[(
    ();
    genTestOrders[];
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    ()
    )]];


.qt.AddCase[test;"depth update contains depth for which the next value is zero";
    deriveCaseParams[(
    ();
    genTestOrders[];
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    ()
    )]];

.qt.AddCase[test;"check that best ask, best bid, is liquid variables are updated";
    deriveCaseParams[(
    ();
    genTestOrders[];
    `SELL;
    `price`qty!(`s#993150 993250i;2689711 2689711i);
    `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
    ()
    )]];


test:.qt.Unit[
    ".order.ProcessDepthUpdate";
    {[c]
        p:c[`params];
        time:.z.z;
        eacc:p[`eaccount];
        einv:p[`einventory];
        ecols:p[`ecols];

        account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
        inventory:Sanitize[p[`inventory];.inventory.defaults[];.inventory.allCols];

        // Execute tested function
        x:p[`params];
        .account.execFill[account;inventory;x[`fillQty];x[`price];x[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        .qt.A[{x!y[x]}[cols eacc;acc];~;eacc;"account";c];
        .qt.A[{x!y[x]}[cols einv;invn];~;einv;"inventory";c];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Given a set of events of the exemplary format (canonical event format)",
    "update the orderbook and order state and return the new representation"];

// TODO figure out how events will be returned?
/ .qt.AddCase[test;"mixed orders of different quantities at 3 different levels and differing offsets: There are no non agent orders left";
/     deriveCaseParams[(
/     ();
/     genTestOrders[];
/     `SELL;
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];


test:.qt.Unit[
    ".order.NewOrder";
    {[c]
        p:c[`params];
        time:.z.z;
        eacc:p[`eaccount];
        einv:p[`einventory];
        ecols:p[`ecols];

        account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
        inventory:Sanitize[p[`inventory];.inventory.defaults[];.inventory.allCols];

        // Execute tested function
        x:p[`params];
        .account.execFill[account;inventory;x[`fillQty];x[`price];x[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        .qt.A[{x!y[x]}[cols eacc;acc];~;eacc;"account";c];
        .qt.A[{x!y[x]}[cols einv;invn];~;einv;"inventory";c];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


.qt.AddCase[test;"New simple ask limit order";
    deriveCaseParams[ ]];

.qt.AddCase[test;"New simple market order";
    deriveCaseParams[ ]];

.qt.AddCase[test;"New simple stop market order";
    deriveCaseParams[ ]];

.qt.AddCase[test;"New simple stop limit order";
    deriveCaseParams[ ]];

.qt.AddCase[test;"Trash fields present";
    deriveCaseParams[]];

.qt.AddCase[test;"Invalid Account Id (form)";
    deriveCaseParams[]];

.qt.AddCase[test;"Invalid Order side";
    deriveCaseParams[]];

.qt.AddCase[test;"Invalid Order type";
    deriveCaseParams[]];

.qt.AddCase[test;"Invalid time in force";
    deriveCaseParams[]];

.qt.AddCase[test;"Invalid Exec inst";
    deriveCaseParams[]];

.qt.AddCase[test;"Invalid price tick size";
    deriveCaseParams[]];

.qt.AddCase[test;"order price>max price";
    deriveCaseParams[]];

.qt.AddCase[test;"order price<min price";
    deriveCaseParams[]];

.qt.AddCase[test;"order size>max order size";
    deriveCaseParams[]];

.qt.AddCase[test;"order price<min order size";
    deriveCaseParams[]];

.qt.AddCase[test;"Account id not found";
    deriveCaseParams[]];

.qt.AddCase[test;"Duplicate clOrdId";
    deriveCaseParams[]];

.qt.AddCase[test;"Duplicate orderId";
    deriveCaseParams[]];

.qt.AddCase[test;"Not enough margin to execute order";
    deriveCaseParams[]];

.qt.AddCase[test;"Accounts do not match";
    deriveCaseParams[]];

.qt.AddCase[test;"Invalid stopPrice for order type";
    deriveCaseParams[]];

.qt.AddCase[test;"Invalid order type for exec inst";
    deriveCaseParams[]];

.qt.AddCase[test;"Account id not found";
    deriveCaseParams[]];

.qt.AddCase[test;"Order placed in book offset = offset at depth price";
    deriveCaseParams[]];

.qt.AddCase[test;"Order placed in book offset when no depth orders exist";
    deriveCaseParams[]];

.qt.AddCase[test;"Participate dont initiate cross throws error";
    deriveCaseParams[]];

.qt.AddCase[test;"Dont participate dont initiate cross calls/places market order";
    deriveCaseParams[]];

.qt.AddCase[test;"Order placed in book";
    deriveCaseParams[]];

.qt.AddCase[test;"Incorrect time format for event";
    deriveCaseParams[]];

.qt.AddCase[test;"Close order larger than inventory";
    deriveCaseParams[]];

.qt.AddCase[test;"Close order with no inventory";
    deriveCaseParams[]];

.qt.AddCase[test;"multiple close orders (of STOP_LIMIT, STOP_MARKET, LIMIT), collectively than inventory";
    deriveCaseParams[]];

.qt.AddCase[test;"Invalid stop order price for trigger";
    deriveCaseParams[]];

test:.qt.Unit[
    ".order.fillTrade";
    {[c]
        p:c[`params];
        time:.z.z;
        eacc:p[`eaccount];
        einv:p[`einventory];
        ecols:p[`ecols];

        account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
        inventory:Sanitize[p[`inventory];.inventory.defaults[];.inventory.allCols];

        // Execute tested function
        x:p[`params];
        .account.execFill[account;inventory;x[`fillQty];x[`price];x[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        .qt.A[{x!y[x]}[cols eacc;acc];~;eacc;"account";c];
        .qt.A[{x!y[x]}[cols einv;invn];~;einv;"inventory";c];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];

.qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent";
    deriveCaseParams[]];

.qt.AddCase[test;"orderbook does not have agent orders, trade was made by an agent, trade is larger than best qty";
    deriveCaseParams[]];

.qt.AddCase[test;"orderbook does not have agent orders, trade was made by an agent, trade is smaller than best qty";
    deriveCaseParams[]];

.qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent, trade is larger than best qty";
    deriveCaseParams[]];

.qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent, trade is smaller than best qty";
    deriveCaseParams[]];

.qt.AddCase[test;"orderbook has agent orders, trade doesn't fill agent order, trade execution > agent order offset, fill is agent";
    deriveCaseParams[]];

.qt.AddCase[test;"orderbook has agent orders, trade fills agent order, trade execution < agent order offset, fill is agent";
    deriveCaseParams[]];

.qt.AddCase[test;"orderbook has agent orders, trade doesn't fill agent order, trade execution > agent order offset, fill is not agent";
    deriveCaseParams[]];

.qt.AddCase[test;"orderbook has agent orders, trade fills agent order, trade execution < agent order offset, fill is not agent";
    deriveCaseParams[]];

.qt.AddCase[test;"agent order fills another agents order";
    deriveCaseParams[]];

.qt.AddCase[test;"agent fills its own limit order";
    deriveCaseParams[]];

.qt.AddCase[test;"agent order fills another agents order";
    deriveCaseParams[]];

.qt.AddCase[test;"no liquidity";
    deriveCaseParams[]];


test:.qt.Unit[
    ".order.processCross";
    {[c]
        p:c[`params];
        time:.z.z;
        eacc:p[`eaccount];
        einv:p[`einventory];
        ecols:p[`ecols];

        account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
        inventory:Sanitize[p[`inventory];.inventory.defaults[];.inventory.allCols];

        // Execute tested function
        x:p[`params];
        .account.execFill[account;inventory;x[`fillQty];x[`price];x[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        .qt.A[{x!y[x]}[cols eacc;acc];~;eacc;"account";c];
        .qt.A[{x!y[x]}[cols einv;invn];~;einv;"inventory";c];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".order.ProcessTradeEvent";
    {[c]
        p:c[`params];
        time:.z.z;
        eacc:p[`eaccount];
        einv:p[`einventory];
        ecols:p[`ecols];

        account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
        inventory:Sanitize[p[`inventory];.inventory.defaults[];.inventory.allCols];

        // Execute tested function
        x:p[`params];
        .account.execFill[account;inventory;x[`fillQty];x[`price];x[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        .qt.A[{x!y[x]}[cols eacc;acc];~;eacc;"account";c];
        .qt.A[{x!y[x]}[cols einv;invn];~;einv;"inventory";c];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".order.UpdateMarkPrice";
    {[c]
        p:c[`params];
        time:.z.z;
        eacc:p[`eaccount];
        einv:p[`einventory];
        ecols:p[`ecols];

        account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
        inventory:Sanitize[p[`inventory];.inventory.defaults[];.inventory.allCols];

        // Execute tested function
        x:p[`params];
        .account.execFill[account;inventory;x[`fillQty];x[`price];x[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        .qt.A[{x!y[x]}[cols eacc;acc];~;eacc;"account";c];
        .qt.A[{x!y[x]}[cols einv;invn];~;einv;"inventory";c];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];