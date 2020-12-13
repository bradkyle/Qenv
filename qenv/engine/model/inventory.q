
.engine.model.inventory.Inventory:([aId:`long$();side:`long$()]
   ordQty:`long$();ordVal:`long$();ordLoss:`long$();amt:`long$();iw:`long$();mm:`long$();
   posVal:`long$();rpnl:`long$();avgPrice:`long$();execCost:`long$();totEnt:`long$();
   upnl:`long$();lev:`long$();time:`datetime$());

.engine.model.inventory.Create:.engine.model.common.Create[`.engine.model.inventory.Inventory];
.engine.model.inventory.Get:.engine.model.common.Get[`.engine.model.inventory.Inventory];
.engine.model.inventory.Update:.engine.model.common.Update[`.engine.model.inventory.Inventory];
