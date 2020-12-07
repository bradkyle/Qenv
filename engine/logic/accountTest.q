
.engine.model.risktier.RiskTier,:flip `rtid`mxamt`mmr`imr`maxlev!flip[(
    (0; 50000;       0.004;    0.008;    125);
    (1; 250000;      0.005;    0.01;     100);
    (2; 1000000;     0.01;     0.02;     50);
    (3; 5000000;     0.025;    0.05;     20);
    (4; 20000000;    0.05;     0.1;      10);
    (5; 50000000;    0.1;      0.20;     5);
    (6; 100000000;   0.125;    0.25;     4);
    (7; 200000000;   0.15;     0.333;    3);
    (8; 500000000;   0.25;     0.50;     2);
    (9; 500000000;   0.25;     1.0;      1))]; 

.engine.model.feetier.FeeTier,:flip `ftid`vol`mkrfee`tkrfee`wdrawfee`dpstfee`wdlim!flip[(
    (0; 50;      0.0006;    0.0006;    0f;  0f; 600);
    (1; 500;     0.00054;   0.0006;    0f;  0f; 600);
    (2; 1500;    0.00048;   0.0006;    0f;  0f; 600);
    (3; 4500;    0.00042;   0.0006;    0f;  0f; 600);
    (4; 10000;   0.00042;   0.00054;   0f;  0f; 600);
    (5; 20000;   0.00036;   0.00048;   0f;  0f; 600);
    (6; 40000;   0.00024;   0.00036;   0f;  0f; 600);
    (7; 80000;   0.00018;   0.000300;  0f;  0f; 600);
    (8; 150000;  0.00012;   0.00024;   0f;  0f; 600))];                             //  

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
        / mck2: .qt.M[`.engine.model.account.Update;{[a;b;c]};c];
        / mck3: .qt.M[`.engine.model.inventory.Update;{[a;b;c]};c];
        mck5: .qt.M[`.engine.Emit;{[a;b;c]};c];

        res:.engine.logic.account.Fill[z;a 0;a 1;a 2];

        .qt.CheckMock[mck1;m[0];c];
        / .qt.CheckMock[mck4;m[3];c];
        .qt.CheckMock[mck5;m[4];c];
        .qt.RestoreMocks[];

        .util.table.dropAll[(
          `.engine.ingress.Events,
          `.engine.egress.Events,
          `.engine.model.order.Order,
          `.engine.model.account.Account,
          `.engine.model.inventory.Inventory,
          `.engine.model.instrument.Instrument,
          `.engine.model.orderbook.OrderBook
        )];

    };
    {[p] :`args`eRes`mocks`err!p};
    (
        enlist("INVERSE:flat to long: UPL: 0, RPL:0 ONE POSITION";(
            ( // Mocks
                .util.testutils.makeInstrument[]; // instrument
                .util.testutils.makeAccount[];
                `qty`price`reduce`ismaker`side!(1;1000;0b;1b;1) // fill
            );
            (); // res 
            (
                (1b;1;();.util.testutils.makeAccount[]); // GetInventory
                (1b;1;.util.testutils.makeAccount[];()); // Update Account
                (1b;1;.util.testutils.makeInventory[];());  
                (1b;1;.util.testutils.makeInstrument[];()); // Update Instrument 
                (1b;2;();.util.testutils.makeEvent[]); // Emit
                (1b;1;();.util.testutils.makeRisktier[]); // GetRiskTier
                (1b;1;();.util.testutils.makeFeetier[]) // GetFeeTier
            ); // mocks 
            () // err 
        ))
        / ("INVERSE:long to flat: UPL: 0, RPL:0 ONE POSITION";(
        /     ( // Mocks
        /         `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
        /         `aId`balance`feetier`risktier!(0;0.1;0;0); // account
        /         `qty`price`reduce`ismaker`side!(1;1000;1b;1b;1) // fill
        /     );
        /     (); // res 
        /     (
        /         (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0));  
        /         (1b;1;enlist(enlist(`aId`balance`feetier`risktier!(0;0.1;0;0)));()); // Update Account
        /         (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(0;0;0;0;0;0;0;0;0)));());  
        /         (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
        /         (1b;2;();`amt`abc!()); // Emit
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
        /         (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
        /     ); // mocks 
        /     () // err 
        / ));
        / ("long to longer: UPL: 0, RPL:0 ONE POSITION";(
        /     ( // Mocks
        /         `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
        /         `aId`balance`feetier`risktier!(0;0.1;0;0); // account
        /         `qty`price`reduce`ismaker`side!(1;1000;0b;1b;1) // fill
        /     );
        /     (); // res 
        /     (
        /         (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(2;2000;0;0;0;0;0;0;0)); // GetInventory
        /         (1b;1;enlist(enlist(`aId`balance`feetier`risktier!(0;0.1;0;0)));()); // Update Account
        /         (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0)));());  
        /         (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
        /         (1b;2;();`amt`abc!()); // Emit
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
        /         (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
        /     ); // mocks 
        /     () // err 
        / ));
        / ("long to longer: UPL:-0.5, orderLoss: 0.5, RPL:0 ONE POSITION";( // TODO
        /     ( // Mocks
        /         `cntTyp`faceValue`mkprice`smul!(0;1;1500;1); // instrument
        /         `aId`balance`feetier`risktier!(0;0.1;0;0); // account
        /         `qty`price`reduce`ismaker`side!(1;1000;0b;1b;1) // fill
        /     );
        /     (); // res 
        /     (
        /         (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(2;2000;0;0;0;0;0;0;0)); // GetInventory
        /         (1b;1;enlist(enlist(`aId`balance`feetier`risktier!(0;0.1;0;0)));()); // Update Account
        /         (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;500;1;1;100000;1000;0;0)));());  
        /         (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
        /         (1b;2;();`amt`abc!()); // Emit
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
        /         (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
        /     ); // mocks 
        /     () // err 
        / ));
        / ("flat to short: UPL: 0, RPL:0 ONE POSITION";(
        /     ( // Mocks
        /         `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
        /         `aId`balance`feetier`risktier!(0;0.1;0;0); // account
        /         `qty`price`reduce`ismaker`side!(1;1000;0b;1b;-1) // fill
        /     );
        /     (); // res 
        /     (
        /         (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(2;2000;0;0;0;0;0;0;0)); // GetInventory
        /         (1b;1;enlist(enlist(`aId`balance`feetier`risktier!(0;0.1;0;0)));()); // Update Account
        /         (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0)));());  
        /         (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
        /         (1b;2;();`amt`abc!()); // Emit
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
        /         (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
        /     ); // mocks 
        /     () // err 
        / ));
        / ("short to flat: UPL: 0, RPL:0 ONE POSITION";(
        /     ( // Mocks
        /         `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
        /         `aId`balance`feetier`risktier!(0;0.1;0;0); // account
        /         `qty`price`reduce`ismaker`side!(1;1000;1b;1b;-1) // fill
        /     );
        /     (); // res 
        /     (
        /         (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0));  
        /         (1b;1;enlist(enlist(`aId`balance`feetier`risktier!(0;0.1;0;0)));()); // Update Account
        /         (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(0;0;0;0;0;0;0;0;0)));());  
        /         (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
        /         (1b;2;();`amt`abc!()); // Emit
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
        /         (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
        /     ); // mocks 
        /     () // err 
        / ));
        / ("short to shorter: UPL: 0, RPL:0 ONE POSITION";(
        /     ( // Mocks
        /         `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
        /         `aId`balance`feetier`risktier!(0;0.1;0;0); // account
        /         `qty`price`reduce`ismaker`side!(1;1000;0b;1b;-1) // fill
        /     );
        /     (); // res 
        /     (
        /         (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(2;2000;0;0;0;0;0;0;0)); // GetInventory
        /         (1b;1;enlist(enlist(`aId`balance`feetier`risktier!(0;0.1;0;0)));()); // Update Account
        /         (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0)));());  
        /         (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
        /         (1b;2;();`amt`abc!()); // Emit
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
        /         (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
        /     ); // mocks 
        /     () // err 
        / ))
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
 

