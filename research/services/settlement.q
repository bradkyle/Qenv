

// Services
// ------------------------------------------------------->
.engine.services.settlement.ProcessSettlementEvents :{
    if[not[first .engine.model.instrument.ValidInstrumentIds[x[`instrument]]];[0;"instrument does not exist"]];
    i:first .engine.model.instrument.GetInstrumentByIds[x[`instrument]];
    // TODO settlement values

    a:.engine.model.account.GetAllUnsettled[x`instrumentId];
    iv:.egnien.model.inventory.GetInventoryOfAccounts[a`accountId];

    // TODO realized pnl is moved from inventory back into balance
    // TODO on settlement trade volume is calculated for the past x days
    a[`balance]+:a[`realizedPnl];
    a[`realizedPnl]:0;
    a[`realizedGrossPnl]:0;

    // Remove orders that will increase the position size passed the given tier
    // todo derive order margin,
    // todo derive for leverage and max amt etc.
    riskTiers:.engine.logic.fill.DeriveRiskTier[i;a]; // TODO test this + make faster
    a[`initMarginReq]:riskTiers[`imr]+(i[`riskBuffer] | 0);
    a[`maintMarginReq]:riskTiers[`mmr]+(i[`riskBuffer] | 0);
    a[`orderMargin]:a[`openOrderValue]^div[a[`openOrderValue];a[`leverage]]; // TODO optional charge based on config

    // TODO balance - realizedPnl
    // withdrawable, frozen
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);
    ok:a[`available]>prd[a[`maintMarginReq`valueInMarket]]; 
    
    a:.engine.model.account.UpdateAccounts[a];
    iv:.engine.model.account.UpdateInventory[iv];
    i:.engine.model.account.UpdateInstrument[i];
    // TODO derive and insert account update events
    };
