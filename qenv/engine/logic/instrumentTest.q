
// TODO test multiple accounts
// TODO test multiple events

/ .qt.SkpBesTest[(27 37)];
.qt.Unit[
    ".engine.logic.instrument.Funding";
    {[c]
        p:c[`params];
        m:p[`mocks];
        .engine.testutils.SwitchSetupModels[p`setup];

        mck0: .qt.M[`.engine.model.account.Update;{[a;b]};c];
        mck1: .qt.M[`.engine.model.inventory.Update;{[a;b]};c];
        mck2: .qt.M[`.engine.E;{[a]};c];

        a:.model.Funding . p`args;
        res:.engine.logic.instrument.Funding a;

        .qt.CheckMock[mck0;m[0];c];
        .qt.CheckMock[mck1;m[1];c];
        .qt.CheckMock[mck2;m[2];c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Positive Funding: no open inventory";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`rpnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;0 0;10 10;10 10))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt`wit`time`froz;enlist(0;10;10;(0 1);(0 -1);0;0;0;z;0))) 
                / (`order;(`oId`aId`iId;enlist(0;0;0))) // Update Account
            ));
            (`iId`time`fundingrate;enlist(0;z;0.0001));
            (); // res 
            (
                (1b;1;e2 `aId`time`froz`bal`avail!(0;z;0;10;10);()); // Update Account
                (1b;1;e2 flip `aId`side`time`amt`avgPrice`upnl`rpnl!(0 0;-1 1;2#z;10 10;0N 0N;0 0;-0.001 -0.001);()); //Update Inventory 
                (1b;3;(
                .event.Inventory[`aId`side`time`amt`avgPrice`upnl`rpnl!(0 0;-1 1;2#z;10 10;0N 0N;0 0;-0.001 -0.001)];
                .event.Account[`aId`time`froz`bal`avail!(0;z;0;10;10)];
                .event.Funding[`iId`time`fundingrate!(0;z;0.0001)]
                );()) // .engine.E 
            ); // mocks 
            () // err 
        ));
        ("Positive Funding: no open inventory";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`rpnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;0 0;10 10;10 10))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt`wit`time`froz;enlist(0;10;10;(0 1);(0 -1);0;0;0;z;0))) 
                / (`order;(`oId`aId`iId;enlist(0;0;0))) // Update Account
            ));
            (`iId`time`fundingrate;enlist(0;z;0.0001));
            (); // res 
            (
                (1b;1;e2 `aId`time`froz`bal`avail!(0;z;0;10;10);()); // Update Account
                (1b;1;e2 flip `aId`side`time`amt`avgPrice`upnl`rpnl!(0 0;-1 1;2#z;10 10;0N 0N;0 0;-0.001 -0.001);()); //Update Inventory 
                (1b;3;(
                .event.Inventory[`aId`side`time`amt`avgPrice`upnl`rpnl!(0 0;-1 1;2#z;10 10;0N 0N;0 0;-0.001 -0.001)];
                .event.Account[`aId`time`froz`bal`avail!(0;z;0;10;10)];
                .event.Funding[`iId`time`fundingrate!(0;z;0.0001)]
                );()) // .engine.E 
            ); // mocks 
            () // err 
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
    ".engine.logic.instrument.Mark";
    {[c]
        p:c[`params];
        m:p[`mocks];
        .engine.testutils.SwitchSetupModels[p`setup];

        mck0: .qt.M[`.engine.model.account.Update;{[a;b]};c];
        mck1: .qt.M[`.engine.model.inventory.Update;{[a;b]};c];
        mck2: .qt.M[`.engine.E;{[a;b;c]};c];

        a:.model.Mark . p`args;
        res:.engine.logic.instrument.Mark a;

        .qt.CheckMock[mck0;m[0];c];
        .qt.CheckMock[mck1;m[1];c];
        .qt.CheckMock[mck2;m[2];c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Update mark price (decreasing), one account: no positions";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1))); 
                (`inventory;(`aId`side`iId`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt`rpnl`time;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;0 0;10 10;10 10;0 0;2#z))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
                / (`order;(`oId`aId`iId;enlist(0;0;0))) // Update Account
            ));
            (`iId`time`markprice;enlist(0;z;0.0001));
            (); // res 
            (
                (1b;1;e2 `aId`time`froz`bal`avail!(0;z;0;10;10);()); // Update Account
                (1b;1;e2 flip `aId`side`time`amt`avgPrice`upnl`rpnl!(0 0;-1 1;2#z;10 10;0N 0N;0 0;-0.001 -0.001);()); //Update Inventory 
                (1b;3;(
                .event.Inventory[`aId`side`time`amt`avgPrice`upnl`rpnl!(0 0;-1 1;2#z;10 10;0N 0N;0 0;-0.001 -0.001)];
                .event.Account[`aId`time`froz`bal`avail!(0;z;0;10;10)];
                .event.Mark[`iId`time`mkprice!(0;z;0.0001)]
                );()) // .engine.E 
            ); // mocks 
            () // err 
        ));
        ("Update mark price (increasing), one account: no positions";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1))); 
                (`inventory;(`aId`side`iId`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt`rpnl`time;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;0 0;10 10;10 10;0 0;2#z))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
                / (`order;(`oId`aId`iId;enlist(0;0;0))) // Update Account
            ));
            (`iId`time`markprice;enlist(0;z;0.0001));
            (); // res 
            (
                (1b;1;e2 `aId`time`froz`bal`avail!(0;z;0;10;10);()); // Update Account
                (1b;1;e2 flip `aId`side`time`amt`avgPrice`upnl`rpnl!(0 0;-1 1;2#z;10 10;0N 0N;0 0;-0.001 -0.001);()); //Update Inventory 
                (1b;3;(
                .event.Inventory[`aId`side`time`amt`avgPrice`upnl`rpnl!(0 0;-1 1;2#z;10 10;0N 0N;0 0;-0.001 -0.001)];
                .event.Account[`aId`time`froz`bal`avail!(0;z;0;10;10)];
                .event.Mark[`iId`time`mkprice!(0;z;0.0001)]
                );()) // .engine.E 
            ); // mocks 
            () // err 
        ))
        / ("Update mark price (decreasing), one account: no positions effected";(
        /     .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Update mark price (decreasing), one account: no positions effected";(
        /     .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Update mark price (decreasing), one account: UPL:0.5";(
        /     .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Update mark price (decreasing), one account: UPL:-0.5";(
        /     .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Update mark price (increasing), one account: UPL:0.5";(
        /     .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Update mark price (increasing), one account: UPL:-0.5";(
        /     .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Update mark price (decreasing), one account: liqduiation for tier should occur";(
        /     .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Update mark price (increasing), one account: liquidation for tier should occur";(
        /     .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("First should succeed";(
        /     .util.testutils.makeMark[`iId`markprice;enlist(0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


/ .qt.SkpBesTest[29];
.qt.Unit[
    ".engine.logic.instrument.Settlement";
    {[c]
        p:c[`params];
        m:p[`mocks];
        .engine.testutils.SwitchSetupModels[p`setup];

        mck0: .qt.M[`.engine.model.account.Update;{[a;b]};c];
        mck1: .qt.M[`.engine.model.inventory.Update;{[a;b]};c];
        mck2: .qt.M[`.engine.E;{[a;b;c]};c];

        a:.model.Settlement . p`args;
        res:.engine.logic.instrument.Settlement a;

        .qt.CheckMock[mck0;m[0];c];
        .qt.CheckMock[mck1;m[1];c];
        .qt.CheckMock[mck2;m[2];c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Settlement no accounts";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt`rpnl`time;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10;0 0;2#z))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
                / (`order;(`oId`aId`iId;enlist(0;0;0))) // Update Account
            ));
            (`iId`time;enlist(0;z));
            (); // res 
            (
                (1b;1;();()); // Account 
                (1b;1;();()); // Inventory  
                (1b;3;();()) // .engine.E 
            ); // mocks 
            () // err 
        ));
        ("Settlement one account no inventory";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt`rpnl`time;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10;0 0;2#z))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
                / (`order;(`oId`aId`iId;enlist(0;0;0))) // Update Account
            ));
            (`iId`time;enlist(0;z));
            (); // res 
            (
                (1b;1;();()); // Account 
                (1b;1;();()); // Inventory  
                (1b;3;();()) // .engine.E 
            ); // mocks 
            () // err 
        ))
        / ("Settlement one account, one short inventory: RPL 0.5";(
        /     .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Settlement one account, one short inventory: RPL -0.5";(
        /     .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Settlement one account, one long inventory: RPL 0.5";(
        /     .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Settlement one account, one long inventory: RPL -0.5";(
        /     .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Settlement one account, both sides long/short (0.75/0.25) inventory: RPL 0.5";(
        /     .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Settlement one account, both sides short/long (0.75/0.25) inventory: RPL 0.5";(
        /     .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Settlement one account, both sides long/short (0.75/0.25) inventory: RPL -0.5";(
        /     .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Settlement one account, both sides short/long (0.75/0.25) inventory: RPL -0.5";(
        /     .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Settlement one account, both sides long/short (0.5/0.5) inventory: RPL 0.5";(
        /     .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Settlement one account, both sides short/long (0.5/0.5) inventory: RPL -0.5";(
        /     .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Settlement multiple account, both sides long/short (0.5/0.5) inventory: RPL 0.5";(
        /     .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Settlement multiple account, both sides short/long (0.5/0.5) inventory: RPL -0.5";(
        /     .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ));
        / ("First should succeed";(
        /     .util.testutils.makeSettlement[`iId`time;enlist(0;z)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
        /         (1b;1;();.util.testutils.makeAccount[]); // GetAccount 
        /         (1b;1;.util.testutils.makeAccount[];()); // UpdateAccount 
        /         (1b;3;.util.testutils.makeEvent[];()) // Emit
        /     ); // mocks 
        /     () // err 
        / ))
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
        .engine.testutils.SwitchSetupModels[p`setup];

        mck0: .qt.M[`.engine.logic.order.Cancel;{[a;b]};c];
        mck1: .qt.M[`.engine.model.inventory.Update;{[a;b]};c];
        mck2: .qt.M[`.engine.E;{[a]};c];

        a:.model.PriceLimit . p`args;
        res:.engine.logic.instrument.PriceLimit a;

        .qt.CheckMock[mck0;m[0];c];
        .qt.CheckMock[mck1;m[1];c];
        .qt.CheckMock[mck2;m[2];c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Settlement multiple account, both sides short/long (0.5/0.5) inventory: RPL -0.5";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`rpnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;0 0;10 10;10 10))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt`wit`time`froz;enlist(0;10;10;(0 1);(0 -1);0;0;0;z;0))) 
                / (`order;(`oId`aId`iId;enlist(0;0;0))) // Update Account
            ));
            (`iId`time`highest`lowest;enlist(0;z;1100;1000));
            (); // res 
            (
                (1b;1;();()); // Cancel Order 
                (1b;1;e2 flip `aId`side`time`amt`avgPrice`upnl`rpnl!(0 0;-1 1;2#z;10 10;0N 0N;0 0;-0.001 -0.001);()); //Update Inventory 
                (1b;1;(
                .event.PriceLimit[`iId`time`highest`lowest!(0;z;1100;1000)]
                );()) // .engine.E 
            ); // mocks 
            () // err 
        ));
        ("First should succeed";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`rpnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;0 0;10 10;10 10))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt`wit`time`froz;enlist(0;10;10;(0 1);(0 -1);0;0;0;z;0))) 
                / (`order;(`oId`aId`iId;enlist(0;0;0))) // Update Account
            ));
            (`iId`time`highest`lowest;enlist(0;z;1100;1000));
            (); // res 
            (
                (1b;1;();()); // Cancel Order 
                (1b;1;e2 flip `aId`side`time`amt`avgPrice`upnl`rpnl!(0 0;-1 1;2#z;10 10;0N 0N;0 0;-0.001 -0.001);()); //Update Inventory 
                (1b;1;(
                .event.PriceLimit[`iId`time`highest`lowest!(0;z;1100;1000)]
                );()) // .engine.E 
            ); // mocks 
            () // err 
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


