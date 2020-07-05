system "d .inventoryTest";
\l qunit.q
\l inventory.q


// Event creation utilities
// -------------------------------------------------------------->

testMakeInventoryUpdateEvent    :{

    };

testMakeAccountInventoryUpdateEvent :{

    };

testMakeAllInventoryUpdateEvent :{

    };


// Inventory CRUD Logic
// -------------------------------------------------------------->

testNewInventory : {
    runCase: {[dscr; case; expects]
            // Setup
            $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
            / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
            $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
            $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

            // Execute tested function
            res:.inventory.NewInventory[case[`account]];
            
            // Run tests on state
            / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
            .qunit.assertEquals[.order.getQtys[case[`side]]; case[`eqtys]; "qtys expected"];
            .qunit.assertEquals[.order.getOffsets[case[`side]]; case[`eoffsets]; "offsets expected"];
            .qunit.assertEquals[.order.getSizes[case[`side]]; case[`esizes]; "sizes expected"];
        
            // Tear Down 
            delete from `.inventory.Inventory
            .inventory.inventoryCount:0;
    }; 

    inventoryCols: `balance`realizedPnl`unrealizedPnl`marginType`positionType;
    / expectedCols: `inventoryCount;

    / runCase[
    /     "long_to_longer";
    /     accountCols!(500;);
    /     inventoryCols!(`LONG;100;100;10000000;1000);
    /     paramsCols!(100;1000;-0.00025); // flat maker fee
    /     accountCols!(490.0025;);
    /     inventoryCols!(`LONG;200;200;20000000;1000);
    / ];
    };
 
    
\d .