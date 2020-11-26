
// wit:witdrawn
// dep:deposited
.engine.model.account.Account:([aId:`long$()] 
  lng:`.engine.model.inventory.Inventory$();srt:`.engine.model.inventory.Inventory$();mrg:`long$();
  dep:`long$();wit:`long$();mmr:`long$();imr:`long$();posTyp:`long$();mrgTyp:`long$();
  feeTier:`long$();avail:`long$();bal:`long$());

.engine.model.account.GetAccount:.engine.model.common.Get[`.engine.model.account.Account];
.engine.model.account.UpdateAccount:.engine.model.common.Update[`.engine.model.account.Account];
