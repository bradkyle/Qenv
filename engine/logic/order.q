

.engine.logic.order.NewOrder:{
    x[`limitprice]:0^x[`limitprice];
    x[`stopprice]:0^x[`stopprice];
    x[`trigger]:0^x[`trigger];
    x[`timeinforce]:0^x[`timeinforce];
    x[`reduce]:0b^x[`reduce];
    x[`displayqty]:x[`size]^x[`displayqty];
    x[`execInst]:0^x[`execInst];
				
    if[x[`price] < i[`minPrice];[0;"Invalid price: price<minPrice"]];
    if[x[`price] > i[`maxPrice];[0;"Invalid price: price>maxPrice"]];
    if[x[`size] < i[`minSize];[0;"Invalid size: size<minSize"]];
    if[x[`size] > i[`maxSize];[0;"Invalid size: size>maxSize"]];
    if[(x[`price] mod i[`tickSize])<>0;[0;"Invalid tickSize"]]; 
    if[(x[`size] mod i[`lotSize])<>0;[0;"Invalid lotSize"]];
    if[x[`displayqty] < i[`minSize];[0;"Invalid displayqty: size<minSize"]];
    if[x[`displayqty] > i[`maxSize];[0;"Invalid displayqty: size>maxSize"]];
    if[(x[`displayqty] mod i[`lotSize])<>0;[0;"Invalid displayqty lot size"]]; 
    if[(all[((x[`side]<0);(i[`bestBidPrice]>=x[`price]);i[`hasLiquidityBuy])] or
        all[((x[`side]<0);(i[`bestBidPrice]>=x[`price]);i[`hasLiquidityBuy])]) and 
        in'[1;x[`execInst]];[0;"Order had execInst of postOnly"]];

		a:?[];
    if[a[`balance]<=0;[0;"Order account has no balance"]];
    if[a[`available]<=0;[0;"Order account has insufficient available balance"]];
    if[a[`state]=1;[0;"Account has been disabled"]];
    if[a[`state]=2;[0;"Account has been locked for liquidation"]];

    // Derive the sum of the margin that will be required
    // for each order to be filled and filter out the orders
    // for which their respective account has insufficient 
    // balance.
    /* amts: ((sums;x`size) fby x`accountId) * x`side; // TODO change to dlt */
    amts:sum[x`size];
    
    // TODO change to allow ffor mutliple position types
		iv:?[];

		.inventory,:iv;
		.account,:account;

		.account.Fill[];
		// add depth, add 

		};

.engine.logic.order.AmendOrder:{
    x[`limitprice]:0^x[`limitprice];
    x[`stopprice]:0^x[`stopprice];
    x[`trigger]:0^x[`trigger];
    x[`timeinforce]:0^x[`timeinforce];
    x[`reduce]:0b^x[`reduce];
    x[`displayqty]:x[`size]^x[`displayqty];
    x[`execInst]:0^x[`execInst];
				
    if[x[`price] < i[`minPrice];[0;"Invalid price: price<minPrice"]];
    if[x[`price] > i[`maxPrice];[0;"Invalid price: price>maxPrice"]];
    if[x[`size] < i[`minSize];[0;"Invalid size: size<minSize"]];
    if[x[`size] > i[`maxSize];[0;"Invalid size: size>maxSize"]];
    if[(x[`price] mod i[`tickSize])<>0;[0;"Invalid tickSize"]]; 
    if[(x[`size] mod i[`lotSize])<>0;[0;"Invalid lotSize"]];
    if[x[`displayqty] < i[`minSize];[0;"Invalid displayqty: size<minSize"]];
    if[x[`displayqty] > i[`maxSize];[0;"Invalid displayqty: size>maxSize"]];
    if[(x[`displayqty] mod i[`lotSize])<>0;[0;"Invalid displayqty lot size"]]; 
    if[(all[((x[`side]<0);(i[`bestBidPrice]>=x[`price]);i[`hasLiquidityBuy])] or
        all[((x[`side]<0);(i[`bestBidPrice]>=x[`price]);i[`hasLiquidityBuy])]) and 
        in'[1;x[`execInst]];[0;"Order had execInst of postOnly"]];

		a:?[];
    if[a[`balance]<=0;[0;"Order account has no balance"]];
    if[a[`available]<=0;[0;"Order account has insufficient available balance"]];
    if[a[`state]=1;[0;"Account has been disabled"]];
    if[a[`state]=2;[0;"Account has been locked for liquidation"]];

    // Derive the sum of the margin that will be required
    // for each order to be filled and filter out the orders
    // for which their respective account has insufficient 
    // balance.
    /* amts: ((sums;x`size) fby x`accountId) * x`side; // TODO change to dlt */
    amts:sum[x`size];
    
    // TODO change to allow ffor mutliple position types
		iv:?[];

		.inventory,:iv;
		.account,:account;

		.account.Fill[];
		// add depth, add 
		};

.engine.logic.order.CancelOrder:{

    /* x:.engine.services.order.ParseCancelOrderEvents[x]; */
		if[not(.engine.model.instrument.ValidInstrumentIds[x[`instrumentId]]);[]];
		if[not(.engine.model.instrument.ValidAccountIds[x[`accountId]]);[]];
				  
    a:.engine.model.account.GetAccountsById[x[`accountId]];
    i:first .engine.model.instrument.GetInstrumentByIds[x[`instrumentId]];

    // get account deltas that will be net positive and
    // derive amts from this
    x:.engine.services.order.validateOrderExists[x];
    c:.engine.model.order.GetOrdersById[x`orderId];

    // Derive the sum of the margin that will be required
    // for each order to be filled and filter out the orders
    // for which their respective account has insufficient 
    // balance.
    amts:neg[sum[x`size]];

    a[`openBuyQty]:?[amts>0;x[`openBuyQty]-abs[dlts];x[`openBuyQty]];
    a[`openSellQty]:?[amts<0;a[`openSellQty]-abs[dlts];a[`openSellQty]];

    // TODO move this logic into margin logic
    a[`openBuyValue]+:prd[(a[`openBuyQty];x[`price])];
    a[`openSellValue]+:prd[(a[`openSellQty];e[`price])];
    a[`openOrderValue]:sum[a[`openSellValue`openBuyValue]];
    a[`qtyInMarket]:sum[a[`openSellQty`openBuyQty`netLongPosition`netShortPosition]]; // TODO derive position from account
    a[`valueInMarket]:sum[a[`openSellValue`openBuyValue]]; // TODO derive position from account

    // Remove orders that will increase the position size passed the given tier
    // todo derive order margin,
    // todo derive for leverage and max amt etc.
    riskTiers:.engine.logic.fill.DeriveRiskTiers[i;a]; // TODO test this + make faster
    a[`initMarginReq]:riskTiers[`imr]+(i[`riskBuffer] | 0);
    a[`maintMarginReq]:riskTiers[`mmr]+(i[`riskBuffer] | 0);
    a[`orderMargin]:a[`openOrderValue]^div[a[`openOrderValue];a[`leverage]]; // TODO optional charge based on config

    / a[`leverage]:0;
    // TODO derive only the outstanding amount
    // TODO derive better
    // derive the instantaneous loss that will be incurred for each order
    // placement and thereafter derive the cumulative loss for each order
    // filter out orders that attribute to insufficient balance where neccessary
    a[`openBuyLoss]:(min[0,(i[`markPrice]*a[`openBuyQty])-a[`openBuyValue]] | 0); // TODO convert to long
    a[`openSellLoss]:(min[0,(i[`markPrice]*a[`openSellQty])-a[`openSellValue]] |0); // TODO convert to long
    a[`openLoss]:(sum[a`openSellLoss`openBuyLoss] | 0); // TODO convert to long
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0); // TODO convert to long
    if[a[`available]<prd[a[`initMarginReq`valueInMarket]];[0;"Account has insufficient balance"]]; 

    a:.engine.model.account.UpdateAccounts[a];

    // create new orders and
    o:.engine.model.order.RemoveOrdersById[c`orderId];

    // TODO derive the batch deltas
    l:((sums;x`size) fby x`side`price); // Derive last visible level deltas
    l:.engine.model.orderbook.UpdateLevels[l];
    // Process Depth updates as derived above
    l:.engine.logic.depth.ProcessDepthUpdates[l];

    .engine.egress.AddAccountEvent[a;x`time];
    .engine.egress.AddOrderCancellledEvent[o;x`time];
    .engine.egress.AddDepthEvent[l;l`time];
		};


.engine.logic.order.CancelAllOrders:{
    /* x:.engine.services.order.ParseCancelAllOrdersEvents[x]; */
		if[not(.engine.model.instrument.ValidInstrumentIds[x[`instrumentId]]);[]];
		if[not(.engine.model.instrument.ValidAccountIds[x[`accountId]]);[]];
				  
    a:.engine.model.account.GetAccountsById[x[`accountId]];
    i:first .engine.model.instrument.GetInstrumentByIds[x[`instrumentId]];

    // remove all orders in the order table before the account
    // has been updated
    o:.engine.model.order.RemoveOrdersByAccountId[a`accountId];
    // TODO emit events

    // check account has no more orders etc.
    a[`openBuyQty]:0;
    a[`openBuyValue]:0;
    a[`openSellQty]:0;
    a[`openSellValue]:0;
    a[`openOrderValue]:0;
    a[`qtyInMarket]:sum[a[`netLongPosition`netShortPosition]]; // TODO derive position from account
    a[`valueInMarket]:sum[a[`openSellValue`openBuyValue]]; // TODO derive position from account

    // Remove orders that will increase the position size passed the given tier
    // todo derive for leverage and max amt etc.
    riskTiers:.engine.logic.fill.DeriveRiskTiers[i;a]; // TODO test this + make faster
    a[`initMarginReq]:riskTiers[`imr]+(i[`riskBuffer] | 0);
    a[`maintMarginReq]:riskTiers[`mmr]+(i[`riskBuffer] | 0);
    a[`orderMargin]:0; // TODO optional charge based on config

    a[`openBuyLoss]:0; // TODO convert to long
    a[`openSellLoss]:0; // TODO convert to long
    a[`openLoss]:0; // TODO convert to long

    / a[`leverage]:0;
    // TODO derive only the outstanding amount
    // TODO derive better
    // derive the instantaneous loss that will be incurred for each order
    // placement and thereafter derive the cumulative loss for each order
    // filter out orders that attribute to insufficient balance where neccessary
    a[`openBuyLoss]:(min[0,(i[`markPrice]*a[`openBuyQty])-a[`openBuyValue]] | 0); // TODO convert to long
    a[`openSellLoss]:(min[0,(i[`markPrice]*a[`openSellQty])-a[`openSellValue]] |0); // TODO convert to long
    a[`openLoss]:(sum[a`openSellLoss`openBuyLoss] | 0); // TODO convert to long
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0); // TODO convert to long
    if[a[`available]<prd[a[`initMarginReq`valueInMarket]];[0;"Account has insufficient balance"]]; 

    a:.engine.model.account.UpdateAccounts[a];

    // create new orders and
    o:.engine.model.order.RemoveOrdersByAccountId[a`accountId];

    l:((sums;x`size) fby x`side`price); // Derive last visible level deltas
    l:.engine.model.orderbook.UpdateLevels[l];

    // Process Depth updates as derived above
    l:.engine.logic.depth.ProcessDepthUpdates[l];

    .engine.egress.AddAccountEvent[a;x`time];
    .engine.egress.AddOrderCancellledEvent[o;x`time];
    };

