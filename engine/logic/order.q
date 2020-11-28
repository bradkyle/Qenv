
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

.engine.logic.order.NewOrder:{[i;a;o]
				// Instrument validations
				if[o[`price] < i[`mnPrice];:.engine.Purge[o;0;"Invalid price: price<mnPrice"]];
				if[o[`price] > i[`mxPrice];:.engine.Purge[o;0;"Invalid price: price>mxPrice"]];
				if[o[`oqty] < i[`mnSize];:.engine.Purge[o;0;"Invalid oqty: oqty<minqty"]];
				if[o[`oqty] > i[`mxSize];:.engine.Purge[o;0;"Invalid oqty: oqty>maxqty"]];
				if[(o[`price] mod i[`ticksize])<>0;:.engine.Purge[o;0;"Invalid ticksize"]]; 
				if[(o[`oqty] mod i[`lotsize])<>0;:.engine.Purge[o;0;"Invalid lotsize"]];
				if[o[`dqty] < i[`mnSize];:.engine.Purge[o;0;"Invalid dqty: dqty<minsize"]];
				if[o[`dqty] > i[`mxSize];:.engine.Purge[o;0;"Invalid dqty: dqty>maxsize"]];
				if[(o[`dqty] mod i[`lotsize])<>0;.engine.Purge[o;0;"Invalid dqty lot oqty"]]; 

				/ if[(all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])] or
				/ 	all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])]) and 
				/ 	in'[1;o[`execInst]];:.engine.Purge[o;0;"Order had execInst of postOnly"]];

				// Account validations
				if[a[`bal]<=0;:.engine.Purge[o;0;"Order account has no balance"]];
				if[a[`avail]<=0;:.engine.Purge[o;0;"Order account has insufficient available balance"]];
				if[a[`state]=1;:.engine.Purge[o;0;"Account has been disabled"]];
				if[a[`state]=2;:.engine.Purge[o;0;"Account has been locked for liquidation"]];

				dlt:o`oqty;
				vdlt:prd[o[`oqty`price]]; 
				lsdlt:min[(((dlt*i[`mkprice])-vdlt);0)];
				show vdlt;

				iv:.engine.model.inventory.GetInventory[(();())];
				iv[`ordQty]+:dlt;
				iv[`ordVal]+:vdlt;
				iv[`ordLoss]:min[(prd[(i`mkprice;iv`ordQty)]-iv[`ordVal];0)];

				// FeeTier  
				feetier:.engine.model.feetier.GetFeeTier[];
				a[`mkrfee]:feetier[`mkrfee];
				a[`tkrfee]:feetier[`tkrfee];

				// RiskTier
				risktier:.engine.model.risktier.GetRiskTier[];
				a[`imr]:risktier[`imr];
				a[`mmr]:risktier[`mmr];

				a[`avail]-:sum[(vdlt;lsdlt)];

				.engine.model.account.UpdateAccount a;
				.engine.model.inventory.UpdateInventory iv;

				$[(o[`okind]=0);[
							.engine.logic.account.Fill[];
						];[
							.engine.model.order.CreateOrder o;
					 		.engine.logic.orderbook.Level[]
						]];


				.engine.Emit[`account] a;
				.engine.Emit[`inventory] iv;
				.engine.Emit[`instrument] i;
				.engine.Emit[`order] i;

		};

.engine.logic.order.AmendOrder:{[i;a;o]
				c:.engie.logic.order.GetOrder[`oId`cId;o`oId`cId];
				if[null[c];.engine.Purge[o;0;"Order not found"]];
				if[not[c[`state] in ()];.engine.Purge[o;0;"update order with terminal state"]];
				o:c^o;

				// Instrument validations
				if[o[`price] < i[`mnPrice];.engine.Purge[o;0;"Invalid price: price<mnPrice"]];
				if[o[`price] > i[`mxPrice];.engine.Purge[o;0;"Invalid price: price>mxPrice"]];
				if[o[`oqty] < i[`minOqty];.engine.Purge[o;0;"Invalid oqty: oqty<minOqty"]];
				if[o[`oqty] > i[`maxOqty];.engine.Purge[o;0;"Invalid oqty: oqty>maxOqty"]];
				if[(o[`price] mod i[`tickOqty])<>0;.engine.Purge[o;0;"Invalid tickOqty"]]; 
				if[(o[`oqty] mod i[`lotOqty])<>0;.engine.Purge[o;0;"Invalid lotOqty"]];
				if[o[`dqty] < i[`minOqty];.engine.Purge[o;0;"Invalid dqty: oqty<minOqty"]];
				if[o[`dqty] > i[`maxOqty];.engine.Purge[o;0;"Invalid dqty: oqty>maxOqty"]];
				if[(o[`dqty] mod i[`lotOqty])<>0;.engine.Purge[o;0;"Invalid dqty lot oqty"]]; 
				if[(all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])] or
				all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])]) and 
				in'[1;o[`execInst]];.engine.Purge[o;0;"Order had execInst of postOnly"]];

				// Account validations
				if[a[`balance]<=0;.engine.Purge[0;"Order account has no balance"]];
				if[a[`available]<=0;.engine.Purge[0;"Order account has insufficient available balance"]];
				if[a[`state]=1;.engine.Purge[0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[0;"Account has been locked for liquidation"]];

				dlt:(-/)(c`oqty;o`oqty);

				iv:.engine.model.inventory.GetInventory[];
				iv[`ordQty]+:dlt;
				iv[`ordVal]:prd[f[`fqty`fprice]];
				iv[`ordLoss]:min[prd[i`mkprice;iv`ordQty]-iv[`ordVal];0];

				a[`mkrfee`tkrfee]:.engine.model.feetier.FeeTier[][`mkrfee`tkrfee];
				a[`imr`mmr]:.engine.model.risktier.RiskTier[][`imr`mmr];
				a[`avail]:.engine.logic.account.DeriveAvailable[];

				.engine.model.account.UpdateAccount a;
				.engine.model.inventory.UpdateInventory iv;
				.engine.model.instrument.UpdateInstrument i;
				.engine.model.order.AddOrder o;

				.engine.logic.account.Fill[]
				.engine.logic.orderbook.Level[]

				.engine.Emit[`account] a;
				.engine.Emit[`inventory] iv;
				.engine.Emit[`instrument] i;
				.engine.Emit[`order] i;
		};

.engine.logic.order.CancelOrder:{[i;a;o]
				c:.engie.logic.order.GetOrder[`oId`cId;o`oId`cId];
				if[null[c];.engine.Purge[o;0;"Order not found"]];
				if[not[c[`state] in ()];.engine.Purge[o;0;"cancel order with terminal state"]];
				o:c^o;

				if[a[`state]=1;.engine.Purge[0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[0;"Account has been locked for liquidation"]];

				dlt:neg[c`oQty];
				iv:.engine.model.inventory.GetInventory[];
				iv[`ordQty]+:dlt;
				iv[`ordVal]:prd[f[`fqty`fprice]];
				iv[`ordLoss]:min[prd[i`mkprice;iv`ordQty]-iv[`ordVal];0];

				a[`mkrfee`tkrfee]:.engine.model.feetier.FeeTier[][`mkrfee`tkrfee];
				a[`imr`mmr]:.engine.model.risktier.RiskTier[][`imr`mmr];
				a[`avail]:.engine.logic.account.DeriveAvailable[];

				.engine.model.account.UpdateAccount a;
				.engine.model.inventory.UpdateInventory iv;
				.engine.model.instrument.UpdateInstrument i;
				.engine.model.order.AddOrder o;

				// add depth, add 
				.engine.logic.orderbook.Level[]

				.engine.Emit[`account] a;
				.engine.Emit[`inventory] iv;
				.engine.Emit[`instrument] i;
				.engine.Emit[`order] i;
		};


.engine.logic.order.CancelAllOrders:{[i;a;o]
				c:.engie.logic.order.GetOrder[`aId`state;(a`aId;0)];
				if[null[c];.engine.Purge[o;0;"No orders found"]];
				if[not[c[`state] in ()];.engine.Purge[o;0;"cancel order with terminal state"]];

				if[a[`state]=1;.engine.Purge[0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[0;"Account has been locked for liquidation"]];

				dlt:neg[sum[c`oQty]];
				iv:.engine.model.inventory.GetInventory[];
				iv[`ordQty]+:dlt;
				iv[`ordVal]:prd[f[`fqty`fprice]];
				iv[`ordLoss]:min[prd[i`mkprice;iv`ordQty]-iv[`ordVal];0];

				a[`mkrfee`tkrfee]:.engine.model.feetier.FeeTier[][`mkrfee`tkrfee];
				a[`imr`mmr]:.engine.model.risktier.RiskTier[][`imr`mmr];
				a[`avail]:.engine.logic.account.DeriveAvailable[];

				.engine.model.account.UpdateAccount a;
				.engine.model.inventory.UpdateInventory iv;
				.engine.model.instrument.UpdateInstrument i;
				.engine.model.order.RemoveOrder o;

				// add depth, add 
				.engine.logic.orderbook.Level[]

				.engine.Emit[`account] a;
				.engine.Emit[`inventory] iv;
				.engine.Emit[`instrument] i;
				.engine.Emit[`order] i;
    };

