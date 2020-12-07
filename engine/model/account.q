
// lng long postition
// srt short position
// wit:witdrawn
// dep:deposited
// rt: RiskTier
// ft: FeeTier
.engine.model.account.Account:([aId:`long$()] 
  iId:`.engine.model.instrument.Instrument$();
  lng:`.engine.model.inventory.Inventory$();srt:`.engine.model.inventory.Inventory$();
  rt:`.engine.model.risktier.Risktier$();ft:`.engine.model.feetier.Feetier$();
  dep:`long$();wit:`long$();mrgTyp:`long$();avail:`long$();bal:`long$());

.engine.model.account.Create:.engine.model.common.Create[`.engine.model.account.Account];
.engine.model.account.Get:.engine.model.common.Get[`.engine.model.account.Account];
.engine.model.account.Update:.engine.model.common.Update[`.engine.model.account.Account];
