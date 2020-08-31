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

    // Apply liquidations
    .account.Liquidate[ins;time]'[.account.GetInsolvent[]];
    
    };

/ Public Event Processing logic (Writes)
/ -------------------------------------------------------------------->
// TODO probabalistic rejection of events
ProcessEvents :{
    {
        k:x`kind;
        r:x`datum;
        $[
            k=0;  [];
            k=1;  [];
            k=2;  [];
            k=3;  [];
            k=4;  [];
            k=5;  [];
            k=6;  [];
            k=7;  [];
            k=8;  [];
            k=9;  [];
            k=10; [];
            'INVALID_EVENT_KIND
        ];
    }'[`f xgroup update f:{sums((<>) prior x)}kind from `time xasc eventBatch];
}

/ Configuration
/ -------------------------------------------------------------------->

NewAccountFromConfig    :{[config]
    a:.account.NewAccount[config[`account]];

    // TODO set accountId
    .account.NewInventory[config[`shortInventory]];
    .account.NewInventory[config[`longInventory]];
    .account.NewInventory[config[`bothInventory]];
    };

NewInstrumentFromConfig :{[config]
    
    };

/ Main Setup Function
/ -------------------------------------------------------------------->

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

    // TODO update engine obs?

    };