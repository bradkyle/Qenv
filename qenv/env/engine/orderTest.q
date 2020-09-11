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
        ("buy and sell orders at best level, previous depth greater than differing updates (3 updates) 2 dec 1 inc";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1100;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#999),(2#1000);4#z); // Current Orders
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));(20#1000 1100);(20#z,(z+`second$5))); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1100);vqty:10#(1300,4#1100)); // Expected Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#88 377);4#100;(2#999),(2#1000);4#z); // Expected Orders
            () // Expected Events
        ));
        ("check that depth update where zero is removed and only one update is processed per side";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1100;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (`SELL`BUY;1000 999;0 0;(z,z));  // Depth Update
            ([price:((998-til 4),(1001+til 4))] side:(4#`.order.ORDERSIDE$`BUY),(4#`.order.ORDERSIDE$`SELL);qty:(8#1100);vqty:(8#1100)); // Expected Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time doesn't cross spread (best price decreases during update)";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((4#`BUY),(2#`SELL));
                ((999 998 998 999),(999 999));
                ((0 0 1000 1000),(1000 0));
                (sc[z] 0 0 1 1 0 1)
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:(1000,1200,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(0 200 100 400);4#100;(2#998),(2#1001);4#z);  // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time doesn't cross spread (best price increases during update)";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((4#`SELL),(2#`BUY));
                ((1000 1001 1001 1000),(1000 1000));
                ((0 0 1000 1000),(1000 0));
                (sc[z] 0 0 1 1 0 1)
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:((6#1000),1200,(3#1000)));  // Expected Depth
            (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price decreases during update) finishes at original";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((6#`BUY),(4#`SELL));
                ((999 998 997 997 998 999),(999 998 999 998));
                ((0 0 0 1000 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 1 0 0 1 1)
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:(1000,1200,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price increases during update) finishes at original";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((6#`SELL),(4#`BUY));
                ((1000 1001 10002 1001 1000 1002),(1000 1001 1000 1001));
                ((0 0 0 1000 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 1 0 0 1 1)
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:((6#1000),1200,(3#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price decreases during update) finishes at order level";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((5#`BUY),(4#`SELL));
                ((999 998 997 997 998),(999 998 999 998));
                ((0 0 0 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 0 0 1 1)
            ); // Depth Update
            ([price:((998-til 4),(1000+til 5))] side:(4#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(9#1000);vqty:(1200,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price increases during update) finishes at order level";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5)));  // Current Depth
            (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((5#`SELL),(4#`BUY));
                ((1000 1001 10002 1001 1002),(1000 1001 1000 1001));
                ((0 0 0 1000 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 1 0 0 1 1)
            );  // Depth Update
            ([price:((999-til 5),(1001+til 4))] side:(5#`.order.ORDERSIDE$`BUY),(4#`.order.ORDERSIDE$`SELL);qty:(9#1000);vqty:((5#1000),1200,(3#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(0 200 100 400);4#100;(2#1001),(2#998);4#z);  // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, repletes order spread during update, finishes at both order levels";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((5#`SELL),(5#`BUY));
                ((1000 1001 1002 1001 1002),(999 998 997 998 997));
                ((0 0 0 1000 1000),(0 0 0 1000 1000));
                (sc[z] 0 0 0 1 1 0 0 0 1 1)
            ); // Depth Update
            ([price:((998-til 4),(1001+til 4))] side:(4#`.order.ORDERSIDE$`BUY),(4#`.order.ORDERSIDE$`SELL);qty:(8#1000);vqty:(8#(1200,(3#1000)))); // Expected Depth
            (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#(0 200));4#100;(2#1001),(2#998);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price decreases during update) finishes past order level (within final spread)";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((4#`BUY),(4#`SELL));
                ((999 998 997 997),(999 998 999 998));
                ((0 0 0 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 0 0 1 1)
            ); // Depth Update
            ([price:((998-til 4),(1000+til 5))] side:(4#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:0,(8#1000);vqty:(300,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price increases during update) finishes past order level (within final spread)";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5)));  // Current Depth
            (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((4#`SELL),(4#`BUY));
                ((1000 1001 1002 1002),(1000 1001 1000 1001));
                ((0 0 0 1000),(1000 1000 0 0));
                (sc[z] 0 0 0 1 0 0 1 1)
            ); // Depth Update
            ([price:((999-til 5),(1001+til 4))] side:(5#`.order.ORDERSIDE$`BUY),(4#`.order.ORDERSIDE$`SELL);qty:9#((5#1000),0);vqty:9#((5#1000),300)); // Expected Depth
            (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price decreases during update) finishes past order level (past final spread)";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // Current Orders
            (
                ((4#`BUY),(2#`SELL));
                ((999 998 997 997),(999 998));
                ((0 0 0 1000),(1000 1000));
                (sc[z] 0 0 0 1 0 0)
            ); // Depth Update
            ([price:((998-til 4),(1000+til 5))] side:(4#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:0,(8#1000);vqty:(300,(8#1000))); // Expected Depth
            (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, crosses order spread during update (best price increases during update) finishes past order level (past final spread)";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#100 400);4#100;(2#1001),(2#998);4#z); // Current Orders
            (
                ((4#`SELL),(2#`BUY));
                ((1000 1001 1002 1002),(1000 1001));
                ((0 0 0 1000),(1000 1000));
                (sc[z] 0 0 0 1 0 0)
            ); // Depth Update
            ([price:((999-til 5),(1001+til 4))] side:(5#`.order.ORDERSIDE$`BUY),(4#`.order.ORDERSIDE$`SELL);qty:9#((5#1000),0);vqty:9#((5#1000),300));  // Expected Depth
            (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(0 200 100 400);4#100;(2#1001),(2#998);4#z);  // Expected Orders
            () // Expected Events
        ));
        ("differing update prices by time, repletes order spread during update, many order offset prices, finishes at both order levels";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5)));  // Current Depth
            (til[8];8#1;8#1;((4#`SELL),(4#`BUY));8#`LIMIT;(8#100 400);8#100;((4#1001 1002),(4#998 997));8#z); // Current Orders
            (
                ((5#`SELL),(5#`BUY));
                ((1000 1001 10002 1001 1002),(999 998 997 997 998));
                ((0 0 0 1000 1000),(0 0 0 1000 1000));
                (sc[z] 0 0 0 1 1 0 0 0 1 1)
            );  // Depth Update
            ([price:((998-til 4),(1001+til 4))] side:(4#`.order.ORDERSIDE$`BUY),(4#`.order.ORDERSIDE$`SELL);qty:(8#1000);vqty:(8#(1200,(3#1000)))); // Expected Depth
            (til[8];8#1;8#1;((4#`SELL),(4#`BUY));8#`LIMIT;((8#0 200 100 400));8#100;((4#1001 1002),(4#998 997));8#z); // Expected Orders
            () // Expected Events
        ));
        ("many levels with many orders at same offset interval, price is removed across all levels partially (900)";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Current Depth
            (til[20];20#1;20#1;((10#`SELL),(10#`BUY));20#`LIMIT;(20#100 400);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // Current Orders
            (
                ((20#`BUY),(20#`SELL));
                ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
                (40#900 1000);
                (sc[z] (40#0 1))
            ); // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:(10#1200)); // Expected Depth
            (til[20];20#1;20#1;((10#`SELL),(10#`BUY));20#`LIMIT;(20#75 350);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // Expected Orders
            () // Expected Events
        ));
        ("many levels with many orders at same offset interval, price is removed across all levels fully (1000)";(
            (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5)));  // Current Depth
            (til[20];20#1;20#1;((10#`SELL),(10#`BUY));20#`LIMIT;(20#100 400);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // Current Orders
            (
                ((20#`BUY),(20#`SELL));
                ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
                (40#0 1000);
                (sc[z] (40#0 1))
            );  // Depth Update
            ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:(10#1200)); // Expected Depth
            (til[20];20#1;20#1;((10#`SELL),(10#`BUY));20#`LIMIT;(20#0 200);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // Expected Orders
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


.qt.RunTests[];