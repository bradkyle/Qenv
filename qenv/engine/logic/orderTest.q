

// TODO integration tests.

// TOOD place limit order, stop order, market order
// TODO Cancel limit order, stop market order, stop limit order
// TODO place limit participate don't initiate (post only)
// TODO place iceberg/hidden order
// TODO commenting
// TODO orderbook update, order update
// TODO amend to different price/
// TODO amend to cross spread
// TODO amend to cross spread stop order
// TODO validation and stop orders
// TODO Check mock called with correct
/// TODO simulate order loss
/ .qt.SkpBesTest[31];
.qt.Unit[
    ".engine.logic.order.New";
    {[c]
        p:c[`params];
        m:p[`mocks];
        .util.table.dropAll[(
          `.engine.model.account.Account,
          `.engine.model.inventory.Inventory,
        )];
        .engine.testutils.SwitchSetupModels[p`setup];

        mck0: .qt.M[`.engine.model.account.Update;{[a;b;c]};c];
        mck1: .qt.M[`.engine.model.inventory.Update;{[a;b;c]};c];
        mck2: .qt.M[`.engine.logic.match.Match;{[a]};c];
        mck3: .qt.M[`.engine.E;{[x]};c];

        a:.model.Order . p`args;
        res:.engine.logic.order.New a;

        .qt.CheckMock[mck0;m[0];c];
        .qt.CheckMock[mck1;m[1];c];
        .qt.CheckMock[mck2;m[2];c];
        .qt.CheckMock[mck3;m[3];c];
        .qt.RestoreMocks[];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    ( // TODO sell side check
        ("Place new buy post only limit order at best price, no previous depth or agent orders should update depth";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;`inverse;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt`avgPrice`rpnl;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10;100 100;0 0))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
            ));
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty`time;enlist(0;0;enlist(0 1);1;1;1000;1;1b;1;z));
            (); // res 
            (
                (1b;1;
                e2 `aId`time`bal`rt`ft`avail!
                (`.engine.model.account.Account!0;z;0;`.engine.model.risktier.Risktier!0;`.engine.model.feetier.Feetier!0;0);
                ()); // Update Account
                (1b;1;e2 `aId`side`time`amt`avgPrice`upnl`rpnl`ordLoss`ordVal`ordQty!(`.engine.model.account.Account!0;1;z;10;100;0;0;0;0;0);());
                (1b;1;();()); 
                (1b;2;(
                .event.Inventory[`aId`side`time`amt`avgPrice`upnl`rpnl`ordLoss`ordVal`ordQty!(`.engine.model.account.Account!0;1;z;10;100;0;0;0;0;0)];
                .event.Account[`aId`time`bal`avail!(`.engine.model.account.Account!0;z;0;0)]
                );()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Place new buy post only limit order, previous depth, no agent orders should update depth";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;`inverse;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt`avgPrice`rpnl;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10;100 100;0 0))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
            ));
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty`time;flip(0 0;0 0;((0 1);(0 -1));1 -1;1 1;1000 1000;1 1;11b;1 1;2#z));
            (); // res 
            (
                (1b;1;e2 flip `aId`time`bal`rt`ft`avail!(`.engine.model.account.Account!(0 0);
                         2#z;2#0;2#`.engine.model.risktier.Risktier!0;2#`.engine.model.feetier.Feetier!0;0 0);()); // Update Account
                (1b;1;e2 flip `aId`side`time`amt`avgPrice`upnl`rpnl`ordLoss`ordVal`ordQty!(`.engine.model.account.Account!(0 0);1 -1;2#z;10 10;100 100;0 0;0 0;0 0;0 0;0 0);());
                (1b;1;();()); // Match 
                (1b;2;(
                enlist .event.Inventory[`aId`side`time`amt`avgPrice`upnl`rpnl`ordLoss`ordVal`ordQty!(`.engine.model.account.Account!0 0;1 -1;2#z;2#10;2#100;2#0;2#0;2#0;2#0;2#0)];
                enlist .event.Account[`aId`time`bal`avail!(`.engine.model.account.Account!0 0;2#z;2#0;2#0)]
                );()) // Emit
            ); // mocks 
            () // err 
        ))
    );
    ({};{};{};{});
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];

// TODO test filled amt
// TODO check mock invocations
// TODO test change in display qty, side, price, execInst
// TODO test with clOrdId
/ .qt.SkpBesTest[32];
.qt.Unit[
    ".engine.logic.order.Amend";
    {[c]
        p:c[`params];
        m:p[`mocks];
        .util.table.dropAll[(
          `.engine.model.account.Account,
          `.engine.model.inventory.Inventory,
        )];
        .engine.testutils.SwitchSetupModels[p`setup];

        mck0: .qt.M[`.engine.model.account.Update;{[a;b;c]};c];
        mck1: .qt.M[`.engine.model.inventory.Update;{[a;b;c]};c];
        mck2: .qt.M[`.engine.logic.match.Match;{[a]};c];
        mck3: .qt.M[`.engine.E;{[x]};c];

        a:.model.Order . p`args;
        res:.engine.logic.order.Amend a;

        .qt.CheckMock[mck0;m[0];c];
        .qt.CheckMock[mck1;m[1];c];
        .qt.CheckMock[mck2;m[2];c];
        .qt.CheckMock[mck3;m[3];c];
        .qt.RestoreMocks[];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        // Decreasing in size stays at same price
        ("Place new buy post only limit order at best price, no previous depth or agent orders should update depth";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;`inverse;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`order;(`oId`aId`iId`ivId`side`oqty`price`reduce`dqty;enlist(0;0;0;(0 1);1;1;1000;1b;1)));
                (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
            ));
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty;enlist(0;0;(0 1);1;1;1000;1;1b;1));
            (); // res 
            (
                (1b;1;();()); // Update Account
                (1b;1;();()); // Inventory 
                (1b;1;();()); // Match 
                (1b;2;();()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Place new buy post only limit order, previous depth, no agent orders should update depth";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;`inverse;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`order;(`oId`aId`iId`ivId`side`oqty`price`reduce`dqty;enlist(0;0;0;(0 1);1;1;1000;1b;1)));
                (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
            ));
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty;enlist(0;0;(0 1);1;1;1000;1;1b;1));
            (); // res 
            (
                (1b;1;();()); // Update Account
                (1b;1;();()); // Inventory 
                (1b;1;();()); // Match 
                (1b;2;();()) // Emit
            ); // mocks 
            () // err 
        ))
    );
    ({};{};{};{});
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];


/ .qt.SkpBesTest[33];
.qt.Unit[
    ".engine.logic.order.Cancel";
    {[c]
        p:c[`params];
        m:p[`mocks];
        .util.table.dropAll[(
          `.engine.model.account.Account,
          `.engine.model.inventory.Inventory,
        )];
        .engine.testutils.SwitchSetupModels[p`setup];

        mck0: .qt.M[`.engine.model.account.Update;{[a;b;c]};c];
        mck1: .qt.M[`.engine.model.inventory.Update;{[a;b;c]};c];
        mck2: .qt.M[`.engine.model.order.Delete;{[a]};c];
        mck3: .qt.M[`.engine.E;{[x]};c];

        a:.model.Order . p`args;
        res:.engine.logic.order.Cancel a;

        .qt.CheckMock[mck0;m[0];c];
        .qt.CheckMock[mck1;m[1];c];
        .qt.CheckMock[mck2;m[2];c];
        .qt.CheckMock[mck3;m[3];c];
        .qt.RestoreMocks[];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        // Decreasing in size stays at same price
        ("Place new buy post only limit order at best price, no previous depth or agent orders should update depth";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;`inverse;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
            ));
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty;enlist(0;0;(0 1);1;1;1000;1;1b;1));
            (); // res 
            (
                (1b;1;();()); // Update Account
                (1b;1;();()); // Inventory 
                (1b;1;();()); // Match 
                (1b;2;();()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Place new buy post only limit order, previous depth, no agent orders should update depth";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;`inverse;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
            ));
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty;enlist(0;0;(0 1);1;1;1000;1;1b;1));
            (); // res 
            (
                (1b;1;();()); // Update Account
                (1b;1;();()); // Inventory 
                (1b;1;();()); // Match 
                (1b;2;();()) // Emit
            ); // mocks 
            () // err 
        ))
    );
    ({};{};{};{});
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];

/ .qt.SkpBesTest[34];
.qt.Unit[
    ".engine.logic.order.CancelAll";
    {[c]
        p:c[`params];
        m:p[`mocks];
        .util.table.dropAll[(
          `.engine.model.account.Account,
          `.engine.model.inventory.Inventory,
        )];
        .engine.testutils.SwitchSetupModels[p`setup];

        mck0: .qt.M[`.engine.model.account.Update;{[a;b;c]};c];
        mck1: .qt.M[`.engine.model.inventory.Update;{[a;b;c]};c];
        mck2: .qt.M[`.engine.model.order.Delete;{[a]};c];
        mck3: .qt.M[`.engine.E;{[x]};c];

        a:.model.Order . p`args;
        res:.engine.logic.order.CancelAll a;

        .qt.CheckMock[mck0;m[0];c];
        .qt.CheckMock[mck1;m[1];c];
        .qt.CheckMock[mck2;m[2];c];
        .qt.CheckMock[mck3;m[3];c];
        .qt.RestoreMocks[];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        // Decreasing in size stays at same price
        ("Place new buy post only limit order at best price, no previous depth or agent orders should update depth";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;`inverse;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
            ));
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty;enlist(0;0;(0 1);1;1;1000;1;1b;1));
            (); // res 
            (
                (1b;1;();()); // Update Account
                (1b;1;();()); // Inventory 
                (1b;1;();()); // Match 
                (1b;2;();()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Place new buy post only limit order, previous depth, no agent orders should update depth";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;`inverse;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
            ));
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty;enlist(0;0;(0 1);1;1;1000;1;1b;1));
            (); // res 
            (
                (1b;1;();()); // Update Account
                (1b;1;();()); // Inventory 
                (1b;1;();()); // Match 
                (1b;2;();()) // Emit
            ); // mocks 
            () // err 
        ))
    );
    ({};{};{};{});
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];










