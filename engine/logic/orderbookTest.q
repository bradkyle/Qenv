
// TODO process depth updates without orders

// TODO check orders event by time
// TODO depth update does not match order update
// TODO depth update crosses
// TODO depth update does not conform to instrument lot size/tick size
// TODO orders not filled yet and cross event
// TODO agent offsets are zero and update is less than agent order size (single update)
// TODO depth update contains depth for which the next value is zero (removes level)
// TODO check that non congruent price/levels still process and produce correct events
// TODO test skips price level in update (temporal)
// TODO differing number of buys and sells etc.
// TODO profile and benchmark function?
// TODO last event update with no agent crosses?
// TODO test differing accounts, orderId with zeros, accountIds with zeros etc.
// TODO orders drift outside of updates
// TODO differing level order counts
// TODO check events created correctly.
// TODO max num levels

// TODO process depth // process trade Integration check
// TODO hidden/iceberg orders orders 
// TODO replicate cases without hidden orders!
// TODO longer update streams

// TODO account for one record
/ ordCols:{$[
/     count[x]=9;`orderId`instrument`account`side`otype`offset`leaves`price`time;
/     count[x]=10;`orderId`instrument`account`side`otype`offset`leaves`displayqty`price`time;
/     ()]};

/ bookCols:`side`price`qty`hqty`iqty`vqty;
/ nxt:$[
/     count[p[2]]=4;`side`price`nqty`time!p[2];
/     count[p[2]]=5;`side`price`nqty`nhqty`time!p[2];
/     'INVALID_NXT];

/ :`cDepth`cOrd`nxt`mocks!(
/     p[0];
/     .util.testutils.makeOrders[ordCols[p[1]];flip p[1]];
/     nxt;
/     (3_5#p));

.qt.Unit[
    ".engine.logic.orderbook.Level";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        / mck1: .qt.M[`.engine.model.inventory.GetInventory;{[a;b] a}[m[6][3]];c];

        res:.engine.logic.orderbook.Level[a 0;a 1];

        / .qt.CheckMock[mck1;m[1];c];
    };
    {`args`eRes`mocks`err!x};
    (
        ("Update increases qty at level, no orders present, no hqty or iqty";(
            ();();();()
        ));
        ("Update decreases qty at level, no orders present, no hqty or iqty";(
            ();();();()
        ));
        ("Update increases qty at level, no orders present, hqty no iqty";(
            ();();();()
        ));
        ("Update decreases qty at level, no orders present, hqty no iqty";(
            ();();();()
        ));
        ("Update increases qty at level, orders present, no hqty or iqty";(
            ();();();()
        ));
        ("Update decreases qty at level, orders present, no hqty or iqty";(
            ();();();()
        ));
        ("Update increases qty at level, orders present, hqty no iqty";(
            ();();();()
        ));
        ("Update decreases qty at level, orders present, hqty no iqty";(
            ();();();()
        ));
        ("Update increases qty at level, orders present, hqty and iqty";(
            ();();();()
        ));
        ("Update decreases qty at level, orders present, hqty and iqty";(
            ();();();()
        ));
        ("New side level, no orders present, no hqty or iqty";(
            ();();();()
        ));
        ("New side level, update crosses spread orders present hqty no iqty";(
            ();();();()
        ));
        ("New side level, update crosses spread orders present hqty and iqty";(
            ();();();()
        ));
        ("New side level, update crosses spread orders present";(
            ();();();()
        ));
        ("New side level, hqty present";(
            ();();();()
        ))
    );
    ({};{};{};{});
    ("Given a depth update which consists of a table of time,side,price",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders where necessary")];
