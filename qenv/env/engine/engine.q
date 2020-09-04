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
.engine.Engine:(
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

// Ingress Queue, Egress Queue
.engine.getInstrument   :{

    };

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
.engine.ProcessDepthUpdateEvents :{[event]
    instrument:.engine.getInstrument[];
    
    lt:exec last time from event;
    event:flip event;
    $[not (type event[`time])~15h;[.logger.Err["Invalid event time"]; :0b];]; //todo erroring
    $[not (type event[`intime])~15h;[.logger.Err["Invalid event intime"]; :0b];]; // todo erroring

    nxt:0!(`side`price xgroup select time, side:datum[;0], price:datum[;1], size:datum[;2] from event);

    .order.ProcessDepth[];

    };

// Process New Iceberg event?

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessNewTradeEvents :{[event]
    instrument:.engine.getInstrument[];
    
    d:event`datum;

    // TODO derive from account

    .order.ProcessTrade[instrument]'[d`account`side`fill`reduce`time];

    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessMarkUpdateEvents :{[event]
    instrument:.engine.getInstrument[];
    d:event`datum;
    instrument[`markPrice]:last[d]; // Derive the last mark price from the event
    .instrument.Instrument,:instrument;

    // Essentially find the deltas in the mark price provided
    // and derive a change in the unrealized pnl, triggering
    // liquidations where neccessary
    .account.UpdateMarkPrice[instrument;d;event`time];

    // Where appliccable trigger stop orders 
    // TODO add a delay in placement of orders
    .order.UpdateMarkPrice[instrument;d;event`time];
    
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessSettlementEvents :{[event]
    instrument:.engine.getInstrument[];
    
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessFundingEvents :{[event]
    instrument:.engine.getInstrument[];

    .account.ApplyFunding[];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessLiquidationEvents :{[event]
    instrument:.engine.getInstrument[];
    
    
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessNewPriceLimitEvents :{[event] // 
    instrument:.engine.getInstrument[];
    
    
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessOrderEvents :{[event] // Requires accountId
    instrument:.engine.getInstrument[];
    
    
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessWithdrawEvents :{[event]
    instrument:.engine.getInstrument[]; // Requires accountId
    .account.Withdraw[];
    
    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessDepositEvents :{[event] // Requires accountId
    instrument:.engine.getInstrument[];
    
    
    };

/ Public Event .engine.Processing logic (Writes)
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
.engine.ProcessEvents :{ // WRITE EVENTS TODO remove liquidation events?
    {
        k:x`kind;
        $[k=0; .engine.ProcessDepthUpdateEvents[x];     // DEPTH
          k=1; .engine.ProcessNewTradeEvents[x];        // TRADE
          k=2; .engine.ProcessMarkUpdateEvents[x];      // MARK
          k=3; .engine.ProcessSettlementEvents[x];      // SETTLEMENT
          k=4; .engine.ProcessFundingEvents[x];         // FUNDING
          k=5; .engine.ProcessLiquidationEvents[x];     // LIQUIDATION
          k=8; .engine.ProcessOrderEvents[x];           // ORDER
          k=9; .engine.ProcessNewPriceLimitEvents[x];   // PRICELIMIT
          k=10;.engine.ProcessWithdrawEvents[x];        // WITHDRAW
          k=10;.engine.ProcessDepositEvents[x];         // DEPOSIT
          'INVALID_EVENT_KIND];
    }'[`f xgroup update f:{sums((<>) prior x)}kind from `time xasc x];
    // TODO pop events
    };

/ Main Setup Function
/ -------------------------------------------------------------------->

// Retreives the important information from account, inventory, orders
// Instrument, liquidation etc.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.Info    :{[aids] 
        :(
            select from .account.Account where accountId in aids;
            select from .account.Inventory where accountId in aids; 
            .engine.Engine;
            .order.Order; // TODO get accoutn
            .instrument.Instrument
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
.engine.Reset   :{[config]
    .util.table.dropAll[(`.order.Order`.order.OrderBook,
                `.instrument.Instrument`.account.Account,
                `.inventory.Inventory`.event.Event)];

    // Instantiate instrument with 
    // given config.
    .instrument.NewInstrument[config[`instrument]];
    
    // Instantiate the given set 
    // of accounts.
    // TODO loop over config
    a:.account.NewAccount[config[`account]];

    // TODO set accountId
    .account.NewInventory[config[`shortInventory]];
    .account.NewInventory[config[`longInventory]];
    .account.NewInventory[config[`bothInventory]];

    // TODO update engine

    };