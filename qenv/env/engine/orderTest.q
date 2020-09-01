\l account.q
\l instrument.q
\l event.q
\l order.q
system "d .orderTest";
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

checkEvents     :{
    if[count[x[`eEv]]>0;
            .qt.A[.event.Events;~;x[`eEv];"orderbook";y];
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
        (1;0.5;1e5f;0f;1e7f;0f;1);.z.z];
    };


// Process Depth Update
// -------------------------------------------------------------->

test:.qt.Unit[
    ".order.ProcessDepthUpdateEvent";
    {[c]
        p:c[`params];
        .qt.M[`.account.UpdateOrderMargin;{[a;b;c;d;e]};c];
        / show p[`event];/         
        setupDepth[p];
        setupOrders[p];

        .order.ProcessDepthUpdateEvent[p[`event]];
        // Assertions
        checkDepth[p;c];
        checkOrders[p;c];        
        / checkEvents[p;c];        

    };();();({};{};defaultBeforeEach;defaultAfterEach);
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
// TODO max num levels

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
        .qt.M[`.account.UpdateOrderMargin;{[a;b;c;d;e]};c];

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
        
    };();();({};{};defaultBeforeEach;defaultAfterEach);
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

    o:makeOrders[params[1]];

    p:`cOB`cOrd`trade`eOB`eOrd`eAddTradeEvent`eApplyFill`eIncSelfFill!(
        makeDepthUpdate[params[0]]; 
        o;
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

.qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent trade is smaller than first level";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$1)));
        (); // CUrrent orders
        (1;`SELL;100;0b;0b;0N;z); // Trade execution
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(900,9#1000);vqty:(900,9#1000)); // expected order book
        (); // expected orders
        (1b;1;enlist((`.order.ORDERSIDE$`SELL;1000;100);z)); // Add trade event mock
        (0b;0;()); // ApplyFill mock
        (0b;0;()) // IncSelfFill mock
    )]];

.qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent trade is larger than first level";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$1)));
        (); // CUrrent orders
        (1;`SELL;1500;0b;0b;0N;z); // Trade execution
        ([price:999-til 9] side:(9#`.order.ORDERSIDE$`BUY);qty:(500,8#1000);vqty:(500,8#1000)); // expected order book
        (); // expected orders
        (1b;2;(
            ((`.order.ORDERSIDE$`SELL;999;500);z);
            ((`.order.ORDERSIDE$`SELL;1000;1000);z)
        )); // Add trade event mock
        (0b;0;()); // ApplyFill mock
        (0b;0;()) // IncSelfFill mock
    )]];

.qt.AddCase[test;"orderbook does not have agent orders, trade was made by an agent, trade is larger than best qty";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        (`.instrument.Instrument!0;`SELL;1500;0b;1b;`.account.Account!0;z); // Trade execution
        ([price:999-til 9] side:(9#`.order.ORDERSIDE$`BUY);qty:(500,8#1000);vqty:(500,8#1000)); // expected order book
        (); // expected orders
        (1b;2;( // side size price
            ((`.order.ORDERSIDE$`SELL;999;500);z);
            ((`.order.ORDERSIDE$`SELL;1000;1000);z)
        )); // Add trade event mock
        (1b;2;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;0b;999;500);
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;0b;1000;1000)
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

/ .qt.AddCase[test;"";
/     deriveCaseParams[(
/         ((10#`BUY);1000-til 10;10#1000);();
/         (1;`SELL;500;0b;1b;1;cTime);();();
/         (1b;1; enlist((`.order.ORDERSIDE$`SELL;500;1000);cTime));
/         (1b;1;enlist (500;1000;`.order.ORDERSIDE$`SELL;cTime;0b;0b;1));0
/     )]];


.qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent, trade is smaller than best qty";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        (`.instrument.Instrument!0;`SELL;200;0b;0b;0N;z); // Trade execution: 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(800,9#1000);vqty:(800,9#1000)); // expected order book
        (); // expected orders
        (1b;1; // AddTradeEvent: side size price
            enlist((`.order.ORDERSIDE$`SELL;1000;200);z)
        );
        (0b;0;());
        (0b;0;()) // IncSelfFill mock
    )]];

.qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent, trade is larger than best qty";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        (`.instrument.Instrument!0;`SELL;1200;0b;0b;0N;z); // Trade execution: 
        ([price:999-til 9] side:(9#`.order.ORDERSIDE$`BUY);qty:(800,8#1000);vqty:(800,8#1000)); // expected order book
        (); // expected orders
        (1b;2;( // AddTradeEvent: side size price
            ((`.order.ORDERSIDE$`SELL;999;200);z);
            ((`.order.ORDERSIDE$`SELL;1000;1000);z)
        ));
        (0b;0;());
        (0b;0;()) // IncSelfFill mock
    )]];

.qt.AddCase[test;"orderbook does not have agent orders, trade was made by an agent, trade is smaller than best qty";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        (`.instrument.Instrument!0;`SELL;200;0b;1b;`.account.Account!0;z); // Trade execution: 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(800,9#1000);vqty:(800,9#1000)); // expected order book
        (); // expected orders
        (1b;1; // AddTradeEvent: side size price
            enlist((`.order.ORDERSIDE$`SELL;1000;200);z)
        );
        (1b;1; // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty 
            enlist(`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;0b;1000;200)
        );
        (0b;0;()) // IncSelfFill mock
    )]];

.qt.AddCase[test;"orderbook does not have agent orders, trade was made by an agent, trade is larger than best qty";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        (`.instrument.Instrument!0;`SELL;1200;0b;1b;`.account.Account!0;z); // Trade execution: 
        ([price:999-til 9] side:(9#`.order.ORDERSIDE$`BUY);qty:(800,8#1000);vqty:(800,8#1000)); // expected order book
        (); // expected orders
        (1b;2;( // AddTradeEvent: side size price
            ((`.order.ORDERSIDE$`SELL;1000;1000);z);
            ((`.order.ORDERSIDE$`SELL;999;200);z)
        ));
        (1b;2;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty 
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;0b;1000;1000);
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;0b;999;200)
        ));
        (0b;0;()) // IncSelfFill mock
    )]];

.qt.AddCase[test;"orderbook has agent orders, lvl1 size > qty, trade doesn't fill agent order, trade execution < agent order offset, fill is agent";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;((2#400),(2#600));4#100;4#1000 999;4#z); // CUrrent orders
        (`.instrument.Instrument!0;`SELL;200;0b;1b;`.account.Account!0;z); // Trade execution: 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(800,9#1000);vqty:(1000 1200, 8#1000)); // expected order book
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;(200 400 400 600);4#100;4#1000 999;4#`NEW;4#z); // expected orders
        (1b;1; // AddTradeEvent: side size price
            enlist((`.order.ORDERSIDE$`SELL;1000;200);z)
        );
        (1b;1; // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty 
            enlist(`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;0b;1000;200)
        );
        (0b;0;()) // IncSelfFill mock
    )]];

.qt.AddCase[test;"orderbook has agent orders, lvl1 size < qty, trade doesn't fill agent order, trade execution < agent order offset, fill is agent";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;((2#400),(2#600));4#100;4#999 998;4#z); // CUrrent orders
        (`.instrument.Instrument!0;`SELL;1200;0b;1b;`.account.Account!0;z); // Trade execution: 
        ([price:999-til 9] side:(9#`.order.ORDERSIDE$`BUY);qty:(800,8#1000);vqty:(1000 1200, 7#1000)); // expected order book
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;(200 400 400 600);4#100;4#999 998;4#`NEW;4#z); // expected orders
        (1b;2;( // AddTradeEvent: side size price
            ((`.order.ORDERSIDE$`SELL;999;200);z);
            ((`.order.ORDERSIDE$`SELL;1000;1000);z)
        ));
        (1b;2;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty 
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;0b;999;200);
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;0b;1000;1000)
        ));
        (0b;0;()) // IncSelfFill mock
    )]];

.qt.AddCase[test;"orderbook has agent orders, trade fills agent order, trade execution > agent order offset, fill is agent";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;((2#100),(2#400));4#100;4#1000 999;4#z); // CUrrent orders
        (`.instrument.Instrument!0;`SELL;1450;0b;1b;`.account.Account!0;z); // Trade execution
        ([price:999-til 9] side:(9#`.order.ORDERSIDE$`BUY);qty:(550,(8#1000));vqty:(750,(8#1000))); // expected order book
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;(4#0);((3#0),50);4#1000 999;(3#`FILLED),`NEW;4#z); // expected orders
        (1b;9;( // AddTradeEvent: side size price
            ((`.order.ORDERSIDE$`SELL;1000;100);z);
            ((`.order.ORDERSIDE$`SELL;1000;100);z);
            ((`.order.ORDERSIDE$`SELL;1000;200);z);
            ((`.order.ORDERSIDE$`SELL;1000;100);z); // TODO make sure is sorted correctly
            ((`.order.ORDERSIDE$`SELL;1000;500);z);
            ((`.order.ORDERSIDE$`SELL;999;100);z);
            ((`.order.ORDERSIDE$`SELL;999;100);z);
            ((`.order.ORDERSIDE$`SELL;999;200);z);
            ((`.order.ORDERSIDE$`SELL;999;50);z)
        ));
        (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`BUY;z;0b;1b;999;50);
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`BUY;z;0b;1b;1000;800);
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;0b;999;450);
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;0b;1000;1000)
        ));
        (1b;1;enlist(`.account.Account!0;4;2300)) // IncSelfFill mock
    )]];

.qt.AddCase[test;"orderbook has agent orders, trade doesn't fill agent order, trade execution < agent order offset, fill is not agent";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;((2#100),(2#400));4#100;4#1000 999;4#z); // CUrrent orders
        (`.instrument.Instrument!0;`SELL;50;0b;0b;0N;z); // Trade execution
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(950,9#1000);vqty:(1150 1200, 8#1000)); // expected order book
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;(50 100 350 400);(4#100);4#1000 999;4#`NEW;4#z); // expected orders
        (1b;1; // AddTradeEvent: side size price 
            enlist((`.order.ORDERSIDE$`SELL;1000;50);z)
        );
        (0b;0;());
        (0b;0;()) // IncSelfFill mock
    )]];

.qt.AddCase[test;"orderbook has agent orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;((2#100),(2#400));4#100;4#1000 999;4#z); // CUrrent orders
        (`.instrument.Instrument!0;`SELL;1450;1b;1b;`.account.Account!1;z); // Trade execution
        ([price:999-til 9] side:(9#`.order.ORDERSIDE$`BUY);qty:(550,(8#1000));vqty:(750,(8#1000))); // expected order book
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;(4#0);((3#0),50);4#1000 999;(3#`FILLED),`NEW;4#z); // expected orders
        (1b;9;( // AddTradeEvent: side size price
            ((`.order.ORDERSIDE$`SELL;1000;100);z);
            ((`.order.ORDERSIDE$`SELL;1000;100);z);
            ((`.order.ORDERSIDE$`SELL;1000;200);z);
            ((`.order.ORDERSIDE$`SELL;1000;100);z); // TODO make sure is sorted correctly
            ((`.order.ORDERSIDE$`SELL;1000;500);z);
            ((`.order.ORDERSIDE$`SELL;999;100);z);
            ((`.order.ORDERSIDE$`SELL;999;100);z);
            ((`.order.ORDERSIDE$`SELL;999;200);z);
            ((`.order.ORDERSIDE$`SELL;999;50);z)
        ));
        (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`BUY;z;0b;1b;999;50);
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`BUY;z;0b;1b;1000;800);
            (`.account.Account!1;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;1b;0b;999;450);
            (`.account.Account!1;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;1b;0b;1000;1000)
        ));
        (0b;0;()) // IncSelfFill mock
    )]];

.qt.AddCase[test;"SELL: orderbook has agent orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;((2#100),(2#400));4#100;4#1000 999;4#z); // CUrrent orders
        (`.instrument.Instrument!0;`SELL;1450;1b;1b;`.account.Account!1;z); // Trade execution
        ([price:999-til 9] side:(9#`.order.ORDERSIDE$`BUY);qty:(550,(8#1000));vqty:(750,(8#1000))); // expected order book
        (til[4];4#1;4#1;4#`BUY;4#`LIMIT;(4#0);((3#0),50);4#1000 999;(3#`FILLED),`NEW;4#z); // expected orders
        (1b;9;( // AddTradeEvent: side size price
            ((`.order.ORDERSIDE$`SELL;1000;100);z);
            ((`.order.ORDERSIDE$`SELL;1000;100);z);
            ((`.order.ORDERSIDE$`SELL;1000;200);z);
            ((`.order.ORDERSIDE$`SELL;1000;100);z); // TODO make sure is sorted correctly
            ((`.order.ORDERSIDE$`SELL;1000;500);z);
            ((`.order.ORDERSIDE$`SELL;999;100);z);
            ((`.order.ORDERSIDE$`SELL;999;100);z);
            ((`.order.ORDERSIDE$`SELL;999;200);z);
            ((`.order.ORDERSIDE$`SELL;999;50);z)
        ));
        (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`BUY;z;0b;1b;999;50);
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`BUY;z;0b;1b;1000;800);
            (`.account.Account!1;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;1b;0b;999;450);
            (`.account.Account!1;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;1b;0b;1000;1000)
        ));
        (0b;0;()) // IncSelfFill mock
    )]];

.qt.AddCase[test;"BUY: orderbook has agent orders, trade fills other agent order, trade execution > agent order offset, fill is agent (reduce only)";
    deriveCaseParams[(
        ((10#`SELL);1000+til 10;10#1000;(10#z,(z+`second$5)));
        (til[4];4#1;4#1;4#`SELL;4#`LIMIT;((2#100),(2#400));4#100;4#1000 1001;4#z); // CUrrent orders
        (`.instrument.Instrument!0;`BUY;1450;1b;1b;`.account.Account!1;z); // Trade execution
        ([price:1001+til 9] side:(9#`.order.ORDERSIDE$`SELL);qty:(550,(8#1000));vqty:(750,(8#1000))); // expected order book
        (til[4];4#1;4#1;4#`SELL;4#`LIMIT;(4#0);((3#0),50);4#1000 1001;(3#`FILLED),`NEW;4#z); // expected orders
        (1b;9;( // AddTradeEvent: side size price
            ((`.order.ORDERSIDE$`BUY;1000;100);z);
            ((`.order.ORDERSIDE$`BUY;1000;100);z);
            ((`.order.ORDERSIDE$`BUY;1000;200);z);
            ((`.order.ORDERSIDE$`BUY;1000;100);z); // TODO make sure is sorted correctly
            ((`.order.ORDERSIDE$`BUY;1000;500);z);
            ((`.order.ORDERSIDE$`BUY;1001;100);z);
            ((`.order.ORDERSIDE$`BUY;1001;100);z);
            ((`.order.ORDERSIDE$`BUY;1001;200);z);
            ((`.order.ORDERSIDE$`BUY;1001;50);z)
        ));
        (1b;4;( // ApplyFill accountId;instrumentId;side;time;reduceOnly;isMaker;price;qty
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;1b;1001;50);
            (`.account.Account!0;`.instrument.Instrument!0;`.order.ORDERSIDE$`SELL;z;0b;1b;1000;800);
            (`.account.Account!1;`.instrument.Instrument!0;`.order.ORDERSIDE$`BUY;z;1b;0b;1001;450);
            (`.account.Account!1;`.instrument.Instrument!0;`.order.ORDERSIDE$`BUY;z;1b;0b;1000;1000)
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

/ .qt.AddCase[test;"";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"orderbook has agent orders, trade fills agent order, trade execution < agent order offset, fill is not agent";
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
// TODO response
test:.qt.Unit[
    ".order.NewOrder";
    {[c]
        p:c[`params];  
        setupDepth[p];
        setupOrders[p];

        p1:p[`eProcessTrade];
        p2:p[`eAddNewOrderEvent];
        p3:p[`eUpdateOrderMargin];   

        // instantiate mock for ApplyFill
        mck1: .qt.M[`.order.ProcessTrade;{[a;b;c;d;e;f;g;h]};c];
        mck2: .qt.M[`.order.AddNewOrderEvent;{[a;b]};c];
        mck3: .qt.M[`.account.UpdateOrderMargin;p3[`fn];c];

        o:p[`order];
        res:.order.NewOrder[o;.z.z]; // TODO assert throws?

        .qt.MA[
            mck1;
            p1[`called];
            p1[`numCalls];
            p1[`calledWith];c];

        .qt.MA[
            mck2;
            p2[`called];
            p2[`numCalls];
            p2[`calledWith];c];

        .qt.MA[
            mck3;
            p3[`called];
            p3[`numCalls];
            p3[`calledWith];c];

        checkOrders[p;c];
        checkDepth[p;c];
        checkEvents[p;c];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];

// TODO test throws errors
// TODO add account
deriveCaseParams    :{[params] 
    mCols:`called`numCalls`calledWith; // Mock specific

    makeOrdersEx :{
    :$[count[x]>0;[ 
        // Side, Price, Size
        :{:(`clId`instrumentId`accountId`side`otype`offset`leaves`price`status!(
            x[0];x[1];x[2];(`.order.ORDERSIDE$x[3]);(`.order.ORDERTYPE$x[4]);x[5];x[6];x[7];(`.order.ORDERSTATUS$x[8]));x[9])} each flip[x];
        ];()]};

    p:`cOB`cOrd`order`eOB`eOrd`eEv`eUpdateOrderMargin`eProcessTrade`eAddNewOrderEvent!(
        makeDepthUpdate[params[0]]; 
        makeOrders[params[1]];
        params[2];
        params[3];
        makeOrdersEx[params[4]];
        params[5];
        (`fn,mCols)!params[6];
        mCols!params[7];
        mCols!params[8]
        );
    :p;
    };

// TODO test participate not initiate
// TODO test unsuccessful update order margin

.qt.AddCase[test;"Place new limit order, no previous depth should update depth";
    deriveCaseParams[(
        ();
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`price`size!(1;1;`BUY;`LIMIT;1000;1000); // TODO 
        ([price:enlist[1000]] side:enlist[`.order.ORDERSIDE$`BUY]; qty:enlist[1000];vqty:enlist[1000]); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"Place new limit order, previous depth should update depth";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`price`size!(1;1;`BUY;`LIMIT;1000;1000); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"Place new limit order";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`price`size!(1;1;`BUY;`LIMIT;1000;1000); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"Place new limit order with participate dont initiate crosses spread";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`price`size`execInst!(1;1;`SELL;`LIMIT;1001;1000;(`PARTICIPATEDONTINITIATE)); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"Place new limit order without participate dont initiate crosses spread";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`price`size!(1;1;`SELL;`LIMIT;1001;1000); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"Place new market order";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size!(1;1;`SELL;`MARKET;1000); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"Place new market order with price, should ignore price";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"Place new limit order reduceOnly larger than short position";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"Place new limit order reduceOnly larger than long position";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];


.qt.AddCase[test;"Place new market order reduceOnly larger than short position";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"Place new market order reduceOnly larger than long position";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"Place new market order reduceOnly larger than long position";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];


.qt.AddCase[test;"invalid account Id";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"invalid order side";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"invalid account Id";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"invalid time in force";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"invalid order type";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"invalid tick size";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"order price>max price";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"order price<min price";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"duplicate clOrdId";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"not enough margin to execute order, errors";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"accounts do not match";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];
    
.qt.AddCase[test;"invalid stop price for order type";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];
    
.qt.AddCase[test;"invalid order type for exec inst";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"Invalid time format";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"closed order larger than inventory, hedged long";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"closed order larger than inventory, hedged short";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];


.qt.AddCase[test;"closed order larger than inventory, combined short";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"closed order larger than inventory, combined long";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"closed order no inventory";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"multiple closed orders larger than inventory";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"invalid stop price for trigger";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

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

test:.qt.Unit[
    ".order.CancelOrder";
    {[c]
        p:c[`params];  
        setupDepth[p];
        setupOrders[p];

        p1:p[`eProcessTrade];
        p2:p[`eAddCancelOrderEvent];
        p3:p[`eUpdateOrderMargin];   

        // instantiate mock for ApplyFill
        mck1: .qt.M[`.order.ProcessTrade;{[a;b;c;d;e;f;g;h]};c];
        mck2: .qt.M[`.order.AddNewOrderEvent;{[a;b]};c];
        mck3: .qt.M[`.account.UpdateOrderMargin;p3[`fn];c];

        o:p[`order];
        res:.order.CancelOrder[o;.z.z]; // TODO assert throws?

        .qt.MA[
            mck1;
            p1[`called];
            p1[`numCalls];
            p1[`calledWith];c];

        .qt.MA[
            mck2;
            p2[`called];
            p2[`numCalls];
            p2[`calledWith];c];

        .qt.MA[
            mck3;
            p3[`called];
            p3[`numCalls];
            p3[`calledWith];c];

        checkOrders[p;c];
        checkDepth[p;c];
        checkEvents[p;c];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];

deriveCaseParams    :{[params] 
    mCols:`called`numCalls`calledWith; // Mock specific

    makeOrdersEx :{
    :$[count[x]>0;[ 
        // Side, Price, Size
        :{:(`clId`instrumentId`accountId`side`otype`offset`leaves`price`status!(
            x[0];x[1];x[2];(`.order.ORDERSIDE$x[3]);(`.order.ORDERTYPE$x[4]);x[5];x[6];x[7];(`.order.ORDERSTATUS$x[8]));x[9])} each flip[x];
        ];()]};

    p:`cOB`cOrd`order`eOB`eOrd`eEv`eUpdateOrderMargin`eProcessTrade`eAddNewOrderEvent!(
        makeDepthUpdate[params[0]]; 
        makeOrders[params[1]];
        params[2];
        params[3];
        makeOrdersEx[params[4]];
        params[5];
        (`fn,mCols)!params[6];
        mCols!params[7];
        mCols!params[8]
        );
    :p;
    };


.qt.AddCase[test;"should cancel given order";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"should error if invalid accountId";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"should error if accountId was not found";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"should error if the order does not belong to the account";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"should update the order status to cancelled";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];


.qt.AddCase[test;"should update the offsets of other orders in level and the orderbook representation should be correct";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];
 
// Amend Order Tests
// -------------------------------------------------------------->

test:.qt.Unit[
    ".order.AmendOrder";
    {[c]
        p:c[`params];  
        setupDepth[p];
        setupOrders[p];

        p1:p[`eProcessTrade];
        p2:p[`eAddCancelOrderEvent];
        p3:p[`eUpdateOrderMargin];   

        // instantiate mock for ApplyFill
        mck1: .qt.M[`.order.ProcessTrade;{[a;b;c;d;e;f;g;h]};c];
        mck2: .qt.M[`.order.AddNewOrderEvent;{[a;b]};c];
        mck3: .qt.M[`.account.UpdateOrderMargin;p3[`fn];c];

        o:p[`order];
        res:.order.CancelOrder[o;.z.z]; // TODO assert throws?

        .qt.MA[
            mck1;
            p1[`called];
            p1[`numCalls];
            p1[`calledWith];c];

        .qt.MA[
            mck2;
            p2[`called];
            p2[`numCalls];
            p2[`calledWith];c];

        .qt.MA[
            mck3;
            p3[`called];
            p3[`numCalls];
            p3[`calledWith];c];

        checkOrders[p;c];
        checkDepth[p;c];
        checkEvents[p;c];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];

deriveCaseParams    :{[params] 
    mCols:`called`numCalls`calledWith; // Mock specific

    makeOrdersEx :{
    :$[count[x]>0;[ 
        // Side, Price, Size
        :{:(`clId`instrumentId`accountId`side`otype`offset`leaves`price`status!(
            x[0];x[1];x[2];(`.order.ORDERSIDE$x[3]);(`.order.ORDERTYPE$x[4]);x[5];x[6];x[7];(`.order.ORDERSTATUS$x[8]));x[9])} each flip[x];
        ];()]};

    p:`cOB`cOrd`order`eOB`eOrd`eEv`eUpdateOrderMargin`eProcessTrade`eAddNewOrderEvent!(
        makeDepthUpdate[params[0]]; 
        makeOrders[params[1]];
        params[2];
        params[3];
        makeOrdersEx[params[4]];
        params[5];
        (`fn,mCols)!params[6];
        mCols!params[7];
        mCols!params[8]
        );
    :p;
    };

.qt.AddCase[test;"should error if accountId is null";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"should error if accountId not found";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"should call cancel order if the new size is = 0";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;("if new order size<old order size",
    "should update orderbook,account etc.");
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;("if new order size>old order size",
    "should upsert the order with an new offset, update orderbook qty etc.");
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        `accountId`instrumentId`side`otype`size`price!(1;1;`SELL;`MARKET;1000;1005); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

// Update Mark Price
// -------------------------------------------------------------->
 
test:.qt.Unit[
    ".order.UpdateMarkPrice";
    {[c]
        p:c[`params];  
        setupOrders[p];

        p1:p[`eNewOrder];  

        // instantiate mock for ApplyFill
        mck1: .qt.M[`.order.NewOrder;{[a;b]};c];

        res:.order.UpdateMarkPrice[p[`markPrice];p[`instrumentId];.z.z]; // TODO assert throws?

        .qt.MA[
            mck1;
            p1[`called];
            p1[`numCalls];
            p1[`calledWith];c];


    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for updating the mark price with respect to the order namespace"];

deriveCaseParams    :{[params] 
    mCols:`called`numCalls`calledWith; // Mock specific
    pCols:`markPrice`instrumentId`time;

    makeOrdersEx :{
    :$[count[x]>0;[ 
        // Side, Price, Size
        :{:(`clId`instrumentId`accountId`side`otype`offset`leaves`price`status!(
            x[0];x[1];x[2];(`.order.ORDERSIDE$x[3]);(`.order.ORDERTYPE$x[4]);x[5];x[6];x[7];(`.order.ORDERSTATUS$x[8]));x[9])} each flip[x];
        ];()]};

    nom:(`fn,mCols)!params[6];

    p:`cOB`cOrd`params`eNewOrder!(
        makeDepthUpdate[params[0]]; 
        makeOrders[params[1]];
        pCols!params[2];
        nom  
        );
    :p;
    };


.qt.AddCase[test;"Should trigger buy stop orders with mark trigger and leave others";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        (1000;1;z); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.AddCase[test;"Should trigger sell stop orders with mark trigger and leave others";
    deriveCaseParams[(
        ((10#`BUY);1000-til 10;10#1000;(10#z,(z+`second$5)));
        (); // CUrrent orders
        (1000;1;z); // TODO 
        ([price:1000-til 10] side:(10#`.order.ORDERSIDE$`BUY);qty:(10#1000);vqty:(2000,9#1000)); // expected order book
        (); // expected orders
        ();
        ({[a;b;c;d;e]};1b;1;enlist(`.order.ORDERSIDE$`BUY;1000;1000;0b;1));
        (0b;0;());
        (1b;1;())
    )]];

.qt.RunTests[];