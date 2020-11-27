

.engine.logic.order.NewOrder:{[i;a;o]
				// Instrument validations
				if[x[`price] < i[`minPrice];.engine.Purge[o;0;"Invalid price: price<minPrice"]];
				if[x[`price] > i[`maxPrice];.engine.Purge[o;0;"Invalid price: price>maxPrice"]];
				if[x[`size] < i[`minSize];.engine.Purge[o;0;"Invalid size: size<minSize"]];
				if[x[`size] > i[`maxSize];.engine.Purge[o;0;"Invalid size: size>maxSize"]];
				if[(x[`price] mod i[`tickSize])<>0;.engine.Purge[o;0;"Invalid tickSize"]]; 
				if[(x[`size] mod i[`lotSize])<>0;.engine.Purge[o;0;"Invalid lotSize"]];
				if[x[`displayqty] < i[`minSize];.engine.Purge[o;0;"Invalid displayqty: size<minSize"]];
				if[x[`displayqty] > i[`maxSize];.engine.Purge[o;0;"Invalid displayqty: size>maxSize"]];
				if[(x[`displayqty] mod i[`lotSize])<>0;.engine.Purge[o;0;"Invalid displayqty lot size"]]; 
				if[(all[((x[`side]<0);(i[`bestBidPrice]>=x[`price]);i[`hasLiquidityBuy])] or
				all[((x[`side]<0);(i[`bestBidPrice]>=x[`price]);i[`hasLiquidityBuy])]) and 
				in'[1;x[`execInst]];.engine.Purge[o;0;"Order had execInst of postOnly"]];

				// Account validations
				if[a[`balance]<=0;.engine.Purge[0;"Order account has no balance"]];
				if[a[`available]<=0;.engine.Purge[0;"Order account has insufficient available balance"]];
				if[a[`state]=1;.engine.Purge[0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[0;"Account has been locked for liquidation"]];

				dlt:x`size;

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

.engine.logic.order.AmendOrder:{[i;a;o]
				c:.engie.logic.order.GetOrder[`oId`cId;o`oId`cId];
				if[null[c];.engine.Purge[o;0;"Order not found"]];
				if[not[c[`state] in ()];.engine.Purge[o;0;"update order with terminal state"]];
				o:c^o;

				// Instrument validations
				if[x[`price] < i[`minPrice];.engine.Purge[o;0;"Invalid price: price<minPrice"]];
				if[x[`price] > i[`maxPrice];.engine.Purge[o;0;"Invalid price: price>maxPrice"]];
				if[x[`size] < i[`minSize];.engine.Purge[o;0;"Invalid size: size<minSize"]];
				if[x[`size] > i[`maxSize];.engine.Purge[o;0;"Invalid size: size>maxSize"]];
				if[(x[`price] mod i[`tickSize])<>0;.engine.Purge[o;0;"Invalid tickSize"]]; 
				if[(x[`size] mod i[`lotSize])<>0;.engine.Purge[o;0;"Invalid lotSize"]];
				if[x[`displayqty] < i[`minSize];.engine.Purge[o;0;"Invalid displayqty: size<minSize"]];
				if[x[`displayqty] > i[`maxSize];.engine.Purge[o;0;"Invalid displayqty: size>maxSize"]];
				if[(x[`displayqty] mod i[`lotSize])<>0;.engine.Purge[o;0;"Invalid displayqty lot size"]]; 
				if[(all[((x[`side]<0);(i[`bestBidPrice]>=x[`price]);i[`hasLiquidityBuy])] or
				all[((x[`side]<0);(i[`bestBidPrice]>=x[`price]);i[`hasLiquidityBuy])]) and 
				in'[1;x[`execInst]];.engine.Purge[o;0;"Order had execInst of postOnly"]];

				// Account validations
				if[a[`balance]<=0;.engine.Purge[0;"Order account has no balance"]];
				if[a[`available]<=0;.engine.Purge[0;"Order account has insufficient available balance"]];
				if[a[`state]=1;.engine.Purge[0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[0;"Account has been locked for liquidation"]];

				dlt:(-/)(c`size;o`size);

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

