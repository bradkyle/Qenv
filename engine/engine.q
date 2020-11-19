
.engine.watermark           :0N;
.engine.ingress.Events      :([])
.engine.egress.Events       :([])

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

.engine.Advance :{}
.engine.Reset   :{}
