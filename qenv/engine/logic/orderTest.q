

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
/// TODO simulate order loss
/ .qt.SkpBesTest[31];
.qt.Unit[
    ".engine.logic.order.NewOrder";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck0: .qt.M[`.engine.Purge;{[a;b;c] show c};c];
        mck1: .qt.M[`.engine.model.inventory.GetInventory;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.account.UpdateAccount;{[a;b;c]};c];
        mck3: .qt.M[`.engine.model.inventory.UpdateInventory;{[a;b;c]};c];
        mck5: .qt.M[`.engine.model.order.CreateOrder;{[a;b;c]};c];
        mck6: .qt.M[`.engine.Emit;{[a;b]};c];
        mck7: .qt.M[`.engine.model.risktier.GetRiskTier;{[a;b] a}[m[5][3]];c];
        mck8: .qt.M[`.engine.model.feetier.GetFeeTier;{[a;b] a}[m[6][3]];c];
        mck9: .qt.M[`.engine.logic.account.Fill;{[a;b]};c];
        mck10: .qt.M[`.engine.logic.orderbook.Level;{[a;b]};c];

        res:.engine.logic.order.NewOrder[a 0;a 1;a 2];

        .qt.CheckMock[mck0;m[7];c];
        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
        .qt.CheckMock[mck5;m[3];c];
        .qt.CheckMock[mck6;m[4];c];
        .qt.CheckMock[mck7;m[5];c];
        .qt.CheckMock[mck8;m[6];c];
        .qt.RestoreMocks[];

    };
    {[p] :`args`eRes`mocks`err!p};
    ( // TODO sell side check
        ("Place new buy post only limit order at best price, no previous depth or agent orders should update depth";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul`mxPrice`mnPrice`mxSize`mnSize`ticksize`lotsize!(0;1;1000;1;7h$1e8;0;7h$1e8;0;1;1); // instrument
                `aId`bal`avail!(0;2000;2000); // account
                `oqty`price`dlt`reduce`dqty!(1;1000;1;1b;1) // fill
            );
            (); // res 
            (
                (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice!(2;0;0;0;0;0;0)); // GetInventory
                (1b;1;enlist(enlist(`aId`bal`avail`ft`rt!(0;2000;1000;1;1)));()); // Update Account
                (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice!(3;1000;0;0;0;0;0)));()); // Inventory 
                (1b;1;();()); // CreateOrder 
                (1b;3;();()); // Emit
                (1b;1;();1); // GetRiskTier
                (1b;1;();1); // GetFeeTier
                (0b;0;();()) // Purge 
            ); // mocks 
            () // err 
        ));
        ("Place new buy post only limit order, previous depth, no agent orders should update depth";(
            ( // Mocks
                `cntTyp`faceValue`mkprice`smul`mxPrice`mnPrice`mxSize`mnSize`ticksize`lotsize!(0;1;1000;1;7h$1e8;0;7h$1e8;0;1;1); // instrument
                `aId`bal`avail!(0;2000;2000); // account
                `oqty`price`dlt`reduce`dqty!(1;1000;1;1b;1) // fill
            );
            (); // res 
            (
                (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice!(2;0;0;0;0;0;0)); // GetInventory
                (1b;1;enlist(enlist(`aId`bal`avail`ft`rt!(0;2000;1000;1;1)));()); // Update Account
                (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice!(3;1000;0;0;0;0;0)));()); // Inventory 
                (1b;1;();()); // CreateOrder 
                (1b;3;();()); // Emit
                (1b;1;();1); // GetRiskTier
                (1b;1;();1); // GetFeeTier
                (0b;0;();()) // Purge 
            ); // mocks 
            () // err 
        ))
        / ("Place new buy post only limit order, previous depth, no agent orders should update depth";(
        /     ( // Mocks
        /         `cntTyp`faceValue`mkprice`smul!(0;1;1000;1); // instrument
        /         `aId`balance`mmr`imr!(0;0.1;0.3;2); // account
        /         `qty`price`dlt`reduce!(1;1000;1;1b) // fill
        /     );
        /     (); // res 
        /     (
        /         (1b;1;();`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice!(2;0;0;0;0;0;0)); // GetInventory
        /         (1b;1;enlist(enlist(`aId`balance`mmr`imr`mkrfee`tkrfee!(0,(5#0.1))));()); // Update Account
        /         (1b;1;enlist(enlist(`ordQty`ordVal`ordLoss`amt`totalEntry`execCost`avgPrice`rpnl`upnl!(1;1000;0;1;1;100000;1000;0;0)));());  
        /         (1b;1;enlist(enlist(`cntTyp`faceValue`mkprice`smul!(0;1;1000;1)));()); // Update Instrument 
        /         (1b;3;();`amt`abc!()); // Emit
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // GetRiskTier
        /         (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // GetFeeTier
        /     ); // mocks 
        /     () // err 
        / ))
        / ("Place new buy post only limit order at best price, no previous depth or agent orders should update depth";(
        /     (); // Current Depth
        /     (); // Current Orders 
        /     (); // Current Instrument
        /     `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;999;0b;z); // Order Placed
        /     ([price:enlist(999)] side:enlist(1);qty:enlist(0);hqty:enlist(0);iqty:enlist(0);vqty:enlist(100)); // Expected Depth
        /     enlist(1;1;1;1;1;1;0;100;100;100;999;0b;z); // Expected Orders
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (1b;1;()); // Expected AddOrderCreatedEvent Mock
        /     (1b;1;())  // Expected AddDepthEvent Mock
        / ));
        / ("Place new buy post only limit order, previous depth, no agent orders should update depth";(
        /     ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(100)); // Current Depth
        /     (); 
        /     `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(1;1;1;1;1;100;100;999;0b;z); // Order Placed
        /     ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(200)); // Expected Depth
        /     enlist(1;1;1;1;1;1;100;100;100;100;999;0b;z); // Expected Orders 
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (1b;1;()); // Expected AddOrderCreatedEvent Mock
        /     (1b;1;())  // Expected AddDepthEvent Mock
        / ));
        / ("Place new buy post only limit order, previous depth, multiple agent orders should update depth";(
        /     ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
        /     (
        /         (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /         (2;2;1;1;1;1;120;100;100;100;999;0b;z)
        /     ); // Current Orders 
        /     `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(3;1;1;1;1;100;100;999;0b;z); // Fill Execution
        /     ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(400)); // Expected Depth
        /     (
        /         (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /         (2;2;1;1;1;1;120;100;100;100;999;0b;z);
        /         (3;3;1;1;1;1;300;100;100;100;999;0b;z)
        /     ); // Expected Orders
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (1b;1;()); // Expected AddOrderCreatedEvent Mock
        /     (1b;1;())  // Expected AddDepthEvent Mock
        / ));
        / ("Place new buy post only limit order, previous depth, multiple agent orders should update depth (best price-1 level) (not on occupied level)";(
        /     ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
        /     (
        /         (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /         (2;2;1;1;1;1;120;100;100;100;999;0b;z)
        /     ); 
        /     `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(3;1;1;1;1;100;100;998;0b;z); // Fill Execution
        /     ([price:(999 998)] side:(1 1);qty:(100 0);hqty:(0 0);iqty:(0 0);vqty:(300 100)); // Expected Depth
        /     (
        /         (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /         (2;2;1;1;1;1;120;100;100;100;999;0b;z)
        /     ); // Expected Orders
        /     (0b;0;()); // Expected ProcessTrade Mock
        /     (1b;1;()); // Expected AddOrderCreatedEvent Mock
        /     (1b;1;())  // Expected AddDepthEvent Mock
        / ));
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
        /("Place new buy limit order (not post only) crosses spread, previous depth, should invoke processTrade";(
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
        /    (
        /        (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /        (2;2;1;1;1;1;120;100;100;100;999;0b;z)
        /    );
        /    `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
        /    `clId`instrumentId`accountId`side`otype`offset`size`price`reduce`time!(3;1;1;1;1;100;100;1000;0b;z); // Fill Execution
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Expected Depth
        /    (
        /        (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /        (2;2;1;1;1;1;120;100;100;100;999;0b;z)
        /    ); // Expected Orders
        /    (1b;1;()); // Expected ProcessTrade Mock
        /    (0b;0;()); // Expected AddOrderCreatedEvent Mock
        /    (0b;0;())  // Expected AddDepthEvent Mock
        /)); 
        ///
        /("Place new iceberg post only limit order, no previous depth, no agent orders should update depth";(
        /    (); // Current Depth
        /    (); 
        /    ();
        /    `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(1;1;1;1;5;1;100;999;0b;z); // Fill Execution
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(0);hqty:enlist(0);iqty:enlist(99);vqty:enlist(1)); // Expected Depth
        /    enlist(1;1;1;1;1;5;0;100;100;1;999;0b;z); // Expected Orders
        /    (0b;0;()); // Expected ProcessTrade Mock
        /    (1b;1;()); // Expected AddOrderCreatedEvent Mock
        /    (1b;1;())  // Expected AddDepthEvent Mock
        /));
        /("Place new buy iceberg post only limit order, previous depth, no agent orders should update depth";(
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(100)); // Current Depth
        /    ();
        /    `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
        /    `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(1;1;1;1;5;1;100;999;0b;z);  // Order Placed
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(99);vqty:enlist(101)); // Expected Depth
        /    enlist(1;1;1;1;1;5;100;100;100;1;999;0b;z); // Expected Orders
        /    (0b;0;()); // Expected ProcessTrade Mock
        /    (1b;1;()); // Expected AddOrderCreatedEvent Mock
        /    (1b;1;())  // Expected AddDepthEvent Mock
        /));
        /("Place new buy iceberg post only limit order, previous depth, agent orders should update depth";(
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
        /    (
        /        (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /        (2;2;1;1;1;1;120;100;100;100;999;0b;z)
        /    );
        /    `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
        /    `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(3;1;1;1;5;1;100;999;0b;z);  // Order Placed
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(99);vqty:enlist(301)); // Expected Depth
        /    (
        /        (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /        (2;2;1;1;1;1;120;100;100;100;999;0b;z);
        /        (3;3;1;1;1;5;300;100;100;1;999;0b;z)
        /    ); // Expected Orders
        /    (0b;0;()); // Expected ProcessTrade Mock
        /    (1b;1;()); // Expected AddOrderCreatedEvent Mock
        /    (1b;1;())  // Expected AddDepthEvent Mock
        /));  
        /("Place new buy iceberg post only limit order crosses spread, previous depth, agent orders should invoke ProcessTrade";(
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
        /    (
        /        (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /        (2;2;1;1;1;1;120;100;100;100;999;0b;z)
        /    );
        /    `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
        /    `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(3;1;1;1;5;1;100;1000;0b;z);  // Order Placed
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Expected Depth
        /    (
        /        (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /        (2;2;1;1;1;1;120;100;100;100;999;0b;z)
        /    ); // Expected Orders
        /    (1b;1;()); // Expected ProcessTrade Mock
        /    (0b;0;()); // Expected AddOrderCreatedEvent Mock
        /    (0b;0;())  // Expected AddDepthEvent Mock
        /));  
        ///
        /("Place new hidden post only limit order, no previous depth, no agent orders should update depth";(
        /    (); // Current Depth
        /    (); 
        /    ();
        /    `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(1;1;1;1;4;0;100;999;0b;z); // Fill Execution
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(0);hqty:enlist(0);iqty:enlist(100);vqty:enlist(0)); // Expected Depth
        /    enlist(1;1;1;1;1;4;0;100;100;0;999;0b;z); // Expected Orders
        /    (0b;0;()); // Expected ProcessTrade Mock
        /    (1b;1;()); // Expected AddOrderCreatedEvent Mock
        /    (1b;1;())  // Expected AddDepthEvent Mock
        /));
        /("Place new buy hidden post only limit order, previous depth, no agent orders should update depth";(
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(100)); // Current Depth
        /    ();
        /    `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
        /    `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(1;1;1;1;4;0;100;999;0b;z);  // Order Placed
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(100);vqty:enlist(100)); // Expected Depth
        /    enlist(1;1;1;1;1;4;100;100;100;0;999;0b;z); // Expected Orders
        /    (0b;0;()); // Expected ProcessTrade Mock
        /    (1b;1;()); // Expected AddOrderCreatedEvent Mock
        /    (1b;1;())  // Expected AddDepthEvent Mock
        /));
        /("Place new buy hidden post only limit order, previous depth, agent orders should update depth";(
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
        /    (
        /        (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /        (2;2;1;1;1;1;120;100;100;100;999;0b;z)
        /    );
        /    `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
        /    `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(3;1;1;1;4;0;100;999;0b;z);  // Order Placed
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(100);vqty:enlist(300)); // Expected Depth
        /    (
        /        (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /        (2;2;1;1;1;1;120;100;100;100;999;0b;z);
        /        (3;3;1;1;1;4;300;100;100;0;999;0b;z)
        /    ); // Expected Orders
        /    (0b;0;()); // Expected ProcessTrade Mock
        /    (1b;1;()); // Expected AddOrderCreatedEvent Mock
        /    (1b;1;())  // Expected AddDepthEvent Mock
        /));  
        /("Place new buy hidden post only limit order crosses spread, previous depth, agent orders should invoke ProcessTrade";(
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Current Depth
        /    (
        /        (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /        (2;2;1;1;1;1;120;100;100;100;999;0b;z)
        /    );
        /    `bestAskPrice`bestBidPrice`hasLiquidityBuy`hasLiquiditySell!(1000;999;1b;1b);
        /    `clId`instrumentId`accountId`side`otype`displayqty`size`price`reduce`time!(3;1;1;1;4;0;100;1000;0b;z);  // Order Placed
        /    ([price:enlist(999)] side:enlist(1);qty:enlist(100);hqty:enlist(0);iqty:enlist(0);vqty:enlist(300)); // Expected Depth
        /    (
        /        (1;1;1;1;1;1;10;100;100;100;999;0b;z);
        /        (2;2;1;1;1;1;120;100;100;100;999;0b;z)
        /    ); // Expected Orders
        /    (1b;1;()); // Expected ProcessTrade Mock
        /    (0b;0;()); // Expected AddOrderCreatedEvent Mock
        /    (0b;0;())  // Expected AddDepthEvent Mock
        /));  
        ///
        /("Place new buy market order, no previous depth or agent orders should update depth";(
        /    (); // Current Depth
        /    (); // Current Orders 
        /    (); // Current Instrument
        /    `clId`instrumentId`accountId`side`otype`size`reduce`time!(1;1;1;1;0;100;0b;z); // Order Placed
        /    (); // Expected Depth
        /    (); // Expected Orders
        /    (1b;1;()); // Expected ProcessTrade Mock
        /    (0b;0;()); // Expected AddOrderCreatedEvent Mock
        /    (0b;0;())  // Expected AddDepthEvent Mock
        /))
    );
    ({};{};{};{});
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];

// TODO test filled amt
// TODO check mock invocations
// TODO test change in display qty, side, price, execInst
// TODO test with clOrdId
.qt.Unit[
    ".engine.logic.order.AmendOrder";
    {[c]
        .qt.RunUnit[c;.engine.logic.order.AmendOrder];

    };
    {[p] :`args`eRes`mocks`err!p};
    (
        // Decreasing in size stays at same price
        ("Amend limit order (first in queue), smaller than previous, should update offsets, depth etc.";(
								(19);();();()
        )); 
        ("Amend limit order (second in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
        )); 
        ("Amend limit order (last in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
        ));
        // Increasing in size stays at same price
        ("Amend limit order (first in queue), larger than previous, should update offsets, depth etc.";(
								();();();()
        )); 
        ("Amend limit order (second in queue), larger than previous, should update offsets, depth etc.";(
								();();();()
        )); 
        ("Amend limit order (last in queue), larger than previous, should update offsets, depth etc.";(
								();();();()
        ));
        // Different price same side no orders on new level (same size)
        ("Amend limit order (first in queue), different price same side, should update offsets, depth etc.";(
								();();();()
        )); 
        ("Amend limit order (second in queue), different price same side, should update offsets, depth etc.";(
								();();();()
        )); 
        ("Amend limit order (last in queue), different price same side, should update offsets, depth etc.";(
								();();();()
        ));
        // Amend to zero (Cancellation)
        ("Amend limit order (first in queue) to zero, different price same side, should update offsets, depth etc.";(
								();();();()
        )); 
        ("Amend limit order (second in queue) to zero, different price same side, should update offsets, depth etc.";(
								();();();()
        )); 
        ("Amend limit order (last in queue) to zero, different price same side, should update offsets, depth etc.";(
								();();();()
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


.qt.Unit[
    ".engine.logic.order.CancelOrder";
    {[c]
        .qt.RunUnit[c;.engine.logic.order.CancelOrder];

    };
    {[p] :`args`eRes`mocks`err!p};
    (
        // Decreasing in size stays at same price
        ("Amend limit order (first in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
				)); 
        ("Amend limit order (first in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
				)) 
    );
    ({};{};{};{});
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];


.qt.Unit[
    ".engine.logic.order.CancelAllOrders";
    {[c]
        .qt.RunUnit[c;.engine.logic.order.CancelAllOrders];

    };
    {[p] :`args`eRes`mocks`err!p};
    (
        // Decreasing in size stays at same price
        ("Amend limit order (first in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
				)); 
        ("Amend limit order (first in queue), smaller than previous, should update offsets, depth etc.";(
								();();();()
				)) 
    );
    ({};{};{};{});
    "Global function for processing new orders, amending orders and cancelling orders (amending to 0)"];








