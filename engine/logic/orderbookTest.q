

.qt.Unit[
    ".engine.logic.orderbook.Levels";
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

