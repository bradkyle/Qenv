
// instrument uses fair price marking?
.engine.services.mark.ProcessLiquidationEvents :{

		if[not(.engine.model.instrument.ValidInstrumentIds[x[`instrumentId]]);[]];
    i:.engine.model.instrument.GetInstrumentByIds[x`instrumentId];
    .engine.model.instrument.UpdateMarkPrice[i`instrumentId;x`markPrice];

    // check mark update event
    a:.engine.model.account.GetInMarketAccounts[x`instrumentId];

    // Derive the open order loss such taht it can be subtracted from 
    // the availbable balance.
    a[`openBuyLoss]:(min[0,(i[`markPrice]*a[`openBuyQty])-a[`openBuyValue]] | 0); // TODO convert to long
    a[`openSellLoss]:(min[0,(i[`markPrice]*a[`openSellQty])-a[`openSellValue]] |0); // TODO convert to long
    a[`openLoss]:(sum[a`openSellLoss`openBuyLoss] | 0);

    // TODO posMargin, markValue, maintMarginReq, initMarginReq
    a[`unrealizedPnl]:sum[(ib;iL;iS)[`unrealizedPnl]];

    // Remove orders that will increase the position size passed the given tier
    // todo derive order margin,
    // todo derive for leverage and max amt etc.
    riskTiers:.engine.logic.fill.DeriveRiskTiers[i;a]; // TODO test this
    a[`initMarginReq]:riskTiers[`imr]+(i[`riskBuffer] | 0);
    a[`maintMarginReq]:riskTiers[`mmr]+(i[`riskBuffer] | 0);
    a[`orderMargin]:a[`openOrderValue]^div[a[`openOrderValue];a[`leverage]]; // TODO optional charge based on config
    
    / a[`leverage]:0;
    // TODO derive only the outstanding amount
    // TODO derive better
    // derive the instantaneous loss that will be incurred for each order
    // placement and thereafter derive the cumulative loss for each order
    // filter out orders that attribute to insufficient balance where neccessary
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0); // TODO convert to long
    ok:a[`available]>prd[a[`maintMarginReq`valueInMarket]];

    // commence liquidation on all insolvent accounts
    .engine.logic.liquidation.Liquidate[a where not[ok]];

    a:.engine.model.account.UpdateAccounts[a];
    .egress.AddAccountEvent[a;x`time];

    .egress.AddMarkEvent[x;x`time];
    };
