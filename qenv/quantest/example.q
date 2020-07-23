
\d .external
externalFn  :{[a;b;c]
    show a b c;
    }
\d .

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

test:.qt.UNIT[
    ".account.execFill";
    {[params]
        time:.z.z;

        eacc:params[`eaccount];
        einv:params[`einventory]
        ecols:params[`ecols];

        account:Sanitize[params[`account];.account.defaults[];.account.allCols];        
        inventory:Sanitize[params[`inventory];.inventory.defaults[];.inventory.allCols];

        .qt.M[];

        // Execute tested function
        .account.execFill[account;inventory;params[`fillQty];params[`price];params[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        .qt.A[acc[ecols];~;eacc[ecols];];
        .qt.A[invn[ecols];~;einv[ecols];];

    };;(;;;defaultAfterEach)];


deriveCaseParams :{[params]
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
    :();
    };

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


// Test Apply Fill
// -------------------------------------------------------------->

test:.qt.UNIT[
    ".account.ApplyFill";
    {[params]
        time:.z.z;

        eacc:params[`eaccount];
        einv:params[`einventory]
        ecols:params[`ecols];

        account:Sanitize[params[`account];.account.defaults[];.account.allCols];        
        inventory:Sanitize[params[`inventory];.inventory.defaults[];.inventory.allCols];

        .qt.M[];

        // Execute tested function
        .account.execFill[account;inventory;params[`fillQty];params[`price];params[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        .qt.A[acc[ecols];~;eacc[ecols];];
        .qt.A[invn[ecols];~;einv[ecols];];

    };;(;;;defaultAfterEach)];

deriveCaseParams :{[params]
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
    :();
    };

.qt.AddCase[test;"check that no funding occurs";deriveCaseParams[(
    (1;10f;0f;100f);(`LONG;0;0;0);(`SHORT;1000;0;0);(`BOTH;0;0;0);
    0f;(1;10f;10f;0f;0f;0f);0N)]];

// Test Deposit
// -------------------------------------------------------------->

test:.qt.UNIT[
    ".account.Deposit";
    {[params]
        time:.z.z;

        eacc:params[`eaccount];
        ecols:params[`ecols];

        .qt.M[];

        // Execute tested function
        .account.Deposit[accountId;deposit;time];

        acc:exec from .account.Account where accountId=account[`accountId];

        // Assertions
        .qt.A[acc[ecols];~;eacc[ecols];];

    };;(;;;defaultAfterEach)];

deriveCaseParams :{[params]
     caseCols:`account`expectedResp`expectedValues;
    :();
    };

.qt.AddCase[test;"check that no funding occurs";deriveCaseParams[(
    (1;10f;0f;100f);(`LONG;0;0;0);(`SHORT;1000;0;0);(`BOTH;0;0;0);
    0f;(1;10f;10f;0f;0f;0f);0N)]];


// Test Withdraw
// -------------------------------------------------------------->

test:.qt.UNIT[
    ".account.Withdraw";
    {[params]
        time:.z.z;

        eacc:params[`eaccount];
        ecols:params[`ecols];

        .qt.M[];

        // Execute tested function
        .account.Withdraw[accountId;deposit;time];

        acc:exec from .account.Account where accountId=account[`accountId];

        // Assertions
        .qt.A[acc[ecols];~;eacc[ecols];];

    };;(;;;defaultAfterEach)];

deriveCaseParams :{[params]
     caseCols:`account`expectedResp`expectedValues;
    :();
    };

.qt.AddCase[test;"check that no funding occurs";deriveCaseParams[(
    (1;10f;0f;100f);(`LONG;0;0;0);(`SHORT;1000;0;0);(`BOTH;0;0;0);
    0f;(1;10f;10f;0f;0f;0f);0N)]];
