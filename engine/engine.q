
// TODO mappings
.engine.watermark           :0N;
.engine.ingress.Events      :.common.event.Event;
.engine.egress.Events       :.common.event.Event;


// Returns the set of events that would occur in the given step 
// of the agent action.
.engine.GetIngressEvents   :{[watermark;frq;per] // TODO should select next batch according to config
    e:select[per] i, time, kind, datum from .engine.ingress.Events where time < ((watermark | first time)+frq); 
    delete from `.engine.ingress.Events where i in e[`i]; 
    enlist[`i] _ e
    };

// Returns the set of events that would occur in the given step 
// of the agent action.
.engine.GetEgressEvents:{[watermark;frq;per] // TODO should select next batch according to config
    e:select[per] i, time, kind, datum from .engine.ingress.Events where time > ((watermark | first time)+frq); 
    delete from `.engine.egress.Events where i in e[`i]; 
    enlist[`i] _ e
    };

// ReInserts events into the egress event buffer
.engine.Emit            :{[kind;time;event]
        .engine.egress.Events,:(event);
				};

.engine.Purge   :{[kind;time;msg;event] 
        .engine.egress.Events,:(event);
        };

/ Event Processing logic (Writes)
/ -------------------------------------------------------------------->
INSTRUMENT:();
ACCOUNT:();
.engine.map:()!();

// Public
.engine.map[`depth]       :{[x] }; //.engine.logic.orderbook.Level[INSTRUMENT];
.engine.map[`trade]       :.engine.logic.trade.Trade[INSTRUMENT;()];
.engine.map[`funding]     :.engine.logic.instrument.Funding[INSTRUMENT];
.engine.map[`mark]        :.engine.logic.instrument.MarkPrice[INSTRUMENT];
.engine.map[`settlement]  :.engine.logic.instrument.Settlement[INSTRUMENT];
.engine.map[`pricerange]  :.engine.logic.instrument.PriceLimit[INSTRUMENT];

// Account
.engine.map[`withdraw]    :.engine.logic.account.Withdraw[INSTRUMENT;ACCOUNT];
.engine.map[`deposit]     :.engine.logic.account.Deposit[INSTRUMENT;ACCOUNT];
.engine.map[`leverage]    :.engine.logic.account.Leverage[INSTRUMENT;ACCOUNT];

// Ordering
.engine.map[`neworder]    :.engine.logic.order.NewOrder[INSTRUMENT;ACCOUNT];
.engine.map[`amendorder]  :.engine.logic.order.AmendOrder[INSTRUMENT;ACCOUNT];
.engine.map[`cancelorder] :.engine.logic.order.CancelOrder[INSTRUMENT;ACCOUNT];
.engine.map[`cancelall]   :.engine.logic.order.CancelAllOrders[INSTRUMENT;ACCOUNT];

.engine.multiplex:{show x;@[.engine.map[first x[`kind]];x;show]}; // TODO logging

// Todo add slight randomization to incoming trades and 
// depth during training
.engine.process            :{[x] // WRITE EVENTS TODO remove liquidation events?
    if[count[x]>0;[
        newwm: max x`time;
        $[(null[.engine.watermark] or (newwm>.engine.watermark));[ // TODO instead of show log to file etc
            / x:.util.batch.TimeOffsetK[x;.conf.c[]]; // Set time offset by config (only for agent events)
            $[count[distinct[x`kind]]>1;
                .engine.multiplex'[0!(`f xgroup update f:{sums((<>) prior x)}kind from `time xasc x)];
                .engine.multiplex[0!(`f xgroup update f:first'[kind] from x)]];
            .engine.watermark:newwm;
            / r:.util.batch.RowDropoutK[.engine.Purge;r;.conf.c[];0;"event dropped"]; // Drop events
            / r:.util.batch.TimeOffsetK[r;.conf.c[]]; // Set return delay
        ];'WATERMARK_HAS_PASSED];
    ]]
    };


/ Public Engine Logic
/ -------------------------------------------------------------------->

.engine.Advance :{[events]
      $[count[.engine.ingress.Events]>0;.engine.ingress.Events,:events;.engine.ingress.Events:events];
      .engine.process[.engine.GetIngressEvents[.engine.watermark;`second$5;950]];
      .engine.GetEgressEvents[.engine.watermark;`second$5;950]
      }

.engine.Reset   :{[events]
    // TODO delete all models 
    .util.table.dropAll[(
      `.engine.model.order.Order,
      `.engine.model.account.Account,
      `.engine.model.inventory.Inventory,
      `.engine.model.instrument.Instrument,
      `.engine.model.risktier.RiskTier,
      `.engine.model.orderbook.OrderBook
    )];

    .engine.model.risktier.Create[];
    .engine.model.feetier.Create[];
    .engine.model.instrument.Create[];
    .engine.model.account.Create[];
    .engine.model.inventory.Create[];

    .engine.Emit[`account;]
    .engine.Emit[`inventory;]

    // TODO recreate all models etc to config
    .engine.Advance[events]
    }










