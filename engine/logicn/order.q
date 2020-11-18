

.order.NewOrder:{
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

.order.AmendOrder:{

				};

.order.CancelOrder:{

				};

.order.CancelAllOrders:{

				};

