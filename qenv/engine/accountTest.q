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

// Test Utilities
// -------------------------------------------------------------->

deRef   :{x[y]:`long$(x[y]);:x};
rmFkeys :{cols[x] except key[fkeys x]};
setupAccount      : {if[count[x[`cAcc]]>0;.account.NewAccount[x[`cAcc];.z.z]]}
setupInventory    : {if[count[x[`cInv]]>0;{.account.NewInventory[x;.z.z]} each x[`cInv]]}

// @x : params
// @y : case
checkInventory     :{
    einv:x[`eInv];
    cx:count[einv];
    if[cx;[
            {
                y:enlist y;
                s:string[first[y][`side]];
                rinv:enlist .account.Inventory@(first[y][`accountId`side]);
                eInvCols: rmFkeys[rinv] inter cols[y];
                .qt.A[count[rinv];>;0;s," inventory exists";x];
                .qt.A[(eInvCols#0!rinv);~;(eInvCols#0!y);s," inventory";x];
            }[y] each einv;
            ]];
    };

checkAccount      :{
    eacc:enlist x[`eAcc];
    cx:count[eacc];
    if[count[eacc]>0;
            racc:enlist .account.Account@eacc[`accountId];
            eAccCols: rmFkeys[racc] inter cols[eacc];
            .qt.A[(eAccCols#0!racc);~;(eAccCols#0!eacc);"account";y];
            ];
    };



// Before and after defaults
// -------------------------------------------------------------->

defaultAfterEach: {
     delete from `.account.Account;
     delete from `.account.Inventory;
     delete from `.event.Events;
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
        checkAccount[p;c];
        checkInventory[p;c];

    };();({};{};defaultBeforeEach;defaultAfterEach);""];

deriveCaseParams :{[p]

    // Construct Current Account
    cAcc:(`accountId`positionType`balance`available`frozen,
    `orderMargin`posMargin`activeFeeId`realizedPnl)!p[0];
    
    // Construct Current Inventory
    cInv:flip[(`accountId`side`amt`totalEntry`execCost`realizedPnl)!flip[p[1]]];

    // Construct Fill
    f:`accountId`instrumentId`side`time`reduceOnly`isMaker`price`qty!p[2];
    f[`accountId]: `.account.Account!f[`accountId];
    f[`instrumentId]: `.instrument.Instrument!f[`instrumentId];
    f[`side]: `.order.ORDERSIDE$f[`side]; 

    // Construct Expected Account
    eAcc:(`accountId`balance`available`frozen`orderMargin`posMargin`bankruptPrice,
    `liquidationPrice`unrealizedPnl`realizedPnl`tradeCount`netLongPosition`netShortPosition,
    `openBuyOrderQty`openSellOrderQty`openBuyOrderPremium`openSellOrderPremium)!p[4];

    // Construct Expected Inventory
    eInv:flip[(`accountId`side`amt`totalEntry`execCost`realizedPnl`unrealizedPnl)!flip[p[5]]];

    :`cAcc`cInv`fill`markPrice`eAcc`eInv`eEvents!(
        cAcc;
        cInv;
        f;
        p[3];
        eAcc;
        eInv;
        p[6]
        );
    };


.qt.AddCase[test;"hedged:long_to_longer ";deriveCaseParams[(
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;
    // activeMakerFee;activeTakerFee;realizedPnl
    (0;`HEDGED;1;1;0;0;0;1;0); // Current Account
    (
        (0;`BOTH;100;100;l 1e9; 1000);
        (0;`LONG;100;100;l 1e9; 1000);
        (0;`SHORT;100;100;l 1e9; 1000)
    );
    //`accountId`instrumentId`side`time`reduceOnly`isMaker`price`qty
    (0;0;`BUY;z;0b;1b;1000;1000); // Parameters
    1000; // Mark Price
    // `accountId`balance`available`frozen`orderMargin`posMargin`bankruptPrice,
    // `liquidationPrice`unrealizedPnl`realizedPnl`tradeCount`netLongPosition`netShortPosition,
    // `openBuyOrderQty`openSellOrderQty`openBuyOrderPremium`openSellOrderPremium,
    (0;1;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0); // Expected Account
    (   // accountId, side;amt;totalEntry;execCost;realizedPnl;unrealizedPnl;
        (0;`BOTH;100;100;l 1e9; 1000; 0);
        (0;`LONG;100;100;l 1e9; 1000; 0);
        (0;`SHORT;100;100;l 1e9; 1000; 0)
    );
    () // Expected events
    )]];



.qt.RunTests[];