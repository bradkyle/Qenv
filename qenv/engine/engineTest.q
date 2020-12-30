        

.qt.Unit[
    ".engine.GetIngressEvents";
    {[c]
        p:c[`params];
        .engine.ingress.Events,:p`setup;

        res:.engine.GetIngressEvents . p[`args];
        .qt.A[res;~;p[`eRes];"res";c];

        .util.table.dropAll[(
            `.engine.ingress.Events,
        )];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Get ingress events no events present";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (z;5;500);
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Get ingress events events present none fit selection";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (z;5;500);
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Get ingress events events present all fit selection";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (z;5;500);
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Get ingress events 50/50 fit selection";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (z;5;500);
            (); // res 
            (); // mocks
            () // err 
        ))
    );
    ({};{};{};{});
    "Path finder action set (made for binance exchange)"];

.qt.Unit[
    ".engine.GetEgressEvents";
    {[c]
        p:c[`params];
        .engine.egress.Events,:p`setup;

        res:.engine.GetEgressEvents . p[`args];
        .qt.A[res;~;p[`eRes];"res";c];

        .util.table.dropAll[(
            `.engine.egress.Events,
        )];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Get egress events no events present";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (z;5;500);
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Get egress events events present none fit selection";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (z;5;500);
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Get egress events events present all fit selection";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (z;5;500);
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Get egress events 50/50 fit selection";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (z;5;500);
            (); // res 
            (); // mocks
            () // err 
        ))
    );
    ({};{};{};{});
    "Path finder action set (made for binance exchange)"];

.qt.Unit[
    ".engine.E";
    {[c]
        p:c[`params];

        res:.engine.E . p[`args];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("One event is emitted";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("2 events are emitted";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("no events are passed to emit functions";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ))
    );
    ({};{};{};{});
    "Path finder action set (made for binance exchange)"];

.engine.test.Purge.Setup:((!) . flip(
    (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;`inverse;1;1000;1))); 
    (`account;(`aId`avail`bal`lng`srt`ft`rt`wit`time`froz;enlist(0;0;0;(0 1);(0 -1);0;0;0;z;0))); 
    (`inventory;(`aId`iId`side`mm`upnl`rpnl`ordQty`ordLoss`amt;flip(0 0;0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10))); 
    (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
    (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))) // Update Account
    ));

.qt.Unit[
    ".engine.Purge";
    {[c]
        p:c[`params];

        res:.engine.Purge . p[`args];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("No events are purged";(
            .engine.test.Purge.Setup; // Setup
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("50/50 events purged to not purged ratio";(
            .engine.test.Purge.Setup; // Setup
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("All events are purged";(
            .engine.test.Purge.Setup; // Setup
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("No events are passed to Purge fnction";(
            .engine.test.Purge.Setup; // Setup
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ))
    );
    ({};{};{};{});
    "Path finder action set (made for binance exchange)"];

.engine.test.process.Setup:((!) . flip(
    (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;`inverse;1;1000;1))); 
    (`account;(`aId`avail`bal`lng`srt`ft`rt`wit`time`froz;enlist(0;0;0;(0 1);(0 -1);0;0;0;z;0))); 
    (`inventory;(`aId`iId`side`mm`upnl`rpnl`ordQty`ordLoss`amt;flip(0 0;0 0;-1 1;0 0;0 0;0 0;0 0;0 0;10 10))); 
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
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process depth event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process funding event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist `funding;datum:enlist enlist[`fundingrate]!enlist(0.001)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process mark event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist `mark;datum:enlist enlist[`mkprice]!enlist(1000)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process settlement event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist `settlement;datum:enlist enlist[`lastsettled]!enlist(z)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process pricerange event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist`pricerange;datum:enlist `highest`lowest!(1000;1000)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process withdraw event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist`withdraw;datum:enlist enlist[`wit]!enlist[1];aId:enlist(0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process deposit event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist`deposit;datum:enlist enlist[`dep]!enlist[1];aId:enlist(0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process leverage event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist`leverage;datum:enlist enlist[`leverage]!enlist[1];aId:enlist(0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process neworder event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist`neworder;datum:enlist `price`okind`side`oqty`dqty!(1000;1;1;100;100);aId:enlist(0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process amendorder event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist`amendorder;datum:enlist `price`okind`side`oqty`dqty!(1000;1;1;100;100);aId:enlist(0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process cancelorder event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist`cancelorder;datum:enlist `price`okind`side`oqty`dqty!(1000;1;1;100;100);aId:enlist(0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("Process cancelall event";(
            .engine.test.process.Setup; // Setup
            ([]time:enlist z;kind:enlist`cancelall;datum:enlist enlist[`command]!enlist[1];aId:enlist(0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ))
    );
    ({};{};{};{});
    "Path finder action set (made for binance exchange)"];

.qt.Unit[
    ".engine.Advance";
    {[c]
        p:c[`params];
        .engine.watermark:.z.z - `second$5;

        .engine.ingress.Events,:p`setup;

        res:.engine.Advance . p[`args];
        .qt.A[res;~;p[`eRes];"res";c];

        .util.table.dropAll[(
            `.engine.ingress.Events
        )];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            ([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0)); // Events
            (); // res 
            (); // mocks
            () // err 
        ))
    );
    ({};{};{};{});
    "Path finder action set (made for binance exchange)"];

.qt.Unit[
    ".engine.Reset";
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

        res: .engine.Reset . p[`args];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (); // Setup
            (til 3;([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0))); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (); // Setup
            (til 3;([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0))); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (); // Setup
            (til 3;([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0))); // Events
            (); // res 
            (); // mocks
            () // err 
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (); // Setup
            (til 3;([]time:enlist z;kind:enlist `trade;datum:enlist `side`price`size!(0;1;0))); // Events
            (); // res 
            (); // mocks
            () // err 
        ))
    );
    ({};{};{};{});
    "Path finder action set (made for binance exchange)"];

