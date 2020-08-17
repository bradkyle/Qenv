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
    `accountId`balance`marginType`positionType!(

        );
    };

makeEAccount :{
    `accountId`balance`marginType`positionType!(

        );
    };

makeInventory   :{
    icols:`accountId`side`amt`avgPrice`totalEntry`execCost`avgPrice;
    einv:x[`eInv];
    cx:count[einv];
    $[cx=3;[
        :(x[;0];`.account.POSITIONSIDE$`BOTH`LONG`SHORT;x[])
    ];
    cx=2;[
        :(x[;0];`.account.POSITIONSIDE$`LONG`SHORT;x[])
    ];
    cx=1;[
        :(x[;0];`.account.POSITIONSIDE$`BOTH;x[])
    ];'NO_INVENTORY_PARAMS]
    };

makeInventory   :{
    `accountId`side`amt`avgPrice`totalEntry`execCost`avgPrice
    };

// Test Utilities
// -------------------------------------------------------------->

setupAccount      : {if[count[x[`cAcc]]>0;.order.ProcessDepthUpdateEvent[x[`cOB]]]}
setupInventory    : {if[count[x[`cInv]]>0;{.order.NewOrder[x[0];x[1]]} each x[`cOrd]]}

// @x : params
// @y : case
checkInventory     :{
    einv:x[`eInv];
    cx:count[einv];
    $[cx=3;[
        
    ];
    cx=2;[

    ];
    cx=1;[

    ];'NO_INVENTORY_PARAMS];
    };

checkAccount      :{
    if[count[x[`eAcc]]>0;
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
        setupAccount[p];
        setupInventory[p];

        f:p[`fill];
        .account.ApplyFill[
            f[`accountId];
            f[`instrumentId];
            f[`side];
            f[`time];
            f[`reduceOnly];
            f[`isMaker];
            f[`price];
            f[`qty]];
         
        // Assertions
        checkAccount[p[`eAcc]];
        checkInventory[p[`eInv]];

    };();({};{};defaultBeforeEach;defaultAfterEach);""];

deriveCaseParams :{[p]
    f:`accountId`instrumentId`side`time`reduceOnly`isMaker`price`qty!p[2];
    `cAcc`cInv`fill`eAcc`eInv`eEvents!(
        makeAccount[p[0]];
        makeInventory[p[1]];
        f;
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
    ]];