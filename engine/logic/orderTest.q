

// TODO integration tests.

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
    ({};{};{};{});
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
    ({};{};{};{});
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];


