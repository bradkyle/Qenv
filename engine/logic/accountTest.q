
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
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.inventory.GetInventory;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.common.Update;{[a;b;c]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b]};c];
        mck4: .qt.M[`.engine.model.risktier.GetRiskTier;{[a;b] a}[m[3][3]];c];
        mck5: .qt.M[`.engine.model.feetier.GetFeeTier;{[a;b] a}[m[4][3]];c];

        res:.engine.logic.account.Fill[a 0;a 1;a 2];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("hedged:long_to_longer";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`ordQty`ordVal`ordLoss`posQty`totalEntry`execCost`avgPrice!(0;0;0;0;0;0;0));
                (1b;3;();`amt`abc!());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("hedged:longer_to_long";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`ordQty`ordVal`ordLoss`posQty`totalEntry`execCost`avgPrice!(0;0;0;0;0;0;0));
                (1b;3;();`amt`abc!());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ))
        / ("hedged:long_to_flat";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("hedged:longer_to_flat";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("hedged:short_to_shorter";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("hedged:shorter_to_short";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("hedged:shorter_to_flat";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("combined:long_to_longer";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("combined:longer_to_long";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("combined:long_to_flat";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("combined:longer_to_short";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("combined:long_to_shorter";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("combined:short_to_shorter";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("combined:shorter_to_short";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("combined:short_to_long";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("combined:short_to_longer";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("combined:short_to_flat_rpl_-50";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("hedged:long_to_flat_rpl_50";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("hedged:short_to_flat_rpl_50";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ));
        / ("hedged:long_to_flat_rpl_-50";(
        /     ( // Mocks
        /     );
        /     (); // Fill
        /     (); // Eres
        /     () // Err
        / ))
    );
    ({};{};{};{});
    "Function for deriving the exec cost from the qty and the price"];


.qt.SkpBesTest[17];
.qt.Unit[
    ".engine.logic.account.Withdraw";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.inventory.GetInventory;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.common.Update;{[a;b;c]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b]};c];
        mck4: .qt.M[`.engine.model.risktier.GetRiskTier;{[a;b] a}[m[3][3]];c];
        mck5: .qt.M[`.engine.model.feetier.GetFeeTier;{[a;b] a}[m[4][3]];c];

        res:.engine.logic.account.Fill[a 0;a 1;a 2];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
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
 

