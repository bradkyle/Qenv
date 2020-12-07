
.engine.logic.order.NewOrder:{[t;i;a;x]
				// Instrument validations
				ordCols:`clOid`aId`price`lprice`sprice`trig`tif`okind`oskind`state`oqty`dqty`lqty`einst`reduce;
				o:flip ordCols!flip x`datum;
				t:first x`time;

				/ if[count[o]>10;:.engine.Purge[o;first x`time;"Invalid batch size: batch size > max batch size"]];
				if[o[`price] < i[`mnPrice];:.engine.Purge[o;t;"Invalid price: price<mnPrice"]];
				if[o[`price] > i[`mxPrice];:.engine.Purge[o;t;"Invalid price: price>mxPrice"]];
				if[o[`oqty] < i[`mnSize];:.engine.Purge[o;t;"Invalid oqty: oqty<minqty"]];
				if[o[`oqty] > i[`mxSize];:.engine.Purge[o;t;"Invalid oqty: oqty>maxqty"]];
				if[(o[`price] mod i[`ticksize])<>0;:.engine.Purge[o;t;"Invalid ticksize"]]; 
				if[(o[`oqty] mod i[`lotsize])<>0;:.engine.Purge[o;t;"Invalid lotsize"]];
				if[o[`dqty] < i[`mnSize];:.engine.Purge[o;t;"Invalid dqty: dqty<minsize"]];
				if[o[`dqty] > i[`mxSize];:.engine.Purge[o;t;"Invalid dqty: dqty>maxsize"]];
				if[(o[`dqty] mod i[`lotsize])<>0;.engine.Purge[o;t;"Invalid dqty lot oqty"]]; 

				// Account validations
				if[a[`bal]<=0;:.engine.Purge[o;t;"Order account has no balance"]];
				if[a[`avail]<=0;:.engine.Purge[o;t;"Order account has insufficient available balance"]];
				if[a[`state]=1;:.engine.Purge[o;t;"Account has been disabled"]];
				if[a[`state]=2;:.engine.Purge[o;t;"Account has been locked for liquidation"]];

				dlt:o`oqty;
				vdlt:prd[o[`oqty`price]]; // TODO contract specific 
				lsdlt:min[(((dlt*i[`mkprice])-vdlt);0)];

				iv:.engine.model.inventory.Get[(();())];
				iv[`ordQty]+:dlt;
				iv[`ordVal]+:vdlt;
				iv[`ordLoss]:min[(prd[(i`mkprice;iv`ordQty)]-iv[`ordVal];0)];

				// FeeTier  
				a[`ft]:.engine.model.feetier.Get[()];

				// RiskTier
				a[`rt]:.engine.model.risktier.Get[()];

				a[`avail]-:sum[(vdlt;lsdlt)];

				.engine.model.account.Update a;
				.engine.model.inventory.Update iv;

				/ match:o where [];
				/ place:o where [];

				// TODO fix this functionality
				/ $[(if[((o[`okind]=0) or all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])] or
				/ 	all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])]) and in'[1;o[`execInst]]);[
				/ 			.engine.Purge[o where in[];0;"Order had execInst of postOnly"];
				/ 			.engine.logic.trade.Match[i;a;o];
				/ 		];[
				/ 			.engine.model.order.CreateOrder o;
				/ 			.engine.logic.orderbook.Level[select sum oqty by side, price from o]
				/ 		]];


				.engine.Emit[`account;t;a];
				.engine.Emit[`inventory;t;iv];
				.engine.Emit[`order;t;o];
		};

.engine.logic.order.AmendOrder:{[t;i;a;o]
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

				iv:.engine.model.inventory.Get[];
				iv[`ordQty]+:dlt;
				iv[`ordVal]:prd[f[`fqty`fprice]];
				iv[`ordLoss]:min[prd[i`mkprice;iv`ordQty]-iv[`ordVal];0];

				a[`mkrfee`tkrfee]:.engine.model.feetier.FeeTier[][`mkrfee`tkrfee];
				a[`imr`mmr]:.engine.model.risktier.Get[][`imr`mmr];
				a[`avail]:.engine.logic.account.DeriveAvailable[];

				.engine.model.account.Update a;
				.engine.model.inventory.Update iv;
				.engine.model.instrument.Update i;
				.engine.model.order.Create o;

				$[(o[`okind]=0);[
							.engine.logic.trade.Match[i;a;o];
						];[
							.engine.model.order.CreateOrder o;
					 		.engine.logic.orderbook.Level[]
						]];


				.engine.Emit[`account;t;a];
				.engine.Emit[`inventory;t;iv];
				.engine.Emit[`order;t;o];
		};

.engine.logic.order.CancelOrder:{[t;i;a;o]
				c:.engie.logic.order.GetOrder[`oId`cId;o`oId`cId];
				if[null[c];.engine.Purge[o;0;"Order not found"]];
				if[not[c[`state] in ()];.engine.Purge[o;0;"cancel order with terminal state"]];
				o:c^o;

				if[a[`state]=1;.engine.Purge[0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[0;"Account has been locked for liquidation"]];

				dlt:neg[c`oQty];
				iv:.engine.model.inventory.Get[];
				iv[`ordQty]+:dlt;
				iv[`ordVal]:prd[f[`fqty`fprice]];
				iv[`ordLoss]:min[prd[i`mkprice;iv`ordQty]-iv[`ordVal];0];

				a[`mkrfee`tkrfee]:.engine.model.feetier.FeeTier[][`mkrfee`tkrfee];
				a[`imr`mmr]:.engine.model.risktier.Get[][`imr`mmr];
				a[`avail]:.engine.logic.account.DeriveAvailable[];

				.engine.model.account.UpdateAccount a;
				.engine.model.inventory.UpdateInventory iv;
				.engine.model.instrument.UpdateInstrument i;
				.engine.model.order.AddOrder o;

				// add depth, add 
				.engine.logic.orderbook.Level[]

				.engine.Emit[`account;t;a];
				.engine.Emit[`inventory;t;iv];
				.engine.Emit[`order;t;o];
		};


.engine.logic.order.CancelAllOrders:{[t;i;a;o]
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

				.engine.Emit[`account;t;a];
				.engine.Emit[`inventory;t;iv];
				.engine.Emit[`order;t;o];
    };

