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
.qt.Unit[
    ".engine.logic.orderbook.Level";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        .util.table.dropAll[(
          `.engine.model.account.Account,
          `.engine.model.inventory.Inventory,
          `.engine.model.risktier.RiskTier,
          `.engine.model.feetier.Feetier
        )];
        .engine.testutils.SwitchSetupModels[p`setup];

        mck0: .qt.OM[`.engine.model.orderbook.Update;c];
        mck1: .qt.OM[`.engine.model.order.Update;c];
        mck2: .qt.OM[`.engine.E;c];

        a:.model.Level . p`args;
        res:.engine.logic.orderbook.Level[a];

        .qt.CheckMock[mck0;m[0];c];
        .qt.CheckMock[mck1;m[1];c];
        .qt.CheckMock[mck2;m[2];c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        enlist("No change occurs and thus no update is triggered";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;`inverse;1;1000;1))); 
                (`account;(`aId`avail`bal`lng`srt`ft`rt`wit`time`froz;enlist(0;0;0;(0 1);(0 -1);0;0;0;z;0))); 
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`amt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;10 10))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`orderbook;(`price`side`qty`hqty`iqty`vqty`time;enlist(1000;1;100;100;0;0;z)));
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))) // Update Account
            ));
            (`iId`price`side`qty`hqty`iqty`vqty`time;enlist(0;1000;1;100;100;0;0;z));
            (); // res 
            (
                (1b;1;();());
                (1b;1;();());
                (1b;1;();());
                (1b;1;();());
                (1b;1;();())
            ); // mscks 
            () // err 
        ))
    );
    ({};{};{};{});
    ("Given a depth update which consists of a table of time,side,price",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders where necessary")];











