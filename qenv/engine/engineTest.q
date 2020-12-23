

.qt.Unit[
    ".engine.GetIngressEvents";
    {[c]
        p:c[`params];

        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes`mocks!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ))
    );
    "Path finder action set (made for binance exchange)"];

.qt.Unit[
    ".engine.GetEgressEvents";
    {[c]
        p:c[`params];

        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes`mocks!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ))
    );
    "Path finder action set (made for binance exchange)"];

.engine.test.process.Setup:((!) . flip(
    (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1))); 
    (`account;(`aId`avail`bal`lng`srt`ft`rt`wit`time`froz;enlist(0;0;0;(0 1);(0 -1);0;0;0;z;0))); 
    (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`amt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;10 10))); 
    (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
    (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))) // Update Account
));

.qt.Unit[
    ".engine.process";
    {[c]
        p:c[`params];
        .engine.watermark:0n;

        .util.table.dropAll[(
          `.engine.model.account.Account,
          `.engine.model.inventory.Inventory,
          `.engine.model.risktier.RiskTier,
          `.engine.model.feetier.Feetier
        )];
        .engine.testutils.SwitchSetupModels[p`setup];

        res:.engine.process[p`args];
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Process trade event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist`trade;datum:enlist(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process trade events";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist`trade;datum:enlist(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process depth event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist`trade;datum:enlist(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process depth events";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist`trade;datum:enlist(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
    );
    ({};{};{};{});
    "Path finder action set (made for binance exchange)"];

.qt.Unit[
    ".engine.Advance";
    {[c]
        p:c[`params];

        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes`mocks!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ))
    );
    "Path finder action set (made for binance exchange)"];

.qt.Unit[
    ".engine.Reset";
    {[c]
        p:c[`params];

        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes`mocks!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ))
    );
    "Path finder action set (made for binance exchange)"];

