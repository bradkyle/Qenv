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
setupAccount      : {if[count[x[`cAcc]]>0;.account.NewAccount[x[`cAcc];.z.z]]};
setupInventory    : {if[count[x[`cInv]]>0;{.account.NewInventory[x;.z.z]} each x[`cInv]]};
setupInstrument   : {if[count[x[`cIns]]>0;.instrument.NewInstrument[x[`cIns];.z.z]]};

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
     delete from `.instrument.Instrument;
     delete from `.event.Events;
    };

setupB:({};{};{};{});

// AvgPrice
// -------------------------------------------------------------->

test:.qt.Unit[
    ".account.avgPrice";
    {[c]
        p:c[`params];
        res: .account.avgPrice[p[0];p[1];p[2]];
        .qt.A[res;=;p[3];c];

    };();setupB;""];

.qt.AddCase[test;"";(1;100;100;100)];


// UnrealizedPnl
// -------------------------------------------------------------->


test:.qt.Unit[
    ".account.unrealizedPnl";
    {[c]

        p:c[`params];
        res: .account.unrealizedPnl[p[0];p[1];p[2];p[3]];
        .qt.A[res;=;p[4];c];

    };();setupB;""];

// RealizedPnl
// -------------------------------------------------------------->

test:.qt.Unit[
    ".account.realizedPnl";
    {[c]
        p:c[`params]; 
        res: .account.realizedPnl[p[0];p[1];p[2];p[3]];
        .qt.A[res;=;p[4];c];   

    };();setupB;""];
    

.qt.AddCase[test;"";(
    `BUY;
    `totalEntry`execCost!();
    `()
    )];

// LiquidationPrice
// -------------------------------------------------------------->
// TODO tick size

test:.qt.Unit[
    ".account.liquidationPrice";
    {[c]
        p:c[`params];

        res:.account.liquidationPrice[
            p[`account];
            p[`inventoryB];
            p[`inventoryL];
            p[`inventoryS];
            p[`instrument]];

        .qt.A[res;=;p[`eRes];"liquidationPrice";c];

    };();setupB;""];

deriveCaseParams    :{[p]
    aCols:`balance`available`positionType`leverage;
    invCols:`side`amt`isignum`execCost`totalEntry;
    insCols:`contractType`riskTiers`riskBuffer`faceValue;

    :`account`inventoryB`inventoryL`inventoryS`instrument`eRes!(
        aCols!p[0];
        invCols!p[1]; // BOTH position
        invCols!p[2];
        invCols!p[3];
        insCols!p[4];
        p[5]);
    };

// Simulation of vanilla contracts
// vanilla uses
.qt.AddCase[test;"Vanilla (Binance) Hedged Full Long";deriveCaseParams[(
    (1e3;1;`HEDGED;25); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;55000;1;55e8;55000); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`VANILLA;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1); // Instrument
    985.84
    )]];

.qt.AddCase[test;"Vanilla (Binance) Combined Full Long";deriveCaseParams[(
    (1e3;1;`HEDGED;25); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;55000;1;55e8;55000); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`VANILLA;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1); // Instrument
    985.84
    )]];

.qt.AddCase[test;"Inverse (Bitmex) Combined Full Long: 1000 USD balance";deriveCaseParams[(
    (1;1;`COMBINED;100); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;55000;1;55e8;55000); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskProcedural[200;100;0.0035;0.01;100;40];0;1); // Instrument
    998.0
    )]];

.qt.AddCase[test;"Inverse (Okex) Hedged Full Long";deriveCaseParams[(
    (1e3;1;`HEDGED;25); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;55000;1;55e8;55000); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskTier[(
        50000     0.005    0.01    100f;
        300000    0.01     0.015   66.66f
    )];0;100); // Instrument
    987.6
    )]];

.qt.AddCase[test;"Inverse (Okex) Combined Full Long";deriveCaseParams[(
    (1;1;`COMBINED;25); // Account
    (`BOTH;550;1;55e8;550); // Both Position
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskTier[(
        50000     0.005    0.01    100f;
        300000    0.01     0.015   66.66f
    )];0;100); // Instrument
    987.6
    )]];

.qt.AddCase[test;"Inverse (Huobi) Combined Full Long";deriveCaseParams[(
    (1;1;`COMBINED;10); // Account
    // side;amt;isignum;execCost;totalEntry
    (`BOTH;55000;1;55e8;55000); // Both Position
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1); // Instrument
    1024.8
    )]];

// BankruptcyPrice
// -------------------------------------------------------------->

test:.qt.Unit[
    ".account.bankruptcyPrice";
    {[c]
        p:c[`params];
        setupInstrument[p];
        setupAccount[p];
        setupInventory[p];

        res:.account.bankruptcyPrice[];

    };();setupB;""];

.qt.AddCase[test;"";(
    `BUY;
    `totalEntry`execCost!();
    `()
    )];

// ApplyFill
// -------------------------------------------------------------->

test:.qt.Unit[
    ".account.ApplyFill";
    {[c]
        p:c[`params];
        setupInstrument[p];
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

    cIns:(`instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier)!p[0];

    // Construct Current Account
    cAcc:(`accountId`positionType`balance`available`frozen,
    `orderMargin`posMargin`activeFeeId`realizedPnl)!p[1];
    
    // Construct Current Inventory
    cInv:flip[(`accountId`side`amt`totalEntry`execCost`realizedPnl)!flip[p[2]]];

    // Construct Fill
    f:`accountId`instrumentId`side`time`reduceOnly`isMaker`price`qty!p[3];
    f[`accountId]: `.account.Account!f[`accountId];
    f[`instrumentId]: `.instrument.Instrument!f[`instrumentId];
    f[`side]: `.order.ORDERSIDE$f[`side]; 

    // Construct Expected Account
    eAcc:(`accountId`balance`available`frozen`orderMargin`posMargin`bankruptPrice,
    `liquidationPrice`unrealizedPnl`realizedPnl`tradeCount`netLongPosition`netShortPosition,
    `openBuyOrderQty`openSellOrderQty`openBuyOrderPremium`openSellOrderPremium)!p[5];

    // Construct Expected Inventory
    eInv:flip[(`accountId`side`amt`totalEntry`execCost`realizedPnl`unrealizedPnl)!flip[p[6]]];

    :`cIns`cAcc`cInv`fill`markPrice`eAcc`eInv`eEvents!(
        cIns;
        cAcc;
        cInv;
        f;
        p[4];
        eAcc;
        eInv;
        p[7]
        );
    };


.qt.AddCase[test;"hedged:long_to_longer ";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
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





// Update Mark Price
// -------------------------------------------------------------->
 
test:.qt.Unit[
    ".account.UpdateMarkPrice";
    {[c]
        p:c[`params];  
        setupOrders[p];

        p1:p[`eNewOrder];  

        // instantiate mock for ApplyFill
        mck1: .qt.M[`.order.CancelAllOrders;{[a;b]};c];

        res:.account.UpdateMarkPrice[
            p[`markPrice];
            p[`instrumentId];
            .z.z]; // TODO assert throws?

        .qt.MA[
            mck1;
            p1[`called];
            p1[`numCalls];
            p1[`calledWith];c];


    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for updating the mark price with respect to the account namespace"];


deriveCaseParams    :{[params] 
    mCols:`called`numCalls`calledWith; // Mock specific
    pCols:`markPrice`instrumentId`time;

    makeOrdersEx :{
    :$[count[x]>0;[ 
        // Side, Price, Size
        :{:(`clId`instrumentId`accountId`side`otype`offset`leaves`price`status!(
            x[0];x[1];x[2];(`.order.ORDERSIDE$x[3]);(`.order.ORDERTYPE$x[4]);x[5];x[6];x[7];(`.order.ORDERSTATUS$x[8]));x[9])} each flip[x];
        ];()]};

    nom:(`fn,mCols)!params[6];

    p:`cOB`cOrd`params`eNewOrder!(
        makeDepthUpdate[params[0]]; 
        makeOrders[params[1]];
        pCols!params[2];
        nom  
        );
    :p;
    };



.qt.RunTests[];