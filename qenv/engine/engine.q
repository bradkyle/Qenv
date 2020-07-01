\l account.q
\l orderbook.q
\l stopmanager.q
\l liquidationengine.q
\l global.q


/ Utility Functions
/ -------------------------------------------------------------------->

GetEngineInfo   : {

    }

ResetEngine     : {

    }

/ Rest/ State Requesting Logic
/ -------------------------------------------------------------------->

/ Event Processing logic
/ -------------------------------------------------------------------->
// TODO probabalistic rejection of events
eventEngine : (`EVENTKIND$()) ! ()

eventEngine[`DEPTH] :   {[event]
    .logger.Debug["new depth"][event];
    events:();
    events,:.orderbook.ProcessDepthUpdate[event]
    :events;
    };

eventEngine[`TRADE] :   {[event]
    .logger.Debug["new trade"][event];
    events:();
    events,:.orderbook.ProcessTradeEvent[event];
    events,:.stopmanager.CheckStopsByTradeEvent[event];
    :events;
    };

eventEngine[`DEPOSIT] :   {[event]
    .logger.Debug["new deposit"][event];
    events:();
    events,:.account.ProcessDeposit[event];
    :events;
    };

eventEngine[`WITHDRAWAL] :   {[event]
    .logger.Debug["new withdrawal"][event];
    events:();
    events,:.account.ProcessWithdraw[event];
    :events;
    };

eventEngine[`FUNDING] :   {[event]
    .logger.Debug["new funding"][event];
    events:();
    events,:.account.ApplyFunding[event];
    :events;
    };

eventEngine[`MARK] :   {[event]
    .logger.Debug["new mark price"][event];
    events:();
    events,:.liquidationengine.CheckByMarkPrice[event];
    events,:.stopmanager.CheckStopsByMarkPrice[event];
    :events;
    };

// TODO add randomization based upon current probability 
// of order being placed due to overload etc.
eventEngine[`PLACE_ORDER] :   {[event]
    .logger.Debug["new place order"][event];
    events:();  
    // todo
    :events;
    };

eventEngine[`PLACE_BATCH_ORDER] :   {[event]
    .logger.Debug["new place batch order"][event];

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

// Processes a single event and matches it
// with its respective processing logic above.
ProcessSingleEvent : {[eventkind; event]
        :eventEngine [eventkind] [event];
}

// Processes a batch of events and matches
// them with their respective processing 
// logic above.
ProcessEventBatch  : {[eventBatch]
        

        :eventEngine [eventkind] [event] each eventBatch;
}