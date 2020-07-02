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
    
    };


/ testDeposit:{

    / };

/ testApplyFunding:{
/     fundingRate:0.01;
/     time:.z.z;
/     aid:1;
/     .account.NewAccount[aid;`CROSS;`HEDGED];
/     events:.account.ApplyFunding[];
/     };

testDeposit:{

    };

testWithdraw:{

    };


/ to set a max time we use the qunitconfig
/ a dictionary from test names to test parameters to their values
qunitConfig:``!();
qunitConfig[`testGetFactorialSpeed]:`maxTime`maxMem!(100;20000000);  
        