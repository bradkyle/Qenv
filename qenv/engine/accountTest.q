\l account.q
\l instrument.q
\l event.q
\l order.q
system "d .accountTest";
\l util.q
\cd ../quantest/
\l quantest.q 
\cd ../engine/


l: `long$
z:.z.z;
sc:{x+(`second$y)};
sz:sc[z];
dts:{(`date$x)+(`second$x)};
dtz:{dts[sc[x;y]]}[z]
doz:`date$z;
dozc:{x+y}[doz];

// Test data generation
// -------------------------------------------------------------->

// Test Utilities
// -------------------------------------------------------------->

deRef   :{x[y]:`long$(x[y]);:x};
rmFkeys :{cols[x] except key[fkeys x]};
setupAccount      : {if[count[x[`cAcc]]>0;[.account.NewAccount[x[`cAcc];.z.z]; :exec from .account.Account where accountId=x[`cAcc][`accountId]]]};
setupInventory    : {if[count[x[`cInv]]>0;{.account.NewInventory[x;.z.z]} each x[`cInv]]};
setupInstrument   : {if[count[x[`cIns]]>0;.instrument.NewInstrument[x[`cIns];.z.z]]};
setupDepth      : {if[count[x[`cOB]]>0;.order.ProcessDepthUpdateEvent[x[`cOB]]]}
setupOrders     : {if[count[x[`cOrd]]>0;{.order.NewOrder[x[0];x[1]]} each x[`cOrd]]}

makeOrders :{
    :$[count[x]>0;[ 
        // Side, Price, Size
        :{:(`clId`instrumentId`accountId`side`otype`offset`size`price!(
            x[0];x[1];x[2];(`.order.ORDERSIDE$x[3]);(`.order.ORDERTYPE$x[4]);x[5];x[6];x[7]);x[8])} each flip[x];
        ];()]};

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


// ApplyFunding
// ==================================================================================>

test:.qt.Unit[
    ".account.ApplyFunding";
    {[c]
        p:c[`params];
        setupInstrument[p];
        setupAccount[p];
        setupInventory[p];

        f:p[`funding];
        .account.ApplyFunding[];
        
        // Assertions
        checkAccount[p;c];
        checkInventory[p;c];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Adds a given fill amount to the account's respective inventory depending on configuration"];

deriveCaseParams :{[p]

    cIns:(`instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier)!p[0];

    // Construct Current Account
    cAcc:(`accountId`positionType`balance`available`frozen,
    `orderMargin`posMargin`activeFeeId`realizedPnl)!p[1];
    
    // Construct Current Inventory
    cInv:flip[(`accountId`side`amt`totalEntry`execCost`realizedPnl)!flip[p[2]]];

    // Construct Funding
    f:`fundingRate`nextFundingRate`nextFundingTime`time!p[3];

    // Construct Expected Account
    eAcc:(`accountId`balance`available`frozen`orderMargin`posMargin`bankruptPrice,
    `liquidationPrice`unrealizedPnl`realizedPnl`tradeCount`netLongPosition`netShortPosition,
    `openBuyOrderQty`openSellOrderQty`openBuyOrderPremium`openSellOrderPremium)!p[5];

    // Construct Expected Inventory
    eInv:flip[(`accountId`side`amt`totalEntry`execCost`realizedPnl`unrealizedPnl)!flip[p[6]]];

    :`cIns`cAcc`cInv`funding`markPrice`eAcc`eInv`eEvents!(
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

.qt.AddCase[test;"No funding occurs";deriveCaseParams[(
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
    //`fundingRate;nextFundingRate;nextFundingTime;time
    (0.1;0.1;sz 5;z); // Parameters
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

.qt.AddCase[test;"- Funding occurs with hedged long position";deriveCaseParams[(
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
    (0.0;0.1;sz 5;z); // Parameters
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


.qt.AddCase[test;"- Funding occurs with hedged short position";deriveCaseParams[(
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
    (0.0;0.1;sz 5;z); // Parameters
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

.qt.AddCase[test;"+ Funding occurs with hedged long position";deriveCaseParams[(
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
    (0.0;0.1;sz 5;z); // Parameters
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


.qt.AddCase[test;"+ Funding occurs with hedged short position";deriveCaseParams[(
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
    (0.0;0.1;sz 5;z); // Parameters
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

.qt.AddCase[test;"- Funding occurs with split hedged short/long position";deriveCaseParams[(
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
    (0.0;0.1;sz 5;z); // Parameters
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


.qt.AddCase[test;"- Funding occurs with split hedged long/short position";deriveCaseParams[(
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
    (0.0;0.1;sz 5;z); // Parameters
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

.qt.AddCase[test;"+ Funding occurs with split hedged short/long position";deriveCaseParams[(
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
    (0.0;0.1;sz 5;z); // Parameters
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


.qt.AddCase[test;"+ Funding occurs with split hedged long/short position";deriveCaseParams[(
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
    (0.0;0.1;sz 5;z); // Parameters
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

.qt.AddCase[test;"+ Funding occurs with combined long position";deriveCaseParams[(
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
    (0.0;0.1;sz 5;z); // Parameters
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


.qt.AddCase[test;"- Funding occurs with combined short position";deriveCaseParams[(
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
    (0.0;0.1;sz 5;z); // Parameters
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


// Deposit
// ==================================================================================>

test:.qt.Unit[
    ".account.Deposit";
    {[c]
        p:c[`params];
        setupInstrument[p];
        setupAccount[p];
        setupInventory[p];

        f:p[`fill];
        .account.Deposit[];
        
        // Assertions
        checkAccount[p;c];
        checkInventory[p;c];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Adds a given fill amount to the account's respective inventory depending on configuration"];

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


.qt.AddCase[test;"deposit invalid account";deriveCaseParams[(
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


.qt.AddCase[test;"deposit amount too small";deriveCaseParams[(
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


.qt.AddCase[test;"deposit amount too large";deriveCaseParams[(
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


.qt.AddCase[test;"deposit";deriveCaseParams[(
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

// Withdraw
// ==================================================================================>

test:.qt.Unit[
    ".account.Withdraw";
    {[c]
        p:c[`params];
        setupInstrument[p];
        setupAccount[p];
        setupInventory[p];

        f:p[`fill];
        .account.Withdraw[];
        
        // Assertions
        checkAccount[p;c];
        checkInventory[p;c];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Adds a given fill amount to the account's respective inventory depending on configuration"];

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

.qt.AddCase[test;"withdraw invalid account id";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;
    // activeMakerFee;activeTakerFee;realizedPnl
    (0;`HEDGED;1;1;0;0;0;1;0); // Current Account
    ();
    //`accountId`instrumentId`side`time`reduceOnly`isMaker`price`qty
    (0;0;`BUY;z;0b;1b;1000;1000); // Parameters
    1000; // Mark Price
    // `accountId`balance`available`frozen`orderMargin`posMargin`bankruptPrice,
    // `liquidationPrice`unrealizedPnl`realizedPnl`tradeCount`netLongPosition`netShortPosition,
    // `openBuyOrderQty`openSellOrderQty`openBuyOrderPremium`openSellOrderPremium,
    (0;1;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0); // Expected Account
    ();
    () // Expected events
    )]];

.qt.AddCase[test;"withdraw amount too small";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;
    // activeMakerFee;activeTakerFee;realizedPnl
    (0;`HEDGED;1;1;0;0;0;1;0); // Current Account
    ();
    //`accountId`instrumentId`side`time`reduceOnly`isMaker`price`qty
    (0;0;`BUY;z;0b;1b;1000;1000); // Parameters
    1000; // Mark Price
    // `accountId`balance`available`frozen`orderMargin`posMargin`bankruptPrice,
    // `liquidationPrice`unrealizedPnl`realizedPnl`tradeCount`netLongPosition`netShortPosition,
    // `openBuyOrderQty`openSellOrderQty`openBuyOrderPremium`openSellOrderPremium,
    (0;1;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0); // Expected Account
    ();
    () // Expected events
    )]];

.qt.AddCase[test;"withdraw amount too large";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;
    // activeMakerFee;activeTakerFee;realizedPnl
    (0;`HEDGED;1;1;0;0;0;1;0); // Current Account
    ();
    //`accountId`instrumentId`side`time`reduceOnly`isMaker`price`qty
    (0;0;`BUY;z;0b;1b;1000;1000); // Parameters
    1000; // Mark Price
    // `accountId`balance`available`frozen`orderMargin`posMargin`bankruptPrice,
    // `liquidationPrice`unrealizedPnl`realizedPnl`tradeCount`netLongPosition`netShortPosition,
    // `openBuyOrderQty`openSellOrderQty`openBuyOrderPremium`openSellOrderPremium,
    (0;1;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0); // Expected Account
    ();
    () // Expected events
    )]];

.qt.AddCase[test;"withdraw sufficient balance";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;
    // activeMakerFee;activeTakerFee;realizedPnl
    (0;`HEDGED;1;1;0;0;0;1;0); // Current Account
    ();
    //`accountId`instrumentId`side`time`reduceOnly`isMaker`price`qty
    (0;0;`BUY;z;0b;1b;1000;1000); // Parameters
    1000; // Mark Price
    // `accountId`balance`available`frozen`orderMargin`posMargin`bankruptPrice,
    // `liquidationPrice`unrealizedPnl`realizedPnl`tradeCount`netLongPosition`netShortPosition,
    // `openBuyOrderQty`openSellOrderQty`openBuyOrderPremium`openSellOrderPremium,
    (0;1;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0); // Expected Account
    ();
    () // Expected events
    )]];


.qt.AddCase[test;"withdraw insufficient balance";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;
    // activeMakerFee;activeTakerFee;realizedPnl
    (0;`HEDGED;1;1;0;0;0;1;0); // Current Account
    ();
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


.qt.AddCase[test;"withdraw insufficient balance with inventory";deriveCaseParams[(
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

.qt.AddCase[test;"withdraw sufficient balance with inventory";deriveCaseParams[(
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

// AveragePrice
// ==================================================================================>
// TODO fix // TODO total entry=0, execCost=0 etc.
test:.qt.Unit[
    ".account.avgPrice";
    {[c]
        p:c[`params];

        a:p[0];
        res: .account.avgPrice[a[0];a[1];a[2];a[3]];
        .qt.A[res;=;p[1];"avgPrice";c];

    };();();setupB;
    "The average entry price of a given inventory"];

.qt.AddCase[test;"(Linear) hedged long position avgPrice one entry";((1;7964637;1000;1b);12556.5)];
.qt.AddCase[test;"(Linear) hedged long position avgPrice multiple entry";((1;797e5;100000;1b);12545.5)];
.qt.AddCase[test;"(Linear) hedged long position avgPrice one entry";((-1;7964637;1000;1b);12554.93)];
.qt.AddCase[test;"(Linear) hedged short position avgPrice multiple entry";((1;797e5;100000;1b);12545.5)];
.qt.AddCase[test;"(Linear) combined short position avgPrice one entry";((1;797e5;100000;1b);12545.5)];
.qt.AddCase[test;"(Linear) combined short position avgPrice multiple entry";((1;797e5;100000;1b);12545.5)];
.qt.AddCase[test;"(Linear) combined long position avgPrice one entry";((1;797e5;100000;1b);12545.5)];
.qt.AddCase[test;"(Linear) combined long position avgPrice multiple entry";((1;797e5;100000;1b);12545.5)];

.qt.AddCase[test;"(Inverse) hedged long position avgPrice one entry";((1;797e5;100000;1b);12545.5)];
.qt.AddCase[test;"(Inverse) hedged long position avgPrice multiple entry";((1;797e5;100000;1b);12545.5)];
.qt.AddCase[test;"(Inverse) hedged short position avgPrice one entry";((1;797e5;100000;1b);12545.5)];
.qt.AddCase[test;"(Inverse) hedged short position avgPrice multiple entry";((1;797e5;100000;1b);12545.5)];
.qt.AddCase[test;"(Inverse) combined short position avgPrice one entry";((1;797e5;100000;1b);12545.5)];
.qt.AddCase[test;"(Inverse) combined short position avgPrice multiple entry";((1;797e5;100000;1b);12545.5)];
.qt.AddCase[test;"(Inverse) combined long position avgPrice one entry";((1;797e5;100000;1b);12545.5)];
.qt.AddCase[test;"(Inverse) combined long position avgPrice multiple entry";((1;797e5;100000;1b);12545.5)];

/ .qt.SkpBes[24];

// UnrealizedPnl
// ==================================================================================>

test:.qt.Unit[
    ".account.unrealizedPnl";
    {[c]

        p:c[`params];

        a:p[0];
        res: .account.unrealizedPnl[a[0];a[1];a[2];a[3]];
        .qt.A[res;=;p[1];"unrealizedPnl";c];

    };();();setupB;
    "The unrealized profit of a given inventory"];

.qt.AddCase[test;"LINEAR (Binance) unrealized pnl short loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"LINEAR (Binance) unrealized pnl short gain";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"LINEAR (Binance) unrealized pnl long loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"LINEAR (Binance) unrealized pnl long gain";((1000;1001;100;1;-1;0b);100)];

.qt.AddCase[test;"Inverse (Bitmex) unrealized pnl short loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Bitmex) unrealized pnl short gain";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Bitmex) unrealized pnl long loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Bitmex) unrealized pnl long gain";((1000;1001;100;1;-1;0b);100)];

.qt.AddCase[test;"LINEAR (Okex) unrealized pnl short loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"LINEAR (Okex) unrealized pnl short gain";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"LINEAR (Okex) unrealized pnl long loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"LINEAR (Okex) unrealized pnl long gain";((1000;1001;100;1;-1;0b);100)];

.qt.AddCase[test;"Inverse (Okex) unrealized pnl short loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Okex) unrealized pnl short gain";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Okex) unrealized pnl long loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Okex) unrealized pnl long gain";((1000;1001;100;1;-1;0b);100)];

.qt.AddCase[test;"Inverse (Huobi) unrealized pnl short loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Huobi) unrealized pnl short gain";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Huobi) unrealized pnl long loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Huobi) unrealized pnl long gain";((1000;1001;100;1;-1;0b);100)];


// RealizedPnl
// ==================================================================================>

test:.qt.Unit[
    ".account.realizedPnl";
    {[c]
        p:c[`params]; 
        a:p[0];
        res: .account.realizedPnl[a[0];a[1];a[2];a[3]];
        .qt.A[res;=;p[1];"realizedPnl";c];   

    };();();setupB;
    "The realized profit incurred by placing an order"];

// Simulation of LINEAR contracts
// LINEAR uses

.qt.AddCase[test;"LINEAR (Binance) realized pnl short loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"LINEAR (Binance) realized pnl short gain";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"LINEAR (Binance) realized pnl long loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"LINEAR (Binance) realized pnl long gain";((1000;1001;100;1;-1;0b);100)];

.qt.AddCase[test;"Inverse (Bitmex) realized pnl short loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Bitmex) realized pnl short gain";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Bitmex) realized pnl long loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Bitmex) realized pnl long gain";((1000;1001;100;1;-1;0b);100)];

.qt.AddCase[test;"LINEAR (Okex) realized pnl short loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"LINEAR (Okex) realized pnl short gain";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"LINEAR (Okex) realized pnl long loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"LINEAR (Okex) realized pnl long gain";((1000;1001;100;1;-1;0b);100)];

.qt.AddCase[test;"Inverse (Okex) realized pnl short loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Okex) realized pnl short gain";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Okex) realized pnl long loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Okex) realized pnl long gain";((1000;1001;100;1;-1;0b);100)];

.qt.AddCase[test;"Inverse (Huobi) realized pnl short loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Huobi) realized pnl short gain";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Huobi) realized pnl long loss";((1000;1001;100;1;-1;0b);100)];
.qt.AddCase[test;"Inverse (Huobi) realized pnl long gain";((1000;1001;100;1;-1;0b);100)];

// LiquidationPrice
// ==================================================================================>
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

    };();();setupB;
    "The price above the bankruptcy price at which liquidation will occur"];

deriveCaseParams    :{[p]
    aCols:`balance`available`positionType`leverage;
    invCols:`side`amt`isignum`execCost`totalEntry;
    insCols:`contractType`riskTiers`riskBuffer`faceValue`tickSize`lotSize;

    :`account`inventoryB`inventoryL`inventoryS`instrument`eRes!(
        aCols!p[0];
        invCols!p[1]; // BOTH position
        invCols!p[2];
        invCols!p[3];
        insCols!p[4];
        p[5]);
    };


// Binance
// ------------------------------------------------------------------------->

// Simulation of LINEAR contracts
// LINEAR uses // TODO precision
.qt.AddCase[test;"LINEAR (Binance) Combined Full Long (first tier)";deriveCaseParams[(
    (1e3;1e3;`HEDGED;25); // Account
    (`BOTH;1;1;7964.637;1); // Both Position price:12555.5
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    11601.90 // actually .91
    )]];

.qt.AddCase[test;"LINEAR (Binance) Combined Full Short (first tier)";deriveCaseParams[(
    (1e3;1e3;`HEDGED;25); // Account
    (`BOTH;1;-1;7964.637;1); // Both Position price:12555.5
    (`LONG;0;1;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    13501.5 // actually .49
    )]];

.qt.AddCase[test;"LINEAR (Binance) Hedged Full Long (first tier)";deriveCaseParams[(
    (1e3;1e3;`HEDGED;25); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;1;1;7964.637;1); // Long Position price:12555.5
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    11601.9 // actually .91
    )]];

.qt.AddCase[test;"LINEAR (Binance) Hedged Full Short (first tier)";deriveCaseParams[(
    (1e3;1e3;`HEDGED;25); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;0;0;0;0); // Long Position price:12555.5
    (`SHORT;1;-1;7964.637;1); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    13501.5 // actually .49
    )]];

// Second tier

.qt.AddCase[test;"LINEAR (Binance) Combined Full Long (second tier)";deriveCaseParams[(
    (1e3;1e3;`HEDGED;25); // Account
    (`BOTH;5;1;7964.637;1); // Both Position price:12555.5
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    12407.54 // actually .91
    )]];

.qt.AddCase[test;"LINEAR (Binance) Combined Full Short (second tier)";deriveCaseParams[(
    (1e3;1e3;`HEDGED;25); // Account
    (`BOTH;5;-1;7964.637;1); // Both Position price:12555.5
    (`LONG;0;1;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    12701.99 // actually .49
    )]];

.qt.AddCase[test;"LINEAR (Binance) Hedged Full Long (second tier)";deriveCaseParams[(
    (1e3;1e3;`HEDGED;25); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;5;1;7964.637;1); // Long Position price:12555.5
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    12407.54 // actually .91
    )]];

.qt.AddCase[test;"LINEAR (Binance) Hedged Full Short (second tier)";deriveCaseParams[(
    (1e3;1e3;`HEDGED;25); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;0;0;0;0); // Long Position price:12555.5
    (`SHORT;5;-1;7964.637;1); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    12701.99 // actually .49
    )]];

// TODO half short etc.

// Bitmex
// ------------------------------------------------------------------------->

.qt.AddCase[test;"Inverse (Bitmex) Combined Full Long: 1000 USD balance";deriveCaseParams[(
    (1;1;`COMBINED;100); // Account
    (`BOTH;55000;1;55e8;55000); // Both Position price 1000
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskProcedural[200;100;0.0035;0.01;100;40];((0.00075*2)+0.0001);1;0.5;1); // Instrument
    987.5
    )]];

.qt.AddCase[test;"Inverse (Bitmex) Combined Full Short: 1000 USD balance";deriveCaseParams[(
    (1;1;`COMBINED;100); // Account
    (`BOTH;55000;-1;55e8;55000); // Both Position
    (`LONG;0;1;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskProcedural[200;100;0.0035;0.01;100;40];((0.00075*2)+0.0001);1;0.5;1); // Instrument
    1006.5
    )]];


// Okex
// ------------------------------------------------------------------------->

.qt.AddCase[test;"Inverse (Okex) Hedged Full Long";deriveCaseParams[(
    (1e3;1;`HEDGED;25); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;55000;1;55e8;55000); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskTier[(
        50000     0.005    0.01    100f;
        300000    0.01     0.015   66.66f
    )];0;100;0.1;1); // Instrument
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
    )];0;100;0.1;1); // Instrument
    987.6
    )]];

.qt.AddCase[test;"LINEAR (Okex) Hedged Full Long";deriveCaseParams[(
    (1e3;1;`HEDGED;25); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;55000;1;55e8;55000); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000     0.005    0.01    100f;
        300000    0.01     0.015   66.66f
    )];0;0.01;0.1;1); // Instrument
    987.6
    )]];

// `contractType`riskTiers`riskBuffer`faceValue`tickSize`lotSize
.qt.AddCase[test;"LINEAR (Okex) Combined Full Long";deriveCaseParams[(
    (1;1;`COMBINED;25); // Account
    (`BOTH;550;1;55e8;550); // Both Position
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000     0.005    0.01    100f;
        300000    0.01     0.015   66.66f
    )];0;0.01;0.1;1); // Instrument TODO check
    987.6
    )]];


// Huobi
// ------------------------------------------------------------------------->

.qt.AddCase[test;"Inverse (Huobi) Combined Full Long";deriveCaseParams[(
    (1;1;`COMBINED;10); // Account
    // side;amt;isignum;execCost;totalEntry
    (`BOTH;55000;1;55e8;55000); // Both Position
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;0.01;0.1;1); // Instrument
    1024.8
    )]];

.qt.AddCase[test;"Inverse (Huobi) Combined Full Short";deriveCaseParams[(
    (1;1;`COMBINED;10); // Account
    // side;amt;isignum;execCost;totalEntry
    (`BOTH;55000;-1;55e8;55000); // Both Position
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;0.01;0.1;1); // Instrument
    1024.8
    )]];

// BankruptcyPrice
// ==================================================================================>

test:.qt.Unit[
    ".account.bankruptcyPrice";
    {[c]
        p:c[`params];

        res:.account.bankruptcyPrice[
            p[`account];
            p[`inventoryB];
            p[`inventoryL];
            p[`inventoryS];
            p[`instrument]];

        .qt.A[res;=;p[`eRes];"bankruptcyPrice";c];

    };();();setupB;
    "The price at which the account will be bankrupt"];


// Binance
// ------------------------------------------------------------------------->

// Simulation of LINEAR contracts
// LINEAR uses
.qt.AddCase[test;"LINEAR (Binance) Combined Full Long";deriveCaseParams[(
    (1e3;1;`HEDGED;25); // Account
    (`BOTH;55000;1;55e8;55000); // Both Position
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    985.84
    )]];

.qt.AddCase[test;"LINEAR (Binance) Combined Full Long";deriveCaseParams[(
    (1e3;1;`HEDGED;25); // Account
    (`BOTH;55000;-1;55e8;55000); // Both Position
    (`LONG;0;1;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    985.84
    )]];

.qt.AddCase[test;"LINEAR (Binance) Combined Full Short";deriveCaseParams[(
    (1e3;1;`HEDGED;25); // Account
    (`BOTH;55000;1;55e8;55000); // Both Position
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    985.84
    )]];

.qt.AddCase[test;"LINEAR (Binance) Combined Full Short";deriveCaseParams[(
    (1e3;1;`HEDGED;25); // Account
    (`BOTH;55000;-1;55e8;55000); // Both Position
    (`LONG;0;1;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    985.84
    )]];

.qt.AddCase[test;"LINEAR (Binance) Hedged Full Long";deriveCaseParams[(
    (1e3;1;`HEDGED;25); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;55000;1;55e8;55000); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    985.84
    )]];

.qt.AddCase[test;"LINEAR (Binance) Hedged Full Short";deriveCaseParams[(
    (1e3;1;`HEDGED;25); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;55000;1;55e8;55000); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;1;0.01;0.001); // Instrument
    985.84
    )]];

// TODO half short etc.

// Bitmex
// ------------------------------------------------------------------------->

.qt.AddCase[test;"Inverse (Bitmex) Combined Full Long: 1000 USD balance";deriveCaseParams[(
    (1;1;`COMBINED;100); // Account
    (`BOTH;55000;1;55e8;55000); // Both Position
    (`LONG;0;1;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskProcedural[200;100;0.0035;0.01;100;40];0;1;0.5;1); // Instrument
    998.0
    )]];

.qt.AddCase[test;"Inverse (Bitmex) Combined Full Short: 1000 USD balance";deriveCaseParams[(
    (1;1;`COMBINED;100); // Account
    (`BOTH;55000;-1;55e8;55000); // Both Position
    (`LONG;0;1;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskProcedural[200;100;0.0035;0.01;100;40];0;1;0.5;1); // Instrument
    998.0
    )]];


// Okex
// ------------------------------------------------------------------------->

.qt.AddCase[test;"Inverse (Okex) Hedged Full Long";deriveCaseParams[(
    (1e3;1;`HEDGED;25); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;55000;1;55e8;55000); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskTier[(
        50000     0.005    0.01    100f;
        300000    0.01     0.015   66.66f
    )];0;100;0.1;1); // Instrument
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
    )];0;100;0.1;1); // Instrument
    987.6
    )]];

.qt.AddCase[test;"LINEAR (Okex) Hedged Full Long";deriveCaseParams[(
    (1e3;1;`HEDGED;25); // Account
    (`BOTH;0;0;0;0); // Both Position
    (`LONG;55000;1;55e8;55000); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000     0.005    0.01    100f;
        300000    0.01     0.015   66.66f
    )];0;0.01;0.1;1); // Instrument
    987.6
    )]];

// `contractType`riskTiers`riskBuffer`faceValue`tickSize`lotSize
.qt.AddCase[test;"LINEAR (Okex) Combined Full Long";deriveCaseParams[(
    (1;1;`COMBINED;25); // Account
    (`BOTH;550;1;55e8;550); // Both Position
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`LINEAR;.instrument.NewRiskTier[(
        50000     0.005    0.01    100f;
        300000    0.01     0.015   66.66f
    )];0;0.01;0.1;1); // Instrument TODO check
    987.6
    )]];


// Huobi
// ------------------------------------------------------------------------->

.qt.AddCase[test;"Inverse (Huobi) Combined Full Long";deriveCaseParams[(
    (1;1;`COMBINED;10); // Account
    // side;amt;isignum;execCost;totalEntry
    (`BOTH;55000;1;55e8;55000); // Both Position
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;0.01;0.1;1); // Instrument
    1024.8
    )]];

.qt.AddCase[test;"Inverse (Huobi) Combined Full Short";deriveCaseParams[(
    (1;1;`COMBINED;10); // Account
    // side;amt;isignum;execCost;totalEntry
    (`BOTH;55000;-1;55e8;55000); // Both Position
    (`LONG;0;0;0;0); // Long Position 
    (`SHORT;0;0;0;0); // Short Position
    (`INVERSE;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )];0;0.01;0.1;1); // Instrument
    1024.8
    )]];

// UpdateOrderMargin
// ==================================================================================>

test:.qt.Unit[
    ".account.AddMargin";
    {[c]
        p:c[`params];
        acc:setupAccount[p];
        setupInventory[p];

        a:p[`args];

        $[all(null[p[`eThrows]]);[
            .account.AddMargin[a[0];a[1];a[2];acc;p[`cIns]];
        ];[
            .qt.AT[.account.AddMargin;(a[0];a[1];a[2];acc;p[`cIns]);p[`eThrows];"AddMargin";c];
        ]];
        
        // Assertions
        checkAccount[p;c];
        checkInventory[p;c];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Updates a given accounts order margin when it has enough margin etc. else returns error/failure"];

deriveCaseParams :{[p]

    cIns:(`instrumentId`contractType`tickSize`maxPrice,
    `minPrice`maxOrderSize`minOrderSize`priceMultiplier`markPrice`riskTiers)!p[0];

    // Construct Current Account
    cAcc:(`accountId`positionType`balance`available`frozen,
    `leverage`orderMargin`posMargin`activeFeeId`realizedPnl)!p[1];
    
    // Construct Current Inventory
    cInv:flip[(`accountId`side`amt`totalEntry`execCost`realizedPnl)!flip[p[2]]];

    // Construct Expected Account
    eAcc:(`accountId`balance`available`frozen`orderMargin`posMargin`bankruptPrice,
    `liquidationPrice`unrealizedPnl`realizedPnl`tradeCount`netLongPosition`netShortPosition,
    `openBuyOrderQty`openSellOrderQty`openBuyOrderPremium`openSellOrderPremium)!p[4];

    // Construct Expected Inventory
    eInv:flip[(`accountId`side`amt`totalEntry`execCost`realizedPnl`unrealizedPnl)!flip[p[5]]];

    :`cIns`cAcc`cInv`args`eAcc`eInv`eThrows!(
        cIns;
        cAcc;
        cInv;
        p[3];
        eAcc;
        eInv;
        p[6]
        );
    };

.qt.AddCase[test;"Order is placed with no premium and no previous order margin etc.";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier`markPrice
    (0;`LINEAR;0.5;1e9;0f;1e6f;0f;100;100f;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )]);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;
    // activeMakerFee;activeTakerFee;realizedPnl
    (0;`HEDGED;1000;1000;0;10;0;0;1;0); // Current Account
    (
        (0;`BOTH;100;100;l 1e9; 1000);
        (0;`LONG;100;100;l 1e9; 1000);
        (0;`SHORT;100;100;l 1e9; 1000)
    );
    //`fundingRate;nextFundingRate;nextFundingTime;time
    (-1;100;3); // Parameters
    // `accountId`balance`available`frozen`orderMargin`posMargin`bankruptPrice,
    // `liquidationPrice`unrealizedPnl`realizedPnl`tradeCount`netLongPosition`netShortPosition,
    // `openBuyOrderQty`openSellOrderQty`openBuyOrderPremium`openSellOrderPremium,
    (0;1;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0); // Expected Account
    (   // accountId, side;amt;totalEntry;execCost;realizedPnl;unrealizedPnl;
        (0;`BOTH;100;100;l 1e9; 1000; 0);
        (0;`LONG;100;100;l 1e9; 1000; 0);
        (0;`SHORT;100;100;l 1e9; 1000; 0)
    );
    0N
    )]];

.qt.AddCase[test;"Order is placed with premium and no previous order margin etc.";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier`markPrice
    (0;`LINEAR;0.5;1e9;0f;1e6f;0f;100;106f;.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f
    )]);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;
    // activeMakerFee;activeTakerFee;realizedPnl
    (0;`HEDGED;1000;1000;0;10;0;0;1;0); // Current Account
    (
        (0;`BOTH;100;100;l 1e9; 1000);
        (0;`LONG;100;100;l 1e9; 1000);
        (0;`SHORT;100;100;l 1e9; 1000)
    );
    //`isignum`price`qty`account`instrument
    (-1;100;3); // Parameters
    // `accountId`balance`available`frozen`orderMargin`posMargin`bankruptPrice,
    // `liquidationPrice`unrealizedPnl`realizedPnl`tradeCount`netLongPosition`netShortPosition,
    // `openBuyOrderQty`openSellOrderQty`openBuyOrderPremium`openSellOrderPremium,
    (0;1;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0); // Expected Account
    (   // accountId, side;amt;totalEntry;execCost;realizedPnl;unrealizedPnl;
        (0;`BOTH;100;100;l 1e9; 1000; 0);
        (0;`LONG;100;100;l 1e9; 1000; 0);
        (0;`SHORT;100;100;l 1e9; 1000; 0)
    );
    0N
    )]];

/ .qt.AddCase[test;"hedged: no positions, open buy (buy/sell) 70/30 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: no positions, open buy (buy/sell) 30/70 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: no positions, open buy (buy/sell) 50/50 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full long position, open buy";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full long position, open buy (buy/sell) 70/30 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full long position, open buy (buy/sell) 30/70 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full long position, open buy (buy/sell) 50/50 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full short position, open buy";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full short position, open buy (buy/sell) 70/30 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full short position, open buy (buy/sell) 30/70 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full short position, open buy (buy/sell) 50/50 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: 70% long and 30% short position, open buy no open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: 30% long and 70% short position, open buy no open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: 70% long and 30% short position, open buy, with open (buy/sell) 70/30 orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: 30% long and 70% short position, open buy, with open (buy/sell) 30/70 orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: 70% long and 30% short position, open buy, with open (buy/sell) 50/50 orders";deriveCaseParams[()]];

/ .qt.AddCase[test;"hedged: no positions, open sell";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: no positions, open sell (buy/sell) 70/30 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: no positions, open sell (buy/sell) 30/70 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: no positions, open sell (buy/sell) 50/50 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full long position, open sell";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full long position, open sell (buy/sell) 70/30 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full long position, open sell (buy/sell) 30/70 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full long position, open sell (buy/sell) 50/50 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full short position, open sell";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full short position, open sell (buy/sell) 70/30 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full short position, open sell (buy/sell) 30/70 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: full short position, open sell (buy/sell) 50/50 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: 70% long and 30% short position, open sell no open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: 30% long and 70% short position, open sell no open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: 70% long and 30% short position, open sell, with open (buy/sell) 70/30 orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: 30% long and 70% short position, open sell, with open (buy/sell) 30/70 orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"hedged: 70% long and 30% short position, open sell, with open (buy/sell) 50/50 orders";deriveCaseParams[()]];

/ .qt.AddCase[test;"combined: no positions, open sell";deriveCaseParams[()]];
/ .qt.AddCase[test;"combined: full long position, open sell, no open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"combined: full short position, open sell, no open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"combined: full short position, open sell (buy/sell) 70/30 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"combined: full short position, open sell (buy/sell) 30/70 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"combined: full short position, open sell (buy/sell) 50/50 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"combined: full long position, open sell (buy/sell) 70/30 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"combined: full long position, open sell (buy/sell) 30/70 open orders";deriveCaseParams[()]];
/ .qt.AddCase[test;"combined: full long position, open sell (buy/sell) 50/50 open orders";deriveCaseParams[()]];


/ .qt.RunTest[test];
// TODO Failed, insufficient balance, leverage too high, max amt for leverage selected etc.

// ApplyFill
// ==================================================================================>

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

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Adds a given fill amount to the account's respective inventory depending on configuration"];

deriveCaseParams :{[p]

    cIns:(`instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier)!p[0];

    // Construct Current Account
    cAcc:(`accountId`positionType`balance`available`frozen,
    `orderMargin`posMargin)!p[1];
    
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

// Single Hedged
// ------------------------------------------------------------------------------------------->

.qt.AddCase[test;"hedged:long_to_longer ";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"hedged:longer_to_long";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"hedged:long_to_flat";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"hedged:longer_to_flat";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"hedged:short_to_shorter";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"hedged:shorter_to_short";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"hedged:shorter_to_flat";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

// Combined
// ------------------------------------------------------------------------------------------->


.qt.AddCase[test;"combined:long_to_longer";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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


.qt.AddCase[test;"combined:longer_to_long";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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


.qt.AddCase[test;"combined:long_to_flat";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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


.qt.AddCase[test;"combined:longer_to_short";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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


.qt.AddCase[test;"combined:long_to_shorter";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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


.qt.AddCase[test;"combined:short_to_shorter";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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


.qt.AddCase[test;"combined:shorter_to_short";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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


.qt.AddCase[test;"combined:short_to_long";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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


.qt.AddCase[test;"combined:short_to_longer";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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


// HEDGED RPNL tests
// ------------------------------------------------------------------------------------------>


.qt.AddCase[test;"combined:short_to_flat_rpl_-50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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


.qt.AddCase[test;"hedged:long_to_flat_rpl_50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"hedged:short_to_flat_rpl_50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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


.qt.AddCase[test;"hedged:long_to_flat_rpl_-50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

// COMBINED RPNL tests
// ------------------------------------------------------------------------------------------>

.qt.AddCase[test;"combined:long_to_flat_rpl_50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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


.qt.AddCase[test;"combined:long_to_flat_rpl_-50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"combined:long_to_short_rpl_-50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"combined:long_to_short_rpl_50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"combined:short_to_flat_rpl_50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"combined:short_to_long_rpl_50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"combined:short_to_long_rpl_-50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"combined:short_to_flat_rpl_-50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"combined:long_to_flat_rpl_50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"combined:long_to_flat_rpl_-50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"combined:short_to_flat_rpl_50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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

.qt.AddCase[test;"combined:short_to_flat_rpl_-50";deriveCaseParams[(
    // `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier
    (0;0.5;1e9;0f;1e6f;0f;100);
    // accountId;positionType;balance;available;frozen;orderMargin;posMargin;realizedPnl
    (0;`HEDGED;500;500;0;0;0); // Current Account
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


// UpdateMarkPrice
// ==================================================================================>
 
test:.qt.Unit[
    ".account.UpdateMarkPrice";
    {[c]
        p:c[`params];  
        setupInstrument[p];
        setupAccount[p];
        setupInventory[p];
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


    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for updating the mark price with respect to the account namespace"];


deriveCaseParams :{[p]

    cIns:(`instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier)!p[0];

    // Construct Current Account
    cAcc:(`accountId`positionType`balance`available`frozen,
    `orderMargin`posMargin`activeFeeId`realizedPnl)!p[1];
    
    // Construct Current Inventory
    cInv:flip[(`accountId`side`amt`totalEntry`execCost`realizedPnl)!flip[p[2]]];

    // Construct Expected Account
    eAcc:(`accountId`balance`available`frozen`orderMargin`posMargin`bankruptPrice,
    `liquidationPrice`unrealizedPnl`realizedPnl`tradeCount`netLongPosition`netShortPosition,
    `openBuyOrderQty`openSellOrderQty`openBuyOrderPremium`openSellOrderPremium)!p[6];

    // Construct Expected Inventory
    eInv:flip[(`accountId`side`amt`totalEntry`execCost`realizedPnl`unrealizedPnl)!flip[p[7]]];

    :`cIns`cAcc`cInv`cOrd`fill`markPrice`eAcc`eInv`eOrd`eEvents!(
        cIns;
        cAcc;
        cInv;
        makeOrders[p[3]];
        p[5];
        eAcc;
        eInv;
        makeOrders[p[8]];
        p[9]
        );
    };

.qt.AddCase[test;"Mark price increases, no liquidations should occur, accounts should be updated";deriveCaseParams[(
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
    (til[4];4#0;4#0;4#`BUY;4#`LIMIT;((2#400),(2#600));4#100;4#1000 999;4#z); // Current Orders
    //`accountId`instrumentId`side`time`reduceOnly`isMaker`price`qty
    (1000;0;z); // Parameters
    // `accountId`balance`available`frozen`orderMargin`posMargin`bankruptPrice,
    // `liquidationPrice`unrealizedPnl`realizedPnl`tradeCount`netLongPosition`netShortPosition,
    // `openBuyOrderQty`openSellOrderQty`openBuyOrderPremium`openSellOrderPremium,
    (0;1;1;0;0;0;0;0;0;0;0;0;0;0;0;0;0); // Expected Account
    (   // accountId, side;amt;totalEntry;execCost;realizedPnl;unrealizedPnl;
        (0;`BOTH;100;100;l 1e9; 1000; 0);
        (0;`LONG;100;100;l 1e9; 1000; 0);
        (0;`SHORT;100;100;l 1e9; 1000; 0)
    );
    (til[4];4#0;4#0;4#`BUY;4#`LIMIT;((2#400),(2#600));4#100;4#1000 999;4#z); // Expected orders
    () // Expected events
    )]];



.qt.RunTests[];