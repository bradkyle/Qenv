
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
    ".engine.logic.inventory.Fill";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];
        s:p[`setup];

        / a[`lng]:`.engine.model.inventory.Inventory$(0 1);
        / a[`srt]:`.engine.model.inventory.Inventory$(0 -1);

        .engine.model.instrument.Instrument,:s[`instrument];
        .engine.model.account.Account,:s[`account];
        .engine.model.inventory.Inventory,:s[`inventory];
        .engine.model.feetier.Feetier,:s[`feetier];
        .engine.model.risktier.Risktier,:s[`risktier];

        a[`aId]:`.engine.model.account.Account$a[`aId];
        a[`iId]:`.engine.model.instrument.Instrument$a[`iId];
        a[`ivId]:`.engine.model.inventory.Inventory$flip[a[`aId`side]];

        mck0: .qt.M[`.engine.model.inventory.Get;{[a;b] a}[m[0][3]];c];
        mck2: .qt.OM[`.engine.model.inventory.Update;c];
        mck3: .qt.M[`.engine.Emit;{[a;b;c]};c];

        res:.engine.logic.inventory.Fill[a];

        .qt.CheckMock[mck2;m[2];c]; // Inventory Update
        .qt.CheckMock[mck3;m[3];c]; // Emit 

        / .util.table.dropAll[(
        /   `.engine.egress.Events;
        /   `.engine.model.inventory.Inventory,
        /   `.engine.model.risktier.RiskTier,
        /   `.engine.model.feetier.Feetier
        / )];

    };
    {[p] `setup`args`eRes`mocks`err!p};
    (
        enlist("INVERSE:flat to long: UPL: 0, RPL:0 ONE POSITION";(
            ((!) . flip(
                (`account;.model.Account[`aId`avail`bal;enlist(0;0;0)]); 
                (`instrument;.model.Instrument[`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1)]); 
                (`inventory;.model.Inventory[`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10)]); 
                (`feetier;.model.Feetier[`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0)]); // Update Account
                (`risktier;.model.Risktier[`rtId`amt`lev;flip(0 1;50000 250000;125 100)]) // Update Account
                (`order;.model.Order[]) // Update Account
            ));
            .model.Fill[`fId`price`side`qty`reduce`ismaker`oId`aId`iId`time;flip(0 1;1000 1000;1 -1;100 100;01b;01b;0 1;0 0;0 0;2#z)];
            (); // res 
            (
                (1b;1;.model.Inventory[];()); // UpdateInventory 
                (1b;2;(.event.Inventory[];.event.Fill[]);()) // Emit
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

