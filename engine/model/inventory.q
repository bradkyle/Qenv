
.engine.model.inventory.Inventory:([ivId:`long$()] 
   aId:`long$();ordQty:`long$();ordVal:`long$();ordLoss:`long$();amt:`long$();
   posValue:`long$();rpnl:`long$();avgPrice:`long$();execCost:`long$();upnl:`long$();lev:`long$());

.engine.model.inventory.GetInventory:.engine.model.common.Get[`.engine.model.inventory.Inventory];
.engine.model.inventory.UpdateInventory:.engine.model.common.Update[`.engine.model.inventory.Inventory];
