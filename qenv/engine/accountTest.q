\l account.q
\l instrument.q
\l event.q
\l order.q
system "d .orderTest";
\l util.q
\cd ../quantest/
\l quantest.q 
\cd ../engine/

z:.z.z;

sc: {x+(`second$y)};

// Test data generation
// -------------------------------------------------------------->

makeAccount :{

    };

makeInventory   :{

    }

// Test Utilities
// -------------------------------------------------------------->

setupAccount      : {if[count[x[`cAcc]]>0;.order.ProcessDepthUpdateEvent[x[`cOB]]]}
setupInventory    : {if[count[x[`cInv]]>0;{.order.NewOrder[x[0];x[1]]} each x[`cOrd]]}

// @x : params
// @y : case
checkInventory     :{
    if[count[x[`eOrd]]>0;[
            eOrd:x[`eOrd][;0];
            rOrd: select from .order.Order where clId in eOrd[`clId];
            eOrdCols: rmFkeys[rOrd] inter cols[eOrd];
            .qt.A[count[x[`eOrd]];=;count[rOrd];"order count";y];
            .qt.A[(eOrdCols#0!rOrd);~;(eOrdCols#0!eOrd);"orders";y];
            ]];
    };

checkAccount      :{
    if[count[x[`eOB]]>0;
            .qt.A[.order.OrderBook;~;x[`eOB];"orderbook";y];
            ];
    };



// Before and after defaults
// -------------------------------------------------------------->

defaultAfterEach: {
    /  delete from `.account.Account;
    /  delete from `.account.Inventory;
     delete from `.event.Events;
     delete from `.order.Order;
     delete from `.order.OrderBook;
    /  delete from  `.instrument.Instrument;
     .account.accountCount:0;
     .order.orderCount:0;
    .instrument.instrumentCount:0;
     .qt.RestoreMocks[];
    };

defaultBeforeEach: {
     delete from `.account.Account;
     delete from `.account.Inventory;
     delete from `.event.Events;
     delete from `.order.Order;
     delete from `.order.OrderBook;
     .account.NewAccount[`accountId`other!1 2;.z.z];
     .account.NewAccount[`accountId`other!2 2;.z.z];

     .instrument.NewInstrument[
        `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier!
        (1;0.5;1e5f;0f;1e7f;0f;1);
        1b;.z.z];
    };

// ApplyFill
// -------------------------------------------------------------->

test:.qt.Unit[
    ".account.ApplyFill";
    {[c]
        p:c[`params];

        // Execute tested function
         
        // Assertions

    };();({};{};defaultBeforeEach;defaultAfterEach);""];

deriveCaseParams :{[p]
    `cAcc`cInv`params`eAcc`eInv`eEvents!(
        makeAccount[p[0]];
        makeInventory[p[1]];
        p[2];
        makeAccount[p[3]];
        makeInventory[p[4]];
        p[5]
        );
    };

.qt.AddCase[test;"";deriveCaseParams[
    (1;`COMBINED;1); // Current Account
    (();();()); // Current Inventory
    (0;0;`BUY;z;0b;0b;100;1000); // Parameters
    (1); // Expected Account
    (();();()); // Expected Inventory
    () // Expected events
    ]]