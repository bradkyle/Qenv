ocols:`oId`side`acc`price`lprice`sprice`trig`tif`okind`oskind`reduce`state`oqty`dqty`lqty`offset`einst;
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

/ .qt.SkpBesTest[35];
                (1b;1;();.util.testutils.makeInventory[]); // GetInventory
                (1b;1;.util.testutils.makeAccount[];()); // Update Account
                (1b;1;.util.testutils.makeInventory[];()); // Update Inventory 
                (1b;2;();.util.testutils.makeEvent[]); // Emit
                (1b;1;();.util.testutils.makeRisktier[]); // GetRiskTier
                (1b;1;();.util.testutils.makeFeetier[]) // GetFeeTier
.qt.Unit[
    ".engine.logic.orderbook.Level";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.orderbook.Get;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.order.Get;{[a;b] a}[m[1][3]];c];
        mck3: .qt.M[`.engine.Emit;{[a;b;c]};c];
        mck4: .qt.M[`.engine.model.order.Update;{[a;b]};c];
        mck5: .qt.M[`.engine.model.orderbook.Update;{[a;b]};c];

        res:.engine.logic.orderbook.Level[a];

        .qt.CheckMock[mck3;m[2];c];
        .qt.CheckMock[mck4;m[3];c];
        .qt.CheckMock[mck5;m[4];c];
    };
    {`args`eRes`mocks`err!x};
    (
        enlist("No change occurs and thus no update is triggered";(
        .util.testutils.makeLevel[`price`side`qty`hqty`iqty`vqty;enlist(1000;1;100;100;0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeLevel[]);
                (1b;1;();.util.testutils.makeOrder[]);
                (0b;0;.util.testutils.makeEvent[];()); // Emit
                (0b;0;.util.testutils.makeOrder[];()); // UpdateOrder
                (0b;0;.util.testutils.makeLevel[];()) // UpdateLevel
            ); // mscks 
            () // err 
        ))
    );
    ({};{};{};{});
    ("Given a depth update which consists of a table of time,side,price",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders where necessary")];











