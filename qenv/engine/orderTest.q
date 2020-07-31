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