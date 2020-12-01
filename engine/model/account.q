
// lng long postition
// srt short position
// wit:witdrawn
// dep:deposited
// rt: RiskTier
// ft: FeeTier
.engine.model.account.Account:([aId:`long$()] 
  lng:`.engine.model.inventory.Inventory$();srt:`.engine.model.inventory.Inventory$();
  dep:`long$();wit:`long$();rt:`.engine.model.risktier.RiskTier$();ft:`.engine.model.feetier.FeeTier$();
  posTyp:`long$();mrgTyp:`long$();
  avail:`long$();bal:`long$());

.engine.model.account.Create:.engine.model.common.Create[`.engine.model.account.Account];
.engine.model.account.GetAccount:.engine.model.common.Get[`.engine.model.account.Account];
.engine.model.account.UpdateAccount:.engine.model.common.Update[`.engine.model.account.Account];
