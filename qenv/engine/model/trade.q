
.engine.model.trade.Trade:([tid:`long$()];price:`long$();qty:`long$();side:`long$();time:`datetime$());
.engine.model.trade.r:.util.NullRowDict[`.engine.model.trade.Trade];

.model.Trade:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:.model.Model[.engine.model.trade.r;cl;vl]; 
    x
    };
