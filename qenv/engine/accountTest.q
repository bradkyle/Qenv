\cd ../quantest
\l quantest.q
\cd ../engine

\l account.q
system "d .accountTest";
\l util.q

defaultAfterEach: {
     delete from `.account.Account;
     delete from `.inventory.Inventory;
     .account.accountCount:0;
     .inventory.inventoryCount:0;
     .qt.RestoreMocks[];
    };

// Account CRUD Logic
// -------------------------------------------------------------->


// Test Exec Fill
// -------------------------------------------------------------->

test:.qt.Unit[
    ".account.execFill";
    {[p;c]
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

    };();({};{};{};defaultAfterEach);""];


deriveCaseParams :{[p]
    accountCols: `accountId`balance;
    priceCols: `markPrice`lastPrice;
    inventoryCols: (`accountId`inventoryId`side`currentQty`totalEntry,
                   `execCost`avgPrice);
    paramsCols:`fillQty`price`fee;
    eaccountCols:accountCols,`available`realizedPnl`unrealizedPnl;
    einventoryCols:inventoryCols,`realizedPnl`unrealizedPnl,
                   `totalCloseAmt`totalCrossAmt`totalOpenAmt,
                   `totalCloseVolume`totalCrossVolume`totalOpenVolume,
                   `totalCloseMarketValue`totalCrossMarketValue`totalOpenMarketValue;
    pCols:`account`inventory`params`eaccount`einventory;

    r:{x[`side]:($[
        x[`side]=`LONG;`.inventory.POSITIONSIDE$`LONG;
        x[`side]=`SHORT;`.inventory.POSITIONSIDE$`SHORT;
        x[`side]=`BOTH;`.inventory.POSITIONSIDE$`SHORT;
        x[`side]]); :x};

    ii:r[(inventoryCols,priceCols)!p[1]];
    ri:r[einventoryCols!p[4]];

    :pCols!(accountCols!p[0];
        ii;
        paramsCols!p[2]; // flat maker fee
        eaccountCols!p[3];
        ri);
    };

// Hedged tests
// ------------------------------------------------------------------------------------------------------>

//TODO make into array and addCases
.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:longer_to_long";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(-50;10f;-0.00025);(1;500.00125f;499.95125;0.00125f;0f);
    (1;1;`LONG;50;100;`long$1e9;10f;0.00125f;0f;5f;0f;0f;50;0;0;0.05f;0f;0f))]];

// close
.qt.AddCase[test;"hedged:longer_to_long";deriveCaseParams[((1;500f);
    (1;1;`LONG;100;100;`long$1e9;10f;10f;10f);
    (-50;10f;-0.00025); // flat maker fee
    (1;500.00125f;499.95125;0.00125f;0f);
    (1;1;`LONG;50;100;`long$1e9;10f;0.00125f;0f;5f;0f;0f;50;0;0;0.05f;0f;0f))]];

// flatten
.qt.AddCase[test;"hedged:long_to_flat";deriveCaseParams[((1;500f);
    (1;1;`LONG;100;100;`long$1e9;10f;10f;10f);
    (-100;10f;-0.00025); // flat maker fee
    (1;500.0025f;500.0025f;0.0025f;0f);
    (1;1;`LONG;0;0;0;0f;0.0025f;0f;10f;0f;0f;100;0;0;0.1f;0f;0f))]];

// open
.qt.AddCase[test;"hedged:short_to_shorter";deriveCaseParams[((1;500f);
    (1;1;`SHORT;-100;100;`long$1e9;10f;10f;10f);
    (-100;10f;-0.00025); // flat maker fee
    (1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`SHORT;-200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

// close
.qt.AddCase[test;"hedged:shorter_to_short";deriveCaseParams[((1;500f);
    (1;1;`SHORT;-100;100;`long$1e9;10f;10f;10f);
    (50;10f;-0.00025); // flat maker fee
    (1;500.00125f;499.95125;0.00125f;0f);
    (1;1;`SHORT;-50;100;`long$1e9;10f;0.00125f;0f;5f;0f;0f;50;0;0;0.05f;0f;0f))]];

// close
.qt.AddCase[test;"hedged:shorter_to_flat";deriveCaseParams[((1;500f);
    (1;1;`SHORT;-100;100;`long$1e9;10f;10f;10f);
    (100;10f;-0.00025); // flat maker fee
    (1;500.0025f;500.0025;0.0025f;0f);
    (1;1;`BOTH;0;0;`long$0;0f;0.0025f;0f;10f;0f;0f;100;0;0;0.1f;0f;0f))]];


// Combined tests
// ------------------------------------------------------------------------------------------>

// open
.qt.AddCase[test;"combined:long_to_longer";deriveCaseParams[((1;500f);
    (1;1;`BOTH;100;100;`long$1e9;10f;10f;10f);
    (100;10f;-0.00025); // flat maker fee
    (1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`BOTH;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

// close
.qt.AddCase[test;"combined:longer_to_long";deriveCaseParams[((1;500f);
    (1;1;`BOTH;100;100;`long$1e9;10f;10f;10f);
    (-50;10f;-0.00025); // flat maker fee
    (1;500.00125f;499.95125;0.00125f;0f);
    (1;1;`BOTH;50;100;`long$1e9;10f;0.00125f;0f;5f;0f;0f;50;0;0;0.05f;0f;0f))]];

// flatten
.qt.AddCase[test;"combined:long_to_flat";deriveCaseParams[((1;500f);
    (1;1;`BOTH;100;100;`long$1e9;10f;10f;10f);
    (-100;10f;-0.00025); // flat maker fee
    (1;500.0025f;500.0025f;0.0025f;0f);
    (1;1;`BOTH;0;0;0;0f;0.0025f;0f;10f;0f;0f;100;0;0;0.1f;0f;0f))]];

// cross
.qt.AddCase[test;"combined:longer_to_short";deriveCaseParams[((1;500f);
    (1;1;`BOTH;100;100;`long$1e9;10f;10f;10f);
    (-150;10f;-0.00025); // flat maker fee
    (1;500.00375f;499.95375;0.00375f;0f);
    (1;1;`BOTH;-50;50;`long$5e8;10f;0.00375f;0f;0f;15f;0f;0;150;0;0f;0.15f;0f))]];

// cross
.qt.AddCase[test;"combined:long_to_short";deriveCaseParams[((1;500f);
    (1;1;`BOTH;100;100;`long$1e9;10f;10f;10f);
    (-200;10f;-0.00025); // flat maker fee
    (1;500.005f;499.905;0.005f;0f);
    (1;1;`BOTH;-100;100;`long$1e9;10f;0.005f;0f;0f;20f;0f;0;200;0;0f;0.20f;0f))]];

// cross
.qt.AddCase[test;"combined:long_to_shorter";deriveCaseParams[((1;500f);
    (1;1;`BOTH;100;100;`long$1e9;10f;10f;10f);
    (-250;10f;-0.00025); // flat maker fee
    (1;500.00625f;499.85625;0.00625f;0f);
    (1;1;`BOTH;-150;150;`long$1.5e9;10f;0.00625f;0f;0f;25f;0f;0;250;0;0f;0.25f;0f))]];

// open
.qt.AddCase[test;"combined:short_to_shorter";deriveCaseParams[((1;500f);
    (1;1;`BOTH;-100;100;`long$1e9;10f;10f;10f);
    (-100;10f;-0.00025); // flat maker fee
    (1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`BOTH;-200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

// close
.qt.AddCase[test;"combined:shorter_to_short";deriveCaseParams[((1;500f);
    (1;1;`BOTH;-100;100;`long$1e9;10f;10f;10f);
    (50;10f;-0.00025); // flat maker fee
    (1;500.00125f;499.95125;0.00125f;0f);
    (1;1;`BOTH;-50;100;`long$1e9;10f;0.00125f;0f;5f;0f;0f;50;0;0;0.05f;0f;0f))]];

// close
.qt.AddCase[test;"combined:shorter_to_flat";deriveCaseParams[((1;500f);
    (1;1;`BOTH;-100;100;`long$1e9;10f;10f;10f);
    (100;10f;-0.00025); // flat maker fee
    (1;500.0025f;500.0025;0.0025f;0f);
    (1;1;`BOTH;0;0;`long$0;0f;0.0025f;0f;10f;0f;0f;100;0;0;0.1f;0f;0f))]];

// cross
.qt.AddCase[test;"combined:short_to_long";deriveCaseParams[((1;500f);
    (1;1;`BOTH;-100;100;`long$1e9;10f;10f;10f);
    (150;10f;-0.00025); // flat maker fee
    (1;500.00375f;499.95375;0.00375f;0f);
    (1;1;`BOTH;50;50;`long$5e8;10f;0.00375f;0f;0f;15f;0f;0;150;0;0f;0.15f;0f))]];

// cross
.qt.AddCase[test;"combined:short_to_longer";deriveCaseParams[((1;500f);
    (1;1;`BOTH;-100;100;`long$1e9;10f;10f;10f);
    (250;10f;-0.00025); // flat maker fee
    (1;500.00625f;499.85625;0.00625f;0f);
    (1;1;`BOTH;150;150;`long$1.5e9;10f;0.00625f;0f;0f;25f;0f;0;250;0;0f;0.25f;0f))]];


// HEDGED RPNL tests
// ------------------------------------------------------------------------------------------>

.qt.AddCase[test;"hedged:short_to_flat_rpl_-50";deriveCaseParams[((1;500f);
    (1;1;`SHORT;-100;100;`long$1e9;10f;20f;20f);
    (100;20f;-0.00025); // flat maker fee
    (1;495.00125f;495.00125f;-4.99875f;0f);
    (1;1;`SHORT;0;0;`long$0;0f;-4.99875f;0f;5f;0f;0f;100;0;0;0.05f;0f;0f))]];


.qt.AddCase[test;"hedged:long_to_flat_rpl_50";deriveCaseParams[((1;500f);
    (1;1;`LONG;100;100;`long$1e9;10f;20f;20f);
    (-100;20f;-0.00025); // flat maker fee
    (1;505.00125f;505.00125f;5.00125f;0f);
    (1;1;`LONG;0;0;`long$0;0f;5.00125f;0f;5f;0f;0f;100;0;0;0.05f;0f;0f))]];


.qt.AddCase[test;"hedged:short_to_flat_rpl_50";deriveCaseParams[((1;500f);
    (1;1;`SHORT;-100;100;`long$1e9;20f;10f;10f);
    (100;10f;-0.00025); // flat maker fee
    (1;505.0025f;505.0025f;5.0025;0f);
    (1;1;`SHORT;0;0;`long$0;0f;5.0025;0f;10f;0f;0f;100;0;0;0.1f;0f;0f))]];

.qt.AddCase[test;"hedged:long_to_flat_rpl_-50";deriveCaseParams[((1;500f);
    (1;1;`LONG;100;100;`long$1e9;20f;10f;10f);
    (-100;10f;-0.00025); // flat maker fee
    (1;495.0025f;495.0025f;-4.9975f;0f);
    (1;1;`LONG;0;0;`long$0;0f;-4.9975f;0f;10f;0f;0f;100;0;0;0.1f;0f;0f))]];

// COMBINED RPNL FULL tests
// ------------------------------------------------------------------------------------------>
// TODO half flat!!

.qt.AddCase[test;"combined:long_to_flat_rpl_50";deriveCaseParams[((1;500f);
    (1;1;`BOTH;100;100;`long$1e9;10f;20f;20f);
    (-100;20f;-0.00025); // flat maker fee
    (1;505.00125f;505.00125f;5.00125f;0f);
    (1;1;`BOTH;0;0;`long$0;0f;5.00125f;0f;5f;0f;0f;100;0;0;0.05f;0f;0f))]];

.qt.AddCase[test;"combined:long_to_flat_rpl_-50";deriveCaseParams[((1;500f);
    (1;1;`BOTH;100;100;`long$1e9;20f;10f;10f);
    (-100;10f;-0.00025); // flat maker fee
    (1;495.0025f;495.0025f;-4.9975f;0f);
    (1;1;`BOTH;0;0;`long$0;0f;-4.9975f;0f;10f;0f;0f;100;0;0;0.1f;0f;0f))]];

.qt.AddCase[test;"combined:long_to_short_rpl_-50";deriveCaseParams[((1;500f);
    (1;1;`BOTH;100;100;`long$1e9;20f;10f;10f);
    (-200;10f;-0.00025); // flat maker fee
    (1;495.005f;494.905f;-4.995f;0f);
    (1;1;`BOTH;-100;100;`long$1e9;10f;-4.995f;0f;0f;20f;0f;0;200;0;0f;0.2f;0f))]];

.qt.AddCase[test;"combined:long_to_short_rpl_50";deriveCaseParams[((1;500f);
    (1;1;`BOTH;100;100;`long$1e9;10f;20f;20f);
    (-200;20f;-0.00025); // flat maker fee
    (1;505.0025f;504.9525f;5.0025f;0f);
    (1;1;`BOTH;-100;100;`long$5e8;20f;5.0025f;0f;0f;10f;0f;0;200;0;0f;0.1f;0f))]];

.qt.AddCase[test;"combined:short_to_flat_rpl_50";deriveCaseParams[((1;500f);
    (1;1;`BOTH;-100;100;`long$1e9;20f;10f;10f);
    (100;10f;-0.00025); // flat maker fee
    (1;505.0025f;505.0025f;5.0025;0f);
    (1;1;`BOTH;0;0;`long$0;0f;5.0025;0f;10f;0f;0f;100;0;0;0.1f;0f;0f))]];

.qt.AddCase[test;"combined:short_to_long_rpl_50";deriveCaseParams[((1;500f);
    (1;1;`BOTH;-100;100;`long$1e9;20f;10f;10f);
    (200;10f;-0.00025); // flat maker fee
    (1;505.005f;504.905f;5.005;0f);
    (1;1;`BOTH;100;100;`long$1e9;10f;5.005f;0f;0f;20f;0f;0;200;0;0f;0.2f;0f))]];

.qt.AddCase[test;"combined:short_to_long_rpl_-50";deriveCaseParams[((1;500f);
    (1;1;`BOTH;-100;100;`long$1e9;10f;20f;20f);
    (200;20f;-0.00025); // flat maker fee
    (1;495.0025f;494.9525f;-4.9975f;0f);
    (1;1;`BOTH;100;100;`long$5e8;20f;-4.9975f;0f;0f;10f;0f;0;200;0;0f;0.1f;0f))]];

.qt.AddCase[test;"combined:short_to_flat_rpl_-50";deriveCaseParams[((1;500f);
    (1;1;`BOTH;-100;100;`long$1e9;10f;20f;20f);
    (100;20f;-0.00025); // flat maker fee
    (1;495.00125f;495.00125f;-4.99875f;0f);
    (1;1;`BOTH;0;0;`long$0;0f;-4.99875f;0f;5f;0f;0f;100;0;0;0.05f;0f;0f))]];

// Half execution rpnl.
// TODO
.qt.AddCase[test;"combined:long_to_flat_rpl_50";deriveCaseParams[((1;500f);
    (1;1;`BOTH;100;100;`long$1e9;10f;20f;20f);
    (-50;20f;-0.00025); // flat maker fee
    (1;502.500625f;502.450625f;2.500625f;2.5f); // TODO check upl aded to available
    (1;1;`BOTH;50;100;`long$1e9;10f;2.500625f;2.5f;2.5f;0f;0f;50;0;0;0.025f;0f;0f))]];

.qt.AddCase[test;"combined:long_to_flat_rpl_-50";deriveCaseParams[((1;500f);
    (1;1;`BOTH;100;100;`long$1e9;20f;10f;10f);
    (-50;10f;-0.00025); // flat maker fee
    (1;497.50125f;497.47625f;-2.49875f;-2.5f);
    (1;1;`BOTH;50;100;`long$1e9;20f;-2.49875f;-2.5f;5f;0f;0f;50;0;0;0.05f;0f;0f))]];

.qt.AddCase[test;"combined:short_to_flat_rpl_50";deriveCaseParams[((1;500f);
    (1;1;`BOTH;-100;100;`long$1e9;20f;10f;10f);
    (50;10f;-0.00025); // flat maker fee
    (1;502.50125f;502.47625f;2.50125f;2.5f);
    (1;1;`BOTH;-50;100;`long$1e9;20f;2.50125f;2.5f;5f;0f;0f;50;0;0;0.05f;0f;0f))]];

.qt.AddCase[test;"combined:short_to_flat_rpl_-50";deriveCaseParams[((1;500f);
    (1;1;`BOTH;-100;100;`long$1e9;10f;20f;20f);
    (50;20f;-0.00025); // flat maker fee
    (1;497.500625f;497.450625f;-2.499375f;-2.5f);
    (1;1;`BOTH;-50;100;`long$1e9;10f;-2.499375f;-2.5f;2.5f;0f;0f;50;0;0;0.025f;0f;0f))]];

// Test Apply Fill
// -------------------------------------------------------------->

test:.qt.Unit[
    ".account.ApplyFill";
    {[p;c]
        time:.z.z;

        eacc:p[`eaccount];
        einv:p[`einventory]
        ecols:p[`ecols];

        account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
        inventory:Sanitize[p[`inventory];.inventory.defaults[];.inventory.allCols];

        // Execute tested function
        .account.execFill[account;inventory;p[`fillQty];p[`price];p[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        .qt.A[acc[ecols];~;eacc[ecols];c];
        .qt.A[invn[ecols];~;einv[ecols];c];

    };();({};{};{};defaultAfterEach);""];

deriveCaseParams :{[p]
    accountCols: `accountId`balance;
    priceCols: `markPrice`lastPrice;
    inventoryCols: (`accountId`inventoryId`side`currentQty`totalEntry,
                   `execCost`avgPrice);
    pCols:`fillQty`price`fee;
    eaccountCols:accountCols,`available`realizedPnl`unrealizedPnl;
    einventoryCols:inventoryCols,`realizedPnl`unrealizedPnl,
                   `totalCloseAmt`totalCrossAmt`totalOpenAmt,
                   `totalCloseVolume`totalCrossVolume`totalOpenVolume,
                   `totalCloseMarketValue`totalCrossMarketValue`totalOpenMarketValue;
    :();
    };

.qt.AddCase[test;"check that no funding occurs";deriveCaseParams[(
    (1;10f;0f;100f);(`LONG;0;0;0);(`SHORT;1000;0;0);(`BOTH;0;0;0);
    0f;(1;10f;10f;0f;0f;0f);0N)]];

/ // Test Deposit
/ // -------------------------------------------------------------->

/ test:.qt.Unit[
/     ".account.Deposit";
/     {[p;c]
/         time:.z.z;

/         eacc:p[`eaccount];
/         ecols:p[`ecols];

/         .qt.M[];

/         // Execute tested function
/         .account.Deposit[accountId;deposit;cime];

/         acc:exec from .account.Account where accountId=account[`accountId];

/         // Assertions
/         .qt.A[acc[ecols];~;eacc[ecols];c];

/     };();({};{};{};defaultAfterEach);""];

/ deriveCaseParams :{[p]
/      caseCols:`account`expectedResp`expectedValues;
/     :();
/     };

/ .qt.AddCase[test;"check that no funding occurs";deriveCaseParams[(
/     (1;10f;0f;100f);(`LONG;0;0;0);(`SHORT;1000;0;0);(`BOTH;0;0;0);
/     0f;(1;10f;10f;0f;0f;0f);0N))]];


/ // Test Withdraw
/ // -------------------------------------------------------------->

/ test:.qt.Unit[
/     ".account.Withdraw";
/     {[p;c]
/         time:.z.z;

/         eacc:p[`eaccount];
/         ecols:p[`ecols];

/         .qt.M[];

/         // Execute tested function
/         .account.Withdraw[accountId;deposit;cime];

/         acc:exec from .account.Account where accountId=account[`accountId];

/         // Assertions
/         .qt.A[acc[ecols];~;eacc[ecols];c];

/     };();({};{};{};defaultAfterEach);""];

/ deriveCaseParams :{[p]
/      caseCols:`account`expectedResp`expectedValues;
/     :();
/     };

/ .qt.AddCase[test;"check that no funding occurs";deriveCaseParams[(
/     (1;10f;0f;100f);(`LONG;0;0;0);(`SHORT;1000;0;0);(`BOTH;0;0;0);
/     0f;(1;10f;10f;0f;0f;0f);0N))]];
