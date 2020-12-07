
// Events will be passed with aId
.engine.logic.order.NewOrder:{
				// Instrument validations
				ordCols:`clOid`aId`price`lprice`sprice`trig`tif`okind`oskind`state`oqty`dqty`lqty`einst`reduce;
				o:flip ordCols!flip x`datum;
				t:first x`time;


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

.engine.logic.order.AmendOrder:{
				c:.engie.logic.order.GetOrder[`oId`cId;o`oId`cId];
				if[null[c];.engine.Purge[o;0;"Order not found"]];
				if[not[c[`state] in ()];.engine.Purge[o;0;"update order with terminal state"]];
				o:c^o;

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

.engine.logic.order.CancelOrder:{

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


.engine.logic.order.CancelAllOrders:{

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

