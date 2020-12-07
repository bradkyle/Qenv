
.qt.Unit[
    ".engine.logic.account.Liquidate";
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
    ".engine.logic.account.Remargin";
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
 
// TODO full integration
// TODO test rpnl and upnl
// TODO test tier change
.qt.SkpBesTest[25];
.qt.Unit[
    ".engine.logic.account.Fill";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.inventory.Get;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.account.Update;{[a;b;c]};c];
        mck3: .qt.M[`.engine.model.inventory.Update;{[a;b;c]};c];
        mck5: .qt.M[`.engine.Emit;{[a;b;c]};c];

        res:.engine.logic.account.Fill[z;a 0;a 1;a 2];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
        / .qt.CheckMock[mck4;m[3];c];
        .qt.CheckMock[mck5;m[4];c];
        .qt.RestoreMocks[];

    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("INVERSE:flat to long: UPL: 0, RPL:0 ONE POSITION";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                `aId`balance`feetier`risktier!(0;0.1;`.engine.model.feetier.FeeTier$0;.engine.model.risktier.RiskTier$0); // account
                `qty`price`reduce`ismaker`side!(1;1000;0b;1b;1) // fill
            );
            (); // res 
            (
                (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(2;2000;0;0;0;0;0;0;0)); // GetInventory
                (1b;1;enlist(enlist(`aId`balance`feetier`risktier!(0;0.1;0;0)));()); // Update Account
                (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0)));());  
                (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
                (1b;2;();`amt`abc!()); // Emit
                (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
                (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
            ); // mocks 
            () // err 
        ));
        ("INVERSE:long to flat: UPL: 0, RPL:0 ONE POSITION";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                `aId`balance`feetier`risktier!(0;0.1;0;0); // account
                `qty`price`reduce`ismaker`side!(1;1000;1b;1b;1) // fill
            );
            (); // res 
            (
                (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0));  
                (1b;1;enlist(enlist(`aId`balance`feetier`risktier!(0;0.1;0;0)));()); // Update Account
                (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(0;0;0;0;0;0;0;0;0)));());  
                (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
                (1b;2;();`amt`abc!()); // Emit
                (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
                (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
            ); // mocks 
            () // err 
        ));
        ("long to longer: UPL: 0, RPL:0 ONE POSITION";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                `aId`balance`feetier`risktier!(0;0.1;0;0); // account
                `qty`price`reduce`ismaker`side!(1;1000;0b;1b;1) // fill
            );
            (); // res 
            (
                (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(2;2000;0;0;0;0;0;0;0)); // GetInventory
                (1b;1;enlist(enlist(`aId`balance`feetier`risktier!(0;0.1;0;0)));()); // Update Account
                (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0)));());  
                (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
                (1b;2;();`amt`abc!()); // Emit
                (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
                (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
            ); // mocks 
            () // err 
        ));
        ("long to longer: UPL:-0.5, orderLoss: 0.5, RPL:0 ONE POSITION";( // TODO
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1500;1); // instrument
                `aId`balance`feetier`risktier!(0;0.1;0;0); // account
                `qty`price`reduce`ismaker`side!(1;1000;0b;1b;1) // fill
            );
            (); // res 
            (
                (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(2;2000;0;0;0;0;0;0;0)); // GetInventory
                (1b;1;enlist(enlist(`aId`balance`feetier`risktier!(0;0.1;0;0)));()); // Update Account
                (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;500;1;1;100000;1000;0;0)));());  
                (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
                (1b;2;();`amt`abc!()); // Emit
                (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
                (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
            ); // mocks 
            () // err 
        ));
        ("flat to short: UPL: 0, RPL:0 ONE POSITION";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                `aId`balance`feetier`risktier!(0;0.1;0;0); // account
                `qty`price`reduce`ismaker`side!(1;1000;0b;1b;-1) // fill
            );
            (); // res 
            (
                (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(2;2000;0;0;0;0;0;0;0)); // GetInventory
                (1b;1;enlist(enlist(`aId`balance`feetier`risktier!(0;0.1;0;0)));()); // Update Account
                (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0)));());  
                (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
                (1b;2;();`amt`abc!()); // Emit
                (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
                (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
            ); // mocks 
            () // err 
        ));
        ("short to flat: UPL: 0, RPL:0 ONE POSITION";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                `aId`balance`feetier`risktier!(0;0.1;0;0); // account
                `qty`price`reduce`ismaker`side!(1;1000;1b;1b;-1) // fill
            );
            (); // res 
            (
                (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0));  
                (1b;1;enlist(enlist(`aId`balance`feetier`risktier!(0;0.1;0;0)));()); // Update Account
                (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(0;0;0;0;0;0;0;0;0)));());  
                (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
                (1b;2;();`amt`abc!()); // Emit
                (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
                (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
            ); // mocks 
            () // err 
        ));
        ("short to shorter: UPL: 0, RPL:0 ONE POSITION";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                `aId`balance`feetier`risktier!(0;0.1;0;0); // account
                `qty`price`reduce`ismaker`side!(1;1000;0b;1b;-1) // fill
            );
            (); // res 
            (
                (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(2;2000;0;0;0;0;0;0;0)); // GetInventory
                (1b;1;enlist(enlist(`aId`balance`feetier`risktier!(0;0.1;0;0)));()); // Update Account
                (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0)));());  
                (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
                (1b;2;();`amt`abc!()); // Emit
                (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
                (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
            ); // mocks 
            () // err 
        ))
        / ("short to flat: UPL: 0, RPL:0 ONE POSITION";(
        /     ( // Mocks
        /         `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
        /         `aId`balance`mmr`imr!(0;0.1;0.3;2); // account
        /         `qty`price`dlt`reduce`ismaker!(1;1000;1;1b;1b) // fill
        /     );
        /     (); // res 
        /     (
        /         (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(2;0;0;0;0;0;0;0;0)); // GetInventory
        /         (1b;1;enlist(enlist(`aId`balance`mmr`imr`mkrfee`tkrfee!(0,(5#0.1))));()); // Update Account
        /         (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0)));());  
        /         (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
        /         (1b;3;();`amt`abc!()); // Emit
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
        /         (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
        /     ); // mocks 
        /     (

        /     ) // err 
        / ));
        / ("short to shorter: UPL: 0, RPL:0 ONE POSITION";(
        /     ( // Mocks
        /         `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
        /         `aId`balance`mmr`imr!(0;0.1;0.3;2); // account
        /         `qty`price`dlt`reduce`ismaker!(1;1000;1;1b;1b) // fill
        /     );
        /     (); // res 
        /     (
        /         (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(2;0;0;0;0;0;0;0;0)); // GetInventory
        /         (1b;1;enlist(enlist(`aId`balance`mmr`imr`mkrfee`tkrfee!(0,(5#0.1))));()); // Update Account
        /         (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0)));());  
        /         (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
        /         (1b;3;();`amt`abc!()); // Emit
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
        /         (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
        /     ); // mocks 
        /     (

        /     ) // err 
        / ))
    );
    ({};{};{};{});
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".engine.logic.account.Withdraw";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.account.UpdateAccount;{[a;b]};c];
        mck2: .qt.M[`.engine.Emit;{[a;b]};c];
        mck3: .qt.M[`.engine.Purge;{[a;b;c]};c];
        mck4: .qt.M[`.engine.model.risktier.GetRiskTier;{[a;b] a}[m[3][3]];c];
        mck5: .qt.M[`.engine.model.feetier.GetFeeTier;{[a;b] a}[m[4][3]];c];

        res:.engine.logic.account.Withdraw[a 0;a 1;a 2];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Withdraw no balance:should fail";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;1;();`mrg`mmr`imr!(0.1;0.03;32)); // account
                (1b;1;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Withdraw insufficient balance:should fail";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;1;();`mrg`mmr`imr!(0.1;0.03;32)); // account
                (1b;1;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Withdraw Account disabled:should fail";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;1;();`mrg`mmr`imr!(0.1;0.03;32)); // account
                (1b;1;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Withdraw Account locked:should fail";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;1;();`mrg`mmr`imr!(0.1;0.03;32)); // account
                (1b;1;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Withdraw Success: Update fee tier, risk tier, apply withdraw fee, avail";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;1;();`mrg`mmr`imr!(0.1;0.03;32)); // account
                (1b;1;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ))
    );
    ({};{};{};{});
    "Process a batch of signal events"];

.qt.Unit[
    ".engine.logic.account.Deposit";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.account.GetAccount;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.account.UpdateAccount;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b]};c];
        mck4: .qt.M[`.engine.model.risktier.GetRiskTier;{[a;b] a}[m[3][3]];c];
        mck5: .qt.M[`.engine.model.feetier.GetFeeTier;{[a;b] a}[m[4][3]];c];

        res:.engine.logic.account.Deposit[a 0;a 1;a 2];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Deposit Account disabled:should fail";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;1;();`mrg`mmr`imr!(0.1;0.03;32)); // account
                (1b;1;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Deposit Account locked:should fail";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;1;();`mrg`mmr`imr!(0.1;0.03;32)); // account
                (1b;1;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Deposit Success: Update fee tier, risk tier, avail";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;1;();`mrg`mmr`imr!(0.1;0.03;32)); // account
                (1b;1;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ))
    );
    ({};{};{};{});
    "Process a batch of signal events"];


.qt.Unit[
    ".engine.logic.account.Leverage";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.account.GetAccount;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.account.UpdateAccount;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b]};c];
        mck4: .qt.M[`.engine.model.risktier.GetRiskTier;{[a;b] a}[m[3][3]];c];
        mck5: .qt.M[`.engine.model.feetier.GetFeeTier;{[a;b] a}[m[4][3]];c];

        res:.engine.logic.account.Leverage[a 0;a 1;a 2];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Leverage no balance:should fail";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;1;();`mrg`mmr`imr!(0.1;0.03;32)); // account
                (1b;1;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Leverage insufficient balance:should fail";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;1;();`mrg`mmr`imr!(0.1;0.03;32)); // account
                (1b;1;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Leverage Account disabled:should fail";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;1;();`mrg`mmr`imr!(0.1;0.03;32)); // account
                (1b;1;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Leverage Account locked:should fail";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;1;();`mrg`mmr`imr!(0.1;0.03;32)); // account
                (1b;1;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Leverage Success: Update fee tier, risk tier, apply withdraw fee, avail";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;1;();`mrg`mmr`imr!(0.1;0.03;32)); // account
                (1b;1;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ))
    );
    "Global function for creating a new account"];
 

