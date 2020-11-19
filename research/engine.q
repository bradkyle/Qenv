
.engine.multiplex           :{
        k:first[x`f];
        $[k=0;  .engine.logic.depth.Levels[x];   // DEPTH
        k=1;    .engine.logic.trade.Trades[x];        // TRADE
        k=2;    .engine.logic.instrument.Mark[x];      // MARK
        k=4;    .engine.logic.instrument.Funding[x];         // FUNDING
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

/*******************************************************
/ Ingress Creation Utils

.ingress.AddPlaceOrderEvent     :{[order;time] // TODO make valid for multiple
        // TODO check size etc        
        .ingress.AddEvent[time;0;8;order];
        };

.ingress.AddPlaceBatchEvent     :{[orders;time]
        // TODO check size etc        
        .ingress.AddEvent[time;0;8;orders];
        };

.ingress.AddCancelOrderEvent    :{[order;time]
        // TODO check size etc        
        .ingress.AddEvent[time;2;8;order];
        };

.ingress.AddCancelBatchEvent    :{[orders;time]
        // TODO check size etc
        .ingress.AddEvent[time;2;8;orders];
        };

.ingress.AddCancelAllEvent      :{[order;time]
        // TODO check size etc        
        .ingress.AddEvent[time;2;8;orders]; // TODO
        };

.ingress.AddAmendOrderEvent     :{[order;time]
        // TODO check size etc        
        .ingress.AddEvent[time;1;8;order]; // TODO        
        };

.ingress.AddAmendBatchEvent     :{[orders;time]
        // TODO check size etc
        .ingress.AddEvent[time;1;8;orders]; // TODO        
        };

.ingress.AddWithdrawEvent       :{[withdraw;time]
        // TODO check size etc
        .ingress.AddEvent[time;0;10;withdraw]; // TODO        
        };

.ingress.AddDepositEvent        :{[deposit;time]
        // TODO check size etc
        .ingress.AddEvent[time;0;11;deposit]; // TODO        
        };

/*******************************************************
/ Ingress Selection/Filtering Utils


// 1) enlist(Time <= Time + StepFreqTime)
// 2) enlist(Index <= Index + StepFreqIndex)
// 3) ((Time <= Time + StepFreqTime);(Index <= Index + StepFreqIndex))
.ingress.getIngressCond  :{$[
        x=0;enlist(<=;`time;(+;`time;`second$5)); // todo pass in time from conf
        x=1;();
        x=3;();
        'INVALID_INGRESS_COND]};

// enlist(<=;`time;)
// enlist(<=;`i;)
// ((<=;`i;);(<=;`time;)) 

// Returns the set of events that would occur in the given step 
// of the agent action.
.ingress._GetIngressEvents   :{[step;windowkind] // TODO should select next batch according to config
    econd:.ingress.getIngressCond[windowkind];
    events:?[`.ingress.Event;econd;0b;()];
    .ingress.test.events:events;
    ![`.ingress.Event;enlist(=;`eid;key[events]`eid);0b;`symbol$()];
    value events
    };

// Simply uses the first window kind 
.ingress.GetIngressEvents    :{[x;y].ingress._GetIngressEvents[x;0]}; 
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












