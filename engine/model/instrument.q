
.engine.model.instrument.Instrument:([iId:`long$()] cntTyp:`long$();state:`long$();faceValue:`long$();markPrice:`long$();
				plmts:`long$();plmtb:`long$();lotSize:`long$();tickSize:`long$();mnSize:`long$();
  			mxSize:`long$();mnPrice:`long$();mxPrice:`long$();
				bestBid:`long$();bestAsk:`long$();liqb:`boolean$();liqs:`boolean$());

.engine.model.instrument.Create:.engine.model.common.Create[`.engine.model.instrument.Instrument]
.engine.model.instrument.Get:.engine.model.common.Get[`.engine.model.instrument.Instrument];
.engine.model.instrument.Update:.engine.model.common.Update[`.engine.model.instrument.Instrument];
