
// TODO mappings

// 
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

// Returns the set of events that would occur in the given step 
// of the agent action.
.egress._GetEgressEvents   :{[step;windowkind] // TODO should select next batch according to config
    econd:.egress.getEgressCond[windowkind];
    events:?[`.egress.Event;econd;0b;()];
    .egress.test.events:events;
    ![`.egress.Event;enlist(=;`eid;key[events]`eid);0b;`symbol$()];
    value events
    };

/ Event Processing logic (Writes)
/ -------------------------------------------------------------------->

.engine.multiplex:{@[.engine.logic[y];x;show]}; // TODO logging

.engine.process            :{[x] // WRITE EVENTS TODO remove liquidation events?
    if[count[x]>0;[
        newwm: max x`time;
        $[(null[.engine.watermark] or (newwm>.engine.watermark));[ // TODO instead of show log to file etc
            x:.util.batch.TimeOffsetK[x];
            r:$[count[distinct[x`kind]]>1;
                .engine.multiplex'[0!(`f xgroup update f:{sums((<>) prior x)}kind from `time xasc x)];
                .engine.multiplex[0!(`f xgroup update f:first'[kind] from x)]];
            .engine.watermark:newwm;
            r:.util.batch.TimeOffsetK[r];
            r:.util.batch.GausRowDropouts[r];
            .egress.AddBatch[r];
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
