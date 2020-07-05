system "d .accountTest";
\l account.q
\l inventory.q


// Event creation utilities
// -------------------------------------------------------------->

testMakeAccountUpdateEvent  :{

    };

testMakeAllAccountsUpdatedEvent :{

    };

// Account CRUD Logic
// -------------------------------------------------------------->
testNewAccount:{
    runCase: {[dscr; case]
        // Setup
        $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
        / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
        $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
        $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

        // Execute tested function
        res:.order.NewAccount[case[`account]];
        
        // Run tests on state
        / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
        .qunit.assertEquals[.order.getQtys[case[`side]]; case[`eqtys]; "qtys expected"];
        .qunit.assertEquals[.order.getOffsets[case[`side]]; case[`eoffsets]; "offsets expected"];
        .qunit.assertEquals[.order.getSizes[case[`side]]; case[`esizes]; "sizes expected"];
    
        // Tear Down
    };
    caseCols:`account`expectedResp`expectedValues;

    / runCase["case1";caseCols!(`BUY;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
    / runCase["case2";caseCols!(`SELL;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];

    };



// Fill and Position Related Logic
// -------------------------------------------------------------->

testExecFill:{
    runCase: {[dscr; case]
        // Setup
        $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
        / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
        $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
        $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

        events:.account.NewAccount[aid;`CROSS;`HEDGED;time];
        update balance:1f, longMargin:longMargin+0.1 from `.account.Account where accountId=aid;
        acc:exec from .account.Account where accountId=aid;
        pos:exec from .inventory.Inventory where accountId=aid, side=`LONG;

        // Execute tested function
        res:.account.execFill[acc;pos;10;1000;0.00075];
        
        // Run tests on state
        / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
        .qunit.assertEquals[posr[`currentQty]; 10; "Account record should be present and inserted"];
        .qunit.assertEquals[accr[`balance]; 0.9998925; "Account record should be present and inserted"];
    
        // Tear Down
    };

    caseCols:`account`expectedResp`expectedValues;

    / runCase["case1";caseCols!(`BUY;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
    / runCase["case2";caseCols!(`SELL;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
    
    };

testApplyFill:{
    runCase: {[dscr; account; inventories; params; expected]
        // Setup
        $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
        / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
        $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
        $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

        events:.account.NewAccount[aid;`CROSS;`HEDGED;time];
        update balance:1f, longMargin:longMargin+0.1 from `.account.Account where accountId=aid;

        // Execute tested function
        res:.account.ApplyFill[10;1000;`SELL;time;0b;1b;aid];
        
        // Run tests on state
        / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
        .qunit.assertEquals[posr[`currentQty]; 10; "Account record should be present and inserted"];
        .qunit.assertEquals[accr[`balance]; 0.9998925; "Account record should be present and inserted"];
    
        // Tear Down
    };

    setupCols:`account`inventories`fundingRate`nextFundingTime`time`expected
    accountCols: `balance;
    inventoryCols: `side`currentQty`totalEntry`execCosts;

    / runCase["case2";caseCols!(`SELL;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
    
    };



// Funding Event/Logic //TODO convert to cnt for reference
// -------------------------------------------------------------->


// TODO balance should not be less than zero
// TODO should update available and maint margin etc. 
// TODO check multiple cases
testApplyFunding:{
    runCase: {[dscr; account; inventories; params; expected]
        // Setup
        $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
        / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
        $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
        $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

        fundingRate:0.01;
        time:.z.z;
        aid:101;
        events:.account.NewAccount[aid;`CROSS;`HEDGED;time];
        update balance:1f, longMargin:longMargin+0.1 from `.account.Account where accountId=aid;
        
        // Execute tested function
        events:.account.ApplyFunding[fundingRate;time];
        
        // Run tests on state
        acc: exec from .account.Account where accountId=aid;
        / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
        .qunit.assertEquals[acc[`balance]; 0.999; "Account record should be present and inserted"];
        .qunit.assertEquals[acc[`longFundingCost]; 0.001; "Long funding cost should be updated accordingly"];
        .qunit.assertEquals[acc[`shortFundingCost]; 0f; "Short funding cost should be updated accordingly"];
        .qunit.assertEquals[acc[`totalFundingCost]; 0.001; "Total funding cost should be updated accordingly"];
    
        // Tear Down
    };

    setupCols:`account`inventories`fundingRate`nextFundingTime`time`expected
    accountCols: `balance;
    inventoryCols: `side`currentQty`totalEntry`execCosts;

    runCase[
        "check no funding occurs";
        accountCols!();
        (
            ();
            ();
            ();
        );
        `fundingRate`nextFundingTime`time!();
        `balance`longFundingCost`shortFundingCost`totalFundingCost!()
    ];
    / runCase["case2";caseCols!(`SELL;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];   
    
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

 
        