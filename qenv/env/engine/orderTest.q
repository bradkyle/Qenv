

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
// TODO replicate cases without hidden orders!

.qt.Unit[
    ".order.ProcessDepth";
    {[c]
        p:c[`params];
        delete from `.order.OrderBook;
        delete from `.order.Order;
        .order.OrderBook,:p[`cDepth];
        .util.testutils.setupOrders[0^p`cOrd];

        m:p`mocks;
        
        mck1: .qt.M[`.order.applyOffsetUpdates;{[a;b;c;d]};c];
        mck2: .qt.M[`.order.applyBookUpdates;{[a;b;c;d;e;f;g]};c];
        mck3: .qt.M[`.order.pruneBook;{};c];
        mck4: .qt.M[`.order.pruneOrders;{};c];

        // instrument;nxt:(side;price;qty;hqty;time)
        .order.ProcessDepth[.util.testutils.defaultInstrument;p`nxt];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyOffsetUpdates Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyBookUpdates Mock

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

        :`cDepth`cOrd`nxt`mocks!(
            p[0];
            .util.testutils.makeOrders[ordCols[p[1]];flip p[1]];
            nxt;
            (3_5#p));
    };
    (
       (("0a) ProcessDepth BUY+SELL: (No hidden or Iceberg qty) differing update prices by time,",
            "repletes order spread during update, many order offset prices");(
            ( // Current Depth  
                [price:1000-til 10] 
                side:(10#1);
                qty:10#1000;
                hqty:((10 20),(8#10));
                iqty:((170 170),(8#0)); // TODO fix
                vqty:((1030 1030),(8#1000)) // TODO fix
            ); 
            (   // Current Orders  
                til[4];4#0;4#1;4#1;4#1; // `orderId`instrumentId`accountId`side`otype 
                ((2#400),(2#600)); // offset
                4#100; // leaves
                ((2#10),(2#20)); // displayqty
                4#1000 999; // price
                4#z // time
            );
            (   // Depth Update
                ((5#-1),(5#1)); // side
                ((1000 1001 1002 1001 1002),(999 998 997 997 998)); // price
                ((0 0 0 1000 1000),(0 0 0 1000 1000)); // NQTY
                (10#0); // NHQTY
                (sc[z] 0 0 0 1 1 0 0 0 1 1) // time
            ); 
            (1b;1;( // Expected .order.applyOffsetUpdates Mock
                enlist flip(
                    (1;999;20;z); // TODO check
                    (3;999;520;z);
                    (0;1000;400;z);
                    (2;1000;600;z)
                )
            ));    
            (1b;1;( // Expected .order.applyBookUpdates Mock
                enlist((
                    1000 1001 1002 999 998 997 1000; // price
                    (3#-1),(4#1);   // side
                    (0 1000 1000 0 1000 1000 0); // qty
                    (20 10 10 0 0 0 0); // hqty
                    (170 ,(6#0)); // iqty
                    (0 1000 1000 30 1000 1000 30); // vqty
                    (sc[z] 0 1 1 0 1 1 0))) // time
            ))     
        ));
        (("0b) ProcessDepth BUY+SELL: many levels with many iceberg orders at ",
            "same offset interval with hidden qty, price is removed across all levels fully (1000)");(
            (   // Current Depth
                [price:((999-til 5),(1000+til 5))] 
                side:(5#1),(5#-1);
                qty:(10#1000);
                hqty:((10, (4#0)),(10, (4#0)));
                iqty:(10#0);
                vqty:(10#1200)
            );  
            (   // Current Orders
                til[20];20#1;20#1; // `orderId`instrumentId`accountId
                ((10#-1),(10#1)); // side
                20#1; // otype
                (20#100 400); // offset
                20#100; // leaves
                20#100; // displayqty
                ((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5))); // price
                20#z // time
            );  
            (   // Depth Update
                ((20#1),(20#-1));
                ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
                (40#0 1000); // NQTY
                ((10, (19#0)),(10, (19#0))); // NHQTY
                (sc[z] (40#0 1)) // TIME
            ); 
            (1b;1;( // Expected .order.applyOffsetUpdates Mock
                enlist flip(
                    (1;999;20;z); // TODO check
                    (3;999;520;z);
                    (0;1000;400;z);
                    (2;1000;600;z)
                )
            ));    
            (1b;1;( // Expected .order.applyBookUpdates Mock
                enlist((
                    1000 1001 1002 999 998 997 1000; // price
                    (3#-1),(4#1);   // side
                    (0 1000 1000 0 1000 1000 0); // qty
                    (20 10 10 0 0 0 0); // hqty
                    (170 ,(6#0)); // iqty
                    (0 1000 1000 30 1000 1000 30); // vqty
                    (sc[z] 0 1 1 0 1 1 0))) // time
            ))     
        ));
        (("0c) ProcessDepth BUY+SELL: many levels with many orders at same offset interval,",
          "price is removed across all levels partially (900) not hidden or iceberg, no hidden update");(
            (   // Current Depth
                [price:((999-til 5),(1000+til 5))] 
                side:(5#1),(5#-1);
                qty:(10#1000);
                hqty:((10, (4#0)),(10, (4#0)));
                iqty:(10#0);
                vqty:(10#1200)
            );  
            (   // Current Orders
                til[20];20#1;20#1; // `orderId`instrumentId`accountId
                ((10#-1),(10#1)); // side
                20#1; // otype
                (20#100 400); // offset
                20#100; // leaves
                20#100; // displayqty
                ((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5))); // price
                20#z // time
            ); 
            ( // Depth Update
                ((20#1),(20#-1));
                ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
                (40#900 1000);
                (sc[z] (40#0 1))
            );
            (1b;1;( // Expected .order.applyOffsetUpdates Mock
                enlist flip(
                    (1;999;20;z); // TODO check
                    (3;999;520;z);
                    (0;1000;400;z);
                    (2;1000;600;z)
                )
            ));    
            (1b;1;( // Expected .order.applyBookUpdates Mock
                enlist((
                    1000 1001 1002 999 998 997 1000; // price
                    (3#-1),(4#1);   // side
                    (0 1000 1000 0 1000 1000 0); // qty
                    (20 10 10 0 0 0 0); // hqty
                    (170 ,(6#0)); // iqty
                    (0 1000 1000 30 1000 1000 30); // vqty
                    (sc[z] 0 1 1 0 1 1 0))) // time
            ))     
        ));
        (("0d) ProcessDepth BUY+SELL: many levels with many orders at same offset interval,",
          "price is removed across all levels partially (900) not hidden or iceberg, no hidden update");(
            (   // Current Depth
                [price:((999-til 5),(1000+til 5))] 
                side:(5#1),(5#-1);
                qty:(10#1000);
                hqty:((10, (4#0)),(10, (4#0)));
                iqty:(10#0);
                vqty:(10#1200)
            );  
            (   // Current Orders
                til[20];20#1;20#1; // `orderId`instrumentId`accountId
                ((10#-1),(10#1)); // side
                20#1; // otype
                (20#100 400); // offset
                20#100; // leaves
                20#100; // displayqty
                ((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5))); // price
                20#z // time
            ); 
            ( // Depth Update
                ((20#1),(20#-1));
                ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
                (40#900 1000);
                (sc[z] (40#0 1))
            );
            (1b;1;( // Expected .order.applyOffsetUpdates Mock
                enlist flip(
                    (1;999;20;z); // TODO check
                    (3;999;520;z);
                    (0;1000;400;z);
                    (2;1000;600;z)
                )
            ));    
            (1b;1;( // Expected .order.applyBookUpdates Mock
                enlist((
                    1000 1001 1002 999 998 997 1000; // price
                    (3#-1),(4#1);   // side
                    (0 1000 1000 0 1000 1000 0); // qty
                    (20 10 10 0 0 0 0); // hqty
                    (170 ,(6#0)); // iqty
                    (0 1000 1000 30 1000 1000 30); // vqty
                    (sc[z] 0 1 1 0 1 1 0))) // time
            ))     
        ));
        (("0e) ProcessDepth BUY+SELL:differing update prices by time, crosses order spread during update",
          "(best price increases during update) finishes past order level (past final spread) with hidden qty");(
            (   // Current Depth
                [price:((999-til 5),(1000+til 5))] 
                side:(5#1),(5#-1);
                qty:(10#1000);
                hqty:((10, (4#0)),(10, (4#0)));
                iqty:(10#0);
                vqty:(10#1200)
            );   
            (   // Current Orders
                til[20];20#1;20#1; // `orderId`instrumentId`accountId
                ((10#-1),(10#1)); // side
                20#1; // otype
                (20#100 400); // offset
                20#100; // leaves
                20#100; // displayqty
                ((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5))); // price
                20#z // time
            ); 
            (  // Depth Update
                ((4#-1),(2#1));
                ((1000 1001 1002 1002),(1000 1001));
                ((0 0 0 1000),(1000 1000));
                (sc[z] 0 0 0 1 0 0)
            );
            (1b;1;( // Expected .order.applyOffsetUpdates Mock
                enlist flip(
                    (1;999;20;z); // TODO check
                    (3;999;520;z);
                    (0;1000;400;z);
                    (2;1000;600;z)
                )
            ));    
            (1b;1;( // Expected .order.applyBookUpdates Mock
                enlist((
                    1000 1001 1002 999 998 997 1000; // price
                    (3#-1),(4#1);   // side
                    (0 1000 1000 0 1000 1000 0); // qty
                    (20 10 10 0 0 0 0); // hqty
                    (170 ,(6#0)); // iqty
                    (0 1000 1000 30 1000 1000 30); // vqty
                    (sc[z] 0 1 1 0 1 1 0))) // time
            ))     
        ));
        (("0f) ProcessDepth BUY+SELL:differing update prices by time, crosses order spread during update ",
          "(best price decreases during update) finishes past order level (past final spread)");(
            (   // Current Depth
                [price:((999-til 5),(1000+til 5))] 
                side:(5#1),(5#-1);
                qty:(10#1000);
                hqty:((10, (4#0)),(10, (4#0)));
                iqty:(10#0);
                vqty:(10#1200)
            );    
            (   // Current Orders
                til[20];20#1;20#1; // `orderId`instrumentId`accountId
                ((10#-1),(10#1)); // side
                20#1; // otype
                (20#100 400); // offset
                20#100; // leaves
                20#100; // displayqty
                ((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5))); // price
                20#z // time
            ); 
            (  // Depth Update
                ((4#1),(2#-1));
                ((999 998 997 997),(999 998));
                ((0 0 0 1000),(1000 1000));
                (sc[z] 0 0 0 1 0 0)
            );   
            (1b;1;( // Expected .order.applyOffsetUpdates Mock
                enlist flip(
                    (1;999;20;z); // TODO check
                    (3;999;520;z);
                    (0;1000;400;z);
                    (2;1000;600;z)
                )
            ));    
            (1b;1;( // Expected .order.applyBookUpdates Mock
                enlist((
                    1000 1001 1002 999 998 997 1000; // price
                    (3#-1),(4#1);   // side
                    (0 1000 1000 0 1000 1000 0); // qty
                    (20 10 10 0 0 0 0); // hqty
                    (170 ,(6#0)); // iqty
                    (0 1000 1000 30 1000 1000 30); // vqty
                    (sc[z] 0 1 1 0 1 1 0))) // time
            ))     
        ));
        (("0g) ProcessDepth BUY+SELL:differing update prices by time, crosses order spread during update",
          "(best price increases during update) finishes past order level (within final spread)");(
            (   // Current Depth
                [price:((999-til 5),(1000+til 5))] 
                side:(5#1),(5#-1);
                qty:(10#1000);
                hqty:((10, (4#0)),(10, (4#0)));
                iqty:(10#0);
                vqty:(10#1200)
            );  
            (   // Current Orders
                til[20];20#1;20#1; // `orderId`instrumentId`accountId
                ((10#-1),(10#1)); // side
                20#1; // otype
                (20#100 400); // offset
                20#100; // leaves
                20#100; // displayqty
                ((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5))); // price
                20#z // time
            ); 
            (  // Depth Update
                ((4#-1),(4#1));
                ((1000 1001 1002 1002),(1000 1001 1000 1001));
                ((0 0 0 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 0 0 1 1)
            );   
            (1b;1;( // Expected .order.applyOffsetUpdates Mock
                enlist flip(
                    (1;999;20;z); // TODO check
                    (3;999;520;z);
                    (0;1000;400;z);
                    (2;1000;600;z)
                )
            ));    
            (1b;1;( // Expected .order.applyBookUpdates Mock
                enlist((
                    1000 1001 1002 999 998 997 1000; // price
                    (3#-1),(4#1);   // side
                    (0 1000 1000 0 1000 1000 0); // qty
                    (20 10 10 0 0 0 0); // hqty
                    (170 ,(6#0)); // iqty
                    (0 1000 1000 30 1000 1000 30); // vqty
                    (sc[z] 0 1 1 0 1 1 0))) // time
            ))     
        ));
        (("0h) ProcessDepth BUY+SELL:differing update prices by time, crosses order spread during update ",
          "(best price decreases during update) finishes past order level (past final spread)");( // incoming orders should be participate don't initiate
            (   // Current Depth
                [price:((999-til 5),(1000+til 5))] 
                side:(5#1),(5#-1);
                qty:(10#1000);
                hqty:((10, (4#0)),(10, (4#0)));
                iqty:(10#0);
                vqty:(10#1200)
            );    
            (   // Current Orders
                til[20];20#1;20#1; // `orderId`instrumentId`accountId
                ((10#-1),(10#1)); // side
                20#1; // otype
                (20#100 400); // offset
                20#100; // leaves
                20#100; // displayqty
                ((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5))); // price
                20#z // time
            ); 
            (  // Depth Update
                ((4#1),(4#-1));
                ((999 998 997 997),(999 998 999 998));
                ((0 0 0 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 0 0 1 1)
            );  
            (1b;1;( // Expected .order.applyOffsetUpdates Mock
                enlist flip(
                    (1;999;20;z); // TODO check
                    (3;999;520;z);
                    (0;1000;400;z);
                    (2;1000;600;z)
                )
            ));    
            (1b;1;( // Expected .order.applyBookUpdates Mock
                enlist((
                    1000 1001 1002 999 998 997 1000; // price
                    (3#-1),(4#1);   // side
                    (0 1000 1000 0 1000 1000 0); // qty
                    (20 10 10 0 0 0 0); // hqty
                    (170 ,(6#0)); // iqty
                    (0 1000 1000 30 1000 1000 30); // vqty
                    (sc[z] 0 1 1 0 1 1 0))) // time
            ))     
        ));
        (("0i) ProcessDepth BUY+SELL:differing update prices by time, crosses order spread during update ",
          "(best price decreases during update) finishes past order level (past final spread)");(
            (   // Current Depth
                [price:((999-til 5),(1000+til 5))] 
                side:(5#1),(5#-1);
                qty:(10#1000);
                hqty:((10, (4#0)),(10, (4#0)));
                iqty:(10#0);
                vqty:(10#1200) // TODO update
            );  
            (   // Current Orders
                til[4];4#1;4#1; // `orderId`instrumentId`accountId
                ((2#-1),(2#1)); // side
                4#1; // otype
                (4#100 400); // offset
                4#100; // leaves
                4#100; // displayqty
                (2#1001),(2#998); // price
                4#z // time
            ); 
            (  // Depth Update
                ((5#-1),(5#1));
                ((1000 1001 1002 1001 1002),(999 998 997 998 997));
                ((0 0 0 1000 1000),(0 0 0 1000 1000));
                (sc[z] 0 0 0 1 1 0 0 0 1 1)
            );  
            (1b;1;( // Expected .order.applyOffsetUpdates Mock
                enlist flip(
                    (1;999;20;z); // TODO check
                    (3;999;520;z);
                    (0;1000;400;z);
                    (2;1000;600;z)
                )
            ));    
            (1b;1;( // Expected .order.applyBookUpdates Mock
                enlist((
                    1000 999 1001 998 1002 997; // price
                    -1 1 -1 1 -1 1;   // side
                    0 0 1000 1000 1000 1000; // qty
                    10 10 0 0 0 0; // hqty
                    0 0 0 0 0 0; // iqty
                    0 0 1200 1200 1000 1000; // vqty
                    (sc[z] 0 0 0 0 1 1))) // time
            ))     
        ));
        (("0j) ProcessDepth BUY+SELL:differing update prices by time, crosses order spread during update",
          "(best price decreases during update) finishes at order level");( // TODO make different
            (   // Current Depth
                [price:((999-til 5),(1000+til 5))] 
                side:(5#1),(5#-1);
                qty:(10#1000);
                hqty:((10, (4#0)),(10, (4#0)));
                iqty:(10#0);
                vqty:(10#1200) // TODO update
            );
            (   // Current Orders
                til[4];4#1;4#1; // `orderId`instrumentId`accountId
                ((2#1),(2#-1)); // side
                4#1; // otype
                (4#100 400); // offset
                4#100; // leaves
                4#100; // displayqty
                (2#998),(2#1001); // price Clearly missing logic here
                4#z // time
            ); 
            (  // Depth Update
                ((5#1),(4#-1));
                ((999 998 997 997 998),(999 998 999 998));
                ((0 0 0 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 0 0 1 1)
            );  
            (1b;1;( // Expected .order.applyOffsetUpdates Mock
                enlist flip(
                    (0;998;0;z); // TODO check
                    (1;998;100;z)
                )
            ));    
            (1b;1;( // Expected .order.applyBookUpdates Mock
                enlist((
                    999 998 997 999 998; // price
                    1 1 1 -1 -1;   // side
                    0 1000 1000 0 0; // qty
                    10 0 0 0 0; // hqty
                    0 0 0 0 0; // iqty
                    0 1200 1000 0 0; // vqty
                    (sc[z] 0 0 1 1 1))) // time
            ))     
        ));
        (("0k) ProcessDepth BUY+SELL:differing update prices by time doesn't cross spread",
         "(best price increases during update)");(
            (   // Current Depth
                [price:((999-til 5),(1000+til 5))] 
                side:(5#1),(5#-1);
                qty:(10#1000);
                hqty:((10, (4#0)),(10, (4#0)));
                iqty:(10#0);
                vqty:(10#1200) // TODO update
            );
            (   // Current Orders
                til[4];4#1;4#1; // `orderId`instrumentId`accountId
                ((2#1),(2#-1)); // side
                4#1; // otype
                (4#100 400); // offset
                4#100; // leaves
                4#100; // displayqty
                (2#998),(2#1001); // price Clearly missing logic here
                4#z // time
            ); 
            (  // Depth Update
                ((5#1),(4#-1));
                ((999 998 997 997 998),(999 998 999 998));
                ((0 0 0 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 0 0 1 1)
            );  
            (1b;1;( // Expected .order.applyOffsetUpdates Mock
                enlist flip(
                    (0;998;0;z); // TODO check
                    (1;998;100;z)
                )
            ));    
            (1b;1;( // Expected .order.applyBookUpdates Mock
                enlist((
                    999 998 997 999 998; // price
                    1 1 1 -1 -1;   // side
                    0 1000 1000 0 0; // qty
                    10 0 0 0 0; // hqty
                    0 0 0 0 0; // iqty
                    0 1200 1000 0 0; // vqty
                    (sc[z] 0 0 1 1 1))) // time
            ))     
        ));
        (("0l) ProcessDepth BUY+SELL:No hidden or iceberg qty differing update prices ",
         "by time doesn't cross spread (best price decreases during update)");( // TODO check with no agent order qty behind order
            (   // Current Depth
                [price:((999-til 5),(1000+til 5))] 
                side:(5#1),(5#-1);
                qty:(10#1000);
                hqty:((10, (4#0)),(10, (4#0)));
                iqty:(10#0);
                vqty:(10#1200) // TODO update
            );  
            (   // Current Orders
                til[4];4#1;4#1; // `orderId`instrumentId`accountId
                ((2#1),(2#-1)); // side
                4#1; // otype
                (4#100 400); // offset
                4#100; // leaves
                4#100; // displayqty
                (2#998),(2#1001); // price Clearly missing logic here
                4#z // time
            ); 
            (  // Depth Update (best ask price jumps)
                ((4#1),(2#-1));
                ((999 998 998 999),(999 999));
                ((0 0 1000 1000),(1000 0));
                (sc[z] 0 0 2 2 0 1)
            );     
            (1b;1;( // Expected .order.applyOffsetUpdates Mock
                enlist flip(
                    (0;998;0;z); /
                    (1;998;100;z)
                )
            ));    
            (1b;1;( // Expected .order.applyBookUpdates Mock
                enlist((
                    998 999 999; // price
                    1 -1 1;   // side
                    (1000 0 1000); // qty
                    (0 10 0); // hqty TODO (hqty at the level will be overwritten by the price change?)
                    (0 0 0); // iqty
                    (1200 0 1000); // vqty
                    (sc[z] 0 1 2))) // time
            ))     
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
// TODO iceberg/hidden order logic
// TODO hidden orders from agent, hidden orders from data.
// TODO drifts out of book bounds
// TODO no previous depth however previous orders.
// TODO fills 3 levels
// TODO test different instrument
// TODO test with different accounts
.qt.Unit[
    ".order.ProcessTrade";
    {[c]
        p:c[`params];
        delete from `.order.Order;
        delete from `.order.OrderBook; // TODO make general
        .order.OrderBook,:p`cDepth;
        .util.testutils.setupOrders[p`cOrd];

        m:p[`mocks];

        mck1: .qt.M[`.order.applyNewTrades;{[a;b;c;d]};c];
        mck2: .qt.M[`.order.applyOrderUpdates;{[a;b;c;d;e;f;g]};c];
        mck3: .qt.M[`.order.applyTakerFills;{[a;b;c;d;e;f;g]};c];
        mck4: .qt.M[`.order.applyMakerFills;{[a;b;c;d;e;f;g]};c];
        mck5: .qt.M[`.order.applyBookUpdates;{[a;b;c;d;e;f;g]};c];
        mck6: .qt.M[`.order.pruneBook;{};c];
        mck7: .qt.M[`.order.pruneOrders;{};c];

        .order.ProcessTrade[
            .util.testutils.defaultInstrument;
            .util.testutils.defaultAccount;
            p`td];
        
        .order.test.m:m;

        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyNewTrades Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyOrderUpdates Mock
        .util.testutils.checkMock[mck3;m[2];c];  // Expected .order.applyTakerFills Mock
        .util.testutils.checkMock[mck4;m[3];c];  // Expected .order.applyMakerFills Mock
        .util.testutils.checkMock[mck5;m[4];c];  // Expected .order.applyBookUpdates Mock

    }; // TOOD derive from // TODO derive orderbook, orders
    {[p] 
        // TODO account for one record
        ordCols:`orderId`instrumentId`accountId`side`otype`offset`leaves`displayqty`price`time;
        ordColsEx:`orderId`instrumentId`accountId`side`otype`offset`leaves`displayqty`price`status`time;
        bookCols:`side`price`qty`hqty`iqty`vqty;
        :`cDepth`cOrd`td`mocks!(
            p[0];
            .util.testutils.makeOrders[ordCols;flip p[1]];
            p[2];
            (3_8#p));
    };
    (
        (("1a) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade doesn't fill agent", // 12
          "order, trade execution <= agent order offset, fill is agent (partial hidden qty fill)");(
                ( // Current Depth  
                    [price:1000-til 10] 
                    side:(10#1);
                    qty:10#1000;
                    hqty:((10 20),(8#10));
                    iqty:((170 170),(8#0)); // TODO fix
                    vqty:((1030 1030),(8#1000)) // TODO fix
                ); 
                (   // Current Orders  
                    til[4];4#0;4#1;4#1;4#1; // `orderId`instrumentId`accountId`side`otype 
                    ((2#400),(2#600)); // offset
                    4#100; // leaves
                    ((2#10),(2#20)); // displayqty
                    4#1000 999; // price
                    4#z // time
                );
                (-1;5;1b;z);  // Sell should reduce // TODO add time check
                (1b;1;( // Expected .order.applyNewTrades Mock
                    enlist(enlist'[(-1;1000;5;z)])
                ));    
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip((0;1000;395;100;10;0;z);(2;1000;595;100;20;0;z))
                ));    
                (1b;1;( // Expected .order.applyTakerFills Mock
                    enlist(enlist'[(0;0;-1;1000;5;1b;z)])
                ));   
                (0b;0;()); // Expected .order.applyMakerFills Mock
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist(enlist'[(1000;1;1000;5;170;1030;z)])
                ))     
          ));
          (("1b) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade doesn't fill agent", // 13
          "order, trade execution <= agent order offset, fill is agent");(
                ( // Current Depth  
                    [price:1000-til 10] 
                    side:(10#1);
                    qty:10#1000;
                    hqty:((10 20),(8#10));
                    iqty:((170 170),(8#0)); // TODO fix
                    vqty:((1030 1030),(8#1000)) // TODO fix
                ); 
                (   // Current Orders  
                    til[4];4#0;4#1;4#1;4#1; // `orderId`instrumentId`accountId`side`otype 
                    ((2#400),(2#600)); // offset
                    4#100; // leaves
                    ((2#10),(2#20)); // displayqty
                    4#1000 999; // price
                    4#z // time
                ); 
                (-1;200;1b;z);   // Sell should reduce
                (1b;1;( // Expected .order.applyNewTrades Mock
                    enlist flip((-1;1000;10;z);(-1;1000;190;z))
                ));    
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip((0;1000;200;100;10;0;z);(2;1000;400;100;20;0;z)) // offset includes hqty
                ));    
                (1b;1;( // Expected .order.applyTakerFills Mock
                    enlist(enlist'[(0;0;-1;1000;200;1b;z)]) // TODO should be same instrument
                ));   
                (0b;0;()); // Expected .order.applyMakerFills Mock
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist(enlist'[(1000;1;810;0;170;840;z)])
                )) 
          ));
          (("1c) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade partially fills agent", // 14
          "order, trade execution >= agent order offset, fill is agent (partially fills iceberg order < displayqty)");(
                ( // Current Depth  
                    [price:1000-til 10] 
                    side:(10#1);
                    qty:10#1000;
                    hqty:((10 20),(8#10));
                    iqty:((170 170),(8#0)); // TODO fix
                    vqty:((1030 1030),(8#1000)) // TODO fix
                ); 
                (   // Current Orders  
                    til[4];4#0;4#1;4#1;4#1; // `orderId`instrumentId`accountId`side`otype 
                    ((2#400),(2#600)); // offset
                    4#100; // leaves
                    ((2#10),(2#20)); // displayqty
                    4#1000 999; // price
                    4#z // time
                );  
                (-1;450;1b;z);  // Fill Execution Buy
                (1b;1;( // Expected .order.applyNewTrades Mock
                    enlist flip((-1;1000;10;z);(-1;1000;390;z);(-1;1000;50;z))
                ));    
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip((0;1000;0;50;10;1;z);(2;1000;150;100;20;0;z)) // offset includes hqty
                ));    
                (1b;1;( // Expected .order.applyTakerFills Mock
                    enlist(enlist'[(0;0;-1;1000;450;1b;z)]) 
                ));   
                (1b;1;( // Expected .order.applyMakerFills Mock
                    enlist(enlist'[(0;1;1;1000;50;0b;z)])
                )); 
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist(enlist'[(1000;1;610;0;120;640;z)])
                )) 
          ));
          (("1d) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade partially fills agent", // 14
          "order, trade execution >= agent order offset, fill is agent (partially fills iceberg order > display qty)");(
                ( // Current Depth  
                    [price:1000-til 10] 
                    side:(10#1);
                    qty:10#1000;
                    hqty:((10 20),(8#10));
                    iqty:((170 170),(8#0)); // TODO fix
                    vqty:((1030 1030),(8#1000)) // TODO fix
                ); 
                (   // Current Orders  
                    til[4];4#0;4#1;4#1;4#1; // `orderId`instrumentId`accountId`side`otype 
                    ((2#400),(2#600)); // offset
                    4#100; // leaves
                    ((2#10),(2#20)); // displayqty
                    4#1000 999; // price
                    4#z // time
                );  
                (-1;495;1b;z);  // Fill Execution Buy
                (1b;1;( // Expected .order.applyNewTrades Mock
                    enlist(3#-1;3#1000;10 390 95;3#z)
                ));    
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip((0;1000;0;5;5;1;z);(2;1000;105;100;20;0;z)) // offset includes hqty // TODO check
                ));    
                (1b;1;( // Expected .order.applyTakerFills Mock
                    enlist(enlist'[(0;0;-1;1000;495;1b;z)]) 
                ));   
                (1b;1;( // Expected .order.applyMakerFills Mock
                    enlist(enlist'[(0;1;1;1000;95;0b;z)])
                )); 
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist(enlist'[(1000;1;610;0;80;635;z)]) // TODO check
                )) 
          ));
          // TODO fills entire level
          (("1e) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade fills agent", // 16
          "orders, trade execution > agent order offset, fill is agent (3 orders on second level)");(
                ( // Current Depth  
                    [price:1000-til 10] 
                    side:(10#1);
                    qty:10#1000;
                    hqty:((10 20),(8#10));
                    iqty:((170 170),(8#0)); // TODO fix
                    vqty:((1030 1030),(8#1000)) // TODO fix
                ); 
                (   // Current Orders  
                    til[5];5#0;5#1;5#1;5#1; // `orderId`instrumentId`accountId`side`otype 
                    ((2#400),(2#600),850); // offset
                    5#100; // leaves
                    ((2#10),(3#20)); // displayqty
                    5#999 1000; // price
                    5#z // time
                ); 
                (-1;1850;1b;z);  // Fill Execution Buy
                (1b;1;( // Expected .order.applyNewTrades Mock
                    enlist flip(
                        (-1;999;20;z);
                        (-1;999;380;z);
                        (-1;999;100;z);
                        (-1;999;100;z);
                        (-1;999;40;z);
                        (-1;1000;10;z);
                        (-1;1000;390;z);
                        (-1;1000;100;z);
                        (-1;1000;100;z);
                        (-1;1000;100;z);
                        (-1;1000;330;z)
                    )
                ));    
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip(
                        (0;999;0;0;0;1;z);
                        (2;999;0;60;20;1;z);
                        (4;999;210;100;20;0;z);
                        (1;1000;0;0;0;1;z);
                        (3;1000;0;0;0;1;z)
                    )
                ));    
                (1b;1;( // Expected .order.applyTakerFills Mock
                    enlist flip((0;0;-1;999;640;1b;z);(0;0;-1;1000;1030;1b;z)) 
                ));   
                (1b;1;( // Expected .order.applyMakerFills Mock
                    enlist flip((0;1;1;999;100;0b;z);(0;1;1;999;40;0b;z);(0;1;1;1000;100;0b;z);(0;1;1;1000;100;0b;z))
                )); 
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist flip((999;1;520;0;120;560;z);(1000;1;0;0;0;0;z)) // TODO check
                )) 
          ));
          (("1f) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade fills agent", // 17
          "orders, trade execution > agent order offset, fill is agent (3 orders on first level)");(
                ( // Current Depth  
                 [price:1000-til 10] 
                 side:(10#1);
                 qty:10#1000;
                 hqty:((10 20),(8#10));
                 iqty:((250 170),(8#0)); // TODO fix
                 vqty:((1050 1030),(8#1000)) // (999:10 20=30(1200-170=1030), 1000:10 20 20=50(1300-250=1050))
                ); 
                (   // Current Orders  
                    til[5];5#0;5#1;5#1;5#1; // 
                    ((2#400),(2#600),850); // offset (includes hidden qty)
                    5#100; // leaves
                    ((2#10),(3#20)); // displayqty (999:10 20=30, 1000:10 20 20=50)
                    5#1000 999; // price 
                    5#z // time
                ); 
                (-1;1850;1b;z);  // Fill Execution Buy
                (1b;1;( // Expected .order.applyNewTrades Mock
                    enlist flip(
                        (-1;1000;10;z);
                        (-1;1000;390;z);
                        (-1;1000;100;z);
                        (-1;1000;100;z);
                        (-1;1000;100;z);
                        (-1;1000;150;z);
                        (-1;1000;100;z);
                        (-1;1000;100;z);
                        (-1;999;20;z);
                        (-1;999;380;z);
                        (-1;999;100;z);
                        (-1;999;40;z)                        
                    )
                ));    
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip(
                        (0;1000;0;0;0;1;z);
                        (2;1000;0;0;0;1;z);
                        (4;1000;0;0;0;1;z);
                        (1;999;0;0;0;1;z);
                        (3;999;60;100;20;0;z))
                ));    
                (1b;1;( // Expected .order.applyTakerFills Mock
                    enlist flip(
                        (0;0;-1;1000;1050;1b;z);
                        (0;0;-1;999;540;1b;z)) 
                ));   
                (1b;1;( // Expected .order.applyMakerFills Mock
                    enlist flip(
                        (0;1;1;1000;100;0b;z);
                        (0;1;1;1000;100;0b;z);
                        (0;1;1;1000;100;0b;z);
                        (0;1;1;999;100;0b;z))
                )); 
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist flip((1000;1;0;0;0;0;z);(999;1;580;0;80;600;z)) // TODO check
                )) 
          ))
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

.qt.SkpBesTest[0];
/ .qt.SkpBes[46];
.qt.RunTests[];
