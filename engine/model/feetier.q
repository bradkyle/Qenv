
feeCols:`vol`makerFee`takerFee`wdrawFee`dpsitFee`wdrawLimit;
.engine.model.feetier.FeeTier:([ftid:`long$()] vol:`long$();mkrfee:`float$();tkrfee:`float$();wdrawfee:`float$();
    dpstfee:`float$();wdlim:`long$());
.engine.model.feetier.Create:.engine.model.common.Create[`.engine.model.feetier.FeeTier];
.engine.model.feetier.GetFeeTier:.engine.model.common.Get[`.engine.model.feetier.FeeTier];
