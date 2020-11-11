
// Inventory of an account
// ---------------------------------------------------------------------------->

.qt.Unit[
    ".engine.model.inventory.NewAccountInventory";
    {[c]
        p:c[`params];
        .util.testutils.revertInventory[];

        res:.util.testutils.checkErr[
            .engine.model.inventory.NewAccountInventory;
            p`args;
            p`err;
            c];

        .util.testutils.checkInventory[p`eRes;c;cols[p`eRes]];
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertInventory[];
    };
    {`cInv`args`err`eRes`mocks!x};
    (
        ("Single NewAccountInventory (1) no error, success";(

        ));
        ("Single NewAccountInventory (1) error, fail";(

        ));
        ("Single NewAccountInventory (list) (1) error, fail";(

        ));
        ("Single NewAccountInventory (dict) error, fail";(

        ));
        ("Batch NewAccountInventory (4) no errors, all succeed";(

        ));
        ("Batch NewAccountInventory (4) errors, none succeed";(

        ));
        ("Batch NewAccountInventory (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account inventorys"];

.qt.Unit[
    ".engine.model.inventory.UpdateInventory";
    {[c]
        p:c[`params];
        .util.testutils.revertInventory[];
        .engine.model.inventory.NewAccountInventory[p`cInv];

        res:.util.testutils.checkErr[
            .engine.model.inventory.UpdateInventory;
            p`args;
            p`err;
            c];

        .util.testutils.checkInventory[p`eRes;c;cols[p`eRes]];
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertInventory[];
    };
    {`cInv`args`err`eRes`mocks!x};
    (
        ("Single UpdateInventory (1) no error, success";(

        ));
        ("Single UpdateInventory (1) error, fail";(

        ));
        ("Single UpdateInventory (list) (1) error, fail";(

        ));
        ("Single UpdateInventory (dict) error, fail";(

        ));
        ("Batch UpdateInventory (4) no errors, all succeed";(

        ));
        ("Batch UpdateInventory (4) errors, none succeed";(

        ));
        ("Batch UpdateInventory (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.account.GetInventoryOfAccounts";
    {[c]
        p:c[`params];
        .util.testutils.revertInventory[];
        .engine.model.inventory.NewAccountInventory[p`cInv];

        res:.util.testutils.checkErr[
            .engine.model.inventory.GetInventoryOfAccounts;
            p`args;
            p`err;
            c];

        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertInventory[];
    };
    {`cAcc`args`err`eRes`mocks!x};
    (
        ("Single GetInventoryOfAccounts (1) no error, success";(

        ));
        ("Single GetInventoryOfAccounts (1) error, fail";(

        ));
        ("Single GetInventoryOfAccounts (list) (1) error, fail";(

        ));
        ("Single GetInventoryOfAccounts (dict) error, fail";(

        ));
        ("Batch GetInventoryOfAccounts (4) no errors, all succeed";(

        ));
        ("Batch GetInventoryOfAccounts (4) errors, none succeed";(

        ));
        ("Batch GetInventoryOfAccounts (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];