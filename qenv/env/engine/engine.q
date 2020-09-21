
// TODO rate limits
// TODO random placement of hidden/iceberg orders 
// TODO random noise added to liquidation.
// TODO move validation into engine
// TODO add slight noise to trades and orderbook updates
// TODO convert/multiply in engine
.engine.WaterMark:0n;

// TODO dropped response etc.
/*******************************************************
// TODO deleverage probability
// represents the offset in milliseconds
// check if flip is right
// TODO rate limit, return order and time, make sure ingress events in order
// TODO supported events types
// TODO rate limits etc.
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

.engine.Requests        :(
    
    );

// Because the Environment for all practical purposes
// only uses one instrument, this function returns the
// primary instance of Instrument for which all actions
// relate and are configured by.
/  @return (Instrument) The primary instance of instrument
.engine.getInstrument   :{
    $[0 in key[.instrument.Instrument];:.instrument.Instrument@0;'UNSET_PRIMARY_INSTRUMENT]; // TODO check
    };

// TODO get account, get order etc.
// TODO error handling

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
.engine.ProcessDepthUpdateEvents :{[events]
    instrument:.engine.getInstrument[];
    // Convert/multiply 
    
    lt:exec last time from events;
    events:flip events;
    $[not (type events[`time])~15h;[.logger.Err["Invalid event time"]; :0b];]; //todo erroring
    $[not (type events[`intime])~15h;[.logger.Err["Invalid event intime"]; :0b];]; // todo erroring

    nxt:0!(`side`price xgroup select time, side:datum[;0], price:datum[;1], size:datum[;2] from events);

    .order.ProcessDepth[];

    };

// Process New Iceberg events?

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessNewTradeEvents :{[events]
    instrument:.engine.getInstrument[];
    
    d:events`datum;

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
.engine.ProcessMarkUpdateEvents :{[events]
    instrument:.engine.getInstrument[];
    d:events`datum;
    instrument[`markPrice]:last[d]; // Derive the last mark price from the events
    .instrument.Instrument,:instrument;

    // Essentially find the deltas in the mark price provided
    // and derive a change in the unrealized pnl, triggering
    // liquidations where neccessary
    .account.CONTRACT.UpdateMarkPrice[instrument;d;events`time];

    // Where appliccable trigger stop orders 
    // TODO add a delay in placement of orders
    .order.UpdateMarkPrice[instrument;d;events`time];
    
    .pipe.egress.AddMarkEvent[];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessSettlementEvents :{[events]
    instrument:.engine.getInstrument[];
    
    // Apply settlement to the given accounts
    // and their respective inventories, this 
    // would reset realized pnl into the balance
    .account.CONTRACT.ApplySettlement[instrument];

    .pipe.egress.AddSettlementEvent[];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessFundingEvents :{[events]
    instrument:.engine.getInstrument[];

    //  Apply funding the the open agent 
    // positions/inventory 
    .account.CONTRACT.ApplyFunding[instrument];

    .pipe.egress.AddFundingEvent[];
    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessNewPriceLimitEvents :{[events] // 
    instrument:.engine.getInstrument[];
    .instrument.UpdatePriceLimits[instrument;]; // TODO derive price limti
    .order.UpdatePriceLimits[instrument;];
    .pipe.egress.AddPriceLimitEvent[instrument;];    
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessOrderEvents :{[events] // Requires accountId
    instrument:.engine.getInstrument[];
    // TODO do validation here
    // $[any[in[o[`orderId`clOrdId];key[.order.Order]`orderId]];
    
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessWithdrawEvents :{[events]
    instrument:.engine.getInstrument[]; // Requires accountId
    .account.CONTRACT.Withdraw[instrument];
    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessDepositEvents :{[events] // Requires accountId
    instrument:.engine.getInstrument[];
    .account.CONTRACT.Deposit[instrument];
    };


/ Extern Signal processing and randomization
/ -------------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessSignalEvents :{[events] // Requires accountId
    .pipe.egress.AddBatch[events]; // TODO add noise/dropout/randomization
    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessLiquidationEvents :{[events]
    // TODO check    
    .pipe.egress.AddLiquidationEvent[];
    };

/ Public Event .engine.Processing logic (Writes)
/ -------------------------------------------------------------------->

// TODO instrument, leverage
// TODO events after watermark
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
    newwm: max x`time;
    $[null[.engine.WaterMark] or [newwm>.engine.WaterMark];[
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
            k=11;.engine.ProcessDepositEvents[x];         // DEPOSIT
            k=16;.engine.ProcessSignalEvents[x];         // SIGNAL
            'INVALID_EVENT_KIND];
        }'[`f xgroup update f:{sums((<>) prior x)}kind from `time xasc x];
        .engine.WaterMark:newwm;
    ];'WATERMARK_HAS_PASSED];
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
                `.inventory.Inventory)];

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
    .engine.NewEngine[config`engine];

    };


