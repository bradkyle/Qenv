\l instrument.q 
\l event.q
\l order.q
\d .engine

// TODO move validation into engine

// TODO dropped response etc.
/*******************************************************
// TODO deleverage probability
// represents the offset in milliseconds
// check if flip is right
// TODO rate limit, return order and time, make sure ingress events in order
// TODO supported event types
Engine:(
    [engineId                   :`long$()];
    instrumentId                : `.instrument.Instrument();
    isConfigured                : `boolean$();
    loadSheddingProbability     : `float$();
    placeOrderOffsetMu          : `float$(); 
    placeOrderOffsetSigma       : `float$();
    placeBatchOffsetMu          : `float$();
    placeBatchOffsetSigma       : `float$();
    cancelOrderOffsetMu         : `float$(); 
    cancelOrderOffsetSigma      : `float$(); 
    cancelOrderBatchOffsetMu    : `float$(); 
    cancelOrderBatchOffsetSigma : `float$(); 
    cancelAllOrdersOffsetMu     : `long$(); 
    cancelAllOrdersOffsetSigma  : `long$(); 
    amendOrderOffsetMu          : `long$(); 
    amendBatchOffsetSigma       : `long$();
    commonOffset                : `long$(); 
    eventCount                  : `long$()
    );

Master  :{:(.engine.Engine@0)}

// Ingress Queue, Egress Queue


// TODO add randomization based upon current probability 
// of order being placed due to overload etc.
// TODO check within max and min orders, run validation etc.

/ Engine specific logic
/ -------------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
ProcessMarkUpdateEvent :{[event]
    instrumentId:.engine.Master[][`instrumentId];
    .instrument.UpdateMarkPrice[];
    .account.UpdateMarkPrice[];
    .order.UpdateMarkPrice[];

    // Apply liquidations
    .account.Liquidate[ins;time]'[.account.GetInsolvent[]];
    };

/ Public Event Processing logic (Writes)
/ -------------------------------------------------------------------->
// TODO probabalistic rejection of events
// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
ProcessEvents :{ // WRITE EVENTS
    {
        k:x`kind;
        r:x`datum;
        $[
            k=0;  [.engine.ProcessDepthUpdateEvents[]]; // DEPTH
            k=1;  [.engine.ProcessNewTradeEvents[]]; // TRADE
            k=2;  [.engine.ProcessMarkUpdateEvents[]]; // MARK
            k=3;  [.engine.ProcessSettlementEvents[]]; // SETTLEMENT
            k=4;  [.engine.ProcessFundingEvents[]]; // FUNDING
            k=5;  [.engine.ProcessLiquidationEvents[]]; // LIQUIDATION
            k=8;  [.engine.ProcessOrderEvents[]]; // ORDER
            k=9;  [.engine.ProcessNewPriceLimitEvents[]]; // PRICELIMIT
            k=10; [.engine.ProcessInstrumentEvents[]]; // INSTRUMENT
            'INVALID_EVENT_KIND
        ];
    }'[`f xgroup update f:{sums((<>) prior x)}kind from `time xasc x];
    // TODO pop events
}

/ Main Setup Function
/ -------------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
Info    :{[aids]
        :(
            select from .account.Account where accountId in aids;
            select from .account.Inventory where accountId in aids; 
            .engine.Engine@0;
        );
    };


 
// Resets engine state 
// Sets up the engine, active instrument,
// Initializes agent and respective inventory config
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
Reset   :{[config]
    delete from `.order.Order;
    delete from `.order.OrderBook;
    delete from `.instrument.Instrument;
    delete from `.account.Account;
    delete from `.inventory.Inventory;
    delete from `.event.Event;

    // Instantiate instrument with 
    // given config.
    .instrument.NewInstrument[config[`instrument]];
    
    // Instantiate the given set 
    // of accounts.
    a:.account.NewAccount[config[`account]];

    // TODO set accountId
    .account.NewInventory[config[`shortInventory]];
    .account.NewInventory[config[`longInventory]];
    .account.NewInventory[config[`bothInventory]];

    // TODO update engine obs?

    };