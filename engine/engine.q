
// TODO mappings
.engine.watermark           :0N;
.engine.ingress.Events      :.common.event.Event;
.engine.egress.Events       :.common.event.Event;


// Returns the set of events that would occur in the given step 
// of the agent action.
.engine.GetIngressEvents   :{[watermark;frq;per] // TODO should select next batch according to config
    e:select[per] i, time, kind, datum from .engine.ingress.Events where (time>watermark) and (time < ((watermark | first time)+frq)); 
    delete from `.engine.ingress.Events where i in e[`i]; 
    enlist[`i] _ e
    };

// Returns the set of events that would occur in the given step 
// of the agent action.
.engine.GetEgressEvents:{[watermark;frq;per] // TODO should select next batch according to config
    e:select[per] i, time, kind, datum from .engine.egress.Events where time < watermark; 
    delete from `.engine.egress.Events where i in e[`i]; 
    enlist[`i] _ e
    };

// ReInserts events into the egress event buffer
.engine.Emit            :{[kind;time;event]
        .engine.egress.Events,:(time;kind;value event);
				};

.engine.Purge   :{[kind;time;msg;event] 
        .engine.egress.Events,:(event);
        };

/ Event Processing logic (Writes)
/ -------------------------------------------------------------------->

.engine.publicWrapper:{};
.engine.privateWrapper:{};

.engine.map:()!();

// Public
.engine.map[`trade]       :.engine.logic.trade.Trade[INSTRUMENT;()]; //.engine.logic.orderbook.Level[INSTRUMENT];
.engine.map[`depth]       :.engine.logic.orderbook.Level[INSTRUMENT];
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

.engine.multiplex:{@[.engine.map[first x[`kind]];x;show first x`kind]}; // TODO logging

// Todo add slight randomization to incoming trades and 
// depth during training
.engine.process            :{[x] // WRITE EVENTS TODO remove liquidation events?
    if[count[x]>0;[
        newwm: max x`time;
        $[(null[.engine.watermark] or (newwm>.engine.watermark));[ // TODO instead of show log to file etc
            / x:.util.batch.TimeOffsetK[x;.conf.c[]]; // Set time offset by config (only for agent events)
            $[count[distinct[x`kind]]>1;
                .engine.multiplex'[0!(`f xgroup update f:{sums((<>) prior x)}kind from `time xasc x)];
                .engine.multiplex[first 0!(`f xgroup update f:first'[kind] from x)]];
            .engine.watermark:newwm;
            / r:.util.batch.RowDropoutK[.engine.Purge;r;.conf.c[];0;"event dropped"]; // Drop events
            / r:.util.batch.TimeOffsetK[r;.conf.c[]]; // Set return delay
        ];'WATERMARK_HAS_PASSED];
    ]]
    };


/ Public Engine Logic
/ -------------------------------------------------------------------->

.engine.Advance :{[events]
    $[(count[.engine.ingress.Events]>0) and (count[events]>0);
        .engine.ingress.Events,:events;
      (count[events]>0);
      .engine.ingress.Events:events;::];
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

    .engine.model.risktier.RiskTier,:flip `rtid`mxamt`mmr`imr`maxlev!flip[(
        (0; 50000;       0.004;    0.008;    125);
        (1; 250000;      0.005;    0.01;     100);
        (2; 1000000;     0.01;     0.02;     50);
        (3; 5000000;     0.025;    0.05;     20);
        (4; 20000000;    0.05;     0.1;      10);
        (5; 50000000;    0.1;      0.20;     5);
        (6; 100000000;   0.125;    0.25;     4);
        (7; 200000000;   0.15;     0.333;    3);
        (8; 500000000;   0.25;     0.50;     2);
        (9; 500000000;   0.25;     1.0;      1))]; 

     .engine.model.feetier.FeeTier,:flip `ftid`vol`mkrfee`tkrfee`wdrawfee`dpstfee`wdlim!flip[(
        (0; 50;      0.0006;    0.0006;    0f;  0f; 600);
        (1; 500;     0.00054;   0.0006;    0f;  0f; 600);
        (2; 1500;    0.00048;   0.0006;    0f;  0f; 600);
        (3; 4500;    0.00042;   0.0006;    0f;  0f; 600);
        (4; 10000;   0.00042;   0.00054;   0f;  0f; 600);
        (5; 20000;   0.00036;   0.00048;   0f;  0f; 600);
        (6; 40000;   0.00024;   0.00036;   0f;  0f; 600);
        (7; 80000;   0.00018;   0.000300;  0f;  0f; 600);
        (8; 150000;  0.00012;   0.00024;   0f;  0f; 600))];                             //  

    .engine.model.instrument.Instrument,:((!) . flip(
        (`iId                      ; 0);                                           
        (`cntTyp                   ; 0);
        (`state                    ; 0);
        (`faceValue                ; 0);
        (`markPrice                ; 0);
        (`mxSize                   ; 0);
        (`mnPrice                  ; 0);
        (`mxPrice                  ; 0) 
        ));

    .engine.model.account.Create[(!) . flip(
        (`state                   ; 0);                                            
        (`quoteAsset              ; `BTC);                                         
        )];

    / .engine.model.account.Create[(!) . flip(
    /     (`state                   ; 0);                                            
    /     (`quoteAsset              ; `BTC);                                         
    /     )];


    .engine.Emit[`account;]
    .engine.Emit[`inventory;]

    // TODO recreate all models etc to config
    .engine.Advance[events]
    }










