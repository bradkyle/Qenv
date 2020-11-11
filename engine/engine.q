
.engine.watermark           :0N;

/ Event Processing logic (Writes)
/ -------------------------------------------------------------------->

.engine.multiplex           :{
        k:first[x`f];
        $[k=0;  .engine.services.depth.ProcessDepthUpdateEvents[x];   // DEPTH
        k=1;    .engine.services.trade.ProcessNewTradeEvents[x];        // TRADE
        k=2;    .engine.services.mark.ProcessMarkUpdateEvents[x];      // MARK
        k=3;    .engine.services.liquidation.ProcessLiquidationEvents[x];     // LIQUIDATION
        k=4;    .engine.services.funding.ProcessFundingEvents[x];         // FUNDING
        k=5;    .engine.services.settlement.ProcessSettlementEvents[x];      // SETTLEMENT
        k=8;    .engine.services.order.ProcessNewOrderEvents[x];        // NEW_ORDER
        k=9;    .engine.services.order.ProcessAmendOrderEvents[x];      // AMEND_ORDER
        k=10;   .engine.services.order.ProcessCancelOrderEvents[x];     // CANCEL_ORDER
        k=11;   .engine.services.order.ProcessCancelAllOrdersEvents[x]; // CANCEL_ALL_ORDERS
        k=12;   .engine.services.pricelimit.ProcessNewPriceLimitEvents[x];   // PRICE_LIMIT
        k=13;   .engine.services.account.ProcessWithdrawEvents[x];        // WITHDRAW
        k=14;   .engine.services.account.ProcessDepositEvents[x];         // DEPOSIT
        k=17;   .engine.services.account.sProcessLeverageUpdateEvents[x];  // LEVERAGE
        k=16;   .engine.services.signal.ProcessSignalEvents[x];          // SIGNAL
        'INVALID_EVENT_KIND];
    };
.engine.multiplex:{@[.engine.multiplex;x;show]}; // TODO logging

.engine.process            :{[x] // WRITE EVENTS TODO remove liquidation events?
    if[count[x]>0;[
        newwm: max x`time;
        $[(null[.engine.watermark] or (newwm>.engine.watermark));[ // TODO instead of show log to file etc
            x:.util.batch.TimeOffsetK[x];
            r:$[count[distinct[x`kind]]>1;
                .engine.multiplex'[0!(`f xgroup update f:{sums((<>) prior x)}kind from `time xasc x)];
                .engine.multiplex[0!(`f xgroup update f:first'[kind] from x)]];
            .engine.watermark:newwm;
            r:.util.batch.TimeOffsetK[r];
            r:.util.batch.GausRowDropouts[r];
            .egress.AddBatch[r];
        ];'WATERMARK_HAS_PASSED];
    ]]
    };


/ Public Engine Logic
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

// Advances the engine state
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.Advance     :{[events]
    // TODO remove this write
    // Based upon initial configuration set in .engine.Reset
    // this function derives the set of events at the given
    // step that should be executed by the engine.
    // This also allows for longer temporal steps and larger
    // batch sizes for faster overall processing speed.
    events:.ingress.GetIngressEvents[
            .conf.c[`engine;`stepFrequency];
            .engine.WaterMark];

    // TODO inject events like random balance etc.
    
    // Process the first set of events produced
    // by the ingress logic to form the initial
    // reset obs seen by the agent.
    .engine.ProcessEvents[events];

    // If the engine has passed the given watermark set
    // by config, request the next batch of events and add
    // them to the ingress pipe. This sends an async message which
    // can be picked up in the next step of the engine advance
    if[.engine.WaterMark>.engine.Threshold;[
        .ingest.AsyncRequestBatch[
            .conf.c[`engine;`dataInterval]];
    ]];


    // Based upon initial configuration set in .engine.Reset
    // this function derives the set of events at the given
    // step that should be inserted into the local state.
    // This also allows for longer temporal steps and larger
    // batch sizes for faster overall processing speed.
    :.pipe.egress.GetEgressEvents[.engine.CONF]; // TODO configs
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
.engine.Reset   :{[events]
    .util.table.dropAll[(`.order.Order`.order.OrderBook,
                `.instrument.Instrument`.account.Account,
                `.inventory.Inventory)];

    .conf.engine[];

    // TODO check data interval is greater than pull interval
    // Instantiate instrument with 
    // given config.
    .instrument.NewInstrument[.conf.ca[`instrument]];
    
    // Instantiate the given set 
    // of accounts.
    // TODO loop over config
    .account.NewAccount[.conf.ca[`accounts]];

    // Advance the state
    .ingress.AddBatch[events];

    // Based upon initial configuration set in .engine.Reset
    // this function derives the set of events at the given
    // step that should be executed by the engine.
    // This also allows for longer temporal steps and larger
    // batch sizes for faster overall processing speed.
    events:.ingress.GetIngressEvents[
            .conf.c[`engine;`stepFrequency];
            .engine.WaterMark];

    // TODO inject events like random balance etc.
    
    // Process the first set of events produced
    // by the ingress logic to form the initial
    // reset obs seen by the agent.
    .engine.ProcessEvents[nevents];

    // Based upon initial configuration set in .engine.Reset
    // this function derives the set of events at the given
    // step that should be inserted into the local state.
    // This also allows for longer temporal steps and larger
    // batch sizes for faster overall processing speed.
    :.pipe.egress.GetEgressEvents[.engine.CONF]; // TODO configs
    };












