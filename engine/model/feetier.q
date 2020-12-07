
feeCols:`vol`makerFee`takerFee`wdrawFee`dpsitFee`wdrawLimit;
.engine.model.feetier.Feetier:([ftid:`long$()] 
    bal:`long$();ref:`long$();vol:`long$();mkrfee:`float$();tkrfee:`float$();wdrawfee:`float$();
    dpstfee:`float$();wdlim:`long$());
.engine.model.feetier.Create:.engine.model.common.Create[`.engine.model.feetier.Feetier];
.engine.model.feetier.Get:.engine.model.common.Get[`.engine.model.feetier.Feetier];
