
.qt.Unit[
    ".engine.logic.account.DeriveRiskTier";
    {[c]
				.qt.RunUnit[c;.engine.logic.account.DeriveRiskTier];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("update leverage sufficient balance without positions";());
        ("update leverage sufficient balance without positions";())
    );
    ({};{};{};{});
    "Global function for creating a new account"];
 

.qt.Unit[
    ".engine.logic.account.Fill";
    {[c]
        .qt.RunUnit[c;.engine.logic.account.Fill];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("hedged:long_to_longer";(
            ( // Mocks
								();
								();
								()
            );
            (
                ();
                ();
                ()
            ); // Fill
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
        ))
    );
    ({};{};{};{});
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".engine.logic.account.Withdraw";
    {[c]
        .qt.RunUnit[c;.engine.logic.account.Withdraw];
    };
    {[p] :`args`eRes`mocks`err!p};
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
    ({};{};{};{});
    "Process a batch of signal events"];

.qt.Unit[
    ".engine.logic.account.Deposit";
    {[c]
        .qt.RunUnit[c;.engine.logic.account.Deposit];
    };
    {[p] :`args`eRes`mocks`err!p};
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
    ({};{};{};{});
    "Process a batch of signal events"];


.qt.Unit[
    ".engine.logic.account.Leverage";
    {[c]
        .qt.RunUnit[c;.engine.logic.account.Leverage];
    };
    {[p] :`args`eRes`mocks`err!p};
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
 

