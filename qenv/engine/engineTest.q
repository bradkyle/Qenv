

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
    {[p] :`args`eRes`mocks!p};
    (
        ("Process trade events";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("Process depth events";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("Process funding events";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("Process mark events";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("Process settlement events";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("Process pricerange events";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("Process withdraw events";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("Process deposit events";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("Process leverage events";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("Process neworder events";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("Process amendorder events";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("Process cancelorder events";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("Process cancelall events";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("Process combined events";(
            (10;5;0.1;1);(1 1 1);()
        ))
    );
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

