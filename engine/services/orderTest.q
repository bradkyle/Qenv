

// Process orders with multiple fails
// Process orders with no successful results  
// TODO max batch size
// TODO getLevels by price
.qt.Unit[
    ".engine.services.order.ProcessNewOrderEvent";
    {[c]
        .qt.RunUnit[c;.engine.services.order.ProcessNewOrderEvent];

    };.qt.generalParams;
    (
        enlist(("7:0) ProcessNewOrderEvents SELL: 1 single new order event");(
        (
          (`.engine.model.instrument.GetInstrumentByIds;{[x] 0!(count[x]#.engine.model.instrument.test.Instrument)};1b;1;enlist[1]);
          (`.engine.model.account.GetAccountById;{[x] 0!(count[x]#.engine.model.account.test.Account)};1b;1;enlist[1]);
          (`.engine.model.instrument.ValidInstrumentIds;{[x] count[x]#1b};1b;1;enlist[1]);
          (`.engine.model.account.ValidAccountIds;{[x] count[x]#1b};1b;1;enlist[1]);
          (`.engine.logic.fill.DeriveRiskTier;{[x;y] first .engine.model.instrument.test.riskTiers};1b;1;enlist[1]); // TDSO simplify
          /* (`.engine.model.order.NewOrders;{[x] };1b;1;enlist[1]); */
          (`.engine.model.orderbook.GetLevelsByPrice;{[x] 0!.engine.model.orderbook.test.OrderBook };1b;1;enlist[enlist 100]);
          (`.engine.model.orderbook.UpdateLevels;{[x] };1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) // TODO make simpler
        );
        `eid`time`cmd`kind`datum!(0;z;0;8;.util.testutils.makeOrders[`instrument`account`price`side`otype`size;enlist(1;1;100;1;1;1)]);
        (

        );
        ::))
        /* (("7:0) ProcessNewOrderEvents BUY: 2 single new order events");( */
        /*    ();();();() */ 
        /* )); */
        /* (("7:0) ProcessNewOrderEvents BUY: 2 batch order events should succeed");( */
        /*     ();();();() */
        /* )); */
        /* (("7:0) ProcessNewOrderEvents BUY: 2 order events none should succeed");( */
        /*    ();();();() */ 
        /* )); */
        /* (("7:0) ProcessNewOrderEvents BUY: batch order events 2 accounts should succeed");( // TODO */
        /*    ();();();() */ 
        /* )); */
        /* (("7:0) ProcessNewOrderEvents BUY: Should remove batch orders for now");( // TODO */
        /*    ();();();() */ 
        /* )); */
        /* ("Place new buy post only limit order at best price, no previous depth or agent orders should update depth";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Place new buy post only limit order, previous depth, no agent orders should update depth";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Place new buy post only limit order, previous depth, multiple agent orders should update depth";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Place new buy post only limit order, previous depth, multiple agent orders should update depth (best price-1 level) (not on occupied level)";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Place new buy post only limit order crosses spread, previous depth, should not invoke processTrade";( // TODO validate */
        /*    ();();();() */ 
        /* )); */ 
        /* ("Place new buy limit order (not post only) crosses spread, previous depth, should invoke processTrade";( */
        /*    ();();();() */ 
        /* )); */ 
        /* // */
        /* ("Place new iceberg post only limit order, no previous depth, no agent orders should update depth";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Place new buy iceberg post only limit order, previous depth, no agent orders should update depth";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Place new buy iceberg post only limit order, previous depth, agent orders should update depth";( */
        /*    ();();();() */ 
        /* )); */  
        /* ("Place new buy iceberg post only limit order crosses spread, previous depth, agent orders should invoke ProcessTrade";( */
        /*    ();();();() */ 
        /* )); */  
        /* // */
        /* ("Place new hidden post only limit order, no previous depth, no agent orders should update depth";( */
        /*   ();();();() */ 
        /* )); */
        /* ("Place new buy hidden post only limit order, previous depth, no agent orders should update depth";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Place new buy hidden post only limit order, previous depth, agent orders should update depth";( */
        /*    ();();();() */ 
        /* )); */  
        /* ("Place new buy hidden post only limit order crosses spread, previous depth, agent orders should invoke ProcessTrade";( */
        /*    ();();();() */ 
        /* )); */  
        /* // */
        /* ("Place new buy market order, no previous depth or agent orders should update depth";( */
        /*    ();();();() */ 
        /* )) */
    );
    .util.testutils.defaultContractHooks;
    "Process a set of order events"];



// TODO max batch size
.qt.Unit[
    ".engine.services.order.ProcessAmendOrderEvent";
    {[c]

        .qt.RunUnit[c;.engine.services.order.ProcessAmendOrderEvent];

    };.qt.generalParams;
    (
        /* ("Amend limit order (second in queue), smaller than previous, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */ 
        /* ("Amend limit order (last in queue), smaller than previous, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */
        /* // Increasing in size stays at same price */
        /* ("Amend limit order (first in queue), larger than previous, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */ 
        /* ("Amend limit order (second in queue), larger than previous, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */ 
        /* ("Amend limit order (last in queue), larger than previous, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */
        /* // Different price same side no orders on new level (same size) */
        /* ("Amend limit order (first in queue), different price same side, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */ 
        /* ("Amend limit order (second in queue), different price same side, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */ 
        /* ("Amend limit order (last in queue), different price same side, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */
        /* // Amend to zero (Cancellation) */
        /* ("Amend limit order (first in queue) to zero, different price same side, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */ 
        /* ("Amend limit order (second in queue) to zero, different price same side, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */ 
        /* ("Amend limit order (last in queue) to zero, different price same side, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Amend limit order, larger than previous, should push to back of queue, update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Amend limit order to zero, should remove order from .order.Order, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Amend iceberg limit order, smaller than previous, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Amend iceberg limit order, larger than previous, should push to back of queue, update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Amend iceberg limit order to zero, should remove order from .order.Order, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Amend hidden limit order, smaller than previous, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Amend hidden limit order, larger than previous, should push to back of queue, update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Amend hidden limit order to zero, should remove order from .order.Order, should update offsets, depth etc.";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Amend stop limit order to zero, should remove order from .order.Order";( */
        /*    ();();();() */ 
        /* )); */
        /* ("Amend stop market order to zero, should remove order from .order.Order";( */
        /*    ();();();() */ 
        /* )) */
    );
    .util.testutils.defaultContractHooks;
    "Process a set of order events"];


.qt.Unit[
    ".engine.services.order.ProcessCancelOrderEvents";
    {[c]
    
        .qt.RunUnit[c;.engine.services.order.ProcessCancelOrdersEvents];

    };.qt.generalParams;
    (
        ("1:0) ProcessCancelOrderEvents";(
           ();();();() 
        ));
        ("1:1) ProcessCancelOrderEvents";(
           ();();();() 
        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a batch of signal events"];


.qt.Unit[
    ".engine.services.order.ProcessCancelAllOrdersEvents";
    {[c]
    
        .qt.RunUnit[c;.engine.services.order.ProcessCancelAllOrdersEvents];

    };.qt.generalParams;
    (
        ("1:0) ProcessCancelAllOrdersEvents";(
           ();();();() 
        ));
        ("1:1) ProcessCancelAllOrdersEvents";(
           ();();();() 
        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a batch of signal events"];
