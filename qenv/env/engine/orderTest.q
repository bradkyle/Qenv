

\cd ../../quantest/
\l quantest.q 
\cd ../env/engine/

\l instrument.q
\l account.q

\cd ../util
\l table.q
\l testutils.q 
\l cond.q
\cd ../engine/

\cd ../pipe
\l common.q
\l event.q 
\l egress.q
\l ingress.q 
\l pipe.q 
\cd ../engine

/ \l ./contract/inverse/account.q 
/ \pwd
/ \l ./contract/linear/account.q 
/ \l ./contract/quanto/account.q 
\l order.q

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
        delete from `.order.OrderBook;
        delete from `.order.Order;
        
        .util.testutils.setupDepth[0^p`cDepth];
        .util.testutils.setupOrders[0^p`cOrd];

        m:p`mocks;
        mck1: .qt.M[`.pipe.egress.AddDepthEvent;{[a;b;c;d;e;f;g;h]};c];

        // instrument;nxt:(side;price;qty;hqty;time)
        .order.ProcessDepth[.util.testutils.defaultInstrument;p`nxt];

        / .util.testutils.checkMock[mck1;m[0];c];
        .util.testutils.checkDepth[p[`eDepth];c];
        .util.testutils._checkOrders[(`orderId`side`otype`offset`leaves`price`time);p[`eOrd];c];

    };
    {[p] 
        // TODO account for one record
        ordCols:{$[
            count[x]=9;`orderId`instrumentId`accountId`side`otype`offset`leaves`price`time;
            count[x]=10;`orderId`instrumentId`accountId`side`otype`offset`leaves`displayqty`price`time;
            ()]};

        bookCols:`side`price`qty`hqty`iqty`vqty;
        nxt:$[
            count[p[2]]=4;`side`price`nqty`time!p[2];
            count[p[2]]=5;`side`price`nqty`nhqty`time!p[2];
            'INVALID_NXT];

        :`cDepth`cOrd`nxt`mocks`eDepth`eOrd!(
            .util.testutils.makeOrderBook[count[p[0]]#bookCols;flip p[0]];
            .util.testutils.makeOrders[ordCols[p[1]];flip p[1]];
            nxt;
            enlist p[5];
            p[3]; // TODO shorten parameterization
            .util.testutils.makeOrders[ordCols[p[4]];flip p[4]]);
    };
    (
        ("simple update no agent orders or previous depth one side";(
            (); // Current Depth
            (); // Current Orders
            ((10#-1);1000+til 10;10#1000;10#z); // Depth Update
            ([price:(1000+til 10)] side:(10#-1);qty:(10#1000);vqty:(10#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both (crossing)";(
            (); // Current Depth
            (); // Current Orders
            ((10#-1);1000+til 10;10#1000;10#z); // Depth Update
            ([price:(1000+til 10)] side:(10#-1);qty:(10#1000);vqty:(10#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("simple update no agent orders or previous depth both; Multi temporal";(
            (); // Current Depth
            (); // Current Orders
            ((10#-1);(raze flip 2 5#(1000+til 5));10#1000 100;(10#z,(z+`second$5))); // Depth Update
            ([price:(1000+til 5)] side:(5#-1);qty:(5#100);vqty:(5#100)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("all OrderBook levels should be removed where the remaining qty<=0 and no agent orders exist";(
            ((10#-1);(raze flip 2 5#(1000+til 5));10#100); // Current Depth
            (); // Current Orders
            ((10#-1);(raze flip 2 5#(1000+til 5));((2#0),(8#100));(10#z,(z+`second$5))); // Depth Update
            ([price:(1001+til 4)] side:(4#-1);qty:(4#100);vqty:(4#100)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("1 buy order at best level, previous depth greater than updates";(
            ((10#-1);(raze flip 2 5#(1000+til 5));10#1100); // Current Depth
            (til[2];2#1;2#1;2#-1;2#1;100 400;2#100;2#1000;2#z); // Current Orders
            ((10#-1);(raze flip 2 5#(1000+til 5));10#1000;(10#z,(z+`second$5))); // Depth Update
            ([price:((1000+til 5))] side:(5#-1);qty:(5#1000);vqty:(1200,4#1000)); // Expected Depth
            (til[2];2#1;2#1;2#-1;2#1;88 377;2#100;2#1000;2#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("1 buy order at best level, previous depth greater than differing updates";(
            ((10#-1);(raze flip 2 5#(1000+til 5));10#1100); // Current Depth
            (til[2];2#1;2#1;2#-1;2#1;100 400;2#100;2#1000;2#z); // Current Orders
            ((10#-1);(raze flip 2 5#(1000+til 5));(10#1050 1000);(10#z,(z+`second$5))); // Depth Update
            ([price:((1000+til 5))] side:(5#-1);qty:(5#1000);vqty:(1200,4#1000)); // Expected Depth
            (til[2];2#1;2#1;2#-1;2#1;88 377;2#100;2#1000;2#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("1 buy order at best level, previous depth greater than differing updates (3 updates) 2 dec 1 inc";(
            ((10#-1);(raze flip 2 5#(1000+til 5));10#1100); // Current Depth
            (til[2];2#1;2#1;2#-1;2#1;100 400;2#100;2#1000;2#z); // Current Orders
            ((9#-1);(raze flip 3#{(1000+x;1000+x;1000+x)}til 3);(9#1050 1000 1100);(9#z,(z+`second$5))); // Depth Update
            ([price:((1000+til 5))] side:(5#-1);qty:(5#1100);vqty:(1300,4#1100)); // Expected Depth
            (til[2];2#1;2#1;2#-1;2#1;88 377;2#100;2#1000;2#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("buy and sell orders at best level, previous depth greater than differing updates (3 updates) 2 dec 1 inc";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1100); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#999),(2#1000);4#z); // Current Orders
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));(20#1000 1100);(20#z,(z+`second$5))); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1100);vqty:10#(1300,4#1100)); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#88 377);4#100;(2#999),(2#1000);4#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("check that depth update where zero is removed and only one update is processed per side";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1100); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (-11;1000 999;0 0;(z,z));  // Depth Update
            ([price:((998-til 4),(1001+til 4))] side:(4#1),(4#-1);qty:(8#1100);vqty:(8#1100)); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("differing update prices by time doesn't cross spread (best price decreases during update)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((4#1),(2#-1));
                ((999 998 998 999),(999 999));
                ((0 0 1000 1000),(1000 0));
                (sc[z] 0 0 1 1 0 1)
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1000);vqty:(1000,1200,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(0 200 100 400);4#100;(2#998),(2#1001);4#z);  // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("differing update prices by time doesn't cross spread (best price increases during update)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000); // Current Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((4#-1),(2#1));
                ((1000 1001 1001 1000),(1000 1000));
                ((0 0 1000 1000),(1000 0));
                (sc[z] 0 0 1 1 0 1)
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1000);vqty:((6#1000),1200,(3#1000)));  // Expected Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price decreases during update) finishes at original";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((6#1),(4#-1));
                ((999 998 997 997 998 999),(999 998 999 998));
                ((0 0 0 1000 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 1 0 0 1 1)
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1000);vqty:(1000,1200,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price increases during update) finishes at original";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000); // Current Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((6#-1),(4#1));
                ((1000 1001 10002 1001 1000 1002),(1000 1001 1000 1001));
                ((0 0 0 1000 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 1 0 0 1 1)
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1000);vqty:((6#1000),1200,(3#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price decreases during update) finishes at order level";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((5#1),(4#-1));
                ((999 998 997 997 998),(999 998 999 998));
                ((0 0 0 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 0 0 1 1)
            ); // Depth Update
            ([price:((998-til 4),(1000+til 5))] side:(4#1),(5#-1);qty:(9#1000);vqty:(1200,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price increases during update) finishes at order level";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000);  // Current Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((5#-1),(4#1));
                ((1000 1001 10002 1001 1002),(1000 1001 1000 1001));
                ((0 0 0 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 0 0 1 1)
            );  // Depth Update
            ([price:((999-til 5),(1001+til 4))] side:(5#1),(4#-1);qty:(9#1000);vqty:((5#1000),1200,(3#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(0 200 100 400);4#100;(2#1001),(2#998);4#z);  // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("differing update prices by time, repletes order spread during update, finishes at both order levels";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000); // Current Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((5#-1),(5#1));
                ((1000 1001 1002 1001 1002),(999 998 997 998 997));
                ((0 0 0 1000 1000),(0 0 0 1000 1000));
                (sc[z] 0 0 0 1 1 0 0 0 1 1)
            ); // Depth Update
            ([price:((998-til 4),(1001+til 4))] side:(4#1),(4#-1);qty:(8#1000);vqty:(8#(1200,(3#1000)))); // Expected Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#(0 200));4#100;(2#1001),(2#998);4#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price decreases during update) finishes past order level (within final spread)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((4#1),(4#-1));
                ((999 998 997 997),(999 998 999 998));
                ((0 0 0 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 0 0 1 1)
            ); // Depth Update
            ([price:((998-til 4),(1000+til 5))] side:(4#1),(5#-1);qty:0,(8#1000);vqty:(300,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price increases during update) finishes past order level (within final spread)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000);  // Current Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((4#-1),(4#1));
                ((1000 1001 1002 1002),(1000 1001 1000 1001));
                ((0 0 0 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 0 0 1 1)
            ); // Depth Update
            ([price:((999-til 5),(1001+til 4))] side:(5#1),(4#-1);qty:9#((5#1000),0);vqty:9#((5#1000),300)); // Expected Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price decreases during update) finishes past order level (past final spread)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000); // Current Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((4#1),(2#-1));
                ((999 998 997 997),(999 998));
                ((0 0 0 1000),(1000 1000));
                (sc[z] 0 0 0 1 0 0)
            ); // Depth Update
            ([price:((998-til 4),(1000+til 5))] side:(4#1),(5#-1);qty:0,(8#1000);vqty:(300,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#1),(2#-1));4#1;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price increases during update) finishes past order level (past final spread)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000); // Current Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((4#-1),(2#1));
                ((1000 1001 1002 1002),(1000 1001));
                ((0 0 0 1000),(1000 1000));
                (sc[z] 0 0 0 1 0 0)
            ); // Depth Update
            ([price:((999-til 5),(1001+til 4))] side:(5#1),(4#-1);qty:9#((5#1000),0);vqty:9#((5#1000),300));  // Expected Depth
            (til[4];4#1;4#1;((2#-1),(2#1));4#1;(0 200 100 400);4#100;(2#1001),(2#998);4#z);  // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("differing update prices by time, repletes order spread during update, many order offset prices, finishes at both order levels";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000);  // Current Depth
            (til[8];8#1;8#1;((4#-1),(4#1));8#1;(8#100 400);8#100;((4#1001 1002),(4#998 997));8#z); // Current Orders
            (
                ((5#-1),(5#1));
                ((1000 1001 10002 1001 1002),(999 998 997 997 998));
                ((0 0 0 1000 1000),(0 0 0 1000 1000));
                (sc[z] 0 0 0 1 1 0 0 0 1 1)
            );  // Depth Update
            ([price:((998-til 4),(1001+til 4))] side:(4#1),(4#-1);qty:(8#1000);vqty:(8#(1200,(3#1000)))); // Expected Depth
            (til[8];8#1;8#1;((4#-1),(4#1));8#1;((8#0 200 100 400));8#100;((4#1001 1002),(4#998 997));8#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("many levels with many orders at same offset interval, price is removed across all levels partially (900)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000); // Current Depth
            (til[20];20#1;20#1;((10#-1),(10#1));20#1;(20#100 400);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // Current Orders
            (
                ((20#1),(20#-1));
                ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
                (40#900 1000);
                (sc[z] (40#0 1))
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1000);vqty:(10#1200)); // Expected Depth
            (til[20];20#1;20#1;((10#-1),(10#1));20#1;(20#75 350);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("many levels with many orders at same offset interval, price is removed across all levels fully (1000)";(
            (((10#1),(10#-1));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000);  // Current Depth
            (til[20];20#1;20#1;((10#-1),(10#1));20#1;(20#100 400);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // Current Orders
            (
                ((20#1),(20#-1));
                ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
                (40#0 1000);
                (sc[z] (40#0 1))
            );  // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#1),(5#-1);qty:(10#1000);vqty:(10#1200)); // Expected Depth
            (til[20];20#1;20#1;((10#-1),(10#1));20#1;(20#0 200);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("many levels with many iceberg orders at same offset interval with hidden qty, price is removed across all levels fully (1000)";(
            // side; price; qty; hqty; iqty; vqty
            (
                ((10#1),(10#-1));
                ((raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5)));
                20#1000;
                ((20,(9#10)),(20,(9#10)));
                (((2#80),(8#10)),((2#80),(8#10)));
                20#1000
            );  // Current Depth
            (
                til[20];20#1;20#1;
                ((10#-1),(10#1));
                20#1;(20#100 400);
                20#100;
                ((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));
                20#z
            ); // Current Orders
            (
                ((20#1),(20#-1));
                ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
                (40#0 1000); // NQTY
                ((10, (19#0)),(10, (19#0))); // NHQTY
                (sc[z] (40#0 1)) // TIME
            );  // Depth Update
            (
                [price:((999-til 5),(1000+til 5))] 
                side:(5#1),(5#-1);
                qty:(10#1000);
                hqty:(10#1000);
                iqty:(10#1000);
                vqty:(10#1200)
            ); // Expected Depth
            (
                til[20];
                20#1;
                20#1;
                ((10#-1),(10#1));
                20#1;
                (20#0 200);
                20#100;
                ((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));
                20#z
            ); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ))
    );
    .util.testutils.defaultEngineHooks;
    "Given a depth update which consists of a table of time,side,price",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders where necessary"];


.qt.SkpBes[16];
/ .qt.SkpBes[46];
.qt.RunTests[];
/

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
// TODO iceberg/hidden order logic
// TODO hidden orders from agent, hidden orders from data.
// TODO drifts out of book bounds
.qt.Unit[
    ".order.ProcessTrade";
    {[c]
        p:c[`params];
        delete from `.order.Order;
        delete from `.order.OrderBook; // TODO make general
        .util.testutils.setupDepth[p`cDepth];
        .util.testutils.setupOrders[p`cOrd];

        m:p[`mocks];

        mck1: .qt.M[`.account.ApplyFill;{[a;b;c;d;e;f;g;h]};c];
        mck2: .qt.M[`.pipe.egress.AddTradeEvent;{[a;b]};c];
        mck3: .qt.M[`.account.IncSelfFill;{[a;b;c]};c];
        mck5: .qt.M[`.pipe.egress.AddOrderUpdatedEvent;{[a;b]};c];
        mck4: .qt.M[`.pipe.egress.AddDepthEvent;{[a;b]};c];

        .order.ProcessTrade[
            .util.testutils.defaultInstrument;
            .util.testutils.defaultAccount;
            p`td];

        / .util.testutils.checkMock[mck1;m[0];c];  // Expected ApplyFill Mock
        / .util.testutils.checkMock[mck2;m[1];c];  // Expected AddTradeEvent Mock
        / .util.testutils.checkMock[mck3;m[2];c];  // Expected IncSelfFill Mock
        / .util.testutils.checkMock[mck4;m[3];c];  // Expected AddOrderUpdated Mock
        / .util.testutils.checkMock[mck5;m[4];c];  // Expected AddDepthEvent Mock

        .util.testutils.checkDepth[p[`eDepth];c];
        .util.testutils._checkOrders[
            (`orderId`side`otype`offset`leaves`displayqty`price`reduce`time);
            p[`eOrd];c];

    }; // TOOD derive from // TODO derive orderbook, orders
    {[p] 
        // TODO account for one record
        ordCols:`orderId`instrumentId`accountId`side`otype`offset`leaves`displayqty`price`time;
        ordColsEx:`orderId`instrumentId`accountId`side`otype`offset`leaves`displayqty`price`status`time;
        bookCols:`side`price`qty`hqty`iqty`vqty;

        :`cDepth`cOrd`td`mocks`eDepth`eOrd!(
            .util.testutils.makeOrderBook[bookCols;flip p[0]];
            .util.testutils.makeOrders[ordCols;flip p[1]];
            p[2];
            (5_10#p);
            p[3]; // TODO shorten parameterization
            .util.testutils.makeOrders[ordColsEx;flip p[4]]);
    };
    (
        ("orderbook does not have agent orders, trade was not made by an agent trade is smaller than first level";(
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;100;0b;z); // Fill Execution
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
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1500;0b;z); // Fill Execution
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
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1500;0b;z); // Fill Execution
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
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;200;0b;z);  // Fill Execution
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
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1200;0b;z);  // Fill Execution
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
        //
        ("orderbook does not have agent orders, trade was not made by an agent, trade < visqty, trade < hidden qty";(
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1200;0b;z);  // Fill Execution
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
        ("orderbook does not have agent orders, trade was not made by an agent, trade < visqty, trade < hidden qty";(
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1200;0b;z);  // Fill Execution
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
        ("orderbook does not have agent orders, trade was not made by an agent, trade < visqty, trade > hidden qty";(
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1200;0b;z);  // Fill Execution
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
        ("orderbook does not have agent orders, trade was not made by an agent, trade > visqty, trade < hidden qty";(
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1200;0b;z);  // Fill Execution
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
        ("orderbook does not have agent orders, trade was not made by an agent, trade > visqty, trade > hidden qty";(
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1200;0b;z);  // Fill Execution
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
        //
        ("orderbook does not have agent orders, trade was made by an agent, trade is smaller than best qty";(
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;200;0b;z);   // Fill Execution
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
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1200;0b;z);  // Fill Execution
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
        ("orderbook does not have agent orders, trade was made by an agent, trade < visqty, trade < hidden qty";(
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1200;0b;z);  // Fill Execution
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
        ("orderbook does not have agent orders, trade was made by an agent, trade < visqty, trade < hidden qty";(
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1200;0b;z);  // Fill Execution
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
        ("orderbook does not have agent orders, trade was made by an agent, trade < visqty, trade > hidden qty";(
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1200;0b;z);  // Fill Execution
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
        ("orderbook does not have agent orders, trade was made by an agent, trade > visqty, trade < hidden qty";(
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1200;0b;z);  // Fill Execution
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
        ("orderbook does not have agent orders, trade was made by an agent, trade > visqty, trade > hidden qty";(
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (); // Current Orders
            (-1;1200;0b;z);  // Fill Execution
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
        //
        ("orderbook has agent orders, lvl1 size > qty, trade doesn't fill agent order, trade execution < agent order offset, fill is agent";(
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (til[4];4#1;4#1;4#1;4#1;((2#400),(2#600));4#100;4#100;4#1000 999;4#z); // Current Orders
            (-1;200;0b;z);  // Fill Execution
            ([price:1000-til 10] side:(10#1);qty:(800,9#1000);vqty:(1000 1200, 8#1000)); // Expected Depth
            (til[4];4#1;4#1;4#1;4#1;(200 400 400 600);4#100;4#100;4#1000 999;4#0;4#z); // Expected Orders
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
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (til[4];4#1;4#1;4#1;4#1;((2#400),(2#600));4#100;4#100;4#999 998;4#z); // Current Orders
            (-1;1200;0b;z);  // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(800,8#1000);vqty:(1000 1200, 7#1000)); // Expected Depth
            (til[4];4#1;4#1;4#1;4#1;(200 400 400 600);4#100;4#100;4#999 998;4#0;4#z); // Expected Orders
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
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#100;4#1000 999;4#z); // Current Orders
            (-1;1450;0b;z);  // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(550,(8#1000));vqty:(750,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;4#1;4#1;(4#0);((3#0),50);((3#0),50);4#1000 999;(3#2),0;4#z); // Expected Orders
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
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#100;4#1000 999;4#z); // Current Orders
            (-1;50;0b;z);  // Fill Execution
            ([price:1000-til 10] side:(10#1);qty:(950,9#1000);vqty:(1150 1200, 8#1000)); // Expected Depth
            (til[4];4#1;4#1;4#1;4#1;(50 100 350 400);(4#100);(4#100);4#1000 999;4#0;4#z); // Expected Orders
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
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#100;4#1000 999;4#z); // Current Orders
            (-1;1450;1b;z);  // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(550,(8#1000));vqty:(750,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;4#1;4#1;(4#0);((3#0),50);((3#0),50);4#1000 999;(3#2),0;4#z); // Expected Orders
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
            ((10#1);1000-til 10;10#1000;10#0;10#0;10#1000); // Current Depth
            (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#100;4#1000 999;4#z); // Current Orders
            (-1;1450;1b;z);  // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(550,(8#1000));vqty:(750,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;4#1;4#1;(4#0);((3#0),50);((3#0),50);4#1000 999;(3#2),0;4#z); // Expected Orders
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
            ((10#-1);1000+til 10;10#1000;10#0;10#0;((1200 1200),(8#1000))); // Current Depth
            (til[4];4#1;4#1;4#-1;4#1;((2#100),(2#400));4#100;4#100;4#1000 1001;4#z); // Current Orders
            (1;1450;1b;z);  // Fill Execution
            ([price:1001+til 9] side:(9#-1);qty:(550,(8#1000));hqty:(9#0);iqty:(9#0);vqty:(600,(8#1000)));  // Expected Depth
            (til[4];4#1;4#1;4#-1;4#1;(4#0);((3#0),50);((3#0),50);4#1000 1001;(3#2),0;4#z); // Expected Orders
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
            (0b;0;()); // Expected IncSelfFill Mock
            (1b;1;()); // Expected AddOrderUpdateEvent Mock
            (1b;1;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("BUY: orderbook has iceberg agent orders and hidden orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";(
            ((10#-1);1000+til 10;10#1000;((10 20),(8#10));((180 160),(8#0));((1020 1040),(8#1000))); // Current Depth
            (til[4];4#1;4#1;4#-1;4#1;((2#100),(2#400));4#100;((2#10),(2#20));4#1000 1001;4#z); // Current Orders
            (1;1450;1b;z);  // Fill Execution
            ([price:1001+til 9] side:(9#-1);qty:(740,(8#1000));hqty:(0,(8#10));iqty:(80,(8#0));vqty:(760,(8#1000)));  // Expected Depth
            (til[4];4#1;4#1;4#-1;4#1;((3#0),160);((3#0),100);((3#0),20);4#1000 1001;(3#2),0;4#z); // Expected Orders
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
            (0b;0;()); // Expected IncSelfFill Mock
            (1b;1;()); // Expected AddOrderUpdateEvent Mock
            (1b;1;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ))
        / ("BUY: orderbook has agent iceberg orders and data hidden orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";(
        /     ((10#-1);1000+til 10;10#1000;((10 20),(8#10));((180 160),(8#0));10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#-1;4#1;((2#100),(2#400));4#100;((2#10),(2#20));4#1000 1001;4#z); // Current Orders
        /     (1;1450;1b;z);  // Fill Execution
        /     ([price:1001+til 9] side:(9#-1);qty:(550,(8#1000));vqty:(750,(8#1000)));  // Expected Depth
        /     (til[4];4#1;4#1;4#-1;4#1;(4#0);((3#0),50);((3#0),50);4#1000 1001;(3#2),0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (0b;0;()); // Expected IncSelfFill Mock
        /     (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;1b;1001;50);
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;1b;1000;800);
        /         (`.account.Account!1;`.instrument.Instrument!0;1;z;1b;0b;1001;450);
        /         (`.account.Account!1;`.instrument.Instrument!0;1;z;1b;0b;1000;1000)
        /     )); // Expected ApplyFill Mock
        /     (1b;9;( // AddTradeEvent: side size price
        /         ((1;1000;100);z);
        /         ((1;1000;100);z);
        /         ((1;1000;200);z);
        /         ((1;1000;100);z); // TODO make sure is sorted correctly
        /         ((1;1000;500);z);
        /         ((1;1001;100);z);
        /         ((1;1001;100);z);
        /         ((1;1001;200);z);
        /         ((1;1001;50);z)
        /     )); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ))
        //
        / ("orderbook has agent hidden orders, lvl1 size > qty, trade doesn't fill agent order, trade execution < agent order offset, fill is agent";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#1;4#1;((2#400),(2#600));4#100;4#100;4#1000 999;4#z); // Current Orders
        /     (-1;200;0b;z);  // Fill Execution
        /     ([price:1000-til 10] side:(10#1);qty:(800,9#1000);vqty:(1000 1200, 8#1000)); // Expected Depth
        /     (til[4];4#1;4#1;4#1;4#1;(200 400 400 600);4#100;4#100;4#1000 999;4#0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (0b;0;()); // Expected IncSelfFill Mock
        /     (1b;1; // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty 
        /         enlist(`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;1000;200)
        /     ); // Expected ApplyFill Mock
        /     (1b;1; // AddTradeEvent: side size price
        /         enlist((-1;1000;200);z)
        /     ); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ));
        / ("orderbook has agent hidden orders, lvl1 size < qty, trade doesn't fill agent order, trade execution < agent order offset, fill is agent";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#1;4#1;((2#400),(2#600));4#100;4#100;4#999 998;4#z); // Current Orders
        /     (-1;1200;0b;z);  // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(800,8#1000);vqty:(1000 1200, 7#1000)); // Expected Depth
        /     (til[4];4#1;4#1;4#1;4#1;(200 400 400 600);4#100;4#100;4#999 998;4#0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (0b;0;()); // Expected IncSelfFill Mock
        /     (1b;2;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty 
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;999;200);
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;1000;1000)
        /     )); // Expected ApplyFill Mock
        /     (1b;2;( // AddTradeEvent: side size price
        /         ((-1;999;200);z);
        /         ((-1;1000;1000);z)
        /     )); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ));
        / ("orderbook has agent hidden orders, trade fills agent order, trade execution > agent order offset, fill is agent";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#100;4#1000 999;4#z); // Current Orders
        /     (-1;1450;0b;z);  // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(550,(8#1000));vqty:(750,(8#1000))); // Expected Depth
        /     (til[4];4#1;4#1;4#1;4#1;(4#0);((3#0),50);((3#0),50);4#1000 999;(3#2),0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (1b;1;enlist(`.account.Account!0;4;2300)); // Expected IncSelfFill Mock
        /     (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
        /         (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;999;50);
        /         (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;1000;800);
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;999;450);
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;1000;1000)
        /     )); // Expected ApplyFill Mock
        /     (1b;9;( // AddTradeEvent: side size price
        /         ((-1;1000;100);z);
        /         ((-1;1000;100);z);
        /         ((-1;1000;200);z);
        /         ((-1;1000;100);z); // TODO make sure is sorted correctly
        /         ((-1;1000;500);z);
        /         ((-1;999;100);z);
        /         ((-1;999;100);z);
        /         ((-1;999;200);z);
        /         ((-1;999;50);z)
        /     )); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ));
        / ("orderbook has agent hidden orders, trade doesn't fill agent order, trade execution < agent order offset, fill is not agent";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#100;4#1000 999;4#z); // Current Orders
        /     (-1;50;0b;z);  // Fill Execution
        /     ([price:1000-til 10] side:(10#1);qty:(950,9#1000);vqty:(1150 1200, 8#1000)); // Expected Depth
        /     (til[4];4#1;4#1;4#1;4#1;(50 100 350 400);(4#100);(4#100);4#1000 999;4#0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (0b;0;()); // Expected IncSelfFill Mock
        /     (0b;0;()); // Expected ApplyFill Mock
        /     (1b;1; // AddTradeEvent: side size price 
        /         enlist((-1;1000;50);z)
        /     ); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ));
        / ("orderbook has agent hidden orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#100;4#1000 999;4#z); // Current Orders
        /     (-1;1450;1b;z);  // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(550,(8#1000));vqty:(750,(8#1000))); // Expected Depth
        /     (til[4];4#1;4#1;4#1;4#1;(4#0);((3#0),50);((3#0),50);4#1000 999;(3#2),0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (0b;0;()); // Expected IncSelfFill Mock
        /     (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
        /         (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;999;50);
        /         (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;1000;800);
        /         (`.account.Account!1;`.instrument.Instrument!0;-1;z;1b;0b;999;450);
        /         (`.account.Account!1;`.instrument.Instrument!0;-1;z;1b;0b;1000;1000)
        /     )); // Expected ApplyFill Mock
        /     (1b;9;( // AddTradeEvent: side size price
        /         ((-1;1000;100);z);
        /         ((-1;1000;100);z);
        /         ((-1;1000;200);z);
        /         ((-1;1000;100);z); // TODO make sure is sorted correctly
        /         ((-1;1000;500);z);
        /         ((-1;999;100);z);
        /         ((-1;999;100);z);
        /         ((-1;999;200);z);
        /         ((-1;999;50);z)
        /     )); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ));
        / ("SELL: orderbook has agent hidden orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#100;4#1000 999;4#z); // Current Orders
        /     (-1;1450;1b;z);  // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(550,(8#1000));vqty:(750,(8#1000))); // Expected Depth
        /     (til[4];4#1;4#1;4#1;4#1;(4#0);((3#0),50);((3#0),50);4#1000 999;(3#2),0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (0b;0;()); // Expected IncSelfFill Mock
        /     (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
        /         (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;999;50);
        /         (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;1000;800);
        /         (`.account.Account!1;`.instrument.Instrument!0;-1;z;1b;0b;999;450);
        /         (`.account.Account!1;`.instrument.Instrument!0;-1;z;1b;0b;1000;1000)
        /     )); // Expected ApplyFill Mock
        /     (1b;9;( // AddTradeEvent: side size price
        /         ((-1;1000;100);z);
        /         ((-1;1000;100);z);
        /         ((-1;1000;200);z);
        /         ((-1;1000;100);z); // TODO make sure is sorted correctly
        /         ((-1;1000;500);z);
        /         ((-1;999;100);z);
        /         ((-1;999;100);z);
        /         ((-1;999;200);z);
        /         ((-1;999;50);z)
        /     )); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ));
        / ("BUY: orderbook has agent hidden orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";(
        /     ((10#-1);1000+til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#-1;4#1;((2#100),(2#400));4#100;4#100;4#1000 1001;4#z); // Current Orders
        /     (1;1450;1b;z);  // Fill Execution
        /     ([price:1001+til 9] side:(9#-1);qty:(550,(8#1000));vqty:(750,(8#1000)));  // Expected Depth
        /     (til[4];4#1;4#1;4#-1;4#1;(4#0);((3#0),50);((3#0),50);4#1000 1001;(3#2),0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (0b;0;()); // Expected IncSelfFill Mock
        /     (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;1b;1001;50);
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;1b;1000;800);
        /         (`.account.Account!1;`.instrument.Instrument!0;1;z;1b;0b;1001;450);
        /         (`.account.Account!1;`.instrument.Instrument!0;1;z;1b;0b;1000;1000)
        /     )); // Expected ApplyFill Mock
        /     (1b;9;( // AddTradeEvent: side size price
        /         ((1;1000;100);z);
        /         ((1;1000;100);z);
        /         ((1;1000;200);z);
        /         ((1;1000;100);z); // TODO make sure is sorted correctly
        /         ((1;1000;500);z);
        /         ((1;1001;100);z);
        /         ((1;1001;100);z);
        /         ((1;1001;200);z);
        /         ((1;1001;50);z)
        /     )); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ));
        / //
        / ("orderbook has agent iceberg orders, lvl1 size > qty, trade doesn't fill agent order, trade execution < agent order offset, fill is agent";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#1;4#1;((2#400),(2#600));4#100;4#100;4#1000 999;4#z); // Current Orders
        /     (-1;200;0b;z);  // Fill Execution
        /     ([price:1000-til 10] side:(10#1);qty:(800,9#1000);vqty:(1000 1200, 8#1000)); // Expected Depth
        /     (til[4];4#1;4#1;4#1;4#1;(200 400 400 600);4#100;4#100;4#1000 999;4#0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (0b;0;()); // Expected IncSelfFill Mock
        /     (1b;1; // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty 
        /         enlist(`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;1000;200)
        /     ); // Expected ApplyFill Mock
        /     (1b;1; // AddTradeEvent: side size price
        /         enlist((-1;1000;200);z)
        /     ); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ));
        / ("orderbook has agent iceberg orders, lvl1 size < qty, trade doesn't fill agent order, trade execution < agent order offset, fill is agent";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#1;4#1;((2#400),(2#600));4#100;4#100;4#999 998;4#z); // Current Orders
        /     (-1;1200;0b;z);  // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(800,8#1000);vqty:(1000 1200, 7#1000)); // Expected Depth
        /     (til[4];4#1;4#1;4#1;4#1;(200 400 400 600);4#100;4#100;4#999 998;4#0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (0b;0;()); // Expected IncSelfFill Mock
        /     (1b;2;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty 
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;999;200);
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;1000;1000)
        /     )); // Expected ApplyFill Mock
        /     (1b;2;( // AddTradeEvent: side size price
        /         ((-1;999;200);z);
        /         ((-1;1000;1000);z)
        /     )); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ));
        / ("orderbook has agent iceberg orders, trade fills agent order, trade execution > agent order offset, fill is agent";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#100;4#1000 999;4#z); // Current Orders
        /     (-1;1450;0b;z);  // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(550,(8#1000));vqty:(750,(8#1000))); // Expected Depth
        /     (til[4];4#1;4#1;4#1;4#1;(4#0);((3#0),50);((3#0),50);4#1000 999;(3#2),0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (1b;1;enlist(`.account.Account!0;4;2300)); // Expected IncSelfFill Mock
        /     (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
        /         (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;999;50);
        /         (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;1000;800);
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;999;450);
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;0b;1000;1000)
        /     )); // Expected ApplyFill Mock
        /     (1b;9;( // AddTradeEvent: side size price
        /         ((-1;1000;100);z);
        /         ((-1;1000;100);z);
        /         ((-1;1000;200);z);
        /         ((-1;1000;100);z); // TODO make sure is sorted correctly
        /         ((-1;1000;500);z);
        /         ((-1;999;100);z);
        /         ((-1;999;100);z);
        /         ((-1;999;200);z);
        /         ((-1;999;50);z)
        /     )); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ));
        / ("orderbook has agent iceberg orders, trade doesn't fill agent order, trade execution < agent order offset, fill is not agent";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#100;4#1000 999;4#z); // Current Orders
        /     (-1;50;0b;z);  // Fill Execution
        /     ([price:1000-til 10] side:(10#1);qty:(950,9#1000);vqty:(1150 1200, 8#1000)); // Expected Depth
        /     (til[4];4#1;4#1;4#1;4#1;(50 100 350 400);(4#100);(4#100);4#1000 999;4#0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (0b;0;()); // Expected IncSelfFill Mock
        /     (0b;0;()); // Expected ApplyFill Mock
        /     (1b;1; // AddTradeEvent: side size price 
        /         enlist((-1;1000;50);z)
        /     ); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ));
        / ("orderbook has agent iceberg orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#100;4#1000 999;4#z); // Current Orders
        /     (-1;1450;1b;z);  // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(550,(8#1000));vqty:(750,(8#1000))); // Expected Depth
        /     (til[4];4#1;4#1;4#1;4#1;(4#0);((3#0),50);((3#0),50);4#1000 999;(3#2),0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (0b;0;()); // Expected IncSelfFill Mock
        /     (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
        /         (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;999;50);
        /         (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;1000;800);
        /         (`.account.Account!1;`.instrument.Instrument!0;-1;z;1b;0b;999;450);
        /         (`.account.Account!1;`.instrument.Instrument!0;-1;z;1b;0b;1000;1000)
        /     )); // Expected ApplyFill Mock
        /     (1b;9;( // AddTradeEvent: side size price
        /         ((-1;1000;100);z);
        /         ((-1;1000;100);z);
        /         ((-1;1000;200);z);
        /         ((-1;1000;100);z); // TODO make sure is sorted correctly
        /         ((-1;1000;500);z);
        /         ((-1;999;100);z);
        /         ((-1;999;100);z);
        /         ((-1;999;200);z);
        /         ((-1;999;50);z)
        /     )); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ));
        / ("SELL: orderbook has agent iceberg orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#1;4#1;((2#100),(2#400));4#100;4#100;4#1000 999;4#z); // Current Orders
        /     (-1;1450;1b;z);  // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(550,(8#1000));vqty:(750,(8#1000))); // Expected Depth
        /     (til[4];4#1;4#1;4#1;4#1;(4#0);((3#0),50);((3#0),50);4#1000 999;(3#2),0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (0b;0;()); // Expected IncSelfFill Mock
        /     (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
        /         (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;999;50);
        /         (`.account.Account!0;`.instrument.Instrument!0;1;z;0b;1b;1000;800);
        /         (`.account.Account!1;`.instrument.Instrument!0;-1;z;1b;0b;999;450);
        /         (`.account.Account!1;`.instrument.Instrument!0;-1;z;1b;0b;1000;1000)
        /     )); // Expected ApplyFill Mock
        /     (1b;9;( // AddTradeEvent: side size price
        /         ((-1;1000;100);z);
        /         ((-1;1000;100);z);
        /         ((-1;1000;200);z);
        /         ((-1;1000;100);z); // TODO make sure is sorted correctly
        /         ((-1;1000;500);z);
        /         ((-1;999;100);z);
        /         ((-1;999;100);z);
        /         ((-1;999;200);z);
        /         ((-1;999;50);z)
        /     )); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ));
        / ("BUY: orderbook has agent iceberg orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";(
        /     ((10#-1);1000+til 10;10#1000); // Current Depth
        /     (til[4];4#1;4#1;4#-1;4#1;((2#100),(2#400));4#100;4#100;4#1000 1001;4#z); // Current Orders
        /     (1;1450;1b;z);  // Fill Execution
        /     ([price:1001+til 9] side:(9#-1);qty:(550,(8#1000));vqty:(750,(8#1000)));  // Expected Depth
        /     (til[4];4#1;4#1;4#-1;4#1;(4#0);((3#0),50);((3#0),50);4#1000 1001;(3#2),0;4#z); // Expected Orders
        /     (0b;0;()); // Expected AddOrderUpdateEvent Mock
        /     (0b;0;()); // Expected IncSelfFill Mock
        /     (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;1b;1001;50);
        /         (`.account.Account!0;`.instrument.Instrument!0;-1;z;0b;1b;1000;800);
        /         (`.account.Account!1;`.instrument.Instrument!0;1;z;1b;0b;1001;450);
        /         (`.account.Account!1;`.instrument.Instrument!0;1;z;1b;0b;1000;1000)
        /     )); // Expected ApplyFill Mock
        /     (1b;9;( // AddTradeEvent: side size price
        /         ((1;1000;100);z);
        /         ((1;1000;100);z);
        /         ((1;1000;200);z);
        /         ((1;1000;100);z); // TODO make sure is sorted correctly
        /         ((1;1000;500);z);
        /         ((1;1001;100);z);
        /         ((1;1001;100);z);
        /         ((1;1001;200);z);
        /         ((1;1001;50);z)
        /     )); // Expected AddTradeEvent Mock
        /     (0b;0;()); // Expected AddDepthEvent Mock
        /     () // Expected Events
        / ))
    );
    .util.testutils.defaultEngineHooks;
    "Process trades from the historical data or agent orders",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders and call Add Events/Fills etc. where necessary"];


// TOOD place limit order, stop order, market order
// TODO Cancel limit order, stop market order, stop limit order
// TODO place limit participate don't initiate (post only)
// TODO place iceberg/hidden order
// TODO commenting
// TODO orderbook update, order update
// TODO amend to different price/
// TODO amend to cross spread
// TODO amend to cross spread stop order
// TODO validation and stop orders
// TODO Check mock called with correct
.qt.Unit[
    ".order.NewOrder";
    {[c]
        p:c[`params];
        delete from `.order.Order;
        delete from `.order.OrderBook; // TODO make general
        .util.testutils.setupDepth[p`cDepth];
        .util.testutils.setupOrders[p`cOrd];
        m:p[`mocks];

        mck1: .qt.M[`.order.ProcessTrade;{[a;b;c;d;e;f]};c];
        mck2: .qt.M[`.pipe.egress.AddOrderCreatedEvent;{[a;b]};c];
        mck3: .qt.M[`.pipe.egress.AddDepthEvent;{[a;b]};c];

        ins:.util.testutils.defaultInstrument;    
        if[count[p[`cIns]]>0;ins^:(p[`cIns])];
        .order.NewOrder[
            ins;
            .util.testutils.defaultAccount;
            p`o];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected ProcessTrade Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected AddOrderCreatedEvent Mock
        .util.testutils.checkMock[mck3;m[2];c];  // Expected AddDepthEvent Mock

        .util.testutils.checkDepth[p[`eDepth];c];
        .util.testutils._checkOrders[
            (`orderId`clId`side`otype`offset`size`leaves`displayqty`price`reduce`time);
            p[`eOrd];c];
    };
    {[p] 
        // TODO account for one record
        ordCols:`orderId`clId`instrumentId`accountId`side`otype`offset`size`leaves`displayqty`price`reduce`time;

        :`cDepth`cOrd`cIns`o`mocks`eDepth`eOrd!(
            p[0];
            .util.testutils.makeOrders[ordCols;p[1]];
            p[2];
            p[3];
            (6_9#p);
            p[4]; // TODO shorten parameterization
            .util.testutils.makeOrders[ordCols;p[5]]);
    };
    ( // TODO sell side check
        ("Place new buy post only limit order at best price, no previous depth or agent orders should update depth";(
            (); // Current Depth
            (); // Current Orders 
            (); // Current Instrument
            `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;999;0b;z); // Order Placed
            ([price:enlist(999)] side:enlist(1);qty:enlist(0);hqty:enlist(0);iqty:enlist(0);vqty:enlist(100)); // Expected Depth
            enlist(1;1;1;1;1;1;0;100;100;100;999;0b;z); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderCreatedEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ));
        ("Place new buy post only limit order, previous depth, no agent orders should update depth";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(100)); // Current Depth
            (); 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;999;0b;z); // Order Placed
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(200)); // Expected Depth
            enlist(1;1;1;1;1;1;100;100;100;100;999;0b;z); // Expected Orders 
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderCreatedEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ));
        ("Place new buy post only limit order, previous depth, multiple agent orders should update depth";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z)
            ); // Current Orders 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(3;1;1;1;1;100;100;999;0b;z); // Fill Execution
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;300;100;100;100;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderCreatedEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ));
        ("Place new buy post only limit order, previous depth, multiple agent orders should update depth (best price-1 level) (not on occupied level)";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z)
            ); 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(3;1;1;1;1;100;100;998;0b;z); // Fill Execution
            ([price:(999 998)] side:(1 1);qty:(100 0);hqty:(0 0);iqty:(0 0);vqty:(300 100)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderCreatedEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ));
        / ("Place new buy post only limit order crosses spread, previous depth, should not invoke processTrade";( // TODO validate
        /     ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
        /     (
        /         (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /         (2;2;1;1;1;1;120;100;100;100;999;0b;z)
        /     ); 
        /    `bestAskPrice`bestBidPrice!(1000;999);
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(3;1;1;1;1;100;100;1000;0b;z); // Fill Execution
        /     ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Expected Depth
        /     (
        /         (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /         (2;2;1;1;1;1;120;100;100;100;999;0b;z)
        /     );  // Expected Orders
        /     (1b;1;()); // Expected ProcessTrade Mock
        /     (0b;0;()); // Expected AddOrderCreatedEvent Mock
        /     (0b;0;())  // Expected AddDepthEvent Mock
        / )); 
        ("Place new buy limit order (not post only) crosses spread, previous depth, should invoke processTrade";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z)
            );
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
            `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(3;1;1;1;1;100;100;1000;0b;z); // Fill Execution
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z)
            ); // Expected Orders
            (1b;1;()); // Expected ProcessTrade Mock
            (0b;0;()); // Expected AddOrderCreatedEvent Mock
            (0b;0;())  // Expected AddDepthEvent Mock
        )); 
        //
        ("Place new iceberg post only limit order, no previous depth, no agent orders should update depth";(
            (); // Current Depth
            (); 
            ();
            `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(1;1;1;1;5;1;100;999;0b;z); // Fill Execution
            ([price:enlist(999)] side:enlist(1);qty:enlist(0);hqty:enlist(0);iqty:enlist(99);vqty:enlist(1)); // Expected Depth
            enlist(1;1;1;1;1;5;0;100;100;1;999;0b;z); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderCreatedEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ));
        ("Place new buy iceberg post only limit order, previous depth, no agent orders should update depth";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(100)); // Current Depth
            ();
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
            `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(1;1;1;1;5;1;100;999;0b;z);  // Order Placed
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(99);vqty:enlist(101)); // Expected Depth
            enlist(1;1;1;1;1;5;100;100;100;1;999;0b;z); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderCreatedEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ));
        ("Place new buy iceberg post only limit order, previous depth, agent orders should update depth";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z)
            );
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
            `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(3;1;1;1;5;1;100;999;0b;z);  // Order Placed
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(99);vqty:enlist(301)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;5;300;100;100;1;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderCreatedEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ));  
        ("Place new buy iceberg post only limit order crosses spread, previous depth, agent orders should invoke ProcessTrade";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z)
            );
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
            `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(3;1;1;1;5;1;100;1000;0b;z);  // Order Placed
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z)
            ); // Expected Orders
            (1b;1;()); // Expected ProcessTrade Mock
            (0b;0;()); // Expected AddOrderCreatedEvent Mock
            (0b;0;())  // Expected AddDepthEvent Mock
        ));  
        //
        ("Place new hidden post only limit order, no previous depth, no agent orders should update depth";(
            (); // Current Depth
            (); 
            ();
            `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(1;1;1;1;4;0;100;999;0b;z); // Fill Execution
            ([price:enlist(999)] side:enlist(1);qty:enlist(0);hqty:enlist(0);iqty:enlist(100);vqty:enlist(0)); // Expected Depth
            enlist(1;1;1;1;1;4;0;100;100;0;999;0b;z); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderCreatedEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ));
        ("Place new buy hidden post only limit order, previous depth, no agent orders should update depth";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(100)); // Current Depth
            ();
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
            `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(1;1;1;1;4;0;100;999;0b;z);  // Order Placed
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(100);vqty:enlist(100)); // Expected Depth
            enlist(1;1;1;1;1;4;100;100;100;0;999;0b;z); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderCreatedEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ));
        ("Place new buy hidden post only limit order, previous depth, agent orders should update depth";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z)
            );
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
            `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(3;1;1;1;4;0;100;999;0b;z);  // Order Placed
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(100);vqty:enlist(300)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;4;300;100;100;0;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderCreatedEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ));  
        ("Place new buy hidden post only limit order crosses spread, previous depth, agent orders should invoke ProcessTrade";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z)
            );
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
            `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(3;1;1;1;4;0;100;1000;0b;z);  // Order Placed
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z)
            ); // Expected Orders
            (1b;1;()); // Expected ProcessTrade Mock
            (0b;0;()); // Expected AddOrderCreatedEvent Mock
            (0b;0;())  // Expected AddDepthEvent Mock
        ));  
        //
        ("Place new buy market order, no previous depth or agent orders should update depth";(
            (); // Current Depth
            (); // Current Orders 
            (); // Current Instrument
            `clId`instrumentId`accountId`side`otype`size`reduce`time!(1;1;1;1;0;100;0b;z); // Order Placed
            (); // Expected Depth
            (); // Expected Orders
            (1b;1;()); // Expected ProcessTrade Mock
            (0b;0;()); // Expected AddOrderCreatedEvent Mock
            (0b;0;())  // Expected AddDepthEvent Mock
        ))
    );
    .util.testutils.defaultEngineHooks;
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];

// TODO test filled amt
// TODO check mock invocations
// TODO test change in display qty, side, price, execInst
// TODO test with clOrdId
.qt.Unit[
    ".order.AmendOrder";
    {[c]
        p:c[`params];
        delete from `.order.Order;
        delete from `.order.OrderBook; // TODO make general
        .util.testutils.setupDepth[p`cDepth];
        .util.testutils.setupOrders[p`cOrd];

        m:p[`mocks];

        mck1: .qt.M[`.order.ProcessTrade;{[a;b;c;d;e;f]};c];
        mck2: .qt.M[`.pipe.egress.AddOrderUpdatedEvent;{[a;b]};c];
        mck3: .qt.M[`.pipe.egress.AddOrderCancellledEvent;{[a;b]};c];
        mck4: .qt.M[`.pipe.egress.AddDepthEvent;{[a;b]};c];

        .order.AmendOrder[
            .util.testutils.defaultInstrument;
            .util.testutils.defaultAccount;
            p`o];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected ProcessTrade Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected AddOrderUpdatedEvent Mock
        .util.testutils.checkMock[mck3;m[2];c];  // Expected AddOrderCancellledEvent Mock
        .util.testutils.checkMock[mck4;m[3];c];  // Expected AddDepthEvent Mock

        .util.testutils.checkDepth[p[`eDepth];c];
        .util.testutils._checkOrders[
            (`orderId`clId`side`otype`offset`size`leaves`displayqty`price`reduce`time);
            p[`eOrd];c];
    };
    {[p] 
        // TODO account for one record
        ordCols:`orderId`clId`instrumentId`accountId`side`otype`offset`size`leaves`displayqty`price`reduce`time;

        :`cDepth`cOrd`cIns`o`mocks`eDepth`eOrd!(
            p[0];
            .util.testutils.makeOrders[ordCols;p[1]];
            p[2];
            p[3];
            (6_10#p);
            p[4]; // TODO shorten parameterization
            .util.testutils.makeOrders[ordCols;p[5]]);
    };
    (
        // Decreasing in size stays at same price
        ("Amend limit order (first in queue), smaller than previous, should update offsets, depth etc.";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;230;100;100;100;999;0b;z)
            ); // Current Orders 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `orderId`clId`size`time!(1;1;10;z); // Fill Execution
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(310)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;10;10;999;0b;z);
                (2;2;1;1;1;1;30;100;100;100;999;0b;z);
                (3;3;1;1;1;1;140;100;100;100;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderUpdatedEvent Mock
            (0b;0;()); // Expected AddOrderCancellledEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        )); 
        ("Amend limit order (second in queue), smaller than previous, should update offsets, depth etc.";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;230;100;100;100;999;0b;z)
            ); // Current Orders 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `orderId`clId`size`time!(2;2;10;z); // Fill Execution
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(310)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;10;10;999;0b;z);
                (3;3;1;1;1;1;140;100;100;100;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderUpdatedEvent Mock
            (0b;0;()); // Expected AddOrderCancellledEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        )); 
        ("Amend limit order (last in queue), smaller than previous, should update offsets, depth etc.";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;230;100;100;100;999;0b;z)
            ); // Current Orders 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `orderId`clId`size`time!(3;3;10;z); // Fill Execution
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(310)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;230;100;10;10;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderUpdatedEvent Mock
            (0b;0;()); // Expected AddOrderCancellledEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ));
        // Increasing in size stays at same price
        ("Amend limit order (first in queue), larger than previous, should update offsets, depth etc.";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;230;100;100;100;999;0b;z)
            ); // Current Orders 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `orderId`clId`size`time!(1;1;110;z); // Fill Execution
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(410)); // Expected Depth
            (
                (1;1;1;1;1;1;300;100;110;110;999;0b;z);
                (2;2;1;1;1;1;20;100;100;100;999;0b;z);
                (3;3;1;1;1;1;130;100;100;100;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderUpdatedEvent Mock
            (0b;0;()); // Expected AddOrderCancellledEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        )); 
        ("Amend limit order (second in queue), larger than previous, should update offsets, depth etc.";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;230;100;100;100;999;0b;z)
            ); // Current Orders 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `orderId`clId`size`time!(2;2;110;z); // Fill Execution
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(410)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;300;100;110;110;999;0b;z);
                (3;3;1;1;1;1;130;100;100;100;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderUpdatedEvent Mock
            (0b;0;()); // Expected AddOrderCancellledEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        )); 
        ("Amend limit order (last in queue), larger than previous, should update offsets, depth etc.";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;230;100;100;100;999;0b;z)
            ); // Current Orders 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `orderId`clId`size`time!(3;3;110;z); // Fill Execution
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(410)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;300;100;110;110;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderUpdatedEvent Mock
            (0b;0;()); // Expected AddOrderCancellledEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ));
        // Different price same side no orders on new level (same size)
        ("Amend limit order (first in queue), different price same side, should update offsets, depth etc.";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;230;100;100;100;999;0b;z)
            ); // Current Orders 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `orderId`clId`price`time!(1;1;998;z); // Fill Execution
            ([price:(999 998)] side:(1 1);qty:(100 0);hqty:(0);iqty:(0);vqty:(300 100)); // Expected Depth
            (
                (1;1;1;1;1;1;0;100;100;100;998;0b;z);
                (2;2;1;1;1;1;20;100;100;100;999;0b;z);
                (3;3;1;1;1;1;130;100;100;100;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderUpdatedEvent Mock
            (0b;0;()); // Expected AddOrderCancellledEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        )); 
        ("Amend limit order (second in queue), different price same side, should update offsets, depth etc.";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;230;100;100;100;999;0b;z)
            ); // Current Orders 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `orderId`clId`price`time!(2;2;998;z); // Fill Execution
            ([price:(999 998)] side:(1 1);qty:(100 0);hqty:(0);iqty:(0);vqty:(300 100)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;0;100;100;100;998;0b;z);
                (3;3;1;1;1;1;130;100;100;100;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderUpdatedEvent Mock
            (0b;0;()); // Expected AddOrderCancellledEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        )); 
        ("Amend limit order (last in queue), different price same side, should update offsets, depth etc.";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;230;100;100;100;999;0b;z)
            ); // Current Orders 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `orderId`clId`price`time!(3;3;998;z); // Fill Execution
            ([price:(999 998)] side:(1 1);qty:(100 0);hqty:(0);iqty:(0);vqty:(300 100)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;0;100;100;100;998;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderUpdatedEvent Mock
            (0b;0;()); // Expected AddOrderCancellledEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ));
        // Amend to zero (Cancellation)
        ("Amend limit order (first in queue) to zero, different price same side, should update offsets, depth etc.";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;230;100;100;100;999;0b;z)
            ); // Current Orders 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `orderId`clId`size`time!(1;1;0;z); // Fill Execution
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Expected Depth
            (
                (2;2;1;1;1;1;20;100;100;100;999;0b;z);
                (3;3;1;1;1;1;130;100;100;100;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderUpdatedEvent Mock
            (0b;0;()); // Expected AddOrderCancellledEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        )); 
        ("Amend limit order (second in queue) to zero, different price same side, should update offsets, depth etc.";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;230;100;100;100;999;0b;z)
            ); // Current Orders 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `orderId`clId`size`time!(2;2;0;z); // Fill Execution
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (3;3;1;1;1;1;130;100;100;100;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderUpdatedEvent Mock
            (0b;0;()); // Expected AddOrderCancellledEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        )); 
        ("Amend limit order (last in queue) to zero, different price same side, should update offsets, depth etc.";(
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Current Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z);
                (3;3;1;1;1;1;230;100;100;100;999;0b;z)
            ); // Current Orders 
            `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
           `orderId`clId`size`time!(3;3;0;z); // Fill Execution
            ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Expected Depth
            (
                (1;1;1;1;1;1;10;100;100;100;999;0b;z);
                (2;2;1;1;1;1;120;100;100;100;999;0b;z)
            ); // Expected Orders
            (0b;0;()); // Expected ProcessTrade Mock
            (1b;1;()); // Expected AddOrderUpdatedEvent Mock
            (0b;0;()); // Expected AddOrderCancellledEvent Mock
            (1b;1;())  // Expected AddDepthEvent Mock
        ))
        / ("Amend limit order, larger than previous, should push to back of queue, update offsets, depth etc.";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (); ();
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;1000;0b;z); // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
        /     (); // Expected Orders
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (0b;0;()); // Expected AddOrderCreatedEvent Mock


        /     (0b;0;())  // Expected AddDepthEvent Mock
        / ));
        / ("Amend limit order to zero, should remove order from .order.Order, should update offsets, depth etc.";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (); ();
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;1000;0b;z); // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
        /     (); // Expected Orders
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (0b;0;()); // Expected AddOrderCreatedEvent Mock


        /     (0b;0;())  // Expected AddDepthEvent Mock
        / ));
        / ("Amend iceberg limit order, smaller than previous, should update offsets, depth etc.";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (); ();
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;1000;0b;z); // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
        /     (); // Expected Orders
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (0b;0;()); // Expected AddOrderCreatedEvent Mock


        /     (0b;0;())  // Expected AddDepthEvent Mock
        / ));
        / ("Amend iceberg limit order, larger than previous, should push to back of queue, update offsets, depth etc.";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (); ();
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;1000;0b;z); // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
        /     (); // Expected Orders
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (0b;0;()); // Expected AddOrderCreatedEvent Mock


        /     (0b;0;())  // Expected AddDepthEvent Mock
        / ));
        / ("Amend iceberg limit order to zero, should remove order from .order.Order, should update offsets, depth etc.";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (); ();
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;1000;0b;z); // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
        /     (); // Expected Orders
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (0b;0;()); // Expected AddOrderCreatedEvent Mock


        /     (0b;0;())  // Expected AddDepthEvent Mock
        / ));
        / ("Amend hidden limit order, smaller than previous, should update offsets, depth etc.";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (); ();
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;1000;0b;z); // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
        /     (); // Expected Orders
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (0b;0;()); // Expected AddOrderCreatedEvent Mock


        /     (0b;0;())  // Expected AddDepthEvent Mock
        / ));
        / ("Amend hidden limit order, larger than previous, should push to back of queue, update offsets, depth etc.";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (); ();
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;1000;0b;z); // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
        /     (); // Expected Orders
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (0b;0;()); // Expected AddOrderCreatedEvent Mock


        /     (0b;0;())  // Expected AddDepthEvent Mock
        / ));
        / ("Amend hidden limit order to zero, should remove order from .order.Order, should update offsets, depth etc.";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (); ();
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;1000;0b;z); // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
        /     (); // Expected Orders
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (0b;0;()); // Expected AddOrderCreatedEvent Mock


        /     (0b;0;())  // Expected AddDepthEvent Mock
        / ));
        / ("Amend stop limit order to zero, should remove order from .order.Order";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (); ();
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;1000;0b;z); // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
        /     (); // Expected Orders
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (0b;0;()); // Expected AddOrderCreatedEvent Mock


        /     (0b;0;())  // Expected AddDepthEvent Mock
        / ));
        / ("Amend stop market order to zero, should remove order from .order.Order";(
        /     ((10#1);1000-til 10;10#1000); // Current Depth
        /     (); ();
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;1000;0b;z); // Fill Execution
        /     ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
        /     (); // Expected Orders
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (0b;0;()); // Expected AddOrderCreatedEvent Mock


        /     (0b;0;())  // Expected AddDepthEvent Mock
        / ))
    );
    .util.testutils.defaultEngineHooks;
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];


.qt.SkpBes[(60 + til[28])];


// TODO mock place order event
// TODO mock order update event
// 

.qt.Unit[
    ".order.ExecuteStop";
    {[c]
        p:c[`params];

        .util.testutils.setupDepth[p`cDepth];
        .util.testutils.setupOrders[p`cOrd];

        m:p[`mocks];

        mck1: .qt.M[`.pipe.ingress.AddPlaceOrderEvent;{[a;b]};c];
        mck2: .qt.M[`.pipe.egress.AddOrderUpdateEvent;{[a;b]};c];

        a:p`args;
        .order.ExecuteStop[.util.testutils.defaultInstrument;a`time;a`o];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected AddPlaceOrderEvent Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected AddOrderUpdateEvent Mock

        .util.testutils.checkDepth[p[`eDepth];c];
        .util.testutils.checkOrders[p[`eOrd];c];
    };
    {[p] 
        // TODO account for one record
        ordCols:`clId`instrumentId`accountId`side`otype`offset`size`price`time;
        bookCols:`side`price`qty;

        :`cDepth`cOrd`cIns`o`mocks`eDepth`eOrd!(
            p[0];
            p[1];
            p[2];
            p[3];
            (6_11#p);
            p[4]; // TODO shorten parameterization
            p[5]);
    };
    (
        ("Amend stop limit order to zero, should remove order from .order.Order";(
            ((10#1);1000-til 10;10#1000); // Current Depth
            (); ();
            (-1;1500;0b;z); // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddPlaceOrderEvent Mock
            (0b;0;()) // Expected AddOrderUpdateEvent Mock
        ));
        ("Amend stop market order to zero, should remove order from .order.Order";(
            ((10#1);1000-til 10;10#1000); // Current Depth
            (); ();
            (-1;1500;0b;z); // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddPlaceOrderEvent Mock
            (0b;0;()) // Expected AddOrderUpdateEvent Mock
        ))
    );
    .util.testutils.defaultEngineHooks;
    "Global function for placing stop orders back into event pipe and removing when triggered"];


.qt.Unit[
    ".order.CheckStopOrders";
    {[c]
        p:c[`params];

        .util.testutils.setupDepth[p`cDepth];
        .util.testutils.setupOrders[p`cOrd];

        m:p[`mocks];

        mck1: .qt.M[`.order.ExecuteStop;{[a;b]};c];

        a:p`args;
        .order.CheckStopOrders[.util.testutils.defaultInstrument;a`time];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected ExecuteStop Mock

        .util.testutils.checkDepth[p[`eDepth];c];
        .util.testutils.checkOrders[p[`eOrd];c];
    };
    {[p] 
        // TODO account for one record
        ordCols:`clId`instrumentId`accountId`side`otype`offset`size`price`time;
        bookCols:`side`price`qty;

        :`cDepth`cOrd`cIns`o`mocks`eDepth`eOrd!(
            p[0];
            p[1];
            p[2];
            p[3];
            (6_11#p);
            p[4]; // TODO shorten parameterization
            p[5]);
    };
    (
        ("Amend stop limit order to zero, should remove order from .order.Order";(
            ((10#1);1000-til 10;10#1000); // Current Depth
            (); ();
            (-1;1500;0b;z); // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddPlaceOrderEvent Mock
            (0b;0;()) // Expected AddOrderUpdateEvent Mock
        ));
        ("Amend stop market order to zero, should remove order from .order.Order";(
            ((10#1);1000-til 10;10#1000); // Current Depth
            (); ();
            (-1;1500;0b;z); // Fill Execution
            ([price:999-til 9] side:(9#1);qty:(500,8#1000);vqty:(500,8#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddPlaceOrderEvent Mock
            (0b;0;()) // Expected AddOrderUpdateEvent Mock
        ))
    );
    .util.testutils.defaultEngineHooks;
    "Global function for checking stop orders"];

 
.qt.RunTests[];