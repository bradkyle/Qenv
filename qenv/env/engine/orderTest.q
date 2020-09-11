


.qt.Unit[
    ".order.ProcessDepth";
    {[c]
        p:c[`params];

        .order.ProcessDepth[p[`event]];

    };
    {[p] };
    (
        ("simple update no agent orders or previous depth one side";(
            (); // Current Depth
            (); // Current Orders
            ((10#`SELL);1000+til 10;10#1000;10#z); // Depth Update
            ([price:(1000+til 10)] side:(10#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:(10#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#`SELL),(10#`BUY));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:(`.order.ORDERSIDE$((10#`SELL),(10#`BUY)));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ))
    );
    .util.testutils.defaultHooks;
    "Given a depth update which consists of a table of time,side,price",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders where necessary"];
 
.qt.Unit[
    ".order.ProcessTrade";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };
    ();
    ();
    .util.testutils.defaultHooks;
    "Process trades from the historical data or agent orders",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders and call Add Events/Fills etc. where necessary"];


test:.qt.Unit[
    ".order.NewOrder";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };
    ();
    ();
    .util.testutils.defaultHooks;
    "Global function for processing new orders"];


test:.qt.Unit[
    ".order.AmendOrder";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };
    ();
    ();
    .util.testutils.defaultHooks;
    "Global function for amending orders"];


test:.qt.Unit[
    ".order.CancelOrder";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };
    ();
    ();
    .util.testutils.defaultHooks;
    "Global function for cancelling orders"];


test:.qt.Unit[
    ".order.ExecStop";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };
    ();
    ();
    .util.testutils.defaultHooks;
    "Global function for triggering stop orders"];


test:.qt.Unit[
    ".order.CheckStopOrders";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };
    ();
    ();
    .util.testutils.defaultHooks;
    "Global function for checking stop orders"];