
.engine.model.inventory.Inventory:([ivId:`long$()] 
   aId:`long$();ordQty:`long$();ordVal:`long$();ordLoss:`long$();amt:`long$();iw:`long$();mm:`long$();
   posValue:`long$();rpnl:`long$();avgPrice:`long$();execCost:`long$();upnl:`long$();lev:`long$());

.engine.model.inventory.Create:.engine.model.common.Create[`.engine.model.inventory.Inventory];
.engine.model.inventory.GetInventory:.engine.model.common.Get[`.engine.model.inventory.Inventory];
.engine.model.inventory.UpdateInventory:.engine.model.common.Update[`.engine.model.inventory.Inventory];
