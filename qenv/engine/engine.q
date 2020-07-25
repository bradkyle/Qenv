\l global.q

/*******************************************************
/ Return code
RETURNCODE  :   (`INVALID_MEMBER;
                `INVALID_ORDER_STATUS;
                `INVALID_ORDER;
                `OK);

// TODO dropped response etc.
/*******************************************************
// represents the offset in milliseconds
// check if flip is right
// TODO rate limit, return order and time, make sure ingress events in order
// TODO supported event types
Engine:(
    [engineId                   :`long$()];
    instrument                  : `.instrument.Instrument();
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


/ REST request handling functionality (Reads)
/ -------------------------------------------------------------------->

// get orders
// get account
// 



/ Event Processing logic (Writes)
/ -------------------------------------------------------------------->
// TODO probabalistic rejection of events
eventEngine : (`.global.EVENTKIND$())!(); // TODO change to subset of supported types.

eventEngine[`DEPTH] :   {[event]
    .logger.Debug["new depth"][event];
    .order.ProcessDepthUpdate[event];
    };

eventEngine[`TRADE] :   {[event]
    .logger.Debug["new trade"][event];
    .order.ProcessTradeEvent[event];
    };

eventEngine[`DEPOSIT] :   {[event]
    .logger.Debug["new deposit"][event];
    .account.ProcessDeposit[event];
    };

eventEngine[`WITHDRAWAL] :   {[event]
    .logger.Debug["new withdrawal"][event];
    .account.ProcessWithdraw[event];
    };

eventEngine[`FUNDING] :   {[event]
    .logger.Debug["new funding"][event];
    .account.ApplyFunding[event];
    };

eventEngine[`MARK] :   {[event]
    .logger.Debug["new mark price"][event];
    .order.UpdateMarkPrice[event];
    };

// TODO add randomization based upon current probability 
// of order being placed due to overload etc.
// TODO check within max and min orders, run validation etc.
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

// Resets engine and its associated state to
// the initial config set in Setup
ResetEngine     : {

    };

// 
prepareIngress   :{[eventBatch]

    };

prepareEgress    :{[eventBatch]

    };

// Processes a batch of events and matches
// them with their respective processing 
// logic above.
ProcessEvents  : {[eventBatch]
        eventEngine [eventkind] [event] each prepareIngress[eventBatch];
        :prepareEgress[.engine.PopEvents[]];
    };


/ Main Setup Function
/ -------------------------------------------------------------------->

// Sets up the engine, active instrument,
// Initializes agent and respective inventory config
//  
Setup   :{[config]

    }