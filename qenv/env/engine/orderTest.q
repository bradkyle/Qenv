\l ./contract/inverse/account.q 
\l ./contract/linear/account.q 
\l ./contract/quanto/account.q 
\l account.q
\l order.q

\d .order.test

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



// TODO check orders event by time
// TODO depth update does not match order update
// TODO depth update crosses
// TODO depth update does not conform to instrument lot size/tick size
// TODO orders not filled yet and cross event
// TODO agent offsets are zero and update is less than agent order size (single update)
// TODO depth update contains depth for which the next value is zero (removes level)
// TODO check that non congruent price/levels still process and produce correct events
// TODO test skips price level in update (temporal)
// TODO differing number of buys and sells etc.
// TODO profile and benchmark function?
// TODO last event update with no agent crosses?
// TODO test differing accounts, orderId with zeros, accountIds with zeros etc.
// TODO orders drift outside of updates
// TODO differing level order counts
// TODO check events created correctly.
// TODO max num levels

// TODO process depth // process trade Integration check
// TODO hidden/iceberg orders orders 

.qt.Unit[
    ".order.ProcessDepth";
    {[c]
        p:c[`params];

        .util.testutils.setupDepth[p`cDepth];
        .util.testutils.setupOrders[p`cOrd];

        .order.ProcessDepth[p[`event]];

        .util.testutils.checkDepth[p[`eDepth];c];
        .util.testutils.checkOrders[p[`eOrd];c];

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
            ((10#-1);1000+til 10;10#1000;10#z); // Depth Update
            ([price:(1000+til 10)] side:(10#-1);qty:(10#1000);vqty:(10#1000)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both; Multi temporal";(
            (); // Current Depth
            (); // Current Orders
            ((10#-1);(raze flip 2 5#(1000+til 5));10#1000 100;(10#z,(z+`second$5))); // Depth Update
            ([price:(1000+til 5)] side:(5#-1);qty:(5#100);vqty:(5#100)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("all OrderBook levels should be removed where the remaining qty<=0 and no agent orders exist";(
            ((10#-1);(raze flip 2 5#(1000+til 5));10#100;(10#z,(z+`second$5))); // Current Depth
            (); // Current Orders
            ((10#-1);(raze flip 2 5#(1000+til 5));((2#0),(8#100));(10#z,(z+`second$5))); // Depth Update
            ([price:(1001+til 4)] side:(4#-1);qty:(4#100);vqty:(4#100)); // Expected Depth
            (); // Expected Orders
            () // Expected Events
        ));
        ("1 buy order at best level, previous depth greater than updates";(
            ((10#-1);(raze flip 2 5#(1000+til 5));10#1100;(10#z,(z+`second$5))); // Current Depth
            (til[2];2#1;2#1;2#-1;2#1;100 400;2#100;2#1000;2#z); // Current Orders
            ((10#-1);(raze flip 2 5#(1000+til 5));10#1000;(10#z,(z+`second$5))); // Depth Update
            ([price:((1000+til 5))] side:(5#-1);qty:(5#1000);vqty:(1200,4#1000)); // Expected Depth
            (til[2];2#1;2#1;2#-1;2#1;88 377;2#100;2#1000;2#z); // Expected Orders
            () // Expected Events
        ));
        ("1 buy order at best level, previous depth greater than differing updates";(
            ((10#-1);(raze flip 2 5#(1000+til 5));10#1100;(10#z,(z+`second$5))); // Current Depth
            (til[2];2#1;2#1;2#-1;2#1;100 400;2#100;2#1000;2#z); // Current Orders
            ((10#-1);(raze flip 2 5#(1000+til 5));(10#1050 1000);(10#z,(z+`second$5))); // Depth Update
            ([price:((1000+til 5))] side:(5#-1);qty:(5#1000);vqty:(1200,4#1000)); // Expected Depth
            (til[2];2#1;2#1;2#-1;2#1;88 377;2#100;2#1000;2#z); // Expected Orders
            () // Expected Events
        ));
        ("1 buy order at best level, previous depth greater than differing updates (3 updates) 2 dec 1 inc";(
            ((10#-1);(raze flip 2 5#(1000+til 5));10#1100;(10#z,(z+`second$5))); // Current Depth
            (til[2];2#1;2#1;2#-1;2#1;100 400;2#100;2#1000;2#z); // Current Orders
            ((9#-1);(raze flip 3#{(1000+x;1000+x;1000+x)}til 3);(9#1050 1000 1100);(9#z,(z+`second$5))); // Depth Update
            ([price:((1000+til 5))] side:(5#-1);qty:(5#1100);vqty:(1300,4#1100)); // Expected Depth
            (til[2];2#1;2#1;2#-1;2#1;88 377;2#100;2#1000;2#z); // Expected Orders
            () // Expected Events
        ));
        ("buy and sell orders at best level, previous depth greater than differing updates (3 updates) 2 dec 1 inc";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1100;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#999),(2#1000);4#z); // Current Orders
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));(20#1000 1100);(20#z,(z+`second$5))); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1100);vqty:10#(1300,4#1100)); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#88 377);4#100;(2#999),(2#1000);4#z); // Expected Orders
            () // Expected Events
        ));
        ("check that depth update where zero is removed and only one update is processed per side";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1100;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (-11;1000 999;0 0;(z,z));  // Depth Update
            ([price:((998-til 4),(1001+til 4))] side:(4#1),(4#-1);qty:(8#1100);vqty:(8#1100)); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time doesn't cross spread (best price decreases during update)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((4#1),(2#-1));
                ((999 998 998 999),(999 999));
                ((0 0 1000 1000),(1000 0));
                (sc[z] 0 0 1 1 0 1)
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1000);vqty:(1000,1200,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(0 200 100 400);4#100;(2#998),(2#1001);4#z);  // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time doesn't cross spread (best price increases during update)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((4#-1),(2#1));
                ((1000 1001 1001 1000),(1000 1000));
                ((0 0 1000 1000),(1000 0));
                (sc[z] 0 0 1 1 0 1)
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1000);vqty:((6#1000),1200,(3#1000)));  // Expected Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price decreases during update) finishes at original";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((6#1),(4#-1));
                ((999 998 997 997 998 999),(999 998 999 998));
                ((0 0 0 1000 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 1 0 0 1 1)
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1000);vqty:(1000,1200,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price increases during update) finishes at original";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((6#-1),(4#1));
                ((1000 1001 10002 1001 1000 1002),(1000 1001 1000 1001));
                ((0 0 0 1000 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 1 0 0 1 1)
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1000);vqty:((6#1000),1200,(3#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price decreases during update) finishes at order level";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((5#1),(4#-1));
                ((999 998 997 997 998),(999 998 999 998));
                ((0 0 0 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 0 0 1 1)
            ); // Depth Update
            ([price:((998-til 4),(1000+til 5))] side:(4#1),(5#-1);qty:(9#1000);vqty:(1200,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price increases during update) finishes at order level";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5)));  // Current Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((5#-1),(4#1));
                ((1000 1001 10002 1001 1002),(1000 1001 1000 1001));
                ((0 0 0 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 0 0 1 1)
            );  // Depth Update
            ([price:((999-til 5),(1001+til 4))] side:(5#1),(4#-1);qty:(9#1000);vqty:((5#1000),1200,(3#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(0 200 100 400);4#100;(2#1001),(2#998);4#z);  // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, repletes order spread during update, finishes at both order levels";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((5#-1),(5#1));
                ((1000 1001 1002 1001 1002),(999 998 997 998 997));
                ((0 0 0 1000 1000),(0 0 0 1000 1000));
                (sc[z] 0 0 0 1 1 0 0 0 1 1)
            ); // Depth Update
            ([price:((998-til 4),(1001+til 4))] side:(4#1),(4#-1);qty:(8#1000);vqty:(8#(1200,(3#1000)))); // Expected Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#(0 200));4#100;(2#1001),(2#998);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price decreases during update) finishes past order level (within final spread)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((4#1),(4#-1));
                ((999 998 997 997),(999 998 999 998));
                ((0 0 0 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 0 0 1 1)
            ); // Depth Update
            ([price:((998-til 4),(1000+til 5))] side:(4#1),(5#-1);qty:0,(8#1000);vqty:(300,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price increases during update) finishes past order level (within final spread)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5)));  // Current Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((4#-1),(4#1));
                ((1000 1001 1002 1002),(1000 1001 1000 1001));
                ((0 0 0 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 0 0 1 1)
            ); // Depth Update
            ([price:((999-til 5),(1001+til 4))] side:(5#1),(4#-1);qty:9#((5#1000),0);vqty:9#((5#1000),300)); // Expected Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price decreases during update) finishes past order level (past final spread)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((4#1),(2#-1));
                ((999 998 997 997),(999 998));
                ((0 0 0 1000),(1000 1000));
                (sc[z] 0 0 0 1 0 0)
            ); // Depth Update
            ([price:((998-til 4),(1000+til 5))] side:(4#1),(5#-1);qty:0,(8#1000);vqty:(300,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price increases during update) finishes past order level (past final spread)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((4#-1),(2#1));
                ((1000 1001 1002 1002),(1000 1001));
                ((0 0 0 1000),(1000 1000));
                (sc[z] 0 0 0 1 0 0)
            ); // Depth Update
            ([price:((999-til 5),(1001+til 4))] side:(5#1),(4#-1);qty:9#((5#1000),0);vqty:9#((5#1000),300));  // Expected Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(0 200 100 400);4#100;(2#1001),(2#998);4#z);  // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, repletes order spread during update, many order offset prices, finishes at both order levels";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5)));  // Current Depth
            (til[8];8#1;8#1;((4#-1),(4#1));8#1;(8#100 400);8#100;((4#1001 1002),(4#998 997));8#z); // Current Orders
            (
                ((5#-1),(5#1));
                ((1000 1001 10002 1001 1002),(999 998 997 997 998));
                ((0 0 0 1000 1000),(0 0 0 1000 1000));
                (sc[z] 0 0 0 1 1 0 0 0 1 1)
            );  // Depth Update
            ([price:((998-til 4),(1001+til 4))] side:(4#1),(4#-1);qty:(8#1000);vqty:(8#(1200,(3#1000)))); // Expected Depth
            (til[8];8#1;8#1;((4#-1),(4#1));8#1;((8#0 200 100 400));8#100;((4#1001 1002),(4#998 997));8#z); // Expected Orders
            () // Expected Events
        ));
        ("many levels with many orders at same offset interval, price is removed across all levels partially (900)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[20];20#1;20#1;((10#-1),(10#1));20#1;(20#100 400);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // Current Orders
            (
                ((20#1),(20#-1));
                ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
                (40#900 1000);
                (sc[z] (40#0 1))
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1000);vqty:(10#1200)); // Expected Depth
            (til[20];20#1;20#1;((10#-1),(10#1));20#1;(20#75 350);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // Expected Orders
            () // Expected Events
        ));
        ("many levels with many orders at same offset interval, price is removed across all levels fully (1000)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5)));  // Current Depth
            (til[20];20#1;20#1;((10#-1),(10#1));20#1;(20#100 400);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // Current Orders
            (
                ((20#1),(20#-1));
                ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
                (40#0 1000);
                (sc[z] (40#0 1))
            );  // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1000);vqty:(10#1200)); // Expected Depth
            (til[20];20#1;20#1;((10#-1),(10#1));20#1;(20#0 200);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // Expected Orders
            () // Expected Events
        ))
    );
    .util.testutils.defaultEngineHooks;
    "Given a depth update which consists of a table of time,side,price",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders where necessary"];


// TODO no liquidity
// TODO add order update events!!!!
// TODO agent trade fills entire price level
// TODO trade size larger than orderbook qty
// TODO instrument id, tick size, lot size etc. 
// TODO inc self fill called
// TODO test that qty is ordered correctly for fills i.e. price is ordered
// TODO less than offset fills price and removes price
// TODO test reduce only, immediate or cancel, participate don't initiate etc.
// TODO test with different accounts
// TODO reduce only
// TODO test other side
// TODO benchmarking
// TOOD test instrument/account doesn't exist
// TODO test erroring

.qt.Unit[
    ".order.ProcessTrade";
    {[c]
        p:c[`params];

        .util.testutils.setupDepth[p`cDepth];
        .util.testutils.setupOrders[p`cOrd];

        m:p[`mocks];

        mck1: .qt.M[`.account.ApplyFill;{[a;b;c;d;e;f;g;h]};c];
        mck2: .qt.M[`.order.AddTradeEvent;{[a;b]};c];
        mck3: .qt.M[`.account.IncSelfFill;{[a;b;c]};c];
        mck4: .qt.M[`.account.IncSelfFill;{[a;b;c]};c];
        mck5: .qt.M[`.account.IncSelfFill;{[a;b;c]};c];

        a:p[`args];
        .order.ProcessTrade[];

        .util.testutils.checkMock[mck1;m[0]];
        .util.testutils.checkMock[mck2;m[1]];
        .util.testutils.checkMock[mck3;m[2]];
        .util.testutils.checkMock[mck4;m[3]];
        .util.testutils.checkMock[mck5;m[4]];

        .util.testutils.checkDepth[p[`eDepth];c];
        .util.testutils.checkOrders[p[`eOrd];c];

    };
    {[p]
    
    };
    (
        ("orderbook does not have agent orders, trade was not made by an agent trade is smaller than first level";(
            ((10#1);1000-til 10;10#1000;(10#z,(z+`second$1))); // Current Depth
            (); // Current Orders
            (1;-1;100;0b;0b;0N;z); // Fill Execution
            ([price:1000-til 10] side:(10#1);qty:(900,9#1000);vqty:(900,9#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (0b;0;()); // Expected IncSelfFill Mock
            (0b;0;()); // Expected ApplyFill Mock
            (1b;1;enlist((-1;1000;100);z)); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("orderbook does not have agent orders, trade was not made by an agent trade is larger than first level";(
            ((10#1);1000-til 10;10#1000;(10#z,(z+`second$1))); // Current Depth
            (); // Current Orders
            (1;-1;1500;0b;0b;0N;z); // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (0b;0;()); // Expected IncSelfFill Mock
            (0b;0;()); // Expected ApplyFill Mock
            (1b;2;(
                ((-1;999;500);z);
                ((-1;1000;1000);z)
            )); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("orderbook does not have agent orders, trade was made by an agent, trade is larger than best qty";(
            ((10#1);1000-til 10;10#1000;(10#z,(z+`second$5))); // Current Depth
            (); // Current Orders
            (`.instrument.Instrument!0;-1;1500;0b;1b;`.account.Account!0;z); // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (0b;0;()); // Expected IncSelfFill Mock
            (1b;2;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
                (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;999;500);
                (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;1000;1000)
            )); // Expected ApplyFill Mock
            (1b;2;( // side size price
                ((-1;999;500);z);
                ((-1;1000;1000);z)
            )); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("orderbook does not have agent orders, trade was not made by an agent, trade is smaller than best qty";(
            ((10#1);1000-til 10;10#1000;(10#z,(z+`second$5))); // Current Depth
            (); // Current Orders
            (`.instrument.Instrument!0;-1;200;0b;0b;0N;z);  // Fill Execution
            ([price:1000-til 10] side:(10#1);qty:(800,9#1000);vqty:(800,9#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (0b;0;()); // Expected IncSelfFill Mock
            (1b;2;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
                (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;999;500);
                (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;1000;1000)
            )); // Expected ApplyFill Mock
            (1b;1; // AddTradeEvent: side size price
                enlist((-1;1000;200);z)
            ); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("orderbook does not have agent orders, trade was not made by an agent, trade is larger than best qty";(
            ((10#1);1000-til 10;10#1000;(10#z,(z+`second$5))); // Current Depth
            (); // Current Orders
            (`.instrument.Instrument!0;-1;1200;0b;0b;0N;z);  // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(800,8#1000);vqty:(800,8#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (0b;0;()); // Expected IncSelfFill Mock
            (0b;0;()); // Expected ApplyFill Mock
            (1b;2;( // AddTradeEvent: side size price
                ((-1;999;200);z);
                ((-1;1000;1000);z)
            )); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("orderbook does not have agent orders, trade was made by an agent, trade is smaller than best qty";(
            ((10#1);1000-til 10;10#1000;(10#z,(z+`second$5))); // Current Depth
            (); // Current Orders
            (`.instrument.Instrument!0;-1;200;0b;1b;`.account.Account!0;z);   // Fill Execution
            ([price:1000-til 10] side:(10#1);qty:(800,9#1000);vqty:(800,9#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (0b;0;()); // Expected IncSelfFill Mock
            (1b;1; // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty 
                enlist(`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;1000;200)
            ); // Expected ApplyFill Mock
            (1b;1; // AddTradeEvent: side size price
                enlist((-1;1000;200);z)
            ); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("orderbook does not have agent orders, trade was made by an agent, trade is larger than best qty";(
            ((10#1);1000-til 10;10#1000;(10#z,(z+`second$5))); // Current Depth
            (); // Current Orders
            (`.instrument.Instrument!0;-1;1200;0b;1b;`.account.Account!0;z);  // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(800,8#1000);vqty:(800,8#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (0b;0;()); // Expected IncSelfFill Mock
            (1b;2;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty 
                (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;1000;1000);
                (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;999;200)
            )); // Expected ApplyFill Mock
            (1b;2;( // AddTradeEvent: side size price
                ((-1;1000;1000);z);
                ((-1;999;200);z)
            )); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("orderbook has agent orders, lvl1 size > qty, trade doesn't fill agent order, trade execution < agent order offset, fill is agent";(
            ((10#1);1000-til 10;10#1000;(10#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;4#1;4#1;((2#400),(2#600));4#100;4#1000 999;4#z); // Current Orders
            (`.instrument.Instrument!0;-1;200;0b;1b;`.account.Account!0;z);  // Fill Execution
            ([price:1000-til 10] side:(10#1);qty:(800,9#1000);vqty:(1000 1200, 8#1000)); // Expected Depth
            (til[4];4#1;4#1;4#1;4#1;(200 400 400 600);4#100;4#1000 999;4#0;4#z); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (0b;0;()); // Expected IncSelfFill Mock
            (1b;1; // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty 
                enlist(`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;1000;200)
            ); // Expected ApplyFill Mock
            (1b;1; // AddTradeEvent: side size price
                enlist((-1;1000;200);z)
            ); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("orderbook has agent orders, lvl1 size < qty, trade doesn't fill agent order, trade execution < agent order offset, fill is agent";(
            ((10#1);1000-til 10;10#1000;(10#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;4#1;4#1;((2#400),(2#600));4#100;4#999 998;4#z); // Current Orders
            (`.instrument.Instrument!0;-1;1200;0b;1b;`.account.Account!0;z);  // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(800,8#1000);vqty:(1000 1200, 7#1000)); // Expected Depth
            (til[4];4#1;4#1;4#1;4#1;(200 400 400 600);4#100;4#999 998;4#0;4#z); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (0b;0;()); // Expected IncSelfFill Mock
            (1b;2;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty 
                (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;999;200);
                (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;1000;1000)
            )); // Expected ApplyFill Mock
            (1b;2;( // AddTradeEvent: side size price
                ((-1;999;200);z);
                ((-1;1000;1000);z)
            )); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("orderbook has agent orders, trade fills agent order, trade execution > agent order offset, fill is agent";(
            ((10#1);1000-til 10;10#1000;(10#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#1000 999;4#z); // Current Orders
            (`.instrument.Instrument!0;-1;1450;0b;1b;`.account.Account!0;z);  // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(550,(8#1000));vqty:(750,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;4#1;4#1;(4#0);((3#0),50);4#1000 999;(3#2),0;4#z); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (1b;1;enlist(`.account.Account!0;4;2300)); // Expected IncSelfFill Mock
            (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
                (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;999;50);
                (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;1000;800);
                (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;999;450);
                (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;1000;1000)
            )); // Expected ApplyFill Mock
            (1b;9;( // AddTradeEvent: side size price
                ((-1;1000;100);z);
                ((-1;1000;100);z);
                ((-1;1000;200);z);
                ((-1;1000;100);z); // TODO make sure is sorted correctly
                ((-1;1000;500);z);
                ((-1;999;100);z);
                ((-1;999;100);z);
                ((-1;999;200);z);
                ((-1;999;50);z)
            )); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("orderbook has agent orders, trade doesn't fill agent order, trade execution < agent order offset, fill is not agent";(
            ((10#1);1000-til 10;10#1000;(10#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#1000 999;4#z); // Current Orders
            (`.instrument.Instrument!0;-1;50;0b;0b;0N;z);  // Fill Execution
            ([price:1000-til 10] side:(10#1);qty:(950,9#1000);vqty:(1150 1200, 8#1000)); // Expected Depth
            (til[4];4#1;4#1;4#1;4#1;(50 100 350 400);(4#100);4#1000 999;4#0;4#z); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (0b;0;()); // Expected IncSelfFill Mock
            (0b;0;()); // Expected ApplyFill Mock
            (1b;1; // AddTradeEvent: side size price 
                enlist((-1;1000;50);z)
            ); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("orderbook has agent orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";(
            ((10#1);1000-til 10;10#1000;(10#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#1000 999;4#z); // Current Orders
            (`.instrument.Instrument!0;-1;1450;1b;1b;`.account.Account!1;z);  // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(550,(8#1000));vqty:(750,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;4#1;4#1;(4#0);((3#0),50);4#1000 999;(3#2),0;4#z); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (0b;0;()); // Expected IncSelfFill Mock
            (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
                (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;999;50);
                (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;1000;800);
                (`.account.Account!1;`.instrument.Instrument!0;-1;z;1b;0b;999;450);
                (`.account.Account!1;`.instrument.Instrument!0;-1;z;1b;0b;1000;1000)
            )); // Expected ApplyFill Mock
            (1b;9;( // AddTradeEvent: side size price
                ((-1;1000;100);z);
                ((-1;1000;100);z);
                ((-1;1000;200);z);
                ((-1;1000;100);z); // TODO make sure is sorted correctly
                ((-1;1000;500);z);
                ((-1;999;100);z);
                ((-1;999;100);z);
                ((-1;999;200);z);
                ((-1;999;50);z)
            )); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("SELL: orderbook has agent orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";(
            ((10#1);1000-til 10;10#1000;(10#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#1000 999;4#z); // Current Orders
            (`.instrument.Instrument!0;-1;1450;1b;1b;`.account.Account!1;z);  // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(550,(8#1000));vqty:(750,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;4#1;4#1;(4#0);((3#0),50);4#1000 999;(3#2),0;4#z); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (0b;0;()); // Expected IncSelfFill Mock
            (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
                (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;999;50);
                (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;1000;800);
                (`.account.Account!1;`.instrument.Instrument!0;-1;z;1b;0b;999;450);
                (`.account.Account!1;`.instrument.Instrument!0;-1;z;1b;0b;1000;1000)
            )); // Expected ApplyFill Mock
            (1b;9;( // AddTradeEvent: side size price
                ((-1;1000;100);z);
                ((-1;1000;100);z);
                ((-1;1000;200);z);
                ((-1;1000;100);z); // TODO make sure is sorted correctly
                ((-1;1000;500);z);
                ((-1;999;100);z);
                ((-1;999;100);z);
                ((-1;999;200);z);
                ((-1;999;50);z)
            )); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("BUY: orderbook has agent orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";(
            ((10#-1);1000+til 10;10#1000;(10#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;4#-1;4#1;((2#100),(2#400));4#100;4#1000 1001;4#z); // Current Orders
            (`.instrument.Instrument!0;1;1450;1b;1b;`.account.Account!1;z);  // Fill Execution
            ([price:1001+til 9] side:(9#-1);qty:(550,(8#1000));vqty:(750,(8#1000)));  // Expected Depth
            (til[4];4#1;4#1;4#-1;4#1;(4#0);((3#0),50);4#1000 1001;(3#2),0;4#z); // Expected Orders
            (0b;0;()); // Expected AddOrderUpdateEvent Mock
            (0b;0;()); // Expected IncSelfFill Mock
            (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
                (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;1b;1001;50);
                (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;1b;1000;800);
                (`.account.Account!1;`.instrument.Instrument!0;1;z;1b;0b;1001;450);
                (`.account.Account!1;`.instrument.Instrument!0;1;z;1b;0b;1000;1000)
            )); // Expected ApplyFill Mock
            (1b;9;( // AddTradeEvent: side size price
                ((1;1000;100);z);
                ((1;1000;100);z);
                ((1;1000;200);z);
                ((1;1000;100);z); // TODO make sure is sorted correctly
                ((1;1000;500);z);
                ((1;1001;100);z);
                ((1;1001;100);z);
                ((1;1001;200);z);
                ((1;1001;50);z)
            )); // Expected AddTradeEvent Mock
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ))
    );
    .util.testutils.defaultEngineHooks;
    "Process trades from the historical data or agent orders",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders and call Add Events/Fills etc. where necessary"];


test:.qt.Unit[
    ".order.ProcessOrder";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };
    {};
    ();
    .util.testutils.defaultEngineHooks;
    "Global function for processing new orders"];

test:.qt.Unit[
    ".order.ExecStop";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };
    {};
    ();
    .util.testutils.defaultEngineHooks;
    "Global function for triggering stop orders"];


test:.qt.Unit[
    ".order.CheckStopOrders";
    {[c]
        p:c[`params];

        .order.ProcessTrade[p[`event]];

    };
    {};
    ();
    .util.testutils.defaultEngineHooks;
    "Global function for checking stop orders"];
