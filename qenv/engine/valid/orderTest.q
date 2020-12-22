
.qt.Unit[
    ".engine.valid.order.NewOrder";
    {[c]
        p:c[`params];
        m:p[`mocks];
        .util.table.dropAll[(
          `.engine.model.account.Account,
          `.engine.model.inventory.Inventory,
        )];
        .engine.testutils.SwitchSetupModels[p`setup];

        res:.engine.valid.order.NewOrder[a];


    };
    {[p] :`setup`args`eRes`mocks`err!p};
    ( // TODO sell side check
        ("Place new buy post only limit order at best price, no previous depth or agent orders should update depth";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1))); 
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
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1))); 
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt`avgPrice`rpnl;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10;100 100;0 0))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
                (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
            ));
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty`time;flip(0 0;0 0;((0 1);(0 -1));1 -1;1 1;1000 1000;1 1;11b;1 1;2#z));
            (); // res 
            (
                (1b;1;e2 flip `aId`time`bal`rt`ft`avail!(
                 `.engine.model.account.Account!(0 0);
                 2#z;2#0;2#`.engine.model.risktier.Risktier!0;2#`.engine.model.feetier.Feetier!0;0 0);()); // Update Account
                 (1b;1;e2 flip `aId`side`time`amt`avgPrice`upnl`rpnl`ordLoss`ordVal`ordQty!(`.engine.model.account.Account!(0 0);1 -1;2#z;10 10;0N 0N;0 0;0 0;0 0;0 0;0 0);());
                (1b;1;();()); // Match 
                (1b;2;(
                .event.Inventory[`aId`side`time`amt`avgPrice`upnl`rpnl`ordLoss`ordVal`ordQty!(`.engine.model.account.Account!0 0;1 -1;2#z;2#10;2#100;2#0;2#0;2#0;2#0;2#0)];
                .event.Account[`aId`time`bal`avail!(`.engine.model.account.Account!0 0;2#z;2#0;2#0)]
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
.qt.Unit[
    ".engine.valid.order.AmendOrder";
    {[c]

    };
    {[p] :`args`eRes`mocks`err!p};
    (
        // Decreasing in size stays at same price
        ("Amend limit order (first in queue), smaller than previous, should update offsets, depth etc.";(
                ();();();()
        )); 
        ("Amend limit order (second in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
        )); 
        ("Amend limit order (last in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
        ))
    );
    ({};{};{};{});
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];


.qt.Unit[
    ".engine.valid.order.CancelOrder";
    {[c]

    };
    {[p] :`args`eRes`mocks`err!p};
    (
        // Decreasing in size stays at same price
        ("Amend limit order (first in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
				)); 
        ("Amend limit order (first in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
				)) 
    );
    ({};{};{};{});
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];


.qt.Unit[
    ".engine.valid.order.CancelAllOrders";
    {[c]

    };
    {[p] :`args`eRes`mocks`err!p};
    (
        // Decreasing in size stays at same price
        ("Amend limit order (first in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
				)); 
        ("Amend limit order (first in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
				)) 
    );
    ({};{};{};{});
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];









