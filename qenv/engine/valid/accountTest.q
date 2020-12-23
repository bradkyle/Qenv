
.engine.valid.account.test.Setup: ((!) . flip(
    (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;`inverse;1;1000;1))); 
    (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`ordVal`amt`totEnt`avgPrice`rpnl;flip(0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10;10 10;100 100;0 0))); 
    (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
    (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))); // Update Account
    (`account;(`aId`avail`bal`lng`srt`ft`rt;enlist(0;0;0;(0 1);(0 -1);0;0))) 
    ));
 

.qt.Unit[
    ".engine.valid.account.Withdraw";
    {[c]
        p:c[`params];
        m:p[`mocks];
        .util.table.dropAll[(
          `.engine.model.account.Account,
          `.engine.model.inventory.Inventory,
        )];
        .engine.testutils.SwitchSetupModels[p`setup];
        mck: .qt.M[`.engine.E;{[x]};c];

        a:.model.Order . p`args;
        res:.engine.valid.order.New[a];

        .qt.CheckMock[mck;m;c];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Withdraw no balance:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty`time;enlist(0;0;enlist(0 1);1;1;1000;1;1b;1;z));
            (0b);
            ((1b;3;();())); //(.event.Failure[`aId`time`froz`wit`bal`avail!(0;z;0;0;0;0)]);()) // Emit ); // mocks 
            () // err 
        ));
        ("Withdraw insufficient balance:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty`time;enlist(0;0;enlist(0 1);1;1;1000;1;1b;1;z));
            (0b);
            ((1b;3;();())); //(.event.Failure[`aId`time`froz`wit`bal`avail!(0;z;0;0;0;0)]);()) // Emit ); // mocks 
            () // err 
        ));
        ("Withdraw Account disabled:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty`time;enlist(0;0;enlist(0 1);1;1;1000;1;1b;1;z));
            (0b);
            ((1b;3;();())); //(.event.Failure[`aId`time`froz`wit`bal`avail!(0;z;0;0;0;0)]);()) // Emit ); // mocks 
            () // err 
        ));
        ("Withdraw Account locked:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty`time;enlist(0;0;enlist(0 1);1;1;1000;1;1b;1;z));
            (0b);
            ((1b;3;();())); //(.event.Failure[`aId`time`froz`wit`bal`avail!(0;z;0;0;0;0)]);()) // Emit ); // mocks 
            () // err 
        ));
        ("Withdraw Success: Update fee tier, risk tier, apply withdraw fee, avail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`ivId`side`oqty`price`dlt`reduce`dqty`time;enlist(0;0;enlist(0 1);1;1;1000;1;1b;1;z));
            (0b);
            ((1b;3;();())); //(.event.Failure[`aId`time`froz`wit`bal`avail!(0;z;0;0;0;0)]);()) // Emit ); // mocks 
            () // err 
        ))
    );
    ({};{};{};{});
    "Process a batch of signal events"];

.qt.Unit[
    ".engine.valid.account.Deposit";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.account.Get;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.account.Update;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b;c]};c];

				res:.engine.valid.account.Deposit[a];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Deposit Account disabled:should fail";(
            .engine.valid.account.test.Setup;
            .util.testutils.makeDeposit[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (enlist(1b;1;();.util.testutils.makeAccount[])); // mocks 
            () // err 
        ));
        ("Deposit Account locked:should fail";(
            .engine.valid.account.test.Setup;
            .util.testutils.makeDeposit[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (enlist(1b;1;();.util.testutils.makeAccount[])); // mocks 
            () // err 
        ));
        ("Deposit Success: Update fee tier, risk tier, avail";(
            .engine.valid.account.test.Setup;
            .util.testutils.makeDeposit[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (enlist(1b;1;();.util.testutils.makeAccount[])); // mocks 
            () // err 
        ))
    );
    ({};{};{};{});
    "Process a batch of signal events"];


.qt.Unit[
    ".engine.valid.account.Leverage";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.account.Get;{[a;b] a}[m[0][3]];c];

				res:.engine.valid.account.Leverage[a 0;a 1;a 2];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Leverage no balance:should fail";(
            .engine.valid.account.test.Setup;
            .util.testutils.makeLeverage[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (enlist(1b;1;();.util.testutils.makeAccount[])); // mocks 
            () // err 
        ));
        ("Leverage insufficient balance:should fail";(
            .engine.valid.account.test.Setup;
            .util.testutils.makeLeverage[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (enlist(1b;1;();.util.testutils.makeAccount[])); // mocks 
            () // err 
        ));
        ("Leverage Account disabled:should fail";(
            .engine.valid.account.test.Setup;
            .util.testutils.makeLeverage[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (enlist(1b;1;();.util.testutils.makeAccount[])); // mocks 
            () // err 
        ));
        ("Leverage Account locked:should fail";(
            .engine.valid.account.test.Setup;
            .util.testutils.makeLeverage[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (enlist(1b;1;();.util.testutils.makeAccount[])); // mocks 
            () // err 
        ));
        ("Leverage Success: Update fee tier, risk tier, apply withdraw fee, avail";(
            .engine.valid.account.test.Setup;
            .util.testutils.makeLeverage[`aId`iId`leverage;enlist(0;0;0)];
            (); // res 
            (enlist(1b;1;();.util.testutils.makeAccount[])); // mocks 
            () // err 
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];
 

