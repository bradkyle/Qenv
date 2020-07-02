\d .inventoryTests
\l qunit.q
\l inventory.q

testNewAccount:{
    aid:1;
    .inventory.NewInventory[aid;`LONG];
    x:select from .inventory.Inventory where accountId=aid;

    .qunit.assertEquals[count x; 1; "Record should be present and inserted"];
    .qunit.assertEquals[(first x)[`side]; `.inventory.POSITIONSIDE$`LONG; "The side should be equal to specified side"];
        
    };



testNewAccount[]
\d .