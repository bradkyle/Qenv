
// Services
// ------------------------------------------------------->


  
// this will be placed in engine
.engine.services.funding.ProcessFundingEvents :{[x]
    // CHekc instrument exists
    // check funding event
    x:x[`datum];
    if[not[first .engine.model.instrument.ValidInstrumentIds[x[`instrument]]];[0;"instrument does not exist"]];
    i:first .engine.model.instrument.GetInstrumentByIds[x[`instrument]];
    .engine.model.instrument.UpdateInstruments[i]; // TODO
    
    iv:.engine.model.inventory.GetInMarketInventory[i[`instrumentId]];

    f:0!select 
    amtInMarket: sum[amt],
    fundingCost:((min[(x[`fundingRate];0)]*(amt*isignum)) + (max[(x[`fundingRate];0)]*(amt*isignum)))
        by accountId from iv;  

    a:.engine.model.account.GetAccountsById[(0!f)`accountId];
    a[`realizedPnl]+:f[`fundingCost]*i[`markPrice];
    a[`valueInMarket]:f[`amtInMarket]*i[`markPrice];

    // Remove orders that will increase the position size passed the given tier
    // todo derive order margin,
    // todo derive for leverage and max amt etc.
    riskTiers:.engine.logic.fill.DeriveRiskTier[i;a]; // TODO test this + make faster
    a[`initMarginReq]:riskTiers[`imr]+(i[`riskBuffer] | 0);
    a[`maintMarginReq]:riskTiers[`mmr]+(i[`riskBuffer] | 0);
    a[`orderMargin]:a[`openOrderValue]^div[a[`openOrderValue];a[`leverage]]; // TODO optional charge based on config

    //TODO derive liquidation price

    // TODO balance - realizedPnl
    // withdrawable, frozen
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);
    ok:a[`available]>prd[a[`maintMarginReq`valueInMarket]]; 
    
    .engine.logic.liquidation.Liquidate[a[`accountId] where not[ok]];

    // TODO change to 
    a:.engine.model.account.UpdateAccounts[a];
    [];
    [];
    };
