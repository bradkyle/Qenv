
.engine.model.instrument.Instrument:([iId:`long$()] cntTyp:`long$();state:`long$();faceValue:`long$();mkprice:`long$();
				plmts:`long$();plmtb:`long$();lotSize:`long$();tickSize:`long$();mnSize:`long$();
  			mxSize:`long$();mnPrice:`long$();mxPrice:`long$();smul:`long$();fudingrate:`float$();
				bestBid:`long$();bestAsk:`long$();liqb:`boolean$();liqs:`boolean$();time:`datetime$());
.engine.model.instrument.r:.util.NullRowDict[`.engine.model.instrument.Instrument];

.engine.model.instrument.Create:.engine.model.common.Create[`.engine.model.instrument.Instrument]
.engine.model.instrument.Get:.engine.model.common.Get[`.engine.model.instrument.Instrument];
.engine.model.instrument.Update:.engine.model.common.Update[`.engine.model.instrument.Instrument];

.model.Instrument:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:.model.Model[.engine.model.instrument.r;cl;vl]; 
    x
    };

.engine.model.funding.r:.util.NullRowDict[([] 
        time:`datetime$(); 
        iId:`.engine.model.instrument.Instrument$(); 
        fundingrate:`float$())];

.model.Funding:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:.model.Model[.engine.model.funding.r;cl;vl]; 
    x[`iId]:`.engine.model.instrument.Instrument$x[`iId];
    x
    };

.engine.model.settlement.r:.util.NullRowDict[([] 
        time:`datetime$(); 
        aId:`.engine.model.account.Account$(); 
        iId:`.engine.model.instrument.Instrument$())];

.model.Settlement:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:.model.Model[.engine.model.settlement.r;cl;vl];
    x[`iId]:`.engine.model.instrument.Instrument$x[`iId];
    x
    };

.engine.model.pricelimit.r:.util.NullRowDict[([] 
        time:`datetime$(); 
        iId:`.engine.model.instrument.Instrument$(); 
        highest:`long$();
        lowest:`long$())];

.model.PriceLimit:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:.model.Model[.engine.model.pricelimit.r;cl;vl];
    x[`iId]:`.engine.model.instrument.Instrument$x[`iId];
    x
    };

.engine.model.pricelimit.r:.util.NullRowDict[([] 
        time:`datetime$(); 
        iId:`.engine.model.instrument.Instrument$(); 
        markprice:`long$())];

.model.Mark:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:.model.Model[.engine.model.markprice.r;cl;vl];
    x[`iId]:`.engine.model.instrument.Instrument$x[`iId];
    x
    };
