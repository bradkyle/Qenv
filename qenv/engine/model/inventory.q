
.engine.model.inventory.Inventory:([aId:`long$();side:`long$()]
   iId:`.engine.model.instrument.Instrument$();
   ordQty:`long$();ordVal:`long$();ordLoss:`long$();amt:`long$();iw:`long$();mm:`long$();
   posVal:`long$();rpnl:`long$();avgPrice:`long$();execCost:`long$();totEnt:`long$();
   upnl:`long$();lev:`long$();time:`datetime$());
.engine.model.inventory.r:.util.NullRowDict[`.engine.model.inventory.Inventory];

.engine.model.inventory.Create:.engine.model.common.Create[`.engine.model.inventory.Inventory];
.engine.model.inventory.Get:.engine.model.common.Get[`.engine.model.inventory.Inventory];
.engine.model.inventory.Update:.engine.model.common.Update[`.engine.model.inventory.Inventory];

.model.Inventory:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:flip .model.Model[.engine.model.inventory.r;cl;vl];  
    x[`iId]:`.engine.model.instrument.Instrument$x[`iId];
    x
    };
