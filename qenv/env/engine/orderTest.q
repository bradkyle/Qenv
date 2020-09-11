\l order.q
\l ../util
\l ../../quantest/
\cd ../env/engine

l: `long$
z:.z.z;
sc:{x+(`second$y)};
sn:{x-(`second$y)};
sz:sc[z];
snz:sn[z];
dts:{(`date$x)+(`second$x)};
dtz:{dts[sc[x;y]]}[z]
doz:`date$z;
dozc:{x+y}[doz];

.qt.Unit[
    ".order.ProcessDepth";
    {[c]
        p:c[`params];

        .order.ProcessDepth[p[`event]];

    };
    {[p] 

    };
    (
        ("simple update no agent orders or previous depth one side";(
            (); // Current Depth
            (); // Current Orders
            ((10#-1);1000+til 10;10#1000;10#z); // Depth Update
            ([price:(1000+til 10)] side:(10#-1);qty:(10#1000);vqty:(10#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both (crossing)";(
            (); // Current Depth
            (); // Current Orders
            ((10#`SELL);1000+til 10;10#1000;10#z); // Depth Update
            ([price:(1000+til 10)] side:(10#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:(10#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both; Multi temporal";(
            (); // Current Depth
            (); // Current Orders
            ((10#`SELL);(raze flip 2 5#(1000+til 5));10#1000 100;(10#z,(z+`second$5))); // Depth Update
            ([price:(1000+til 5)] side:(5#`.order.ORDERSIDE$`SELL);qty:(5#100);vqty:(5#100)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("all OrderBook levels should be removed where the remaining qty<=0 and no agent orders exist";(
            ((10#`SELL);(raze flip 2 5#(1000+til 5));10#100;(10#z,(z+`second$5))); // Current Depth
            (); // Current Orders
            ((10#`SELL);(raze flip 2 5#(1000+til 5));((2#0),(8#100));(10#z,(z+`second$5))); // Depth Update
            ([price:(1001+til 4)] side:(4#`.order.ORDERSIDE$`SELL);qty:(4#100);vqty:(4#100)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("1 buy order at best level, previous depth greater than updates";(
            ((10#`SELL);(raze flip 2 5#(1000+til 5));10#1100;(10#z,(z+`second$5))); // Current Depth
            (til[2];2#1;2#1;2#`SELL;2#`LIMIT;100 400;2#100;2#1000;2#z); // Current Orders
            ((10#`SELL);(raze flip 2 5#(1000+til 5));10#1000;(10#z,(z+`second$5))); // Depth Update
            ([price:((1000+til 5))] side:(5#`.order.ORDERSIDE$`SELL);qty:(5#1000);vqty:(1200,4#1000)); // Expected Depth
            (til[2];2#1;2#1;2#`SELL;2#`LIMIT;88 377;2#100;2#1000;2#z); // Expected Orders
            () // Expected Events
        ));
        ("1 buy order at best level, previous depth greater than differing updates";(
            ((10#`SELL);(raze flip 2 5#(1000+til 5));10#1100;(10#z,(z+`second$5))); // Current Depth
            (til[2];2#1;2#1;2#`SELL;2#`LIMIT;100 400;2#100;2#1000;2#z); // Current Orders
            ((10#`SELL);(raze flip 2 5#(1000+til 5));(10#1050 1000);(10#z,(z+`second$5))); // Depth Update
            ([price:((1000+til 5))] side:(5#`.order.ORDERSIDE$`SELL);qty:(5#1000);vqty:(1200,4#1000)); // Expected Depth
            (til[2];2#1;2#1;2#`SELL;2#`LIMIT;88 377;2#100;2#1000;2#z); // Expected Orders
            () // Expected Events
        ));
        ("1 buy order at best level, previous depth greater than differing updates (3 updates) 2 dec 1 inc";(
            ((10#`SELL);(raze flip 2 5#(1000+til 5));10#1100;(10#z,(z+`second$5))); // Current Depth
            (til[2];2#1;2#1;2#`SELL;2#`LIMIT;100 400;2#100;2#1000;2#z); // Current Orders
            ((9#`SELL);(raze flip 3#{(1000+x;1000+x;1000+x)}til 3);(9#1050 1000 1100);(9#z,(z+`second$5))); // Depth Update
            ([price:((1000+til 5))] side:(5#`.order.ORDERSIDE$`SELL);qty:(5#1100);vqty:(1300,4#1100)); // Expected Depth
            (til[2];2#1;2#1;2#`SELL;2#`LIMIT;88 377;2#100;2#1000;2#z); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
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


.qt.RunTests[];