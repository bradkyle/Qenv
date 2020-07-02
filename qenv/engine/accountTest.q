system "d .accountTest";
\l account.q
\l inventory.q

testNewAccount:{
    aid:4;
    time:.z.z;
    events:.account.NewAccount[aid;`CROSS;`HEDGED;time];
    x:select from .account.Account where accountId=aid;
    .qunit.assertEquals[count x; 1; "Account record should be present and inserted"];
    };


testExecFill:{
    time:.z.z;
    aid:103;
    events:.account.NewAccount[aid;`CROSS;`HEDGED;time];
    update balance:1f, longMargin:longMargin+0.1 from `.account.Account where accountId=aid;
    acc:exec from .account.Account where accountId=aid;
    pos:exec from .inventory.Inventory where accountId=aid, side=`LONG;
    .account.execFill[acc;pos;10;1000;0.00075];
    accr:exec from .account.Account where accountId=aid;
    posr:exec from .inventory.Inventory where inventoryId=pos[`inventoryId];
    .qunit.assertEquals[posr[`currentQty]; 10; "Account record should be present and inserted"];
    };

testApplyFill:{
    time:.z.z;
    aid:107;
    events:.account.NewAccount[aid;`CROSS;`HEDGED;time];
    update balance:1f, longMargin:longMargin+0.1 from `.account.Account where accountId=aid;
    .account.ApplyFill[10;1000;`SELL;time;0b;1b;aid];
    };

// TODO balance should not be less than zero
// TODO should update available and maint margin etc. 
// TODO check multiple cases
testApplyFunding:{
    fundingRate:0.01;
    time:.z.z;
    aid:101;
    events:.account.NewAccount[aid;`CROSS;`HEDGED;time];
    update balance:1, longMargin:longMargin+0.1 from `.account.Account where accountId=aid;
    events:.account.ApplyFunding[fundingRate;time];
    acc: exec from .account.Account where accountId=aid;
    .qunit.assertEquals[acc[`balance]; 0.999; "Account record should be present and inserted"];
    .qunit.assertEquals[acc[`longFundingCost]; 0.001; "Long funding cost should be updated accordingly"];
    .qunit.assertEquals[acc[`shortFundingCost]; 0f; "Short funding cost should be updated accordingly"];
    .qunit.assertEquals[acc[`totalFundingCost]; 0.001; "Total funding cost should be updated accordingly"];
    };

testProcessDeposit:{

    };

testProcessWithdraw:{

    };


/ to set a max time we use the qunitconfig
/ a dictionary from test names to test parameters to their values
qunitConfig:``!();
qunitConfig[`testGetFactorialSpeed]:`maxTime`maxMem!(100;20000000);  
        