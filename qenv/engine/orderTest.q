\l account.q
\l instrument.q
\l event.q
\l order.q
system "d .orderTest";
\l util.q
\cd ../quantest/
\l quantest.q 
\cd ../engine/

z:.z.z;

sc: {x+(`second$y)};

// Test data generation
// -------------------------------------------------------------->

deRef   :{x[y]:`long$(x[y]);:x};
rmFkeys :{cols[x] except key[fkeys x]};


makeDepthUpdate :{
    :$[count[x]>0;[ 
        // Side, Price, Size
        x:{:`time`intime`kind`cmd`datum!(x[3];x[3];`DEPTH;`UPDATE;
        ((`.order.ORDERSIDE$x[0]);x[1];x[2]))} each flip[x];
        :flip[x];
        ];()]};


makeDepth :{
    :$[count[x]>0;[  
        // Side, Price, Size
          :([price:x[1]] side:(`.order.ORDERSIDE$x[0]); qty:x[2]);
        ];()]};

makeOrders :{
    :$[count[x]>0;[ 
        // Side, Price, Size
        :{:(`clId`instrumentId`accountId`side`otype`offset`size`price!(
            x[0];x[1];x[2];(`.order.ORDERSIDE$x[3]);(`.order.ORDERTYPE$x[4]);x[5];x[6];x[7]);x[8])} each flip[x];
        ];()]};


/ nxt:update qty:qty+(first 1?til 100) from select qty:last (datum[;0][;2]) by price:datum[;0][;1] from d where[(d[`datum][;0][;0])=`BUY]
/ nxt:exec qty by price from update qty:rand qty from select qty:last (datum[;0][;2]) by price:datum[;0][;1] from d where[(d[`datum][;0][;0])=`BUY]
/ .account.NewAccount[`accountId`other!1 2;.z.z]
testOrders:{[num;oidstart;params]
    // params is a dictionary of values that are sanitized below
    :([price:`long$(num?prices); orderId:`long$(oidstart+til num)]
        accountId       : `long$(num#1);
        side            : num?(`.order.ORDERSIDE$`BUY;`.order.ORDERSIDE$`SELL);
        otype           : num#`.order.ORDERTYPE$`LIMIT;
        offset          : `long$(num?til 10000);
        timeinforce     : num#`.order.TIMEINFORCE$`NIL;
        size            : `long$(num?til 10000); / multiply by 100
        leaves          : `long$(num?til 10000);
        filled          : `long$(num?til 10000);
        limitprice      : `long$(num?til 10000); / multiply by 100
        stopprice       : `long$(num?til 10000); / multiply by 100
        status          : num#`.order.ORDERSTATUS$`NEW;
        time            : num#.z.z;
        isClose         : `boolean$(num?(1 0));
        trigger         : num#`.order.STOPTRIGGER$`NIL;
        execInst        : num#`.order.EXECINST$`NIL)
    };

// Test Utilities
// -------------------------------------------------------------->

setupDepth      : {if[count[x[`cOB]]>0;.order.ProcessDepthUpdateEvent[x[`cOB]]]}
setupOrders     : {if[count[x[`cOrd]]>0;{.order.NewOrder[x[0];x[1]]} each x[`cOrd]]}

// @x : params
// @y : case
checkOrders     :{
    if[count[x[`eOrd]]>0;[
            eOrd:x[`eOrd][;0];
            rOrd: select from .order.Order where clId in eOrd[`clId];
            eOrdCols: rmFkeys[rOrd] inter cols[eOrd];
            .qt.A[count[x[`eOrd]];=;count[rOrd];"order count";y];
            .qt.A[(eOrdCols#0!rOrd);~;(eOrdCols#0!eOrd);"orders";y];
            ]];
    };

checkDepth      :{
    if[count[x[`eOB]]>0;
            .qt.A[.order.OrderBook;~;x[`eOB];"orderbook";y];
            ];
    };


// Before and after defaults
// -------------------------------------------------------------->

defaultAfterEach: {
    /  delete from `.account.Account;
    /  delete from `.account.Inventory;
     delete from `.event.Events;
     delete from `.order.Order;
     delete from `.order.OrderBook;
    /  delete from  `.instrument.Instrument;
     .account.accountCount:0;
     .order.orderCount:0;
    .instrument.instrumentCount:0;
     .qt.RestoreMocks[];
    };

defaultBeforeEach: {
     delete from `.account.Account;
     delete from `.account.Inventory;
     delete from `.event.Events;
     delete from `.order.Order;
     delete from `.order.OrderBook;
     .account.NewAccount[`accountId`other!1 2;.z.z];
     .account.NewAccount[`accountId`other!2 2;.z.z];

     .instrument.NewInstrument[
        `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier!
        (1;0.5;1e5f;0f;1e7f;0f;1);
        1b;.z.z];
    };


// Process Depth Update
// -------------------------------------------------------------->

test:.qt.Unit[
    ".order.ProcessDepthUpdateEvent";
    {[c]
        p:c[`params];
        / show p[`event];/         
        setupDepth[p];
        setupOrders[p];

        .order.ProcessDepthUpdateEvent[p[`event]];
        // Assertions
        checkDepth[p;c];
        checkOrders[p;c];        

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Given a side update which consists of a table of price, time,",
    "size update the orderbook and the individual order offsets"];

deriveCaseParams    :{[params]
    :`cOB`cOrd`event`eOB`eOrd`eEvents!(
        makeDepthUpdate[params[0]];
        makeOrders[params[1]];
        makeDepthUpdate[params[2]];
        params[3];
        makeOrders[params[4]];
        params[5]
        );
    };

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

/ Add time to allow for multiple simultaneous updates.
/TODO make into array and addCases
.qt.AddCase[test;"simple update no agent orders or previous depth one side";deriveCaseParams[(
    ();();
    ((10#`SELL);1000+til 10;10#1000;10#z);
    ([price:(1000+til 10)] side:(10#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:(10#1000));
    ();()
    )]];

.qt.AddCase[test;"simple update no agent orders or previous depth both";deriveCaseParams[(
    ();();
    (((10#`SELL),(10#`BUY));((1000+til 10),(999-til 10));20#1000;20#z);
    ([price:(((1000+til 10),(999-til 10)))] side:(`.order.ORDERSIDE$((10#`SELL),(10#`BUY)));qty:(20#1000);vqty:(20#1000));
    ();()
    )]];

.qt.AddCase[test;"simple update no agent orders or previous depth both (crossing)";deriveCaseParams[(
    ();();
    ((10#`SELL);1000+til 10;10#1000;10#z);
    ([price:(1000+til 10)] side:(10#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:(10#1000));
    ();()
    )]];

.qt.AddCase[test;"simple update no agent orders or previous depth both; Multi temporal";deriveCaseParams[(
    ();();
    ((10#`SELL);(raze flip 2 5#(1000+til 5));10#1000 100;(10#z,(z+`second$5)));
    ([price:(1000+til 5)] side:(5#`.order.ORDERSIDE$`SELL);qty:(5#100);vqty:(5#100));
    ();()
    )]];

.qt.AddCase[test;"all OrderBook levels should be removed where the remaining qty<=0 and no agent orders exist";deriveCaseParams[(
    ((10#`SELL);(raze flip 2 5#(1000+til 5));10#100;(10#z,(z+`second$5)));();
    ((10#`SELL);(raze flip 2 5#(1000+til 5));((2#0),(8#100));(10#z,(z+`second$5))); // Depth update
    ([price:(1001+til 4)] side:(4#`.order.ORDERSIDE$`SELL);qty:(4#100);vqty:(4#100));
    ();()
    )]];

.qt.AddCase[test;"1 buy order at best level, previous depth greater than updates";deriveCaseParams[(
    ((10#`SELL);(raze flip 2 5#(1000+til 5));10#1100;(10#z,(z+`second$5))); // Previous depth
    (til[2];2#1;2#1;2#`SELL;2#`LIMIT;100 400;2#100;2#1000;2#z); // previous orders
    ((10#`SELL);(raze flip 2 5#(1000+til 5));10#1000;(10#z,(z+`second$5))); // Depth update
    ([price:((1000+til 5))] side:(5#`.order.ORDERSIDE$`SELL);qty:(5#1000);vqty:(1200,4#1000)); // Expected depth
    (til[2];2#1;2#1;2#`SELL;2#`LIMIT;88 377;2#100;2#1000;2#z); // Expected orders
    () // Expected Events TODO
    )]];

.qt.AddCase[test;"1 buy order at best level, previous depth greater than differing updates";deriveCaseParams[(
    ((10#`SELL);(raze flip 2 5#(1000+til 5));10#1100;(10#z,(z+`second$5))); // Previous depth
    (til[2];2#1;2#1;2#`SELL;2#`LIMIT;100 400;2#100;2#1000;2#z); // previous orders
    ((10#`SELL);(raze flip 2 5#(1000+til 5));(10#1050 1000);(10#z,(z+`second$5))); // Depth update
    ([price:((1000+til 5))] side:(5#`.order.ORDERSIDE$`SELL);qty:(5#1000);vqty:(1200,4#1000)); // Expected depth
    (til[2];2#1;2#1;2#`SELL;2#`LIMIT;88 377;2#100;2#1000;2#z); // Expected orders
    () // Expected Events TODO
    )]];

.qt.AddCase[test;"1 buy order at best level, previous depth greater than differing updates (3 updates) 2 dec 1 inc";deriveCaseParams[(
    ((10#`SELL);(raze flip 2 5#(1000+til 5));10#1100;(10#z,(z+`second$5))); // Previous depth
    (til[2];2#1;2#1;2#`SELL;2#`LIMIT;100 400;2#100;2#1000;2#z); // previous orders
    ((9#`SELL);(raze flip 3#{(1000+x;1000+x;1000+x)}til 3);(9#1050 1000 1100);(9#z,(z+`second$5))); // Depth update
    ([price:((1000+til 5))] side:(5#`.order.ORDERSIDE$`SELL);qty:(5#1100);vqty:(1300,4#1100)); // Expected depth
    (til[2];2#1;2#1;2#`SELL;2#`LIMIT;88 377;2#100;2#1000;2#z); // Expected orders
    () // Expected Events TODO
    )]];

.qt.AddCase[test;"buy and sell orders at best level, previous depth greater than differing updates (3 updates) 2 dec 1 inc";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1100;(20#z,(z+`second$5))); // Previous depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#999),(2#1000);4#z); // previous orders
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));(20#1000 1100);(20#z,(z+`second$5))); // Depth update
    ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1100);vqty:10#(1300,4#1100)); // Expected depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#88 377);4#100;(2#999),(2#1000);4#z); // Expected orders
    () // Expected Events TODO
    )]];

// Because vqty is set when orders are placed, no delta occurs in visqty apart from the deletion of certain price levels.
.qt.AddCase[test;"check that depth update where zero is removed and only one update is processed per side";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1100;(20#z,(z+`second$5))); // Previous depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // previous orders
    (`SELL`BUY;1000 999;0 0;(z,z)); // Depth update
    ([price:((998-til 4),(1001+til 4))] side:(4#`.order.ORDERSIDE$`BUY),(4#`.order.ORDERSIDE$`SELL);qty:(8#1100);vqty:(8#1100)); // Expected depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // Expected orders
    () // Expected Events TODO
    )]];

.qt.AddCase[test;"differing update prices by time doesn't cross spread (best price decreases during update)";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // previous orders
    (
        ((4#`BUY),(2#`SELL));
        ((999 998 998 999),(999 999));
        ((0 0 1000 1000),(1000 0));
        (sc[z] 0 0 1 1 0 1)
    ); // Previous depth
    ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:(1000,1200,(8#1000))); // Expected depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected orders
    () // Expected Events TODO
    )]];

.qt.AddCase[test;"differing update prices by time doesn't cross spread (best price increases during update)";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#100 400);4#100;(2#1001),(2#998);4#z); // previous orders
    (
        ((4#`SELL),(2#`BUY));
        ((1000 1001 1001 1000),(1000 1000));
        ((0 0 1000 1000),(1000 0));
        (sc[z] 0 0 1 1 0 1)
    ); // Previous depth
    ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:((6#1000),1200,(3#1000))); // Expected depth
    (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected orders
    () // Expected Events TODO
    )]];

// TODO think about this case!!
.qt.AddCase[test;"differing update prices by time, crosses order spread during update (best price decreases during update) finishes at original";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // previous orders
    (
        ((6#`BUY),(4#`SELL));
        ((999 998 997 997 998 999),(999 998 999 998));
        ((0 0 0 1000 1000 1000),(1000 1000 0 0));
        (sc[z] 0 0 0 1 1 1 0 0 1 1)
    ); // Previous depth
    ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:(1000,1200,(8#1000))); // Expected depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected orders
    () // Expected Events TODO
    )]];

.qt.AddCase[test;"differing update prices by time, crosses order spread during update (best price increases during update) finishes at original";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#100 400);4#100;(2#1001),(2#998);4#z); // previous orders
    (
        ((6#`SELL),(4#`BUY));
        ((1000 1001 10002 1001 1000 1002),(1000 1001 1000 1001));
        ((0 0 0 1000 1000 1000),(1000 1000 0 0));
        (sc[z] 0 0 0 1 1 1 0 0 1 1)
    ); // Previous depth
    ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:((6#1000),1200,(3#1000))); // Expected depth
    (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected orders
    () // Expected Events TODO
    )]];

.qt.AddCase[test;"differing update prices by time, crosses order spread during update (best price decreases during update) finishes at order level";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // previous orders
    (
        ((5#`BUY),(4#`SELL));
        ((999 998 997 997 998),(999 998 999 998));
        ((0 0 0 1000 1000),(1000 1000 0 0));
        (sc[z] 0 0 0 1 1 0 0 1 1)
    ); // Previous depth
    ([price:((998-til 4),(1000+til 5))] side:(4#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(9#1000);vqty:(1200,(8#1000))); // Expected depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected orders
    () // Expected Events TODO
    )]];

.qt.AddCase[test;"differing update prices by time, crosses order spread during update (best price increases during update) finishes at order level";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#100 400);4#100;(2#1001),(2#998);4#z); // previous orders
    (
        ((5#`SELL),(4#`BUY));
        ((1000 1001 10002 1001 1002),(1000 1001 1000 1001));
        ((0 0 0 1000 1000),(1000 1000 0 0));
        (sc[z] 0 0 0 1 1 0 0 1 1)
    ); // Previous depth
    ([price:((999-til 5),(1001+til 4))] side:(5#`.order.ORDERSIDE$`BUY),(4#`.order.ORDERSIDE$`SELL);qty:(9#1000);vqty:((5#1000),1200,(3#1000))); // Expected depth
    (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected orders
    () // Expected Events TODO
    )]];

.qt.AddCase[test;"differing update prices by time, repletes order spread during update, finishes at both order levels";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#100 400);4#100;(2#1001),(2#998);4#z); // previous orders
    (
        ((5#`SELL),(5#`BUY));
        ((1000 1001 1002 1001 1002),(999 998 997 998 997));
        ((0 0 0 1000 1000),(0 0 0 1000 1000));
        (sc[z] 0 0 0 1 1 0 0 0 1 1)
    ); // Previous depth
    ([price:((998-til 4),(1001+til 4))] side:(4#`.order.ORDERSIDE$`BUY),(4#`.order.ORDERSIDE$`SELL);qty:(8#1000);vqty:(8#(1200,(3#1000)))); // Expected depth
    (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#(0 200));4#100;(2#1001),(2#998);4#z); // Expected orders
    () // Expected Events TODO
    )]];

.qt.AddCase[test;"differing update prices by time, crosses order spread during update (best price decreases during update) finishes past order level (within final spread)";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // previous orders
    (
        ((4#`BUY),(4#`SELL));
        ((999 998 997 997),(999 998 999 998));
        ((0 0 0 1000),(1000 1000 0 0));
        (sc[z] 0 0 0 1 0 0 1 1)
    ); // Previous depth
    ([price:((998-til 4),(1000+til 5))] side:(4#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:0,(8#1000);vqty:(300,(8#1000))); // Expected depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected orders
    () // Expected Events TODO
    )]];

.qt.AddCase[test;"differing update prices by time, crosses order spread during update (best price increases during update) finishes past order level (within final spread)";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#100 400);4#100;(2#1001),(2#998);4#z); // previous orders
    (
        ((4#`SELL),(4#`BUY));
        ((1000 1001 1002 1002),(1000 1001 1000 1001));
        ((0 0 0 1000),(1000 1000 0 0));
        (sc[z] 0 0 0 1 0 0 1 1)
    ); // Previous depth
    ([price:((999-til 5),(1001+til 4))] side:(5#`.order.ORDERSIDE$`BUY),(4#`.order.ORDERSIDE$`SELL);qty:9#((5#1000),0);vqty:9#((5#1000),300)); // Expected depth
    (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected orders
    () // Expected Events TODO
    )]];

// TODO think about this, Should orders be cancelled?
.qt.AddCase[test;"differing update prices by time, crosses order spread during update (best price decreases during update) finishes past order level (past final spread)";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(4#100 400);4#100;(2#998),(2#1001);4#z); // previous orders
    (
        ((4#`BUY),(2#`SELL));
        ((999 998 997 997),(999 998));
        ((0 0 0 1000),(1000 1000));
        (sc[z] 0 0 0 1 0 0)
    ); // Previous depth
    ([price:((998-til 4),(1000+til 5))] side:(4#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:0,(8#1000);vqty:(300,(8#1000))); // Expected depth
    (til[4];4#1;4#1;((2#`BUY),(2#`SELL));4#`LIMIT;(0 200 100 400);4#100;(2#998),(2#1001);4#z); // Expected orders
    () // Expected Events TODO
    )]];

// TODO think about this, Should orders be cancelled?
.qt.AddCase[test;"differing update prices by time, crosses order spread during update (best price increases during update) finishes past order level (past final spread)";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(4#100 400);4#100;(2#1001),(2#998);4#z); // previous orders
    (
        ((4#`SELL),(2#`BUY));
        ((1000 1001 1002 1002),(1000 1001));
        ((0 0 0 1000),(1000 1000));
        (sc[z] 0 0 0 1 0 0)
    ); // Previous depth
    ([price:((999-til 5),(1001+til 4))] side:(5#`.order.ORDERSIDE$`BUY),(4#`.order.ORDERSIDE$`SELL);qty:9#((5#1000),0);vqty:9#((5#1000),300)); // Expected depth
    (til[4];4#1;4#1;((2#`SELL),(2#`BUY));4#`LIMIT;(0 200 100 400);4#100;(2#1001),(2#998);4#z); // Expected orders
    () // Expected Events TODO
    )]];

// TODO think about this, Should orders be cancelled?
// TODO not working
.qt.AddCase[test;"differing update prices by time, repletes order spread during update, many order offset prices, finishes at both order levels";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[8];8#1;8#1;((4#`SELL),(4#`BUY));8#`LIMIT;(8#100 400);8#100;((4#1001 1002),(4#998 997));8#z); // previous orders
    (
        ((5#`SELL),(5#`BUY));
        ((1000 1001 10002 1001 1002),(999 998 997 997 998));
        ((0 0 0 1000 1000),(0 0 0 1000 1000));
        (sc[z] 0 0 0 1 1 0 0 0 1 1)
    ); // Previous depth
    ([price:((998-til 4),(1001+til 4))] side:(4#`.order.ORDERSIDE$`BUY),(4#`.order.ORDERSIDE$`SELL);qty:(8#1000);vqty:(8#(1200,(3#1000)))); // Expected depth
    (til[8];8#1;8#1;((4#`SELL),(4#`BUY));8#`LIMIT;((8#0 200 100 400));8#100;((4#1001 1002),(4#998 997));8#z); // Expected orders
    () // Expected Events TODO
    )]];


.qt.AddCase[test;"many levels with many orders at same offset interval, price is removed across all levels partially (900)";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[20];20#1;20#1;((10#`SELL),(10#`BUY));20#`LIMIT;(20#100 400);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // previous orders
    (
        ((20#`BUY),(20#`SELL));
        ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
        (40#900 1000);
        (sc[z] (40#0 1))
    ); // Previous depth
    ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:(10#1200)); // Expected depth
    (til[20];20#1;20#1;((10#`SELL),(10#`BUY));20#`LIMIT;(20#75 350);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z);  // Expected orders
    () // Expected Events TODO
    )]];

.qt.AddCase[test;"many levels with many orders at same offset interval, price is removed across all levels fully (1000)";deriveCaseParams[(
    (((10#`BUY),(10#`SELL));(raze flip 2 5#(999-til 5)),(raze flip 2 5#(1000+til 5));20#1000;(20#z,(z+`second$5))); // Previous depth
    (til[20];20#1;20#1;((10#`SELL),(10#`BUY));20#`LIMIT;(20#100 400);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z); // previous orders
    (
        ((20#`BUY),(20#`SELL));
        ((raze flip 2 10#(999-til 5)),(raze flip 2 10#(1000+til 5)));
        (40#0 1000);
        (sc[z] (40#0 1))
    ); // Previous depth
    ([price:((999-til 5),(1000+til 5))] side:(5#`.order.ORDERSIDE$`BUY),(5#`.order.ORDERSIDE$`SELL);qty:(10#1000);vqty:(10#1200)); // Expected depth
    (til[20];20#1;20#1;((10#`SELL),(10#`BUY));20#`LIMIT;(20#0 200);20#100;((raze flip 2 5#(1000+til 5)),(raze flip 2 5#(999-til 5)));20#z);  // Expected orders
    () // Expected Events TODO
    )]];



// Process Trade tests
// -------------------------------------------------------------->

/ // TODO
/ // TODO better (more consice/shorter test)
test:.qt.Unit[
    ".order.ProcessTrade";
    {[c]
        p:c[`params];  
        setupDepth[p];
        setupOrders[p];

        // instantiate mock for ApplyFill
        mck1: .qt.M[`.account.ApplyFill;{[a;b;c;d;e;f;g;h]};c];
        mck2: .qt.M[`.order.AddTradeEvent;{[a;b]};c];
        mck3: .qt.M[`.account.IncSelfFill;{[a;b;c]};c];

        t:p[`trade];
        .order.ProcessTrade[t[`iId];t[`side];t[`qty];t[`isClose];t[`isAgent];t[`accountId];t[`time]];

        p1:p[`eApplyFill];        
        .qt.MA[
            mck1;
            p1[`called];
            p1[`numCalls];
            p1[`calledWith];c];

        p2:p[`eAddTradeEvent];
        .qt.MA[
            mck2;
            p2[`called];
            p2[`numCalls];
            p2[`calledWith];c];

        p3:p[`eIncSelfFill];
        .qt.MA[
            mck3;
            p3[`called];
            p3[`numCalls];
            p3[`calledWith];c];

        checkOrders[p;c];
        checkDepth[p;c];
        
    };();({};{};defaultBeforeEach;defaultAfterEach);
    "process trades from the historical data or agent orders"];


deriveCaseParams    :{[params]
    t:`iId`side`qty`isClose`isAgent`accountId`time!params[2];
    t[`side]:`.order.ORDERSIDE$t[`side]; 
    mCols:`called`numCalls`calledWith; // Mock specific

    makeOrdersEx :{
    :$[count[x]>0;[ 
        // Side, Price, Size
        :{:(`clId`instrumentId`accountId`side`otype`offset`leaves`price`status!(
            x[0];x[1];x[2];(`.order.ORDERSIDE$x[3]);(`.order.ORDERTYPE$x[4]);x[5];x[6];x[7];(`.order.ORDERSTATUS$x[8]));x[9])} each flip[x];
        ];()]};

    p:`cOB`cOrd`trade`eOB`eOrd`eAddTradeEvent`eApplyFill`eIncSelfFill!(
        makeDepthUpdate[params[0]]; 
        makeOrders[params[1]];
        t;
        params[3];
        makeOrdersEx[params[4]];
        mCols!params[5];
        mCols!params[6];
        mCols!params[7]
        );
    :p;
    };

// TODO no liquidity
// TODO no bestQty
// TODO check return qty
// TODO check offset on multiple levels
// TODO self fill vs non self fill
// TODO add order update events!
// TODO agent trade fills entire price level
// TODO trade size larger than orderbook qty
// TODO instrument id, tick size, lot size etc. 
// TODO inc self fill called
// TODO test that qty is ordered correctly for fills i.e. price is ordered

.qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$1)));
        (); // CUrrent orders
        (1;`SELL;100;0b;0b;0N;z); // Trade execution
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(10#1000)); // expected order book
        (); // expected orders
        (1b;1;enlist((`.order.ORDERSIDE$`SELL;100;1000);z)); // Add trade event mock
        (0b;0;()); // ApplyFill mock
        (0b;0;()) // IncSelfFill mock
    )]];

.qt.AddCase[test;"orderbook does not have agent orders, trade was made by an agent, trade is larger than best qty";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        (1;`SELL;1500;0b;1b;1;z); // Trade execution
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(10#1000)); // expected order book
        (); // expected orders
        (1b;1;( // side size price
            ((`.order.ORDERSIDE$`SELL;100;1000);z);
            ((`.order.ORDERSIDE$`SELL;100;1000);z)
        )); // Add trade event mock
        (1b;1;( // qty;price;side;time;reduceOnly;isMaker;accountId
            (1000;1000;`.order.ORDERSIDE$`SELL;z;0b;0b;1);
            (1000;1000;`.order.ORDERSIDE$`SELL;z;0b;0b;1)
        )); // ApplyFill mock
        (0b;0;()) // IncSelfFill mock
    )]];

/ .qt.AddCase[test;;
/     deriveCaseParams[(
/         ((10#`BUY);1000-til 10;10#1000);();
/         ;();();
/         (1b;1;enlist ((`.order.ORDERSIDE$`SELL;1000;1000);cTime));
/         (1b;1;enlist (1000;1000;`.order.ORDERSIDE$`SELL;cTime;0b;0b;1));500
/     )]];

/ .qt.AddCase[test;"orderbook does not have agent orders, trade was made by an agent, trade is smaller than best qty";
/     deriveCaseParams[(
/         ((10#`BUY);1000-til 10;10#1000);();
/         (1;`SELL;500;0b;1b;1;cTime);();();
/         (1b;1; enlist((`.order.ORDERSIDE$`SELL;500;1000);cTime));
/         (1b;1;enlist (500;1000;`.order.ORDERSIDE$`SELL;cTime;0b;0b;1));0
/     )]];

/ .qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent, trade is smaller than best qty";
/     deriveCaseParams[(
/         ((10#`BUY);1000-til 10;10#1000);();
/         (1;`SELL;500;0b;0b;1;cTime);();();
/         (1b;1;enlist ((`.order.ORDERSIDE$`SELL;500;1000);cTime));
/         (0b;0;(()));0
/     )]];

/ // TODO check this
/ .qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent, trade is larger than best qty";
/     deriveCaseParams[(
/         ((10#`BUY);1000-til 10;10#1000);();
/         (1;`SELL;1500;0b;0b;1;cTime);();();
/         (1b;1;enlist ((`.order.ORDERSIDE$`SELL;1500;1000);cTime));
/         (0b;0;());0
/     )]];

/ / `cOB`cOrd`trade`eOB`eOrd`eAddTradeEvent`eApplyFill`eQty
/ .qt.AddCase[test;"orderbook has agent orders, trade doesn't fill agent order, trade execution > agent order offset, fill is agent";
/     deriveCaseParams[(
/         ((10#`BUY);1000-til 10;10#1000);(til[2];2#1;2#1;2#`BUY;2#`LIMIT;100 400;2#100;2#1000;2#cTime);
/         (1;`SELL;150;0b;1b;1;cTime);
/         ((10#`BUY);1000-til 10;900,9#1000);(til[2];2#1;2#1;2#`BUY;2#`LIMIT;0 300;50 100;2#1000;2#cTime);
/         (1b;2;(((`.order.ORDERSIDE$`SELL;100;1000);cTime);((`.order.ORDERSIDE$`SELL;50;1000);cTime)));
/         (1b;2;((50;1000;`.order.ORDERSIDE$`BUY;cTime;0b;1b;1);(50;1000;`.order.ORDERSIDE$`SELL;cTime;0b;0b;1)));0
/     )]];

/ .qt.AddCase[test;"orderbook has agent orders, trade fills agent order, trade execution < agent order offset, fill is agent";
/     deriveCaseParams[(
/         ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
/         (til[2];2#1;2#1;2#`BUY;2#`LIMIT;100 400;2#100;2#1000;2#z); // CUrrent orders
/         (1;`SELL;250;0b;1b;1;z); // Trade execution
/         ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(10#1000)); // expected order book
/         (til[2];2#1;2#1;2#`BUY;2#`LIMIT;100 400;2#100;2#1000;2#z); // expected orders
/         (1b;2;( // AddTradeEvent: side size price
/             ((`.order.ORDERSIDE$`SELL;100;1000);z);
/             ((`.order.ORDERSIDE$`SELL;50;1000);z)
/         ));
/         (1b;2;( // ApplyFill qty;price;side;time;reduceOnly;isMaker;accountId
/             (50;1000;`.order.ORDERSIDE$`BUY;z;0b;1b;1);
/             (50;1000;`.order.ORDERSIDE$`SELL;z;0b;0b;1)
/         ));
/         (0b;0;()) // IncSelfFill mock
/     )]];

/ .qt.AddCase[test;"orderbook has agent orders, trade fills agent order, trade execution < agent order offset, fill is agent";
/     deriveCaseParams[(
/         ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
/         (til[4];4#1;4#1;4#`BUY;4#`LIMIT;((2#100),(2#400));4#100;4#1000 999;4#z); // CUrrent orders
/         (1;`SELL;250;0b;1b;1;z); // Trade execution
/         ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(10#1000)); // expected order book
/         (til[4];4#1;4#1;4#`BUY;4#`LIMIT;((2#100),(2#400));4#100;4#1000 999;4#z); // expected orders
/         (1b;2;( // AddTradeEvent: side size price
/             ((`.order.ORDERSIDE$`SELL;100;1000);z);
/             ((`.order.ORDERSIDE$`SELL;50;1000);z)
/         ));
/         (1b;2;( // ApplyFill qty;price;side;time;reduceOnly;isMaker;accountId
/             (50;1000;`.order.ORDERSIDE$`BUY;z;0b;1b;1);
/             (50;1000;`.order.ORDERSIDE$`SELL;z;0b;0b;1)
/         ));
/         (0b;0;()) // IncSelfFill mock
/     )]];

.qt.AddCase[test;"orderbook has agent orders, trade fills agent order, trade execution < agent order offset, fill is agent";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;((2#100),(2#400));4#100;4#1000 999;4#z); // CUrrent orders
        (`.instrument.Instrument!0;`SELL;1450;0b;1b;`.account.Account!0;z); // Trade execution
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(10#1000)); // expected order book
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;((3#0),150);((3#0),250);4#1000 999;(3#`FILLED),`NEW;4#z); // expected orders
        (1b;8;( // AddTradeEvent: side size price
            ((`.order.ORDERSIDE$`SELL;1000;100);z);
            ((`.order.ORDERSIDE$`SELL;1000;100);z);
            ((`.order.ORDERSIDE$`SELL;1000;200);z);
            ((`.order.ORDERSIDE$`SELL;1000;100);z); // TODO make sure is sorted correctly
            ((`.order.ORDERSIDE$`SELL;1000;700);z);
            ((`.order.ORDERSIDE$`SELL;999;100);z);
            ((`.order.ORDERSIDE$`SELL;999;100);z);
            ((`.order.ORDERSIDE$`SELL;999;50);z)
        ));
        (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`BUY;z;0b;1b;999;-150);
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;1b;1000;1200);
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;0b;1000;1200);
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;0b;1000;1200)
        ));
        (0b;0;()) // IncSelfFill mock
    )]];


/ .qt.AddCase[test;"";
/     deriveCaseParams[(
/         ((10#`BUY);1000-til 10;10#1000);;
/         ;
/         ((10#`BUY);1000-til 10;900,9#1000);(til[2];2#1;2#1;2#`BUY;2#`LIMIT;0 150;0 100;2#1000;2#cTime);
/         (1b;2;((;cTime);(;cTime)));
/         (1b;2;(;));0
/     )]];

/ .qt.AddCase[test;
/     deriveCaseParams[]];

/ .qt.AddCase[test;;
/     deriveCaseParams[]];

/ .qt.AddCase[test;"orderbook has agent orders, trade doesn't fill agent order, trade execution > agent order offset, fill is not agent";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"orderbook has agent orders, trade fills agent order, trade execution < agent order offset, fill is not agent";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"agent order fills another agents order";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"agent fills its own limit order";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"agent order fills another agents order";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"no liquidity";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"should update instrument etc. last price";
/     deriveCaseParams[]];

/ / .qt.AddCase[test;"should update open interest, open value etc.";
/     / deriveCaseParams[]];

// New Order Tests
// -------------------------------------------------------------->

/ oBeforeAll :{
/     .instrument.NewInstrument[
/         `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier!
/         (1;0.5;1e5f;0f;1e7f;0f;1);
/         1b;.z.z];
/     };

/ oAfterAll :{
/     / delete from `.instrument.Instrument;
/     };

/ BAM:();

/ test:.qt.Unit[
/     ".order.NewOrder";
/     {[c]
/         p:c[`params]; 
/         if[count[p[`cOB]]>0;.order.ProcessDepthUpdate[p[`cOB]]];
  
/         // instantiate mock for ProcessTrade
/         mck: .qt.M[`.order.ProcessTrade;p[`mFn];c];

/         o:p[`order];

/         / show .instrument.Instrument;
/         res:.order.NewOrder[o;.z.z];
/         // Assertions
/         k:key p[`eOrd]; 
/         o1:first (0!select from .order.Order where orderId=1);
/         .qt.A[o1[k];~;p[`eOrd][k];"order";c];

/     };();(oBeforeAll;oAfterAll;defaultBeforeEach;defaultAfterEach);
/     "Global function for processing new orders"];

/ deriveCaseParams    :{[params]
    
/     p:`cOB`cOrd`order`eOB`eOrd`eEvents!(
/         makeDepthUpdate[params[0]];
/         params[1];
/         params[2];
/         params[3];
/         params[4];
/         params[5]
/         );
/     :p;
/     };

/ .qt.AddCase[test;"New limit order no previous depth or orders should update";
/     deriveCaseParams[(
/     ((10#`SELL);1000+til 10;10#1000);();
/     `accountId`instrumentId`side`otype`price`size!(1;1;`SELL;`LIMIT;1000;1000);
/     ([price:(1000+til 10)] side:(10#`.order.ORDERSIDE$`SELL);qty:(10#1000));
/     (`price`offset!(1000;1000));
/     ()
/     )]];

/ .qt.AddCase[test;"New limit order participate don't initiate not triggered, calls processCross";
/     deriveCaseParams[(
/     ((10#`SELL);1000+til 10;10#1000);();
/     `accountId`instrumentId`side`otype`price`size!(1;1;`SELL;`LIMIT;1000;1000);
/     ([price:(1000+til 10)] side:(10#`.order.ORDERSIDE$`SELL);qty:(10#1000));
/     (`price`offset!(1000;1000));
/     ()
/     )]];


/ .qt.AddCase[test;"New simple market order";
/     deriveCaseParams[ ]];

/ .qt.AddCase[test;"New simple stop market order";
/     deriveCaseParams[ ]];

/ .qt.AddCase[test;"New simple stop limit order";
/     deriveCaseParams[ ]];

/ .qt.AddCase[test;"Trash fields present";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid Account Id (form)";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid Order side";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid Order type";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid time in force";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid Exec inst";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid price tick size";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"order price>max price";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"order price<min price";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"order size>max order size";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"order price<min order size";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Account id not found";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Duplicate clOrdId";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Duplicate orderId";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Not enough margin to execute order";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Accounts do not match";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid stopPrice for order type";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid order type for exec inst";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Account id not found";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Order placed in book offset = offset at depth price";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Order placed in book offset when no depth orders exist";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Participate dont initiate cross throws error";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Dont participate dont initiate cross calls/places market order";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Order placed in book";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Incorrect time format for event";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Close order larger than inventory";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Close order with no inventory";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"multiple close orders (of STOP_LIMIT, STOP_MARKET, LIMIT), collectively than inventory";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid stop order price for trigger";
/     deriveCaseParams[]];


// Cancel Order Tests
// -------------------------------------------------------------->


// Amend Order Tests
// -------------------------------------------------------------->



// Update Mark Price
// -------------------------------------------------------------->

/ test:.qt.Unit[
/     ".order.triggerStop";
/     {[c]
/         p:c[`params];
        
/         res: .order.UpdateMarkPrice[p[`markPrice];1;.z.z];

/     };();({};{};defaultBeforeEach;defaultAfterEach);
/     "Private function for advancing stop orders once triggered"];
 
/ test:.qt.Unit[
/     ".order.UpdateMarkPrice";
/     {[c]
/         p:c[`params];
        
/         res: .order.UpdateMarkPrice[p[`markPrice];1;.z.z];

/     };();({};{};defaultBeforeEach;defaultAfterEach);
/     "Global function for processing mark price updates specifically for orders"];

/ .qt.AddCase[test;"Should update markprice for instrument, account inventory etc.";
/     deriveCaseParams[(
/         ();();96000;
/     )]];

/ .qt.AddCase[test;"Should update the cumulative unrealized pnl, available balance, margin, orders etc.";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Should liquidate relevant inventory/accounts depending on the configuration";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Should trigger triggerable stop limit orders";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Should not trigger non-triggerable stop limit orders";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Should trigger triggerable stop market orders";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Should not trigger non-triggerable stop market orders";
/     deriveCaseParams[]];

// TODO integration tests i.e. loading data and making sure that it works


.qt.RunTests[];