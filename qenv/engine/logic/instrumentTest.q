
// TODO test multiple accounts
// TODO test multiple events

/ .qt.SkpBesTest[27];
.qt.Unit[
    ".engine.logic.instrument.Funding";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck0: .qt.M[`.engine.model.inventory.GetInventory;{[a;b] a}[m[0][3]];c];
        mck1: .qt.M[`.engine.model.account.GetAccount;{[a;b] a}[m[1][3]];c];
        mck2: .qt.M[`.engine.model.account.UpdateAccount;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b;c]};c];
        mck4: .qt.M[`.engine.logic.account.Remargin;{[a;b;c] a}[m[4][3]];c];

        res:.engine.logic.instrument.Funding[z;a 0;a 1];

        .qt.CheckMock[mck0;m[0];c];
        .qt.CheckMock[mck1;m[1];c];
        .qt.CheckMock[mck2;m[2];c];
        .qt.CheckMock[mck3;m[3];c];
        .qt.CheckMock[mck4;m[4];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Positive Funding: no accounts";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                0.0001
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            () // err 
        ));
        ("Negative Funding: No accounts";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                0.0001
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Positive Funding: One account, longs pay shorts";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                0.0001
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Negative Funding: One account, shorts pay longs";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                0.0001
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Positive Funding: Multiple accounts, longs pay shorts";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                0.0001
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Negative Funding: Multiple accounts, shorts pay longs";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                0.0001
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

/ .qt.SkpBesTest[28];
.qt.Unit[
    ".engine.logic.instrument.MarkPrice";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck0: .qt.M[`.engine.model.account.GetAccount;{[a;b] a}[m[0][3]];c];
        mck1: .qt.M[`.engine.model.inventory.GetInventory;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.account.UpdateAccount;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b;c]};c];
        mck4: .qt.M[`.engine.model.risktier.GetRiskTier;{[a;b] a}[m[3][3]];c];
        mck5: .qt.M[`.engine.model.feetier.GetFeeTier;{[a;b] a}[m[4][3]];c];

        res:.engine.logic.instrument.MarkPrice[z;a 0;a 1];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Update mark price (decreasing), one account: no positions";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (increasing), one account: no positions";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (decreasing), one account: no positions effected";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (decreasing), one account: no positions effected";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (decreasing), one account: UPL:0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (decreasing), one account: UPL:-0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (increasing), one account: UPL:0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (increasing), one account: UPL:-0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (decreasing), one account: liqduiation for tier should occur";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Update mark price (increasing), one account: liquidation for tier should occur";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("First should succeed";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
                1000
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


/ .qt.SkpBesTest[29];
.qt.Unit[
    ".engine.logic.instrument.Settlement";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck0: .qt.M[`.engine.model.account.GetAccount;{[a;b] a}[m[0][3]];c];
        mck1: .qt.M[`.engine.model.inventory.GetInventory;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.account.UpdateAccount;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b;c]};c];
        mck4: .qt.M[`.engine.model.risktier.GetRiskTier;{[a;b] a}[m[3][3]];c];
        mck5: .qt.M[`.engine.model.feetier.GetFeeTier;{[a;b] a}[m[4][3]];c];


        res:.engine.logic.instrument.Settlement[z;a 0;a 1];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Settlement no accounts";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Settlement one account no inventory";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Settlement one account, one short inventory: RPL 0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Settlement one account, one short inventory: RPL -0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Settlement one account, one long inventory: RPL 0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Settlement one account, one long inventory: RPL -0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Settlement one account, both sides long/short (0.75/0.25) inventory: RPL 0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Settlement one account, both sides short/long (0.75/0.25) inventory: RPL 0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Settlement one account, both sides long/short (0.75/0.25) inventory: RPL -0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Settlement one account, both sides short/long (0.75/0.25) inventory: RPL -0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Settlement one account, both sides long/short (0.5/0.5) inventory: RPL 0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Settlement one account, both sides short/long (0.5/0.5) inventory: RPL -0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Settlement multiple account, both sides long/short (0.5/0.5) inventory: RPL 0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("Settlement multiple account, both sides short/long (0.5/0.5) inventory: RPL -0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("First should succeed";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                ()
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


/ .qt.SkpBesTest[30];
.qt.Unit[
    ".engine.logic.instrument.PriceLimit";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.order.GetOrder;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.instrument.UpdateInstrument;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b;c]};c];

        res:.engine.logic.instrument.PriceLimit[z;a 0;a 1];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Settlement multiple account, both sides short/long (0.5/0.5) inventory: RPL -0.5";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                (1000 1000)
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ));
        ("First should succeed";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                (1000 1000)
            );
            (); // res 
            (
                (1b;1;();flip(enlist(`aId`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl`side!(0;1;1000;0;1;1;100000;1000;0;0;-1))));  
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))); // GetAccount 
                (1b;1;();()); // UpdateAccount 
                (1b;3;();()); // Emit
                (1b;1;();flip(enlist(`balance`mmr`imr!(0.1;0.03;32)))) // Remargin 
            ); // mocks 
            (

            ) // err 
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

