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

/ Event Processing logic
/ -------------------------------------------------------------------->
// TODO probabalistic rejection of events
eventEngine : (`.global.EVENTKIND$())!(); // TODO change to subset of supported types.

eventEngine[`DEPTH] :   {[event]
    .logger.Debug["new depth"][event];
    .orderbook.ProcessDepthUpdate[event];
    };

eventEngine[`TRADE] :   {[event]
    .logger.Debug["new trade"][event];
    .orderbook.ProcessTradeEvent[event];
    .stopmanager.CheckStopsByTradeEvent[event];
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
    .order.CheckByMarkPrice[event];
    .stopmanager.CheckStopsByMarkPrice[event];
    };

// TODO add randomization based upon current probability 
// of order being placed due to overload etc.
// TODO check within max and min orders, run validation etc.
eventEngine[`PLACE_ORDER] :   {[event]
    .logger.Debug["new place order"][event];
    };

eventEngine[`PLACE_BATCH_ORDER] :   {[event]
    .logger.Debug["new place batch order"][event];
    // TODO 
    };
//
eventEngine[`CANCEL_ORDER] :   {[event]
    .logger.Debug["new cancel order"][event];

    };

eventEngine[`CANCEL_BATCH_ORDER] :   {[event]
    .logger.Debug["new cancel batch order"][event];

    };

eventEngine[`CANCEL_ALL_ORDERS] :   {[event]
    .logger.Debug["new cancel all orders"][event];

    };

// Amend an existing order
eventEngine[`AMEND_ORDER] :   {[event]
    .logger.Debug["new amend order"][event];

    };

// Amend a batch of existing orders
eventEngine[`AMEND_BATCH_ORDER] :   {[event]
    .logger.Debug["new amend batch order"][event];

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
preprocessEventIngressBatch   :{[]

    };

preprocessEventEgressBatch     :{[]

    };

// Processes a batch of events and matches
// them with their respective processing 
// logic above.
ProcessEvents  : {[eventBatch]
        eventEngine [eventkind] [event] each eventBatch;
    };

// Sets up the engine, active instrument and
// sundary config which 
Setup   :{[config]

    }