

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

.qt.Unit[
    ".engine.process";
    {[c]
        p:c[`params];

        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
        ("Process trade events";(
            ((!) . flip(
                (`instrument;(`iId`cntTyp`faceValue`mkprice`smul;enlist(0;0;1;1000;1))); 
                (`account;(`aId`avail`bal`lng`srt`ft`rt`wit`time`froz;enlist(0;0;0;(0 1);(0 -1);0;0;0;z;0))); 
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`amt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;10 10))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))) // Update Account
            ));
            (`aId`iId`wit`time;enlist(0;0;0;z));
            (); // res 
            (
                (1b;1;e2 `aId`time`froz`wit`bal`avail!(`.engine.model.account.Account!0;z;0;0;0;0);()); // Update Account
                (1b;2;(.event.Account[`aId`time`froz`wit`bal`avail!(0;z;0;0;0;0)];.event.Withdraw[`aId`iId`wit`time!(0;0;0;z)]);()) // Emit 
            ); // mocks 
            () // err 
        ))
        / ("Process depth events";(
        / ));
        / ("Process funding events";(
        / ));
        / ("Process mark events";(
        / ));
        / ("Process settlement events";(
        / ));
        / ("Process pricerange events";(
        / ));
        / ("Process withdraw events";(
        / ));
        / ("Process deposit events";(
        / ));
        / ("Process leverage events";(
        / ));
        / ("Process neworder events";(
        / ));
        / ("Process amendorder events";(
        / ));
        / ("Process cancelorder events";(
        / ));
        / ("Process cancelall events";(
        / ));
        / ("Process combined events";(
        / ))
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

