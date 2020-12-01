
// TODO mappings
.engine.watermark           :0N;
.engine.ingress.Events      :.common.event.Event;
.engine.egress.Events       :.common.event.Event;


// 1) enlist(Time <= Time + StepFreqTime)
// 2) enlist(Index <= Index + StepFreqIndex)
// 3) ((Time <= Time + StepFreqTime);(Index <= Index + StepFreqIndex))
.ingress.getIngressCond  :{$[
        x=0;enlist(<=;`time;(+;`time;`second$5)); // todo pass in time from conf
        x=1;();
        x=3;();
        'INVALID_INGRESS_COND]};

// Returns the set of events that would occur in the given step 
// of the agent action.
.ingress._GetIngressEvents   :{[step;windowkind] // TODO should select next batch according to config
    econd:.ingress.getIngressCond[windowkind];
    events:?[`.ingress.Event;econd;0b;()];
    .ingress.test.events:events;
    ![`.ingress.Event;enlist(=;`eid;key[events]`eid);0b;`symbol$()];
    value events
    };

// 1) enlist(Time <= Time + StepFreqTime)
// 2) enlist(Index <= Index + StepFreqIndex)
// 3) ((Time <= Time + StepFreqTime);(Index <= Index + StepFreqIndex))
.ingress.getEgressCond  :{$[
        x=0;enlist(<=;`time;(+;`time;`second$5)); // todo pass in time from conf
        x=1;();
        x=3;();
        'INVALID_INGRESS_COND]};

// Returns the set of events that would occur in the given step 
// of the agent action.
.egress._GetEgressEvents   :{[step;windowkind] // TODO should select next batch according to config
    econd:.egress.getEgressCond[windowkind];
    events:?[`.egress.Event;econd;0b;()];
    .egress.test.events:events;
    ![`.egress.Event;enlist(=;`eid;key[events]`eid);0b;`symbol$()];
    value events
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

.engine.multiplex:{@[.engine.map[first x[`kind]];x;show]}; // TODO logging

// Todo add slight randomization to incoming trades and 
// depth during training
.engine.process            :{[x] // WRITE EVENTS TODO remove liquidation events?
    if[count[x]>0;[
        newwm: max x`time;
        $[(null[.engine.watermark] or (newwm>.engine.watermark));[ // TODO instead of show log to file etc
                x:.util.batch.TimeOffsetK[x;.conf.c[]]; // Set time offset by config (only for agent events)
            r:$[count[distinct[x`kind]]>1;
                .engine.multiplex'[0!(`f xgroup update f:{sums((<>) prior x)}kind from `time xasc x)];
                .engine.multiplex[0!(`f xgroup update f:first'[kind] from x)]];
            .engine.watermark:newwm;
            r:.util.batch.RowDropoutK[.engine.Purge;r;.conf.c[];0;"event dropped"]; // Drop events
            r:.util.batch.TimeOffsetK[r;.conf.c[]]; // Set return delay
            if[count[r]>0;.engine.egress.Events,:r];
        ];'WATERMARK_HAS_PASSED];
    ]]
    };


/ Public Engine Logic
/ -------------------------------------------------------------------->

.engine.Advance :{[events]
      .engine.ingress.Events,:events;
      .engine.process .engine.GetIngressEvents[]
      .engine.GetEgressEvents[]
      }

.engine.Reset   :{[events]
      // TODO delete all models 
      // TODO recreate all models etc to config
      .engine.Advance[events]
      }










