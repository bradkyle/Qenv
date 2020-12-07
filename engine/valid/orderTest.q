
.qt.Unit[
    ".engine.logic.order.NewOrder";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.inventory.Get;{[a;b] a}[m[0][3]];c];

        res:.engine.logic.order.NewOrder[a 0;a 1;a 2];

        .qt.CheckMock[mck0;m[7];c];
        .qt.RestoreMocks[];

    };
    {[p] :`args`eRes`mocks`err!p};
    ( // TODO sell side check
        ("Place new buy post only limit order at best price, no previous depth or agent orders should update depth";(
            .util.testutils.makeOrder[`oqty`price`dlt`reduce`dqty;enlist(1;1000;1;1b;1)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;.util.testutils.makeAccount[`aId`bal`avail`ft`rt;enlist(0;2000;1000;1;1)];()); // Update Account
                (1b;1;.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(3;1000;0;0;0;0;0)];()); // Inventory 
                (1b;1;.util.testutils.makeOrder[`oqty`price`dlt`reduce`dqty;enlist(1;1000;1;1b;1)];()); // CreateOrder 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
            ); // mocks 
            () // err 
        ));
        ("Place new buy post only limit order, previous depth, no agent orders should update depth";(
            .util.testutils.makeOrder[`oqty`price`dlt`reduce`dqty;enlist(1;1000;1;1b;1)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(2;0;0;0;0;0;0)]); // GetInventory
                (1b;1;.util.testutils.makeAccount[`aId`bal`avail`ft`rt;enlist(0;2000;1000;1;1)];()); // Update Account
                (1b;1;.util.testutils.makeInventory[`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice;enlist(3;1000;0;0;0;0;0)];()); // Inventory 
                (1b;1;.util.testutils.makeOrder[`oqty`price`dlt`reduce`dqty;enlist(1;1000;1;1b;1)];()); // CreateOrder 
                (1b;3;.util.testutils.makeEvent[];()) // Emit
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
    ".engine.logic.order.AmendOrder";
    {[c]

    };
    {[p] :`args`eRes`mocks`err!p};
    (
        // Decreasing in size stays at same price
        ("Amend limit order (first in queue), smaller than previous, should update offsets, depth etc.";(
								(19);();();()
        )); 
        ("Amend limit order (second in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
        )); 
        ("Amend limit order (last in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
        ));
    );
    ({};{};{};{});
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];


.qt.Unit[
    ".engine.logic.order.CancelOrder";
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
    ".engine.logic.order.CancelAllOrders";
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









