\d .inventoryTests
\l qunit.q
\l account.q
\l inventory.q

testNewAccount:{
    aid:1;
    events.account.NewAccount[aid;`CROSS;`HEDGED];
    x:select from .account.Account where accountId=aid;
    / y:select from .inventory.Inventory where accountId=aid;

    .qunit.assertEquals[count x; 1; "Account record should be present and inserted"];
    / .qunit.assertEquals[count y; 3; "Inventory record should be present and inserted"];

    };

testDeposit:{

    };

testWithdraw:{

    };

testNewAccount[];
testDeposit[];
testWithdraw[];
\d .