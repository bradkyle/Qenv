system "d .accountTest";
\l account.q
\l inventory.q
\l util.q


revert:   {
            delete from `.account.Account;
            delete from `.inventory.Inventory;
            .account.accountCount:0;
            .inventory.inventoryCount:0;
    };

// Event creation utilities
// -------------------------------------------------------------->

testMakeAccountUpdateEvent  :{

    };

testMakeAllAccountsUpdatedEvent :{

    };

// Account CRUD Logic
// -------------------------------------------------------------->
testNewAccount:{
    runCase: {[dscr; account; expects] 
            res:();
            // Execute tested function
            $[expects[`shouldError];
                .qunit.assertError[.account.NewAccount;(account;.z.z);"should error"];
                res,:.account.NewAccount[account;.z.z]];
            
            // Run tests on state
            / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc 
            ins:select from .account.Account;
            .qunit.assertEquals[count ins; expects[`accountCount]; "accountCount"];
            .qunit.assertEquals[.account.accountCount; expects[`accountCount]; "accountCount"];      

            // Tear Down 
            revert[];
    }; 

    accountCols: `balance`realizedPnl`unrealizedPnl`marginType`positionType;
    expectedCols: `accountCount`shouldError;

    runCase["should pass and insert value";accountCols!(1f;0f;0f;`CROSS;`COMBINED);expectedCols!(1;0b)];

    revert[];
    };



// Fill and Position Related Logic
// -------------------------------------------------------------->

testExecFill:{
    runCase: {[dscr; account; inventory; params; eaccount; einventory]
        // Setup
        time:.z.z;

        account:Sanitize[account;.account.defaults[];.account.allCols];        
        inventory:Sanitize[inventory;.inventory.defaults[];.inventory.allCols];

        // Execute tested function
        .account.execFill[account;inventory;params[`fillQty];params[`price];params[`fee]];

        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Run tests on state
        .qunit.assertEquals[acc[`balance]; eaccount[`balance]; "account balance"];
        .qunit.assertEquals[acc[`realizedPnl]; eaccount[`realizedPnl]; "account realized pnl"];
        .qunit.assertEquals[acc[`unrealizedPnl]; eaccount[`unrealizedPnl]; "account unrealized pnl"];

        .qunit.assertEquals[invn[`currentQty]; einventory[`currentQty]; "inventory current qty"];
        .qunit.assertEquals[invn[`totalEntry]; einventory[`totalEntry]; "inventory total entry"];
        .qunit.assertEquals[invn[`execCost]; einventory[`execCost]; "inventory exec costs"];
        .qunit.assertEquals[invn[`avgPrice]; einventory[`avgPrice]; "inventory avgPrice"];
        .qunit.assertEquals[invn[`realizedPnl]; einventory[`realizedPnl]; "inventory realized pnl"]; 
        .qunit.assertEquals[invn[`unrealizedPnl]; einventory[`unrealizedPnl]; "inventory unrealizedPNL"]; 
        .qunit.assertEquals[invn[`totalCloseAmt]; einventory[`totalCloseAmt]; "inventory total close amt"]; 
        .qunit.assertEquals[invn[`totalCrossAmt]; einventory[`totalCrossAmt]; "inventory total cross amt"]; 
        .qunit.assertEquals[invn[`totalOpenAmt]; einventory[`totalOpenAmt]; "inventory total open amt"]; 
        .qunit.assertEquals[invn[`totalCloseVolume]; einventory[`totalCloseVolume]; "inventory total close amt"]; 
        .qunit.assertEquals[invn[`totalCrossVolume]; einventory[`totalCrossVolume]; "inventory total cross amt"]; 
        .qunit.assertEquals[invn[`totalOpenVolume]; einventory[`totalOpenVolume]; "inventory total open amt"]; 

        // Tear Down
       delete from `.account.Account;
       delete from `.inventory.Inventory;
       .account.accountCount:0;
       .inventory.inventoryCount:0;
    };

    // TODO margin etc.
    accountCols: `accountId`balance;
    inventoryCols: (`accountId`inventoryId`side`currentQty`totalEntry,
                   `execCost`avgPrice);
    paramsCols:`fillQty`price`fee;
    eaccountCols:accountCols,`realizedPnl`unrealizedPnl;
    einventoryCols:inventoryCols,`realizedPnl`unrealizedPnl,
                   `totalCloseAmt`totalCrossAmt`totalOpenAmt,
                   `totalCloseVolume`totalCrossVolume`totalOpenVolume;

    // TEST BOTH, LONG, SHORT etc.
    // TEST margin usage

    runCase["long_to_longer";
        accountCols!(1;500f);
        inventoryCols!(1;1;`LONG;100;100;`long$1e9;10f);
        paramsCols!(100;10f;-0.00025); // flat maker fee
        eaccountCols!(1;499.9025;0f;0f);
        einventoryCols!(1;1;`LONG;200;200;`long$2e9;10f;0f;0f;0f;0f;0.0975f;0;0;100)];
    
    revert[];
    };

testApplyFill:{
    runCase: {[dscr; account; inventories; params; expected]
        time:.z.z;
        // Setup 
        events:.account.NewAccount[account;time];

        // Execute tested function
        res:.account.ApplyFill[10;1000;`SELL;time;0b;1b;aid];
        
        // Run tests on state
        / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
        .qunit.assertEquals[10; 10; "Account record should be present and inserted"];
        .qunit.assertEquals[10; 10; "Account record should be present and inserted"];
    
        // Tear Down
        revert[];
    };
    setupCols:`account`inventories`fundingRate`nextFundingTime`time`expected;
    accountCols: `balance;
    inventoryCols: `side`currentQty`totalEntry`execCosts;

    / runCase["case2";caseCols!(`SELL;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];

    / runCase[
    /     "check no funding occurs";
    /     accountCols!();
    /     (inventoryCols!(`LONG;0;0;0);inventoryCols!(`SHORT;1000;0;0);inventoryCols!(`BOTH;0;0;0));
    /     fundingCols!(0;t+1;t);
    /     expectedCols!(1;0;0;0)
    / ];
    revert[];
    
    };



// Funding Event/Logic //TODO convert to cnt for reference
// -------------------------------------------------------------->


// TODO balance should not be less than zero
// TODO should update available and maint margin etc. 
// Does funding apply to margin or position
// TODO remove positions and just use net outstanding
testApplyFunding:{
    runCase: {[dscr; account; inventories; params; expected]
        time:.z.z;
        // Setup 
        .account.NewAccount[account;time]; 
        
        // Execute tested function
        events:.account.ApplyFunding[params[`fundingRate];time];
        
        // Run tests on state
        acc: exec from .account.Account where accountId=aid;
        / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
        .qunit.assertEquals[acc[`balance]; 0.999; "Account record should be present and inserted"];
        .qunit.assertEquals[acc[`longFundingCost]; 0.001; "Long funding cost should be updated accordingly"];
        .qunit.assertEquals[acc[`shortFundingCost]; 0f; "Short funding cost should be updated accordingly"];
        .qunit.assertEquals[acc[`totalFundingCost]; 0.001; "Total funding cost should be updated accordingly"];
    
        // Tear Down
        revert[];
    };
    accountCols: `balance`longMargin`shortMargin`netLongPosition`netShortPosition`maintMargin`available;
    inventoryCols: `side`currentQty`totalEntry`execCosts;
    fundingCols: `fundingRate`nextFundingTime`time;
    expectedCols:`balance`longFundingCost`shortFundingCost`totalFundingCost;

    / runCase[
    /     "check no funding occurs";
    /     accountCols!();
    /     (inventoryCols!(`LONG;0;0;0);inventoryCols!(`SHORT;1000;0;0);inventoryCols!(`BOTH;0;0;0));
    /     fundingCols!(0;t+1;t);
    /     expectedCols!(1;0;0;0)
    / ];

    / runCase[
    /     "apply positive (0.0001) funding hedged short only (recieves funding value) Positive funding rate means long pays short";
    /     accountCols!();
    /     (inventoryCols!(`LONG;0;0;0);inventoryCols!(`SHORT;1000;0;0);inventoryCols!(`BOTH;0;0;0));
    /     fundingCols!(0.0001;t+1;t);
    /     expectedCols!(1.0001;0;-0.0001;-0.0001)
    / ];  

    / runCase[
    /     "apply positive (0.0001) funding hedged long only (recieves funding value) Negative funding rate means short pays long";
    /     accountCols!();
    /     (inventoryCols!(`SHORT;0;0;0);inventoryCols!(`LONG;1000;0;0);inventoryCols!(`BOTH;0;0;0));
    /     fundingCols!(0.0001;t+1;t);
    /     expectedCols!(1.0001;-0.0001;0;-0.0001)
    / ];  

    / runCase[
    /     "apply negative (-0.0001) funding hedged short only (removes funding value) Negative funding rate means short pays long";
    /     accountCols!();
    /     (inventoryCols!(`LONG;0;0;0);inventoryCols!(`SHORT;1000;0;0);inventoryCols!(`BOTH;0;0;0));
    /     fundingCols!(-0.0001;t+1;t);
    /     expectedCols!(0.9999;0;0.0001;0.0001)
    / ];  

    / runCase[
    /     "apply positive (0.0001) funding hedged long only (removes funding value) Positive funding rate means long pays short";
    /     accountCols!();
    /     (inventoryCols!(`SHORT;0;0;0);inventoryCols!(`LONG;1000;0;0);inventoryCols!(`BOTH;0;0;0));
    /     fundingCols!(0.0001;t+1;t);
    /     expectedCols!(0.9999;0.0001;0;0.0001)
    / ];  
    
    / runCase[
    /     "apply positive (0.0001) funding hedged long and short (position sizes nullify) Position sizes nullify cost";
    /     accountCols!();
    /     (inventoryCols!(`SHORT;1000;0;0);inventoryCols!(`LONG;1000;0;0);inventoryCols!(`BOTH;0;0;0));
    /     fundingCols!(0.0001;t+1;t);
    /     expectedCols!(1f;0.0001;-0.0001;0f)
    / ];  
    
    / runCase[
    /     "apply negative (-0.0001) funding hedged long and short (position sizes nullify) Position sizes nullify cost";
    /     accountCols!();
    /     (inventoryCols!(`SHORT;1000;0;0);inventoryCols!(`LONG;1000;0;0);inventoryCols!(`BOTH;0;0;0));
    /     fundingCols!(-0.0001;t+1;t);
    /     expectedCols!(1f;-0.0001;0.0001;0f)
    / ];  

    / runCase[
    /     "apply negative (-0.0001) funding hedged long and short (position sizes 1 short/2 long)";
    /     accountCols!();
    /     (inventoryCols!(`SHORT;1000;0;0);inventoryCols!(`LONG;2000;0;0);inventoryCols!(`BOTH;0;0;0));
    /     fundingCols!(-0.0001;t+1;t);
    /     expectedCols!(1.0001;-0.0002;0.0001;-0.0001)
    / ];  

    / runCase[
    /     "apply negative (-0.0001) funding hedged long and short (position sizes 2 short/1 long)";
    /     accountCols!();
    /     (inventoryCols!(`LONG;1000;0;0);inventoryCols!(`SHORT;2000;0;0);inventoryCols!(`BOTH;0;0;0));
    /     fundingCols!(-0.0001;t+1;t);
    /     expectedCols!(0.9999;-0.0001;0.0002;0.0001)
    / ];  

    / runCase[
    /     "apply positive (0.0001) funding hedged long and short (position sizes 1 short/2 long)";
    /     accountCols!();
    /     (inventoryCols!(`LONG;2000;0;0);inventoryCols!(`SHORT;1000;0;0);inventoryCols!(`BOTH;0;0;0));
    /     fundingCols!(0.0001;t+1;t);
    /     expectedCols!(0.9999;0.0002;-0.0001;0.0001)
    / ];  

    / runCase[
    /     "apply positive (0.0001) funding hedged long and short (position sizes 2 short/1 long)";
    /     accountCols!();
    /     (inventoryCols!(`LONG;2000;0;0);inventoryCols!(`SHORT;1000;0;0);inventoryCols!(`BOTH;0;0;0));
    /     fundingCols!(0.0001;t+1;t);
    /     expectedCols!(1.0001;0.0001;-0.0002;0.0001)
    / ];  

    / runCase[
    /     "apply positive (0.0001) funding combined short -1000 (longs pay shorts)";
    /     accountCols!();
    /     (inventoryCols!(`LONG;0;0;0);inventoryCols!(`SHORT;0;0;0);inventoryCols!(`BOTH;-1000;0;0));
    /     fundingCols!(0.0001;t+1;t);
    /     expectedCols!(1.0001;0f;-0.0001;-0.0001)
    / ];  

    / runCase[
    /     "apply negative (-0.0001) funding combined short -1000 (shorts pay longs)";
    /     accountCols!();
    /     (inventoryCols!(`LONG;0;0;0);inventoryCols!(`SHORT;0;0;0);inventoryCols!(`BOTH;-1000;0;0));
    /     fundingCols!(-0.0001;t+1;t);
    /     expectedCols!(0.9999;0.0001;0f;0.0001)
    / ];  

    / runCase[
    /     "apply positive (0.0001) funding combined long 1000 (longs pay shorts)";
    /     accountCols!();
    /     (inventoryCols!(`LONG;0;0;0);inventoryCols!(`SHORT;0;0;0);inventoryCols!(`BOTH;1000;0;0));
    /     fundingCols!(0.0001;t+1;t);
    /     expectedCols!(0.9999;0f;0.0001;0.0001)
    / ];  

    / runCase[
    /     "apply negative (-0.0001) funding combined long 1000 (shorts pay longs)";
    /     accountCols!();
    /     (inventoryCols!(`LONG;0;0;0);inventoryCols!(`SHORT;0;0;0);inventoryCols!(`BOTH;1000;0;0));
    /     fundingCols!(-0.0001;t+1;t);
    /     expectedCols!(1.0001;0f;-0.0001;-0.0001)
    / ];  
    
    };


// Balance Management
// -------------------------------------------------------------->

// TODO more cases
testDeposit:{
    runCase: {[dscr; case]
        // Setup
        $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
        / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
        $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
        $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

        time:.z.z;
        aid:19;
        depo: 5;

        .account.NewAccount[aid;`CROSS;`HEDGED;time];
        update balance:1f from `.account.Account where accountId=aid;
        
        // Execute tested function
        events:.account.Deposit[depo;time;aid];
        
        // Run tests on state
        acc: exec from .account.Account where accountId=aid;
        / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
        .qunit.assertEquals[acc[`balance]; 0.999; "Account record should be present and inserted"];
        .qunit.assertEquals[acc[`longFundingCost]; 0.001; "Long funding cost should be updated accordingly"];
        .qunit.assertEquals[acc[`shortFundingCost]; 0f; "Short funding cost should be updated accordingly"];
        .qunit.assertEquals[acc[`totalFundingCost]; 0.001; "Total funding cost should be updated accordingly"];
    
        // Tear Down
    };

    caseCols:`account`expectedResp`expectedValues;

    / runCase["case1";caseCols!(`BUY;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
    / runCase["case2";caseCols!(`SELL;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];       
    
    };

// TODO more cases
testProcessWithdraw:{ 
    runCase: {[dscr; case]
        // Setup
        $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
        / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
        $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
        $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

        time:.z.z;
        aid:190;
        widr: 5;
        .account.NewAccount[aid;`CROSS;`HEDGED;time];
        update balance:widr*2f from `.account.Account where accountId=aid;
        
        // Execute tested function
        events:.account.Withdraw[widr;time;aid];
        
        // Run tests on state
        acc: exec from .account.Account where accountId=aid;
        / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
        .qunit.assertEquals[acc[`balance]; 0.999; "Account record should be present and inserted"];
        .qunit.assertEquals[acc[`longFundingCost]; 0.001; "Long funding cost should be updated accordingly"];
        .qunit.assertEquals[acc[`shortFundingCost]; 0f; "Short funding cost should be updated accordingly"];
        .qunit.assertEquals[acc[`totalFundingCost]; 0.001; "Total funding cost should be updated accordingly"];
    
        // Tear Down
    };

    caseCols:`account`expectedResp`expectedValues;

    / runCase["case1";caseCols!(`BUY;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
    / runCase["case2";caseCols!(`SELL;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];       
    
    };

 
        