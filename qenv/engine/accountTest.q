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
l: `long$

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
        :(x[;0];`.account.POSITIONSIDE$`BOTH`LONG`SHORT;x[;1_til 5])
    ];
    cx=2;[
        :(x[;0];`.account.POSITIONSIDE$`LONG`SHORT;x[;1_til 5])
    ];
    cx=1;[
        :(x[;0];`.account.POSITIONSIDE$`BOTH;x[;1_til 5])
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
    f:`accountId`instrumentId`side`time`reduceOnly`isMaker`price`qty!p[3];
    f[`accountId]: `.account.Account!f[`accountId];
    f[`instrumentId]: `.instrument.Instrument!f[`instrumentId];
    f[`side]: `.order.ORDERSIDE$f[`side];
    `cAcc`cInv`fill`eAcc`eInv`eEvents!(
        makeAccount[p[0]];
        makeInventory[p[1]];
        `markPrice!p[2];
        f;
        makeAccount[p[4]];
        makeInventory[p[5]];
        p[6]
        );
    };

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[
    (0;`COMBINED;1); // Current Account
    (
        (0;`BOTH;100;100;l 1e9; 1000);
        (0;`LONG;100;100;l 1e9; 1000);
        (0;`SHORT;100;100;l 1e9; 1000)
    );
    1000;
    //`accountId`instrumentId`side`time`reduceOnly`isMaker`price`qty
    (0;0;`BUY;z;0b;0b;100;1000); // Parameters
    (0;`COMBINED;1); // Expected Account
    (   // accountId, side;amt;totalEntry;execCost;realizedPnl;unrealizedPnl;
        (0;`BOTH;100;100;l 1e9; 1000; 1000; 1000);
        (0;`LONG;100;100;l 1e9; 1000; 1000; 1000);
        (0;`SHORT;100;100;l 1e9; 1000; 1000; 1000)
    );
    () // Expected events
    ]];