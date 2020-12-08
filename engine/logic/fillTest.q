
/ .engine.model.instrument.Instrument,:.util.testutils.makeInstrument[`iId`mkprice`smul;enlist(0;100;100)];

/ .engine.model.risktier.Risktier,:.util.testutils.makeRiskTier[`rtid`mxamt`mmr`imr`maxlev;(
/     (0; 50000;       0.004;    0.008;    125);
/     (1; 250000;      0.005;    0.01;     100))]; 

/ .engine.model.feetier.Feetier,:.util.testutils.makeFeeTier[`ftid`vol`mkrfee`tkrfee`wdrawfee`dpstfee`wdlim;(
/     (0; 50;      0.0006;    0.0006;    0f;  0f; 600);
/     (1; 500;     0.00054;   0.0006;    0f;  0f; 600))];                             //  

/ .engine.model.account.Account,:.util.testutils.makeAccount[`aId`ft`rt;enlist(0;0;0)]

// TODO full integration
// TODO test rpnl and upnl
// TODO test tier change
/ .qt.SkpBesTest[37];
.qt.Unit[
    ".engine.logic.account.Fill";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.inventory.Get;{[a;b] a}[m[0][3]];c];
        mck2: .qt.OM[`.engine.model.account.Update;c];
        mck3: .qt.OM[`.engine.model.inventory.Update;c];
        mck5: .qt.M[`.engine.Emit;{[a;b;c]};c];

        res:.engine.logic.account.Fill[a];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck5;m[4];c];

    };
    {[p] `args`eRes`mocks`err!p};
    (
        enlist("INVERSE:flat to long: UPL: 0, RPL:0 ONE POSITION";(
            .util.testutils.makeFill[`price`side`qty`reduce`ismaker`oId`aId`iId;
                enlist(1000;1;100;0b;0b;0;`.engine.model.account.Account$0;`.engine.model.instrument.Instrument$0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[
                    `amt`totalEntry`ordQty`ordVal`ordLoss`rpnl`execCost`avgPrice`reduce`amt`upnl;
                    enlist(0;0;0;0;0;0;0;0;0;0;0)
                ]); // GetInventory
                (1b;2;();.util.testutils.makeEvent[]); // Emit
                (1b;1;();.util.testutils.makeRisktier[]); // GetRiskTier
                (1b;1;();.util.testutils.makeFeetier[]); // GetFeeTier
                (1b;1;.util.testutils.makeAccount[];()); // Update Account
                (1b;1;.util.testutils.makeInventory[];()) // Update Inventory 
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

