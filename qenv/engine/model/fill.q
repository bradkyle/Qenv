
.engine.model.fill.Fill:([fId:`long$()];time:`datetime$();price:`long$();qty:`long$();reduce:`boolean$();
	ismaker:`boolean$();side:`long$();iId:`.engine.model.instrument.Instrument$();
  oId:`.engine.model.order.Order$();ivId:`.engine.model.inventory.Inventory$();
  aId:`.engine.model.account.Account$());
.engine.model.fill.r:.util.NullRowDict[`.engine.model.fill.Fill];

.model.Fill:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:.model.Model[.engine.model.fill.r;cl;vl];
    x[`aId]:`.engine.model.account.Account$x[`aId];
    / .bam.x:x;
    / .bam.ivId:x`ivId;
    / .bam.iv: .engine.model.inventory.Inventory;
    show x[`ivId];
    show `.engine.model.inventory.Inventory$x[`ivId];
    x[`ivId]:`.engine.model.inventory.Inventory$x[`ivId];
    x[`oId]:`.engine.model.order.Order$x[`oId];
    x[`iId]:`.engine.model.instrument.Instrument$x[`iId];
    x
    };
