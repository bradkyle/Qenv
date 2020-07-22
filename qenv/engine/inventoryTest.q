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

// TODO test wrong types etc.
testNewInventory : {
    runCase: {[dscr; inventory; expects] 
            show dscr;
            res:();
            // Execute tested function
            $[expects[`shouldError];
                .qunit.assertError[.inventory.NewInventory;(inventory;.z.z);"should error"];
                res,:.inventory.NewInventory[inventory;.z.z]];
            
            // Run tests on state
            / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc 
            invs:select from .inventory.Inventory;
            .qunit.assertEquals[count invs; expects[`inventoryCount]; dscr,":inventoryCount"];
            .qunit.assertEquals[.inventory.inventoryCount; expects[`inventoryCount]; dscr,":inventoryCount"];      
            // Tear Down 
            delete from `.inventory.Inventory
            .inventory.inventoryCount:0;
    }; 

    inventoryCols: `accountId`side`currentQty;
    expectedCols: `inventoryCount`shouldError;
    
    runCase["should pass and insert value";inventoryCols!(1;`SHORT;0);expectedCols!(1;0b)];
    runCase["should pass and insert value with unknown col";(inventoryCols,`unknownCol)!(1;`SHORT;0;88);expectedCols!(1;0b)];
    / runCase["should error without mandCol";`currentQty!(0);expectedCols!(1;1b)]; TODO fix!

    // TODO test response events

    };
 
    
\d .