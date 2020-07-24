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
    :pCols!(accountCols!p[0];
        (inventoryCols,priceCols)!p[1];
        paramsCols!p[2]; // flat maker fee
        eaccountCols!p[3];
        einventoryCols!p[4]);
    };

// Hedged tests
// ------------------------------------------------------------------------------------------------------>

//TODO make into array and addCases
.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

// Hedged tests
// ------------------------------------------------------------------------------------------------------>

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];

.qt.AddCase[test;"hedged:long_to_longer";deriveCaseParams[(
    (1;500f);(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);(100;10f;-0.00025);(1;500.0025f;499.8025;0.0025f;0f);
    (1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f))]];


/ // Test Apply Fill
/ // -------------------------------------------------------------->

/ test:.qt.Unit[
/     ".account.ApplyFill";
/     {[p;c]
/         time:.z.z;

/         eacc:p[`eaccount];
/         einv:p[`einventory]
/         ecols:p[`ecols];

/         account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
/         inventory:Sanitize[p[`inventory];.inventory.defaults[];.inventory.allCols];

/         // Execute tested function
/         .account.execFill[account;inventory;p[`fillQty];p[`price];p[`fee]];

/         // 
/         acc:exec from .account.Account where accountId=account[`accountId];
/         invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

/         // Assertions
/         .qt.A[acc[ecols];~;eacc[ecols];c];
/         .qt.A[invn[ecols];~;einv[ecols];c];

/     };();({};{};{};defaultAfterEach);""];

/ deriveCaseParams :{[p]
/     accountCols: `accountId`balance;
/     priceCols: `markPrice`lastPrice;
/     inventoryCols: (`accountId`inventoryId`side`currentQty`totalEntry,
/                    `execCost`avgPrice);
/     pCols:`fillQty`price`fee;
/     eaccountCols:accountCols,`available`realizedPnl`unrealizedPnl;
/     einventoryCols:inventoryCols,`realizedPnl`unrealizedPnl,
/                    `totalCloseAmt`totalCrossAmt`totalOpenAmt,
/                    `totalCloseVolume`totalCrossVolume`totalOpenVolume,
/                    `totalCloseMarketValue`totalCrossMarketValue`totalOpenMarketValue;
/     :();
/     };

/ .qt.AddCase[test;"check that no funding occurs";deriveCaseParams[(
/     (1;10f;0f;100f);(`LONG;0;0;0);(`SHORT;1000;0;0);(`BOTH;0;0;0);
/     0f;(1;10f;10f;0f;0f;0f);0N)]];

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
/     0f;(1;10f;10f;0f;0f;0f);0N)]];


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
/     0f;(1;10f;10f;0f;0f;0f);0N)]];
