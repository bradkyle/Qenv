
// TODO test multiple accounts
// TODO test multiple events

.qt.SkpBesTest[27];
.qt.Unit[
    ".engine.logic.instrument.Funding";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck2: .qt.M[`.engine.model.account.Update;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b;c]};c];

        res:.engine.logic.instrument.Funding[z;a 0;a 1];

        .qt.CheckMock[mck0;m[0];c];
        .qt.CheckMock[mck1;m[1];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Positive Funding: no accounts";(
            ((!) . flip(
            (`account;.model.Account[`aId`avail`bal;enlist(0;0;0)]); 
            (`instrument;.model.Instrument[`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1)]); 
            (`inventory;.model.Inventory[`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10)]); 
            (`feetier;.model.Feetier[`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0)]); // Update Account
            (`risktier;.model.Risktier[`rtId`amt`lev;flip(0 1;50000 250000;125 100)]) // Update Account
            ));
            .event.Funding[`iId`fundingrate;enlist(0;0.0001)];
            (); // res 
            (
            (1b;1;.model.Account[];()); // UpdateAccount 
            (1b;3;(.event.Funding[], .event.Inventory[], .event.Account[]);()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Negative Funding: No accounts";(
            ((!) . flip(
            (`account;.model.Account[`aId`avail`bal;enlist(0;0;0)]); 
            (`instrument;.model.Instrument[`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1)]); 
            (`inventory;.model.Inventory[`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10)]); 
            (`feetier;.model.Feetier[`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0)]); // Update Account
            (`risktier;.model.Risktier[`rtId`amt`lev;flip(0 1;50000 250000;125 100)]) // Update Account
            ));
            .event.Funding[`iId`fundingrate;enlist(0;0.0001)];
            (); // res 
            (
                (1b;1;.model.Account[];()); // UpdateAccount 
                (1b;3;(.event.Funding[], .event.Inventory[], .event.Account[]);()) // Emit
            ); // mocks 
            (

            ) // err 
        ))
        / ("Positive Funding: One account, longs pay shorts";(
        /     .util.testutils.makeFunding[`iId`fundingrate;enlist(0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     (

        /     ) // err 
        / ));
        / ("Negative Funding: One account, shorts pay longs";(
        /     .util.testutils.makeFunding[`iId`fundingrate;enlist(0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     (

        /     ) // err 
        / ));
        / ("Positive Funding: Multiple accounts, longs pay shorts";(
        /     .util.testutils.makeFunding[`iId`fundingrate;enlist(0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     (

        /     ) // err 
        / ));
        / ("Negative Funding: Multiple accounts, shorts pay longs";(
        /     .util.testutils.makeFunding[`iId`fundingrate;enlist(0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     (

        /     ) // err 
        / ))
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

        mck2: .qt.M[`.engine.model.account.Update;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b;c]};c];

        res:.engine.logic.instrument.MarkPrice[z;a 0;a 1];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Update mark price (decreasing), one account: no positions";(
            ((!) . flip(
            (`account;.model.Account[`aId`avail`bal;enlist(0;0;0)]); 
            (`instrument;.model.Instrument[`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1)]); 
            (`inventory;.model.Inventory[`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10)]); 
            (`feetier;.model.Feetier[`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0)]); // Update Account
            (`risktier;.model.Risktier[`rtId`amt`lev;flip(0 1;50000 250000;125 100)]) // Update Account
            ));
            .event.Mark[`iId`markprice;enlist(0;0.0001)];
            (); // res 
            (
            (1b;1;.model.Account[];()); // UpdateAccount 
            (1b;3;(.event.Funding[], .event.Inventory[], .event.Account[]);()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Update mark price (increasing), one account: no positions";(
            .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Update mark price (decreasing), one account: no positions effected";(
            .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Update mark price (decreasing), one account: no positions effected";(
            .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Update mark price (decreasing), one account: UPL:0.5";(
            .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Update mark price (decreasing), one account: UPL:-0.5";(
            .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Update mark price (increasing), one account: UPL:0.5";(
            .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Update mark price (increasing), one account: UPL:-0.5";(
            .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Update mark price (decreasing), one account: liqduiation for tier should occur";(
            .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Update mark price (increasing), one account: liquidation for tier should occur";(
            .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("First should succeed";(
            .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
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
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Settlement one account no inventory";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Settlement one account, one short inventory: RPL 0.5";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Settlement one account, one short inventory: RPL -0.5";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Settlement one account, one long inventory: RPL 0.5";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Settlement one account, one long inventory: RPL -0.5";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Settlement one account, both sides long/short (0.75/0.25) inventory: RPL 0.5";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Settlement one account, both sides short/long (0.75/0.25) inventory: RPL 0.5";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Settlement one account, both sides long/short (0.75/0.25) inventory: RPL -0.5";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Settlement one account, both sides short/long (0.75/0.25) inventory: RPL -0.5";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Settlement one account, both sides long/short (0.5/0.5) inventory: RPL 0.5";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Settlement one account, both sides short/long (0.5/0.5) inventory: RPL -0.5";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Settlement multiple account, both sides long/short (0.5/0.5) inventory: RPL 0.5";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Settlement multiple account, both sides short/long (0.5/0.5) inventory: RPL -0.5";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("First should succeed";(
            .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
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
            .util.testutils.makeMark[`iId`time`highest`lowest;enlist(0;z;0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("First should succeed";(
            .util.testutils.makeMark[`iId`time`highest`lowest;enlist(0;z;0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
                (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


