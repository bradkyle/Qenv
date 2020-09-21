

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
        mck1: .qt.M[`.pipe.egress.AddDepthEvent;{[a;b;c;d;e;f;g;h]};c];

        // instrument;nxt:(side;price;qty;hqty;time)
        .order.ProcessDepth[.util.testutils.defaultInstrument;p`nxt];

        / .util.testutils.checkMock[mck1;m[0];c];
        .util.testutils.checkDepth[p[`eDepth];c];
        .util.testutils._checkOrders[(`orderId`side`otype`offset`leaves`displayqty`price`time);p[`eOrd];c];

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
            p[0];
            .util.testutils.makeOrders[ordCols[p[1]];flip p[1]];
            nxt;
            enlist p[5];
            p[3]; // TODO shorten parameterization
            .util.testutils.makeOrders[ordCols[p[4]];flip p[4]]);
    };
    (
       
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
.qt.Unit[
    ".order.ProcessTrade";
    {[c]
        p:c[`params];
        delete from `.order.Order;
        delete from `.order.OrderBook; // TODO make general
        .order.OrderBook,:p`cDepth;
        .util.testutils.setupOrders[p`cOrd];

        m:p[`mocks];

        mck1: .qt.M[`.account.ApplyFillG;{[a;b;c;d;e;f;g;h]};c];
        mck2: .qt.M[`.pipe.egress.AddTradeEvent;{[a;b]};c];
        mck3: .qt.M[`.account.IncSelfFill;{[a;b;c]};c];
        mck5: .qt.M[`.pipe.egress.AddOrderUpdatedEvent;{[a;b]};c];
        mck4: .qt.M[`.pipe.egress.AddDepthEvent;{[a;b]};c];

        .order.ProcessTrade[
            .util.testutils.defaultInstrument;
            .util.testutils.defaultAccount;
            p`td];

        // TODO test all
        / .util.testutils.checkMock[mck1;m[0];c];  // Expected ApplyFill Mock
        / .util.testutils.checkMock[mck2;m[1];c];  // Expected AddTradeEvent Mock
        / .util.testutils.checkMock[mck3;m[2];c];  // Expected IncSelfFill Mock
        / .util.testutils.checkMock[mck4;m[3];c];  // Expected AddOrderUpdated Mock
        / .util.testutils.checkMock[mck5;m[4];c];  // Expected AddDepthEvent Mock

        .util.testutils.checkDepth[p[`eDepth];c];
        .util.testutils._checkOrders[
            (`orderId`side`otype`offset`leaves`displayqty`price`reduce`status`time);
            p[`eOrd];c];

    }; // TOOD derive from // TODO derive orderbook, orders
    {[p] 
        // TODO account for one record
        ordCols:`orderId`instrumentId`accountId`side`otype`offset`leaves`displayqty`price`time;
        ordColsEx:`orderId`instrumentId`accountId`side`otype`offset`leaves`displayqty`price`status`time;
        bookCols:`side`price`qty`hqty`iqty`vqty;
        .order.test.p4:p[4];
        .order.test.p1:p[1];
        :`cDepth`cOrd`td`mocks`eDepth`eOrd!(
            p[0];
            .util.testutils.makeOrders[ordCols;flip p[1]];
            p[2];
            (5_10#p);
            p[3]; // TODO shorten parameterization
            .util.testutils.makeOrders[ordColsEx;flip p[4]]);
    };
    (
        
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

/  .qt.SkpBes[11];
.qt.SkpBesTest[1];
/ .qt.SkpBes[46];
.qt.RunTests[];
