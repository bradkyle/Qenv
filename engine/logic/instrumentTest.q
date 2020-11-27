

/ .qt.SkpBesTest[27];
.qt.Unit[
    ".engine.logic.instrument.Funding";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.account.GetAccount;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.account.UpdateAccount;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b]};c];
        mck4: .qt.M[`.engine.model.risktier.GetRiskTier;{[a;b] a}[m[3][3]];c];
        mck5: .qt.M[`.engine.model.feetier.GetFeeTier;{[a;b] a}[m[4][3]];c];

        res:.engine.logic.instrument.Funding[a 0;a 1];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (


        ("Positive Funding: no accounts";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Negative Funding: No accounts";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));

        ("Positive Funding: One account, longs pay shorts";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Negative Funding: One account, shorts pay longs";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Positive Funding: Multiple accounts, longs pay shorts";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Negative Funding: Multiple accounts, shorts pay longs";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.SkpBesTest[28];
.qt.Unit[
    ".engine.logic.instrument.MarkPrice";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.inventory.GetInventory;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.account.UpdateAccount;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b]};c];
        mck4: .qt.M[`.engine.model.risktier.GetRiskTier;{[a;b] a}[m[3][3]];c];
        mck5: .qt.M[`.engine.model.feetier.GetFeeTier;{[a;b] a}[m[4][3]];c];

        res:.engine.logic.instrument.MarkPrice[a 0;a 1];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Update mark price (decreasing), one account: no positions";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();enlist(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1;1000;0;1;1;100000;1000;0;0))));
                (1b;3;();()); // 
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (increasing), one account: no positions";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();enlist(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1;1000;0;1;1;100000;1000;0;0))));
                (1b;3;();()); // 
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (decreasing), one account: no positions effected";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();enlist(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1;1000;0;1;1;100000;1000;0;0))));
                (1b;3;();()); // 
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (decreasing), one account: no positions effected";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();enlist(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1;1000;0;1;1;100000;1000;0;0))));
                (1b;3;();()); // 
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (decreasing), one account: UPL:0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();enlist(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1;1000;0;1;1;100000;1000;0;0))));
                (1b;3;();()); // 
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (decreasing), one account: UPL:-0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();enlist(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1;1000;0;1;1;100000;1000;0;0))));
                (1b;3;();()); // 
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (increasing), one account: UPL:0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();enlist(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1;1000;0;1;1;100000;1000;0;0))));
                (1b;3;();()); // 
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (increasing), one account: UPL:-0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();enlist(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1;1000;0;1;1;100000;1000;0;0))));
                (1b;3;();()); // 
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (decreasing), one account: liqduiation for tier should occur";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();enlist(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1;1000;0;1;1;100000;1000;0;0))));
                (1b;3;();()); // 
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (increasing), one account: liquidation for tier should occur";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();enlist(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1;1000;0;1;1;100000;1000;0;0))));
                (1b;3;();()); // 
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("First should succeed";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();enlist(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1;1000;0;1;1;100000;1000;0;0))));
                (1b;3;();()); // 
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.logic.instrument.Settlement";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.account.GetAccount;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.account.UpdateAccount;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b]};c];
        mck4: .qt.M[`.engine.model.risktier.GetRiskTier;{[a;b] a}[m[3][3]];c];
        mck5: .qt.M[`.engine.model.feetier.GetFeeTier;{[a;b] a}[m[4][3]];c];

        res:.engine.logic.instrument.Settlement[a 0;a 1];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Update mark price (increasing), one account: liquidation for tier should occur";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();enlist(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1;1000;0;1;1;100000;1000;0;0))));
                (1b;3;();()); // 
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("First should succeed";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();enlist(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1;1000;0;1;1;100000;1000;0;0))));
                (1b;3;();()); // 
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];



.qt.Unit[
    ".engine.logic.instrument.PriceLimit";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.account.GetAccount;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.account.UpdateAccount;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b]};c];
        mck4: .qt.M[`.engine.model.risktier.GetRiskTier;{[a;b] a}[m[3][3]];c];
        mck5: .qt.M[`.engine.model.feetier.GetFeeTier;{[a;b] a}[m[4][3]];c];

        res:.engine.logic.instrument.PriceLimit[a 0;a 1];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("First should succeed";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        ("Second should succeed";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        / ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
        /     (10;5;0.1;1);(1 1 1);()
        / ));
        / ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
        /     (10;5;0.1;1);(1 1 1);()
        / ));
        / ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
        /     (10;5;0.1;1);(1 1 1);()
        / ))
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


