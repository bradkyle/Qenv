
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
    .engine.egress.Events,:(time;kind;event);
		};

.engine.Purge   :{[event;time;msg] 
    .engine.egress.Events,:(time;`failure;(msg;event));
    };

/ Event Processing logic (Writes)
/ -------------------------------------------------------------------->


.engine.publicWrapper:{[x;y]
    i:?[`.engine.model.instrument.Instrument;enlist(=;`iId;0);();()];
    x[y`time;i;y`datum]};

.engine.privateWrapper:{[x;y]
    i:?[`.engine.model.instrument.Instrument;enlist(=;`iId;0);();()];
    a:?[`.engine.model.account.Account;enlist(=;`aId;0);();()];
    x[y`time;i;a;y`datum]};

.engine.map:()!();

// Public
.engine.map[`trade]       :.engine.publicWrapper[.engine.logic.trade.Trade]; //.engine.logic.orderbook.Level[INSTRUMENT];
.engine.map[`depth]       :.engine.publicWrapper[.engine.logic.orderbook.Level];
.engine.map[`funding]     :.engine.publicWrapper[.engine.logic.instrument.Funding];
.engine.map[`mark]        :.engine.publicWrapper[.engine.logic.instrument.MarkPrice];
.engine.map[`settlement]  :.engine.publicWrapper[.engine.logic.instrument.Settlement];
.engine.map[`pricerange]  :.engine.publicWrapper[.engine.logic.instrument.PriceLimit];

// Account
.engine.map[`withdraw]    :.engine.privateWrapper[.engine.logic.account.Withdraw];
.engine.map[`deposit]     :.engine.privateWrapper[.engine.logic.account.Deposit];
.engine.map[`leverage]    :.engine.privateWrapper[.engine.logic.account.Leverage];

// Ordering
.engine.map[`neworder]    :.engine.privateWrapper[.engine.logic.order.NewOrder];
.engine.map[`amendorder]  :.engine.privateWrapper[.engine.logic.order.AmendOrder];
.engine.map[`cancelorder] :.engine.privateWrapper[.engine.logic.order.CancelOrder];
.engine.map[`cancelall]   :.engine.privateWrapper[.engine.logic.order.CancelAllOrders];

.engine.multiplex:{.Q.sbt[.engine.map[first x[`kind]];x;{show x;show[.Q.sbt y]}]}; // TODO logging
/ .engine.multiplex:{@[.engine.map[first x[`kind]];x;show first[x`kind]]}; // TODO logging

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

.engine.Reset   :{[aIds; events]
    // TODO delete all models 
    .util.table.dropAll[(
      `.engine.ingress.Events,
      `.engine.egress.Events,
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

    n:count[aIds];
    dn:n*2;
    .engine.model.inventory.Inventory,:ivn:flip[(!) . flip(
        (`aId              ; floor[til[dn]%2]);                                            
        (`side             ; dn#(1 -1));                                            
        (`ordQty           ; dn#0);
        (`ordVal           ; dn#0);
        (`ordLoss          ; dn#0);
        (`amt              ; dn#0);
        (`iw               ; dn#0); // isolated wallet
        (`mm               ; dn#0);
        (`posVal           ; dn#0);
        (`rpnl             ; dn#0);  
        (`avgPrice         ; dn#0);  
        (`execCost         ; dn#0);  
        (`upnl             ; dn#0);  
        (`lev              ; dn#0)  
        )];

    .engine.model.account.Account,:acc:flip((!) . flip(
        (`aId              ; aIds);                                            
        (`lng              ; `.engine.model.inventory.Inventory$(flip(aIds;n#1)));
        (`srt              ; `.engine.model.inventory.Inventory$(flip(aIds;n#-1)));
        (`dep              ; n#0);  
        (`wit              ; n#0);  
        (`rt               ; n#`.engine.model.risktier.RiskTier$0);  
        (`ft               ; n#`.engine.model.feetier.FeeTier$0);  
        (`posTyp           ; n#0);  
        (`mrgTyp           ; n#0);  
        (`avail            ; n?10);  
        (`bal              ; n?10)  
        ));
    .bam.acc:acc;

    // TODO make cleaner
    t:min events`time;
    {.engine.Emit[`account;x;value y]}[t]'[select aId, time:t, bal, avail, dep, mm:0 from acc];
    {.engine.Emit[`inventory;x;value y]}[t]'[select aId, side, time:t, amt, rpnl, avgPrice, upnl from ivn];

    // TODO recreate all models etc to config
    .engine.Advance[events]
    }










