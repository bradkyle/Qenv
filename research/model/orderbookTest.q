

.qt.Unit[
    ".engine.model.orderbook.NewLevels";
    {[c]
        p:c[`params];
        .util.testutils.revertOrderBook[];

        res:.util.testutils.checkErr[
            .engine.model.account.NewLevels;
            p`args;
            p`err;
            c];

        .util.testutils.checkOrderBook[p`eRes;c;cols[p`eRes]];
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrderBook[];
    };
    {`args`err`eRes`mocks!x};
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
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.orderbook.UpdateLevels";
    {[c]
        p:c[`params];
        .util.testutils.revertOrderBook[];
        .engine.model.account.NewLevels[p`cLvl];
        
        res:.util.testutils.checkErr[
            .engine.model.account.UpdateLevels;
            p`args;
            p`err;
            c];

        .util.testutils.checkOrderBook[p`eRes;c;cols[p`eRes]];
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrderBook[];
    }; 
    {`cAcc`args`err`eRes`mocks!x};
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
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.orderbook.GetLevelsByPrice";
    {[c]
        p:c[`params];
        .util.testutils.revertOrderBook[];
        .engine.model.account.NewLevels[p`cLvl];
        
        res:.util.testutils.checkErr[
            .engine.model.account.GetLevelsByPrice;
            p`args;
            p`err;
            c];
 
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrderBook[];
    };
    {};
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
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.orderbook.GetLevelsBySide";
    {[c]
        p:c[`params];
        .util.testutils.revertOrderBook[];
        .engine.model.account.NewLevels[p`cLvl];
        
        res:.util.testutils.checkErr[
            .engine.model.account.GetLevelsBySide;
            p`args;
            p`err;
            c];
 
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrderBook[];
    };
    {};
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
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.orderbook.PruneOrderBook";
    {[c]
        p:c[`params];
        .util.testutils.revertOrderBook[];
        .engine.model.account.NewLevels[p`cLvl];
        
        res:.util.testutils.checkErr[
            .engine.model.account.PruneOrderBook;
            p`args;
            p`err;
            c];

        .util.testutils.checkOrderBook[p`eRes;c;cols[p`eRes]];
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrderBook[];
    }; 
    {`cAcc`args`err`eRes`mocks!x};
    (
        ("Single PruneOrderBook (1) no error, success";(

        ));
        ("Single PruneOrderBook (1) error, fail";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];