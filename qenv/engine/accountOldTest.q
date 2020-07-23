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

    / runCase["should pass and insert value";accountCols!(1f;0f;0f;`CROSS;`COMBINED);expectedCols!(1;0b)];

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
        .qunit.assertEquals[acc[`balance]; eaccount[`balance]; dscr,": account balance"];
        .qunit.assertEquals[acc[`available]; eaccount[`available]; dscr,": account available"];
        .qunit.assertEquals[acc[`realizedPnl]; eaccount[`realizedPnl]; dscr,": account realized pnl"];
        .qunit.assertEquals[acc[`unrealizedPnl]; eaccount[`unrealizedPnl]; dscr,": account unrealized pnl"];

        .qunit.assertEquals[invn[`currentQty]; einventory[`currentQty]; dscr,": inventory current qty"];
        .qunit.assertEquals[invn[`totalEntry]; einventory[`totalEntry]; dscr,": inventory total entry"];
        .qunit.assertEquals[invn[`execCost]; einventory[`execCost]; dscr,": inventory exec costs"];
        .qunit.assertEquals[invn[`avgPrice]; einventory[`avgPrice]; dscr,": inventory avgPrice"];
        .qunit.assertEquals[invn[`realizedPnl]; einventory[`realizedPnl]; dscr,": inventory realized pnl"]; 
        .qunit.assertEquals[invn[`unrealizedPnl]; einventory[`unrealizedPnl]; dscr,": inventory unrealizedPNL"]; 
        .qunit.assertEquals[invn[`totalCloseAmt]; einventory[`totalCloseAmt]; dscr,": inventory total close amt"]; 
        .qunit.assertEquals[invn[`totalCrossAmt]; einventory[`totalCrossAmt]; dscr,": inventory total cross amt"]; 
        .qunit.assertEquals[invn[`totalOpenAmt]; einventory[`totalOpenAmt]; dscr,": inventory total open amt"]; 
        .qunit.assertEquals[invn[`totalCloseVolume]; einventory[`totalCloseVolume]; dscr,": inventory total close vol"]; 
        .qunit.assertEquals[invn[`totalCrossVolume]; einventory[`totalCrossVolume]; dscr,": inventory total cross vol"]; 
        .qunit.assertEquals[invn[`totalOpenVolume]; einventory[`totalOpenVolume]; dscr,": inventory total open vol"]; 
        .qunit.assertEquals[invn[`totalCloseMarketValue]; einventory[`totalCloseMarketValue]; dscr,": inventory total close market value"]; 
        .qunit.assertEquals[invn[`totalCrossMarketValue]; einventory[`totalCrossMarketValue]; dscr,": inventory total cross market value"]; 
        .qunit.assertEquals[invn[`totalOpenMarketValue]; einventory[`totalOpenMarketValue]; dscr,": inventory total open market value"]; 

        // Tear Down
       delete from `.account.Account;
       delete from `.inventory.Inventory;
       .account.accountCount:0;
       .inventory.inventoryCount:0;
    };

    // TODO margin etc.
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
                /    `initMargin`posMargin`liquidationPrice`;

    // TEST BOTH, LONG, SHORT etc.
    // TEST margin usage
    // TODO with order margin!!, short margin, long margin, posmargin etc.

    // Hedged tests
    // =======================================================================================>

    // TODO order margin

    // open TODO
    runCase["hedged:long_to_longer";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);
        paramsCols!(100;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.0025f;499.8025;0.0025f;0f);
        einventoryCols!(1;1;`LONG;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f)];
    
    // close
    runCase["hedged:longer_to_long";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);
        paramsCols!(-50;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.00125f;499.95125;0.00125f;0f);
        einventoryCols!(1;1;`LONG;50;100;`long$1e9;10f;0.00125f;0f;5f;0f;0f;50;0;0;0.05f;0f;0f)];

    // flatten
    runCase["hedged:long_to_flat";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`LONG;100;100;`long$1e9;10f;10f;10f);
        paramsCols!(-100;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.0025f;500.0025f;0.0025f;0f);
        einventoryCols!(1;1;`LONG;0;0;0;0f;0.0025f;0f;10f;0f;0f;100;0;0;0.1f;0f;0f)];

    // open
    runCase["hedged:short_to_shorter";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`SHORT;-100;100;`long$1e9;10f;10f;10f);
        paramsCols!(-100;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.0025f;499.8025;0.0025f;0f);
        einventoryCols!(1;1;`SHORT;-200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f)];

    // close
    runCase["hedged:shorter_to_short";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`SHORT;-100;100;`long$1e9;10f;10f;10f);
        paramsCols!(50;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.00125f;499.95125;0.00125f;0f);
        einventoryCols!(1;1;`SHORT;-50;100;`long$1e9;10f;0.00125f;0f;5f;0f;0f;50;0;0;0.05f;0f;0f)];

    // close
    runCase["hedged:shorter_to_flat";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`SHORT;-100;100;`long$1e9;10f;10f;10f);
        paramsCols!(100;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.0025f;500.0025;0.0025f;0f);
        einventoryCols!(1;1;`BOTH;0;0;`long$0;0f;0.0025f;0f;10f;0f;0f;100;0;0;0.1f;0f;0f)];


    // Combined tests
    // ------------------------------------------------------------------------------------------>

    // open
    runCase["combined:long_to_longer";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;100;100;`long$1e9;10f;10f;10f);
        paramsCols!(100;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.0025f;499.8025;0.0025f;0f);
        einventoryCols!(1;1;`BOTH;200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f)];
    
    // close
    runCase["combined:longer_to_long";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;100;100;`long$1e9;10f;10f;10f);
        paramsCols!(-50;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.00125f;499.95125;0.00125f;0f);
        einventoryCols!(1;1;`BOTH;50;100;`long$1e9;10f;0.00125f;0f;5f;0f;0f;50;0;0;0.05f;0f;0f)];

    // flatten
    runCase["combined:long_to_flat";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;100;100;`long$1e9;10f;10f;10f);
        paramsCols!(-100;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.0025f;500.0025f;0.0025f;0f);
        einventoryCols!(1;1;`BOTH;0;0;0;0f;0.0025f;0f;10f;0f;0f;100;0;0;0.1f;0f;0f)];

    // cross
    runCase["combined:longer_to_short";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;100;100;`long$1e9;10f;10f;10f);
        paramsCols!(-150;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.00375f;499.95375;0.00375f;0f);
        einventoryCols!(1;1;`BOTH;-50;50;`long$5e8;10f;0.00375f;0f;0f;15f;0f;0;150;0;0f;0.15f;0f)];

    // cross
    runCase["combined:long_to_short";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;100;100;`long$1e9;10f;10f;10f);
        paramsCols!(-200;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.005f;499.905;0.005f;0f);
        einventoryCols!(1;1;`BOTH;-100;100;`long$1e9;10f;0.005f;0f;0f;20f;0f;0;200;0;0f;0.20f;0f)];

    // cross
    runCase["combined:long_to_shorter";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;100;100;`long$1e9;10f;10f;10f);
        paramsCols!(-250;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.00625f;499.85625;0.00625f;0f);
        einventoryCols!(1;1;`BOTH;-150;150;`long$1.5e9;10f;0.00625f;0f;0f;25f;0f;0;250;0;0f;0.25f;0f)];

    // open
    runCase["combined:short_to_shorter";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;-100;100;`long$1e9;10f;10f;10f);
        paramsCols!(-100;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.0025f;499.8025;0.0025f;0f);
        einventoryCols!(1;1;`BOTH;-200;200;`long$2e9;10f;0.0025f;0f;0f;0f;10f;0;0;100;0f;0f;0.1f)];

    // close
    runCase["combined:shorter_to_short";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;-100;100;`long$1e9;10f;10f;10f);
        paramsCols!(50;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.00125f;499.95125;0.00125f;0f);
        einventoryCols!(1;1;`BOTH;-50;100;`long$1e9;10f;0.00125f;0f;5f;0f;0f;50;0;0;0.05f;0f;0f)];

    // close
    runCase["combined:shorter_to_flat";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;-100;100;`long$1e9;10f;10f;10f);
        paramsCols!(100;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.0025f;500.0025;0.0025f;0f);
        einventoryCols!(1;1;`BOTH;0;0;`long$0;0f;0.0025f;0f;10f;0f;0f;100;0;0;0.1f;0f;0f)];

    // cross
    runCase["combined:short_to_long";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;-100;100;`long$1e9;10f;10f;10f);
        paramsCols!(150;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.00375f;499.95375;0.00375f;0f);
        einventoryCols!(1;1;`BOTH;50;50;`long$5e8;10f;0.00375f;0f;0f;15f;0f;0;150;0;0f;0.15f;0f)];

    // cross
    runCase["combined:short_to_longer";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;-100;100;`long$1e9;10f;10f;10f);
        paramsCols!(250;10f;-0.00025); // flat maker fee
        eaccountCols!(1;500.00625f;499.85625;0.00625f;0f);
        einventoryCols!(1;1;`BOTH;150;150;`long$1.5e9;10f;0.00625f;0f;0f;25f;0f;0;250;0;0f;0.25f;0f)];

    
    // HEDGED RPNL tests
    // ------------------------------------------------------------------------------------------>

    runCase["hedged:short_to_flat_rpl_-50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`SHORT;-100;100;`long$1e9;10f;20f;20f);
        paramsCols!(100;20f;-0.00025); // flat maker fee
        eaccountCols!(1;495.00125f;495.00125f;-4.99875f;0f);
        einventoryCols!(1;1;`SHORT;0;0;`long$0;0f;-4.99875f;0f;5f;0f;0f;100;0;0;0.05f;0f;0f)];


    runCase["hedged:long_to_flat_rpl_50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`LONG;100;100;`long$1e9;10f;20f;20f);
        paramsCols!(-100;20f;-0.00025); // flat maker fee
        eaccountCols!(1;505.00125f;505.00125f;5.00125f;0f);
        einventoryCols!(1;1;`LONG;0;0;`long$0;0f;5.00125f;0f;5f;0f;0f;100;0;0;0.05f;0f;0f)];


    runCase["hedged:short_to_flat_rpl_50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`SHORT;-100;100;`long$1e9;20f;10f;10f);
        paramsCols!(100;10f;-0.00025); // flat maker fee
        eaccountCols!(1;505.0025f;505.0025f;5.0025;0f);
        einventoryCols!(1;1;`SHORT;0;0;`long$0;0f;5.0025;0f;10f;0f;0f;100;0;0;0.1f;0f;0f)];
 
    runCase["hedged:long_to_flat_rpl_-50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`LONG;100;100;`long$1e9;20f;10f;10f);
        paramsCols!(-100;10f;-0.00025); // flat maker fee
        eaccountCols!(1;495.0025f;495.0025f;-4.9975f;0f);
        einventoryCols!(1;1;`LONG;0;0;`long$0;0f;-4.9975f;0f;10f;0f;0f;100;0;0;0.1f;0f;0f)];

    // COMBINED RPNL FULL tests
    // ------------------------------------------------------------------------------------------>
    // TODO half flat!!

    runCase["combined:long_to_flat_rpl_50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;100;100;`long$1e9;10f;20f;20f);
        paramsCols!(-100;20f;-0.00025); // flat maker fee
        eaccountCols!(1;505.00125f;505.00125f;5.00125f;0f);
        einventoryCols!(1;1;`BOTH;0;0;`long$0;0f;5.00125f;0f;5f;0f;0f;100;0;0;0.05f;0f;0f)];

    runCase["combined:long_to_flat_rpl_-50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;100;100;`long$1e9;20f;10f;10f);
        paramsCols!(-100;10f;-0.00025); // flat maker fee
        eaccountCols!(1;495.0025f;495.0025f;-4.9975f;0f);
        einventoryCols!(1;1;`BOTH;0;0;`long$0;0f;-4.9975f;0f;10f;0f;0f;100;0;0;0.1f;0f;0f)];

    runCase["combined:long_to_short_rpl_-50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;100;100;`long$1e9;20f;10f;10f);
        paramsCols!(-200;10f;-0.00025); // flat maker fee
        eaccountCols!(1;495.005f;494.905f;-4.995f;0f);
        einventoryCols!(1;1;`BOTH;-100;100;`long$1e9;10f;-4.995f;0f;0f;20f;0f;0;200;0;0f;0.2f;0f)];

    runCase["combined:long_to_short_rpl_50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;100;100;`long$1e9;10f;20f;20f);
        paramsCols!(-200;20f;-0.00025); // flat maker fee
        eaccountCols!(1;505.0025f;504.9525f;5.0025f;0f);
        einventoryCols!(1;1;`BOTH;-100;100;`long$5e8;20f;5.0025f;0f;0f;10f;0f;0;200;0;0f;0.1f;0f)];

    runCase["combined:short_to_flat_rpl_50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;-100;100;`long$1e9;20f;10f;10f);
        paramsCols!(100;10f;-0.00025); // flat maker fee
        eaccountCols!(1;505.0025f;505.0025f;5.0025;0f);
        einventoryCols!(1;1;`BOTH;0;0;`long$0;0f;5.0025;0f;10f;0f;0f;100;0;0;0.1f;0f;0f)];

    runCase["combined:short_to_long_rpl_50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;-100;100;`long$1e9;20f;10f;10f);
        paramsCols!(200;10f;-0.00025); // flat maker fee
        eaccountCols!(1;505.005f;504.905f;5.005;0f);
        einventoryCols!(1;1;`BOTH;100;100;`long$1e9;10f;5.005f;0f;0f;20f;0f;0;200;0;0f;0.2f;0f)];

    runCase["combined:short_to_long_rpl_-50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;-100;100;`long$1e9;10f;20f;20f);
        paramsCols!(200;20f;-0.00025); // flat maker fee
        eaccountCols!(1;495.0025f;494.9525f;-4.9975f;0f);
        einventoryCols!(1;1;`BOTH;100;100;`long$5e8;20f;-4.9975f;0f;0f;10f;0f;0;200;0;0f;0.1f;0f)];

    runCase["combined:short_to_flat_rpl_-50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;-100;100;`long$1e9;10f;20f;20f);
        paramsCols!(100;20f;-0.00025); // flat maker fee
        eaccountCols!(1;495.00125f;495.00125f;-4.99875f;0f);
        einventoryCols!(1;1;`BOTH;0;0;`long$0;0f;-4.99875f;0f;5f;0f;0f;100;0;0;0.05f;0f;0f)];

    // Half execution rpnl.
    // TODO
    runCase["combined:long_to_flat_rpl_50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;100;100;`long$1e9;10f;20f;20f);
        paramsCols!(-50;20f;-0.00025); // flat maker fee
        eaccountCols!(1;502.500625f;502.450625f;2.500625f;2.5f); // TODO check upl aded to available
        einventoryCols!(1;1;`BOTH;50;100;`long$1e9;10f;2.500625f;2.5f;2.5f;0f;0f;50;0;0;0.025f;0f;0f)];

    runCase["combined:long_to_flat_rpl_-50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;100;100;`long$1e9;20f;10f;10f);
        paramsCols!(-50;10f;-0.00025); // flat maker fee
        eaccountCols!(1;497.50125f;497.47625f;-2.49875f;-2.5f);
        einventoryCols!(1;1;`BOTH;50;100;`long$1e9;20f;-2.49875f;-2.5f;5f;0f;0f;50;0;0;0.05f;0f;0f)];

    runCase["combined:short_to_flat_rpl_50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;-100;100;`long$1e9;20f;10f;10f);
        paramsCols!(50;10f;-0.00025); // flat maker fee
        eaccountCols!(1;502.50125f;502.47625f;2.50125f;2.5f);
        einventoryCols!(1;1;`BOTH;-50;100;`long$1e9;20f;2.50125f;2.5f;5f;0f;0f;50;0;0;0.05f;0f;0f)];
 
    runCase["combined:short_to_flat_rpl_-50";
        accountCols!(1;500f);
        (inventoryCols,priceCols)!(1;1;`BOTH;-100;100;`long$1e9;10f;20f;20f);
        paramsCols!(50;20f;-0.00025); // flat maker fee
        eaccountCols!(1;497.500625f;497.450625f;-2.499375f;-2.5f);
        einventoryCols!(1;1;`BOTH;-50;100;`long$1e9;10f;-2.499375f;-2.5f;2.5f;0f;0f;50;0;0;0.025f;0f;0f)];
 
    // Multiple open hedged tests (UPNL, liquidation price, bankruptcy price etc.)
    // ------------------------------------------------------------------------------------------>
    // TODO long short
    // dscr; account; inventory; params; eaccount; einventory
    


    revert[];
    };

testApplyFill:{
    runCase: {[dscr; account; inventories; params; expected]
        time:.z.z;
        // Setup 
        .account.NewAccount[account;time];

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
    runCase: {[dscr; account; inventories; params; eaccount; einventory]
        time:.z.z;
        // Setup 
        .account.NewAccount[account;time]; 
        
        // Execute tested function
        .account.ApplyFunding[params[`fundingRate];time];
        
        // Run tests on state
        acc: exec from .account.Account where accountId=account[`accountId];
        / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc

        // Run tests on state
        .qunit.assertEquals[acc[`balance]; eaccount[`balance]; dscr,": account balance"];
        .qunit.assertEquals[acc[`available]; eaccount[`available]; dscr,": account available"];
        .qunit.assertEquals[acc[`realizedPnl]; eaccount[`realizedPnl]; dscr,": account realized pnl"];
    
        // Tear Down
        revert[];
    };
    accountCols: `accountId`balance`longValue`shortValue;
    inventoryCols: `side`currentQty`totalEntry`execCosts;
    fundingCols: `fundingRate`nextFundingTime`time;
    expectedCols:`balance`longFundingCost`shortFundingCost`totalFundingCost;
    t:.z.z;

    eaccountCols:accountCols,`available`realizedPnl;
    einventoryCols:inventoryCols,`realizedPnl`unrealizedPnl,
                   `totalCloseAmt`totalCrossAmt`totalOpenAmt,
                   `totalCloseVolume`totalCrossVolume`totalOpenVolume,
                   `totalCloseMarketValue`totalCrossMarketValue`totalOpenMarketValue;
    
    runCase["check no funding occurs";
            accountCols!(1;10f;0f;100f);
            (inventoryCols!(`LONG;0;0;0);inventoryCols!(`SHORT;1000;0;0);inventoryCols!(`BOTH;0;0;0));
            fundingCols!(0;t+1;t);
            eaccountCols!(1;10f;10f;0f;0f;0f);0N];

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
        .account.Deposit[depo;time;aid];
        
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
        .account.Withdraw[widr;time;aid];
        
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

 
        