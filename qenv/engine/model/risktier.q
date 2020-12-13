
riskCols:`mxamt`mmr`imr`maxlev;
.engine.model.risktier.Risktier:([rtId:`long$()] amt:`long$();mmr:`float$();imr:`float$();lev:`long$());
.engine.model.risktier.r:.util.NullRowDict[`.engine.model.risktier.Risktier];

.engine.model.risktier.Create:.engine.model.common.Create[`.engine.model.risktier.Risktier];
.engine.model.risktier.Get:.engine.model.common.Get[`.engine.model.risktier.Risktier];
