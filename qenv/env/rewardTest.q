



test:.qt.Unit[
    ".adapter.createOrderAtLevel";
    {[c]
        p:c[`params];

        .state.DefaultInstrumentId:p[`eDI];
        .qt.M[`.state.getPriceAtLevel;p[`MgetPriceAtLevel];c];
        .qt.M[`.state.genNextClOrdId;p[`MgenNextClOrdId];c];
        
        a:p[`args];
        res:.adapter.createOrderAtLevel[a[0];a[1];a[2];a[3]];

        .qt.A[res;~;p[`eRes];"result";c];

    };
    {[p]:`args`MgetPriceAtLevel`MgenNextClOrdId`eDI`eRes!(p[0];p[1];p[2];p[3];p[4])};
    (
        ("Given correct params should return correct";(
            (1;`SELL;100;1;0b;z);
            {[l;s] :100};
            {0};
            0;0));
        ("Given correct params should return correct";(
            (1;`SELL;100;1;0b;z);
            {[l;s] :100};
            {0};
            0;0))
    );
    .qt.sBlk;
    "Creates the event to place a new order at a given level in the orderbook"];