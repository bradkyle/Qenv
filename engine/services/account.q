
// Services
// ------------------------------------------------------->


.engine.services.account.ProcessWithdrawEvents       :{
    if[not(.engine.model.instrument.ValidInstrumentIds[x[`datum][`instrumentId]]);
        [0;"Invalid instrumentId"]];
    if[not(.engine.model.account.ValidAccountIds[x[`datum][`accountId]]);
        [0;"Invalid accountId"]];

    i:.engine.model.instrument.GetInstrumentByIds[x[`datum][`instrumentId]];
    if[x[`withdraw]<i[`minWithdraw];[0;"leverage is smaller than minLeverage"]];
    if[x[`withdraw]<i[`lotSize];[0;"leverage is smaller than minLeverage"]];
    if[x[`withdraw]>i[`maxWithdraw];[0;"leverage is larger than maxLeverage"]];

    a:.engine.model.account.GetAccountsById[x[`datum][`accountId]];
    if[a[`balance]<=0;[0;"Account has no balance"]];
    if[a[`available]<=0;[0;"Account has insufficient available balance"]];
    if[a[`state]=1;[0;"Account has been disabled"]];
    if[a[`state]=2;[0;"Account has been locked for liquidation"]];

    a[`balance]-:withdrawn;
    a[`withdrawAmount]+:withdrawn;
    a[`withdrawCount]+:1;
    a[`withdrawable]-:withdrawn;

    /* // Remove orders that will increase the position size passed the given tier */
    /* // todo derive order margin, */
    /* // todo derive for leverage and max amt etc. */
    riskTiers:.engine.logic.fill.DeriveRiskTiers[i;a]; // TODO test this + make faster
    a[`initMarginReq]:riskTiers[`imr]+(i[`riskBuffer] | 0);
    a[`maintMarginReq]:riskTiers[`mmr]+(i[`riskBuffer] | 0);
    // TODO derive pos margin
    a[`orderMargin]:a[`openOrderValue]^div[a[`openOrderValue];a[`leverage]]; // TODO optional charge based on config
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);
    if[(a[`available]<prd[a[`initMarginReq`valueInMarket]]);[0;"Account has insufficient balance"]]; 

    // queue operation
    a:.engine.model.account.UpdateAccounts[a];

    /* .egress.AddAccountEvent[a;x`time]; */
    };


.engine.services.account.ProcessDepositEvents        :{
    if[not(.engine.model.instrument.ValidInstrumentIds[x[`datum][`instrumentId]]);
        [0;"Invalid instrumentId"]];
    if[not(.engine.model.account.ValidAccountIds[x[`datum][`accountId]]);
        [0;"Invalid accountId"]];

    i:.engine.model.instrument.GetInstrumentByIds[x[`datum][`instrumentId]];
    if[(x[`size] mod y[`lotSize])<>0;[0;"Invalid lotSize"]];

    a:.engine.model.account.GetAccountsById[x[`datum][`accountId]];
    if[a[`balance]<=0;[0;"Account has no balance"]];
    if[a[`available]<=0;[0;"Account has insufficient available balance"]];
    if[a[`state]=1;[0;"Account has been disabled"]];
    if[a[`state]=2;[0;"Account has been locked for liquidation"]];

    a[`balance]+:deposited;
    a[`depositAmount]+:deposited;
    a[`depositCount]+:1;
    a[`withdrawable]+:deposited;
    // TODO withdraw cost

    // Remove orders that will increase the position size passed the given tier
    // todo derive order margin,
    // todo derive for leverage and max amt etc.
    riskTiers:.engine.logic.fill.DeriveRiskTiers[i;a]; // TODO test this + make faster
    a[`initMarginReq]:riskTiers[`imr]+(i[`riskBuffer] | 0);
    a[`maintMarginReq]:riskTiers[`mmr]+(i[`riskBuffer] | 0);
    // TODO derive pos margin
    a[`orderMargin]:a[`openOrderValue]^div[a[`openOrderValue];a[`leverage]]; // TODO optional charge based on config
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);

    a:.engine.model.account.UpdateAccounts[a];

    /* .egress.AddAccountEvent[a;x`time]; */
    };



.engine.services.account.ProcessLeverageUpdateEvents :{
    if[not(.engine.model.instrument.ValidInstrumentIds[x[`datum][`instrumentId]]);
        [0;"Invalid instrumentId"]];
    if[not(.engine.model.account.ValidAccountIds[x[`datum][`accountId]]);
        [0;"Invalid accountId"]];

    i:.engine.model.instrument.GetInstrumentByIds[x[`datum][`instrumentId]];
    if[x[`newLeverage]<i[`minLeverage];[0;"leverage is smaller than minLeverage"]];
    if[x[`newLeverage]>i[`maxLeverage];[0;"leverage is larger than maxLeverage"]];

    a:.engine.model.account.GetAccountsById[x[`datum][`accountId]];
    if[a[`balance]<=0;[0;"Order account has no balance"]];
    if[a[`available]<=0;[0;"Order account has insufficient available balance"]];
    if[a[`state]=1;[0;"Account has been disabled"]];
    if[a[`state]=2;[0;"Account has been locked for liquidation"]];
    // TODO purge where inadequate

    a[`leverage]:x`newLeverage;

    // Remove orders that will increase the position size passed the given tier
    // todo derive order margin,
    // todo derive for leverage and max amt etc.
    riskTiers:.engine.logic.fill.DeriveRiskTiers[i;a]; // TODO test this + make faster
    a[`initMarginReq]:riskTiers[`imr]+(i[`riskBuffer] | 0);
    a[`maintMarginReq]:riskTiers[`mmr]+(i[`riskBuffer] | 0);
    // TOOO derive pos margin
    a[`orderMargin]:a[`openOrderValue]^div[a[`openOrderValue];a[`leverage]]; // TODO optional charge based on config
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);
    ok:a[`available]>prd[a[`initMarginReq`valueInMarket]]; 

    x:.util.batch.Purge[x;x where not[ok];0;"Account has insufficient balance"];
    a:a where ok;
    a:.engine.model.account.UpdateAccounts[a];

    /* .egress.AddAccountEvent[a;x`time]; */
    };



.engine.services.account.ProcessPositionTypeUpdateEvents :{
    if[not(.engine.model.instrument.ValidInstrumentIds[x[`datum][`instrumentId]]);
        [0;"Invalid instrumentId"]];
    if[not(.engine.model.account.ValidAccountIds[x[`datum][`accountId]]);
        [0;"Invalid accountId"]];

    i:.engine.model.instrument.GetInstrumentByIds[x[`datum][`instrumentId]];
    if[x[`newLeverage]<i[`minLeverage];[0;"leverage is smaller than minLeverage"]];
    if[x[`newLeverage]>i[`maxLeverage];[0;"leverage is larger than maxLeverage"]];

    a:.engine.model.account.GetAccountsById[x[`datum][`accountId]];
    if[a[`balance]<=0;[0;"Order account has no balance"]];
    if[a[`available]<=0;[0;"Order account has insufficient available balance"]];
    if[a[`state]=1;[0;"Account has been disabled"]];
    if[a[`state]=2;[0;"Account has been locked for liquidation"]];
    // TODO purge where inadequate

		a[`positionType]:x`positionType;

    // Remove orders that will increase the position size passed the given tier
    // todo derive order margin,
    // todo derive for leverage and max amt etc.
    riskTiers:.engine.logic.fill.DeriveRiskTiers[i;a]; // TODO test this + make faster
    a[`initMarginReq]:riskTiers[`imr]+(i[`riskBuffer] | 0);
    a[`maintMarginReq]:riskTiers[`mmr]+(i[`riskBuffer] | 0);
    // TOOO derive pos margin
    a[`orderMargin]:a[`openOrderValue]^div[a[`openOrderValue];a[`leverage]]; // TODO optional charge based on config
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);
    ok:a[`available]>prd[a[`initMarginReq`valueInMarket]]; 

    x:.util.batch.Purge[x;x where not[ok];0;"Account has insufficient balance"];
    a:a where ok;
    a:.engine.model.account.UpdateAccounts[a];

    /* .egress.AddAccountEvent[a;x`time]; */
    };



.engine.services.account.ProcessMarginTypeUpdateEvents	:{
    if[not(.engine.model.instrument.ValidInstrumentIds[x[`datum][`instrumentId]]);
        [0;"Invalid instrumentId"]];
    if[not(.engine.model.account.ValidAccountIds[x[`datum][`accountId]]);
        [0;"Invalid accountId"]];

    i:.engine.model.instrument.GetInstrumentByIds[x[`datum][`instrumentId]];
    if[x[`newLeverage]<i[`minLeverage];[0;"leverage is smaller than minLeverage"]];
    if[x[`newLeverage]>i[`maxLeverage];[0;"leverage is larger than maxLeverage"]];

    a:.engine.model.account.GetAccountsById[x[`datum][`accountId]];
    if[a[`balance]<=0;[0;"Order account has no balance"]];
    if[a[`available]<=0;[0;"Order account has insufficient available balance"]];
    if[a[`state]=1;[0;"Account has been disabled"]];
    if[a[`state]=2;[0;"Account has been locked for liquidation"]];
    // TODO purge where inadequate

		a[`marginType]:x`marginType;

    // Remove orders that will increase the position size passed the given tier
    // todo derive order margin,
    // todo derive for leverage and max amt etc.
    riskTiers:.engine.logic.fill.DeriveRiskTiers[i;a]; // TODO test this + make faster
    a[`initMarginReq]:riskTiers[`imr]+(i[`riskBuffer] | 0);
    a[`maintMarginReq]:riskTiers[`mmr]+(i[`riskBuffer] | 0);
    // TOOO derive pos margin
    a[`orderMargin]:a[`openOrderValue]^div[a[`openOrderValue];a[`leverage]]; // TODO optional charge based on config
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);
    ok:a[`available]>prd[a[`initMarginReq`valueInMarket]]; 

    x:.util.batch.Purge[x;x where not[ok];0;"Account has insufficient balance"];
    a:a where ok;
    a:.engine.model.account.UpdateAccounts[a];

    /* .egress.AddAccountEvent[a;x`time]; */
    };


// TODO update 30 day trade volume
