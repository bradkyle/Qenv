


test:.qt.Unit[
    ".engine.getPriceAtLevel";
    {[c]
        p:c[`params];
        time:.z.z;
        eacc:p[`eaccount];
        einv:p[`einventory];
        ecols:p[`ecols];

        account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
        inventory:Sanitize[p[`inventory];.inventory.defaults[];.inventory.allCols];

        // Execute tested function
        x:p[`params];
        .account.execFill[account;inventory;x[`fillQty];x[`price];x[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        .qt.A[{x!y[x]}[cols eacc;acc];~;eacc;"account";c];
        .qt.A[{x!y[x]}[cols einv;invn];~;einv;"inventory";c];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".engine.getOpenPositions";
    {[c]
        p:c[`params];
        time:.z.z;
        eacc:p[`eaccount];
        einv:p[`einventory];
        ecols:p[`ecols];

        account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
        inventory:Sanitize[p[`inventory];.inventory.defaults[];.inventory.allCols];

        // Execute tested function
        x:p[`params];
        .account.execFill[account;inventory;x[`fillQty];x[`price];x[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        .qt.A[{x!y[x]}[cols eacc;acc];~;eacc;"account";c];
        .qt.A[{x!y[x]}[cols einv;invn];~;einv;"inventory";c];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".engine.getCurrentOrderLvlDist";
    {[c]
        p:c[`params];
        time:.z.z;
        eacc:p[`eaccount];
        einv:p[`einventory];
        ecols:p[`ecols];

        account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
        inventory:Sanitize[p[`inventory];.inventory.defaults[];.inventory.allCols];

        // Execute tested function
        x:p[`params];
        .account.execFill[account;inventory;x[`fillQty];x[`price];x[`fee]];

        // 
        acc:exec from .account.Account where accountId=account[`accountId];
        invn:exec from .inventory.Inventory where accountId=inventory[`accountId], side=inventory[`side];

        // Assertions
        .qt.A[{x!y[x]}[cols eacc;acc];~;eacc;"account";c];
        .qt.A[{x!y[x]}[cols einv;invn];~;einv;"inventory";c];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];
