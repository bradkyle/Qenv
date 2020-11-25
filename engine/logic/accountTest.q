
.qt.Unit[
    ".engine.logic.account.InitMarginReq";
    {[c]
        p:c[`params];

        res:.engine.logic.fill.InitMarginReq[];
        .qt.A[res;~;p[`eRes];"avgPrice";c];
    };
    {[p]
    
    };
    (
        ("Minimum tier position size init margin req";((0 0 0 0 0 0);0));
        ("Maximum tier position size init margin req";((0 0 0 0 0 0);0));
        ("Minimum tier effective leverage init margin req";((0 0 0 0 0 0);0));
        ("Maximum tier effective leverage init margin req";((0 0 0 0 0 0);0))
    );
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];

.qt.Unit[
    ".engine.logic.account.MaintMarginReq";
    {[c]
        p:c[`params];

        res:.engine.logic.fill.MaintMarginReq[];
        .qt.A[res;~;p[`eRes];"avgPrice";c];
    };
    {[p]
    
    };
    (
        ("Minimum tier position size maint margin req";((0 0 0 0 0 0);0));
        ("Maximum tier position size maint margin req";((0 0 0 0 0 0);0));
        ("Minimum tier effective leverage maint margin req";((0 0 0 0 0 0);0));
        ("Maximum tier effective leverage maint margin req";((0 0 0 0 0 0);0))
    );
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];

.qt.Unit[
    ".engine.logic.account.MaintMargin";
    {[c]
        p:c[`params];

        res:.engine.logic.fill.MaintMargin[];
        .qt.A[res;~;p[`eRes];"avgPrice";c];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".engine.logic.account.InitMargin";
    {[c]
        p:c[`params];

        res:.engine.logic.fill.InitMargin[];
        .qt.A[res;~;p[`eRes];"avgPrice";c];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];

.qt.Unit[
    ".engine.logic.account.Fill";
    {[c]
        .qt.RunUnit[c;.engine.logic.fill.ApplyFills];
    };.qt.generalParams;
    (
        ("hedged:long_to_longer";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:longer_to_long";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:long_to_flat";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:longer_to_flat";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:short_to_shorter";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:shorter_to_short";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:shorter_to_flat";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:long_to_longer";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:longer_to_long";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:long_to_flat";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:longer_to_short";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:long_to_shorter";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_shorter";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:shorter_to_short";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_long";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_longer";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_flat_rpl_-50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:long_to_flat_rpl_50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:short_to_flat_rpl_50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:long_to_flat_rpl_-50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
    );
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".engine.logic.account.Withdraw";
    {[c]
        .qt.RunUnit[c;.engine.services.account.ProcessWithdrawEvents];
    };.qt.generalParams;
    (
        ("1:0) ProcessWithdrawEvents";());
        ("1:1) ProcessWithdrawEvents";());
        ("withdraw sufficient balance without positions";());
        ("withdraw sufficient balance with combined short position";());
        ("withdraw sufficient balance with combined long position";());
        ("withdraw sufficient balance with hedged short position";());
        ("withdraw sufficient balance with hedged long position";());
        ("withdraw sufficient balance with split hedged short(0.50)/long(0.50) position";());
        ("withdraw sufficient balance with split hedged long(0.50)/short(0.50) position";());
        ("withdraw sufficient balance with split hedged short(0.75)/long(0.25) position";());
        ("withdraw sufficient balance with split hedged long(0.25)/short(0.75) position";());
        ("withdraw sufficient balance with split hedged short(0.75)/long(0.25) position";());
        ("withdraw sufficient balance with split hedged long(0.25)/short(0.75) position";());
        ("withdraw insufficient balance without positions";());
        ("withdraw insufficient balance with combined short position";());
        ("withdraw insufficient balance with combined long position";());
        ("withdraw insufficient balance with hedged short position";());
        ("withdraw insufficient balance with hedged long position";());
        ("withdraw insufficient balance with split hedged short(0.50)/long(0.50) position";());
        ("withdraw insufficient balance with split hedged long(0.50)/short(0.50) position";());
        ("withdraw insufficient balance with split hedged short(0.75)/long(0.25) position";());
        ("withdraw insufficient balance with split hedged long(0.25)/short(0.75) position";());
        ("withdraw insufficient balance with split hedged short(0.75)/long(0.25) position";());
        ("withdraw insufficient balance with split hedged long(0.25)/short(0.75) position";())
    );
    .util.testutils.defaultContractHooks;
    "Process a batch of signal events"];

.qt.Unit[
    ".engine.logic.account.Deposit";
    {[c]
        .qt.RunUnit[c;.engine.services.account.ProcessDepositEvents];
    };.qt.generalParams;
    (
        (("1:0) ProcessDepositEvents");());
        (("1:1) ProcessDepositEvents");());
        ("deposit valid amt without positions";());
        ("deposit valid amt with combined short position";());
        ("deposit valid amt with combined long position";());
        ("deposit valid amt with hedged short position";());
        ("deposit valid amt with hedged long position";());
        ("deposit valid amt with split hedged short(0.50)/long(0.50) position";());
        ("deposit valid amt with split hedged long(0.50)/short(0.50) position";());
        ("deposit valid amt with split hedged short(0.75)/long(0.25) position";());
        ("deposit valid amt with split hedged long(0.25)/short(0.75) position";());
        ("deposit valid amt with split hedged short(0.75)/long(0.25) position";());
        ("deposit valid amt with split hedged long(0.25)/short(0.75) position";());
        ("deposit invalid amt without positions";());
        ("deposit invalid amt with combined short position";());
        ("deposit invalid amt with combined long position";());
        ("deposit invalid amt with hedged short position";());
        ("deposit invalid amt with hedged long position";());
        ("deposit invalid amt with split hedged short(0.50)/long(0.50) position";());
        ("deposit invalid amt with split hedged long(0.50)/short(0.50) position";());
        ("deposit invalid amt with split hedged short(0.75)/long(0.25) position";());
        ("deposit invalid amt with split hedged long(0.25)/short(0.75) position";());
        ("deposit invalid amt with split hedged short(0.75)/long(0.25) position";());
        ("deposit invalid amt with split hedged long(0.25)/short(0.75) position";())
    );
    .util.testutils.defaultContractHooks;
    "Process a batch of signal events"];


.qt.Unit[
    ".engine.logic.account.Leverage";
    {[c]
        .qt.RunUnit[c;.engine.services.account.ProcessLeverageUpdateEvents];
    };.qt.generalParams;
    (
        ("update leverage sufficient balance without positions";());
        ("update leverage sufficient balance with combined short position";());
        ("update leverage sufficient balance with combined long position";());
        ("update leverage sufficient balance with hedged short position";());
        ("update leverage sufficient balance with hedged long position";());
        ("update leverage sufficient balance with split hedged short(0.50)/long(0.50) position";());
        ("update leverage sufficient balance with split hedged long(0.50)/short(0.50) position";());
        ("update leverage sufficient balance with split hedged short(0.75)/long(0.25) position";());
        ("update leverage sufficient balance with split hedged long(0.25)/short(0.75) position";());
        ("update leverage sufficient balance with split hedged short(0.75)/long(0.25) position";());
        ("update leverage sufficient balance with split hedged long(0.25)/short(0.75) position";());
        ("update leverage insufficient balance without positions";());
        ("update leverage insufficient balance with combined short position";());
        ("update leverage insufficient balance with combined long position";());
        ("update leverage insufficient balance with hedged short position";());
        ("update leverage insufficient balance with hedged long position";());
        ("update leverage insufficient balance with split hedged short(0.50)/long(0.50) position";());
        ("update leverage insufficient balance with split hedged long(0.50)/short(0.50) position";());
        ("update leverage insufficient balance with split hedged short(0.75)/long(0.25) position";());
        ("update leverage insufficient balance with split hedged long(0.25)/short(0.75) position";());
        ("update leverage insufficient balance with split hedged short(0.75)/long(0.25) position";());
        ("update leverage insufficient balance with split hedged long(0.25)/short(0.75) position";())
    );
    ({};{};{};{});
    "Global function for creating a new account"];
 

