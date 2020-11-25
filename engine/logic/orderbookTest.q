
// TODO process depth updates without orders

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
// TODO longer update streams

// TODO account for one record
/ ordCols:{$[
/     count[x]=9;`orderId`instrument`account`side`otype`offset`leaves`price`time;
/     count[x]=10;`orderId`instrument`account`side`otype`offset`leaves`displayqty`price`time;
/     ()]};

/ bookCols:`side`price`qty`hqty`iqty`vqty;
/ nxt:$[
/     count[p[2]]=4;`side`price`nqty`time!p[2];
/     count[p[2]]=5;`side`price`nqty`nhqty`time!p[2];
/     'INVALID_NXT];

/ :`cDepth`cOrd`nxt`mocks!(
/     p[0];
/     .util.testutils.makeOrders[ordCols[p[1]];flip p[1]];
/     nxt;
/     (3_5#p));

.qt.Unit[
    ".engine.logic.depth.ProcessDepthUpdatesWithOrders";
    {[c]
        .qt.RunUnit[c;.engine.services.mark.ProcessMarkUpdateEvents];
    };
    {`args`eRes`mocks`err!x};
    (
       (("0a) ProcessDepth BUY+SELL: (No hidden or Iceberg qty) differing update prices by time,",
            "repletes order spread during update, many order offset prices");(
            (   // Depth Update
                ((5#-1),(5#1)); // side
                ((1000 1001 1002 1001 1002),(999 998 997 997 998)); // price
                ((0 0 0 1000 1000),(0 0 0 1000 1000)); // NQTY
                (10#0); // NHQTY
                (sc[z] 0 0 0 1 1 0 0 0 1 1) // time
            ); 
            ();
            (
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
                (1b;1;( // Expected .order.applyOrderUpdates Mock
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
            );
            ()
        ));
        (("0b) ProcessDepth BUY+SELL: many levels with many iceberg orders at ",
            "same offset interval with hidden qty, price is removed across all levels fully (1000)");(
            (   // Depth Update
                ((20#1),(20#-1));
                ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
                (40#0 1000); // NQTY
                ((10, (19#0)),(10, (19#0))); // NHQTY
                (sc[z] (40#0 1)) // TIME
            );
            (); 
            (
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip(
                        (10;999;20;100;100;0;z); // TODO check
                        (11;999;120;100;100;0;z);
                        (12;998;0;100;100;0;z);
                        (13;998;100;100;100;0;z);
                        (14;997;0;100;100;0;z); // TODO check
                        (15;997;100;100;100;0;z);
                        (16;996;0;100;100;0;z);
                        (17;996;100;100;100;0;z);
                        (18;995;0;100;100;0;z); // TODO check
                        (19;995;100;100;100;0;z);
                        (0;1000;20;100;100;0;z);
                        (1;1000;120;100;100;0;z);
                        (2;1001;0;100;100;0;z); // TODO check
                        (3;1001;100;100;100;0;z);
                        (4;1002;0;100;100;0;z);
                        (5;1002;100;100;100;0;z);
                        (6;1003;0;100;100;0;z); // TODO check
                        (7;1003;100;100;100;0;z);
                        (8;1004;0;100;100;0;z);
                        (9;1004;100;100;100;0;z)
                    )
                ));    
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist((
                        ((999-til 5),(1000+til 5)); // price
                        (5#1),(5#-1);   // side
                        (10#1000); // qty
                        ((20, (4#0)),(20, (4#0))); // hqty is increased by update
                        10#0; // iqty
                        10#1200; // vqty
                        (sc[z] (10#0)))) // time
                ));
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
                )  
            );
            ()
        ));
        (("0d) ProcessDepth BUY+SELL: many levels with many orders at same offset interval,",
          "price is removed across all levels partially (900) not hidden or iceberg, no hidden update");(
            ( // Depth Update
                ((20#1),(20#-1));
                ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
                (40#900 1000);
                (sc[z] (40#0 1))
            );
            ();
            (
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip(
                        (10;999;80;100;100;0;z); // TODO check
                        (11;999;340;100;100;0;z);
                        (12;998;80;100;100;0;z);
                        (13;998;340;100;100;0;z);
                        (14;997;80;100;100;0;z); // TODO check
                        (15;997;340;100;100;0;z);
                        (16;996;80;100;100;0;z);
                        (17;996;340;100;100;0;z);
                        (18;995;80;100;100;0;z); // TODO check
                        (19;995;340;100;100;0;z);
                        (0;1000;80;100;100;0;z);
                        (1;1000;340;100;100;0;z);
                        (2;1001;80;100;100;0;z); // TODO check
                        (3;1001;340;100;100;0;z);
                        (4;1002;80;100;100;0;z);
                        (5;1002;340;100;100;0;z);
                        (6;1003;80;100;100;0;z); // TODO check
                        (7;1003;340;100;100;0;z);
                        (8;1004;80;100;100;0;z);
                        (9;1004;340;100;100;0;z)
                    )
                ));    
                (1b;1;( // Expected .order.aspplyBookUpdates Mock
                    enlist((
                        999 998 997 996 995 1000 1001 1002 1003 1004; // price
                        (5#1),(5#-1);   // side
                        10#1000; // qty
                        10#(10 0 0 0 0); // hqty
                        10#0; // iqty
                        10#1200; // vqty
                        (sc[z] (10#0)))) // time
                ));
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
                ) 
            );
            ()
        ));
        / (("0e) ProcessDepth BUY+SELL:differing update prices by time, crosses order spread during update",
        /   "(best price increases during update) finishes past order level (past final spread) with hidden qty");(
        /     (   // Current Depth
        /         [price:((999-til 5),(1000+til 5))] 
        /         side:(5#1),(5#-1);
        /         qty:(10#1000);
        /         hqty:((10, (4#0)),(10, (4#0)));
        /         iqty:(10#0);
        /         vqty:(10#1200)
        /     );   
        /     (   // Current Orders
        /         til[20];20#1;20#1; // `orderId`instrumentId`accountId
        /         ((10#-1),(10#1)); // side
        /         20#1; // otype
        /         (20#100 400); // offset
        /         20#100; // leaves
        /         20#100; // displayqty
        /         ((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5))); // price
        /         20#z // time
        /     ); 
        /     (  // Depth Update
        /         ((4#-1),(2#1));
        /         ((1000 1001 1002 1002),(1000 1001));
        /         ((0 0 0 1000),(1000 1000));
        /         (sc[z] 0 0 0 1 0 0)
        /     );
        /     (1b;1;( // Expected .order.applyOrderUpdates Mock
        /         enlist flip(
        /             (1;999;20;100;100;0;z); // TODO check
        /             (3;999;520;100;100;0;z);
        /             (0;1000;400;100;100;0;z);
        /             (2;1000;600;100;100;0;z)
        /         )
        /     ));    
        /     (1b;1;( // Expected .order.applyBookUpdates Mock
        /         enlist((
        /             1000 1001 1002 999 998 997 1000; // price
        /             (3#-1),(4#1);   // side
        /             (0 1000 1000 0 1000 1000 0); // qty
        /             (20 10 10 0 0 0 0); // hqty
        /             (170 ,(6#0)); // iqty
        /             (0 1000 1000 30 1000 1000 30); // vqty
        /             (sc[z] 0 1 1 0 1 1 0))) // time
        /     ))     
        / ));
        / (("0f) ProcessDepth BUY+SELL:differing update prices by time, crosses order spread during update ",
        /   "(best price decreases during update) finishes past order level (past final spread)");(
        /     (   // Current Depth
        /         [price:((999-til 5),(1000+til 5))] 
        /         side:(5#1),(5#-1);
        /         qty:(10#1000);
        /         hqty:((10, (4#0)),(10, (4#0)));
        /         iqty:(10#0);
        /         vqty:(10#1200)
        /     );    
        /     (   // Current Orders
        /         til[20];20#1;20#1; // `orderId`instrumentId`accountId
        /         ((10#-1),(10#1)); // side
        /         20#1; // otype
        /         (20#100 400); // offset
        /         20#100; // leaves
        /         20#100; // displayqty
        /         ((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5))); // price
        /         20#z // time
        /     ); 
        /     (  // Depth Update
        /         ((4#1),(2#-1));
        /         ((999 998 997 997),(999 998));
        /         ((0 0 0 1000),(1000 1000));
        /         (sc[z] 0 0 0 1 0 0)
        /     );   
        /     (1b;1;( // Expected .order.applyOrderUpdates Mock
        /         enlist flip(
        /             (10;999;10;100;100;0;z); // TODO check
        /             (11;999;110;100;100;0;z);
        /             (12;998;0;100;100;0;z);
        /             (13;998;100;100;100;0;z); // TODO check
        /             (14;997;0;100;100;0;z);
        /             (15;997;100;100;100;0;z)
        /         )
        /     ));    
        /     (1b;1;( // Expected .order.applyBookUpdates Mock
        /         enlist((
        /             999 998 999 998 997; // price
        /             (2#-1),(3#1);   // side
        /             (1000 1000 0 0 1000); // qty
        /             (0 0 10 0 0); // hqty
        /             (0 0 0 0 0); // iqty
        /             (1000 1000 200 200 1200); // vqty
        /             (sc[z] 0 0 0 0 0))) // time
        /     ))     
        / ));
        (("0g) ProcessDepth BUY+SELL:differing update prices by time, crosses order spread during update",
          "(best price increases during update) finishes past order level (within final spread)");(
            (  // Depth Update
                ((4#-1),(4#1));
                ((1000 1001 1002 1002),(1000 1001 1000 1001));
                ((0 0 0 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 0 0 1 1)
            );   
            ();
            (
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip(
                        (0;1000;10;100;100;0;z); // TODO check
                        (1;1000;110;100;100;0;z);
                        (2;1001;0;100;100;0;z);
                        (3;1001;100;100;100;0;z);
                        (4;1002;0;100;100;0;z);
                        (5;1002;100;100;100;0;z)
                    )
                ));    
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist((
                        1000 1001 1002 1000 1001; // price // TODO check that this is sufficient
                        (3#-1),(2#1);   // side
                        0 0 1000 0 0; // qty
                        10 0 0 0 0; // hqty
                        0 0 0 0 0; // iqty
                        200 200 1200 0 0; // vqty
                        (sc[z] 0 0 0 1 1))) // time
                ));
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
                ) 
            );
            ()
        ));
        (("0h) ProcessDepth BUY+SELL:differing update prices by time, crosses order spread during update ",
          "(best price decreases during update) finishes past order level (past final spread)");( // incoming orders should be participate don't initiate
            (  // Depth Update The mid price decreases by two 
                // levels (updating open buy orders) and 
                // then returns by one spread having increased by one
                ((4#1),(4#-1));
                ((999 998 997 997), (999,  998,  999, 998)); // 
                ((0,  0,  0,  1000),(1000, 1000, 0,   0));
                (sc[z] 0 0 0 1 0 0 1 1) // 
            );  
            ();
            (
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip(
                        (10;999;10;100;100;0;z); // offset equalt to hqty
                        (11;999;110;100;100;0;z); // offset = hqty+o1leaves
                        (12;998;0;100;100;0;z); // 
                        (13;998;100;100;100;0;z);
                        (14;997;0;100;100;0;z);
                        (15;997;100;100;100;0;z)
                    )
                ));    
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist((
                        999 998 997 999 998; // price
                        1 1 1 -1 -1;   // side
                        0 0 1000 0 0; // qty
                        10 0 0 0 0; // hqty
                        0 0 0 0 0; // iqty
                        200 200 1200 0 0; // vqty
                        (sc[z] 0 0 0 1 1))) // time
                ));
                (   // Current Depth
                    [price:((999-til 5),(1000+til 5))] 
                    side:(5#1),(5#-1);
                    qty:(10#1000);
                    hqty:((10, (4#0)),(10, (4#0)));
                    iqty:(10#0);
                    vqty:(10#1200)
                );    
                (   // Current Orders (order for each level)
                    til[20];20#1;20#1; // `orderId`instrumentId`accountId
                    ((10#-1),(10#1)); // side
                    20#1; // otype
                    (20#100 400); // offset
                    20#100; // leaves
                    20#100; // displayqty
                    ((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5))); // price
                    20#z // time
                )
            );
            ()
        ));
        (("0i) ProcessDepth BUY+SELL: order levels retract past order prices i.e. spread increases",
          "The orders should remain behind in this instance");( // Has been checked
            (  // Depth Update
                ((5#-1),(5#1));
                ((1000 1001 1002 1001 1002),(999 998 997 998 997)); // spread increases before decreasing again
                ((0 0 0 1000 1000),(0 0 0 1000 1000));
                (sc[z] 0 0 0 1 1 0 0 0 1 1)
            );  
            ();
            (
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip( // offset on both sides should be reduced to 0
                        (0;1001;0;100;100;0;z); // TODO check
                        (1;1001;100;100;100;0;z);
                        (2;998;0;100;100;0;z);
                        (3;998;100;100;100;0;z)
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
                ));
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
                ) 
            );
            ()
        ));
        (("0j) ProcessDepth BUY+SELL:differing update prices by time, crosses order spread during update",
          "(best price decreases during update) finishes at order level");( // TODO make different
            (  // Depth Update
                ((5#1),(4#-1));
                ((999 998 997 997 998),(999 998 999 998)); /// TODO make unique
                ((0 0 0 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 0 0 1 1)
            );  
            ();
            (
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip(
                        (0;998;0;100;100;0;z); // TODO check
                        (1;998;100;100;100;0;z)
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
                ));
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
                )
            );
            ()
        ));
        (("0k) ProcessDepth BUY+SELL:differing update prices by time doesn't cross spread",
         "(best price increases during update)");(
            (  // Depth Update
                ((5#1),(4#-1));
                ((999 998 997 997 998),(999 998 999 998));
                ((0 0 0 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 0 0 1 1)
            );  
            ();
            (
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip(
                        (0;998;0;100;100;0;z); // TODO check
                        (1;998;100;100;100;0;z)
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
                ));
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
            );
            () 
        ));
        (("0l) ProcessDepth BUY+SELL:No hidden or iceberg qty differing update prices ",
         "by time doesn't cross spread (best price decreases during update)");( // TODO check with no agent order qty behind order
            (  // Depth Update (best ask price jumps)
                ((4#1),(2#-1));
                ((999 998 998 999),(999 999)); // Because the level at 99 changes (and no trades occur, hqty stays the same)
                ((0 0 1000 1000),(1000 0));
                (sc[z] 0 0 2 2 0 1)
            );     
            ();
            (
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip(
                        (0;998;0;100;100;0;z); /
                        (1;998;100;100;100;0;z)
                    )
                ));    
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist((
                        998 999 999; // price
                        1 -1 1;   // side
                        (1000 0 1000); // qty
                        (0 0 10); // hqty TODO (hqty at the level will be overwritten by the price change?)
                        (0 0 0); // iqty
                        (1200 0 1000); // vqty
                        (sc[z] 0 1 2))) // time
                ));
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
                ) 
            );
            ()
        ));
        (("0m) ProcessDepth BUY+SELL:differing update prices by time, crosses order spread during update ",
          "(best price decreases during update) finishes past order level (past final spread)");( // incoming orders should be participate don't initiate
            (  // Depth Update The mid price decreases by two 
                // levels (updating open buy orders) and 
                // then returns by one spread having increased by one
                ((4#1),(4#-1));
                ((999 998 997 997), (999,  998,  999, 998)); // 
                ((0,  0,  0,  1000),(1000, 1000, 0,   0));
                (sc[z] 0 0 0 1 0 0 1 1) // 
            );  
            ();
            (
                (   // Current Depth
                    [price:((999-til 5),(1000+til 5))] 
                    side:(5#1),(5#-1);
                    qty:(10#1000);
                    hqty:((10, (4#0)),(10, (4#0)));
                    iqty:(10#0);
                    vqty:(10#1200)
                );    
                (   // Current Orders (order for each level)
                    til[20];20#1;20#1; // `orderId`instrumentId`accountId
                    ((10#-1),(10#1)); // side
                    20#1; // otype
                    (20#100 400); // offset
                    20#100; // leaves
                    20#100; // displayqty
                    ((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5))); // price
                    20#z // time
                ); 
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip(
                        (10;999;10;100;100;0;z); // offset equalt to hqty
                        (11;999;110;100;100;0;z); // offset = hqty+o1leaves
                        (12;998;0;100;100;0;z); // 
                        (13;998;100;100;100;0;z);
                        (14;997;0;100;100;0;z);
                        (15;997;100;100;100;0;z)
                    )
                ));    
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist((
                        999 998 997 999 998; // price
                        1 1 1 -1 -1;   // side
                        0 0 1000 0 0; // qty
                        10 0 0 0 0; // hqty
                        0 0 0 0 0; // iqty
                        200 200 1200 0 0; // vqty
                        (sc[z] 0 0 0 1 1))) // time
                ))
            );
            ()     
        ))
    );
    ({};{};{};{});
    ("Given a depth update which consists of a table of time,side,price",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders where necessary")];
