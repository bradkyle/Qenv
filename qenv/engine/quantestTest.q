
\d .external
externalFn  :{[a;b;c]
    show a b c;
    }
\d .

testExecFill: {
    beforeAll  :{[]

        };

    afterAll   :{[]

        };

    beforeEach  :{[]

        };

    afterEach   :{[]
        delete from `.account.Account;
        delete from `.inventory.Inventory;
        .account.accountCount:0;
        .inventory.inventoryCount:0;
        };

    testFn  :{[params;test]
        time:.z.z;

        account:Sanitize[account;.account.defaults[];.account.allCols];        
        inventory:Sanitize[inventory;.inventory.defaults[];.inventory.allCols];

        // Execute tested function
        .account.execFill[account;inventory;params[`fillQty];params[`price];params[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        A[acc[ecols];~;eacc[ecols]]
        A[invn[ecols];~;einv[ecols]];

        };

    test :.quantest.UNIT[testFn;before;after;beforeEach;afterEach];

    //TODO make into array and addCases
    .quantest.AddCase[test;"hedged:long_to_longer";()];
    .quantest.AddCase[test;"hedged:";()];
    .quantest.AddCase[test;"hedged:";()];
    .quantest.AddCase[test;"hedged:";()];
    .quantest.AddCase[test;"hedged:";()];
    .quantest.AddCase[test;"hedged:";()];
    .quantest.AddCase[test;"hedged:";()];
    .quantest.AddCase[test;"hedged:";()];

    .quantest.RunTest[test];
    };