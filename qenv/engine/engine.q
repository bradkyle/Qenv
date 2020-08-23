\l instrument.q 
\l event.q
\l order.q
\d .engine
// TODO dropped response etc.
/*******************************************************
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

/ Public REST request handling functionality (Reads)
/ -------------------------------------------------------------------->


/ Private REST request handling functionality (Reads)
/ -------------------------------------------------------------------->

// get orders
// get account
// 


/ Engine specific logic
/ -------------------------------------------------------------------->

UpdateMarkPrice :{[event]
    instrumentId:.engine.Master[][`instrumentId];
    .instrument.UpdateMarkPrice[];
    .account.UpdateMarkPrice[];
    .order.UpdateMarkPrice[];
    };

/ Public Event Processing logic (Writes)
/ -------------------------------------------------------------------->
// TODO probabalistic rejection of events
eventEngine : (`.event.INGRESSKIND$())!(); // TODO change to subset of supported types.

eventEngine[`DEPTH]:   {[event]
    .logger.Debug["new depth"][event];
    .order.ProcessDepthUpdate[event];
    };

eventEngine[`TRADE] :   {[event]
    .logger.Debug["new trade"][event];
    .order.ProcessTradeEvent[event];
    };

eventEngine[`FUNDING] :   {[event]
    .logger.Debug["new funding"][event];
    .account.ApplyFunding[event];
    };

eventEngine[`MARK] :   {[event]
    .logger.Debug["new mark price"][event];
    .engine.UpdateMarkPrice[event];
    };

eventEngine[`SETTLEMENT] :   {[event]
    .logger.Debug["new settlement"][event];
    .order.DoSettlement[event];
    };

eventEngine[`PRICERANGE] :   {[event]
    .logger.Debug["new price range"][event];
    .order.DoSettlement[event];
    };

/ Private Event Processing logic (Writes)
/ -------------------------------------------------------------------->

eventEngine[`DEPOSIT] :   {[event]
    .logger.Debug["new deposit"][event];
    .account.ProcessDeposit[event];
    };

eventEngine[`WITHDRAW] :   {[event]
    .logger.Debug["new withdrawal"][event];
    .account.ProcessWithdraw[event];
    };

eventEngine[`PLACE_ORDER] :   {[event]
    .logger.Debug["new place order"][event];
    .order.NewOrder[event[`datum];event[`time]]
    };

eventEngine[`PLACE_BATCH_ORDER] :   {[event]
    .logger.Debug["new place batch order"][event];
    .order.NewOrderBatch[event[`datum];event[`time]]
    };
//
eventEngine[`CANCEL_ORDER] :   {[event]
    .logger.Debug["new cancel order"][event];
    .order.CancelOrder[event[`datum];event[`time]]
    };

eventEngine[`CANCEL_BATCH_ORDER] :   {[event]
    .logger.Debug["new cancel batch order"][event];
    .order.CancelOrderBatch[event[`datum];event[`time]]
    };

eventEngine[`CANCEL_ALL_ORDERS] :   {[event]
    .logger.Debug["new cancel all orders"][event];
    .order.CancelOrder[event[`datum];event[`time]]
    };

// Amend an existing order
eventEngine[`AMEND_ORDER] :   {[event]
    .logger.Debug["new amend order"][event];
    .order.AmendOrder[event[`datum];event[`time]];
    };

// Amend a batch of existing orders
eventEngine[`AMEND_BATCH_ORDER] :   {[event]
    .logger.Debug["new amend batch order"][event];
    .order.AmendOrderBatch[event[`datum];event[`time]];
    };


/ Main call/execution functions
/ -------------------------------------------------------------------->

// Updates the configured engine probabilities
// from which normal distributions on processing
// time and return /outage probabilities are derived etc.
UpdateEngineProbs   :{[]

    };

// 
prepareIngress   :{[eventBatch]
    / :0!`kind xgroup eventBatch;
    :`f xgroup update f:{sums((<>) prior x)}kind from `time xasc eventBatch;
    };

prepareEgress    :{[eventBatch]

    };

// Processes a batch of events and matches
// them with their respective processing 
// logic above.
ProcessEvents  : {[eventBatch]
        {eventEngine[(`.event.INGRESSKIND$first[x[`kind]])][x]} each prepareIngress[eventBatch];
        / :prepareEgress[.engine.PopEvents[]];
    };

NewAccountFromConfig    :{[config]

    };

/ Main Setup Function
/ -------------------------------------------------------------------->

Info    :{[aids]
        select from .account.Account where accountId in aids;
        select from .account.Inventory where accountId in aids; 
        
    };


 
// Resets engine state 
// Sets up the engine, active instrument,
// Initializes agent and respective inventory config
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
    .engine.NewAccountFromConfig'[config[`accounts]];


    };