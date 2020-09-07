


test:.qt.Unit[
    ".order.ProcessDepth";
    {[c]
        p:c[`params];

        .order.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Given a depth update which consists of a table of time,side,price",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders where necessary"];



test:.qt.Unit[
    ".order.ProcessTrade";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Process trades from the historical data or agent orders",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders and call Add Events/Fills etc. where necessary"];


test:.qt.Unit[
    ".order.NewOrder";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".order.AmendOrder";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for amending orders"];


test:.qt.Unit[
    ".order.CancelOrder";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for cancelling orders"];


test:.qt.Unit[
    ".order.ExecStop";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for triggering stop orders"];


test:.qt.Unit[
    ".order.CheckStopOrders";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for checking stop orders"];