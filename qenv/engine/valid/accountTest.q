
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

        a:.model.Deposit . p`args;
        res:.engine.valid.account.Deposit[a];

        .qt.CheckMock[mck;m;c];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Withdraw no balance:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`dep`time;enlist(0;0;10;z));
            (); // res 
            ((1b;3;();())); 
            () // err 
        ));
        ("Withdraw insufficient balance:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`wit`time;enlist(0;0;10;z));
            (); // res 
            ((1b;3;();())); 
            () // err 
        ));
        ("Withdraw Account disabled:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`wit`time;enlist(0;0;10;z));
            (); // res 
            ((1b;3;();())); 
            () // err 
        ));
        ("Withdraw Account locked:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`wit`time;enlist(0;0;10;z));
            (); // res 
            ((1b;3;();())); 
            () // err 
        ));
        ("Withdraw Success: Update fee tier, risk tier, apply withdraw fee, avail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`wit`time;enlist(0;0;10;z));
            (); // res 
            ((1b;3;();())); 
            () // err 
        ))
    );
    ({};{};{};{});
    "Process a batch of signal events"];

.qt.Unit[
    ".engine.valid.account.Deposit";
    {[c]
        p:c[`params];
        m:p[`mocks];
        .util.table.dropAll[(
          `.engine.model.account.Account,
          `.engine.model.inventory.Inventory,
        )];
        .engine.testutils.SwitchSetupModels[p`setup];
        mck: .qt.M[`.engine.E;{[x]};c];

        a:.model.Deposit . p`args;
        res:.engine.valid.account.Deposit[a];

        .qt.CheckMock[mck;m;c];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Deposit Account disabled:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`dep`time;enlist(0;0;10;z));
            (); // res 
            ((1b;3;();())); 
            () // err 
        ));
        ("Deposit Account locked:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`dep`time;enlist(0;0;10;z));
            (); // res 
            ((1b;3;();())); 
            () // err 
        ));
        ("Deposit Success: Update fee tier, risk tier, avail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`dep`time;enlist(0;0;10;z));
            (); // res 
            ((1b;3;();())); 
            () // err 
        ))
    );
    ({};{};{};{});
    "Process a batch of signal events"];


.qt.Unit[
    ".engine.valid.account.Leverage";
    {[c]
        p:c[`params];
        m:p[`mocks];
        .util.table.dropAll[(
          `.engine.model.account.Account,
          `.engine.model.inventory.Inventory,
        )];
        .engine.testutils.SwitchSetupModels[p`setup];
        mck: .qt.M[`.engine.E;{[x]};c];

        a:.model.Leverage . p`args;
        res:.engine.valid.account.Deposit[a];

        .qt.CheckMock[mck;m;c];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Leverage no balance:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`lev`time;enlist(0;0;10;z));
            (); // res 
            ((1b;3;();())); 
            () // err 
        ));
        ("Leverage insufficient balance:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`lev`time;enlist(0;0;10;z));
            (); // res 
            ((1b;3;();())); 
            () // err 
        ));
        ("Leverage Account disabled:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`lev`time;enlist(0;0;10;z));
            (); // res 
            ((1b;3;();())); 
            () // err 
        ));
        ("Leverage Account locked:should fail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`lev`time;enlist(0;0;10;z));
            (); // res 
            ((1b;3;();())); 
            () // err 
        ));
        ("Leverage Success: Update fee tier, risk tier, apply withdraw fee, avail";(
            .engine.valid.account.test.Setup;
            (`aId`iId`lev`time;enlist(0;0;10;z));
            (); // res 
            ((1b;3;();())); 
            () // err 
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];
 

