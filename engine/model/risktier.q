
riskCols:`mxamt`mmr`imr`maxlev;
.engine.model.risktier.RiskTier:([rtid:`long$()];mmr:`float$();imr:`float$();maxlev:`long$();mxamt:`long$());

.engine.model.risktier.Create:.engine.model.common.Create[`.engine.model.risktier.RiskTier];
.engine.model.risktier.GetRiskTier:.engine.model.common.Get[`.engine.model.risktier.RiskTier];
