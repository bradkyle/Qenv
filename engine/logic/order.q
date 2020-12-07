
// Events will be passed with aId
.engine.logic.order.NewOrder:{
				dlt:o`oqty;
				vdlt:prd[o[`oqty`price]]; // TODO contract specific 
				lsdlt:min[(((dlt*i[`mkprice])-vdlt);0)];

				iv:.engine.model.inventory.Get[(();())];
				iv[`ordQty]+:dlt;
				iv[`ordVal]+:vdlt;
				iv[`ordLoss]:min[(prd[(i`mkprice;iv`ordQty)]-iv[`ordVal];0)];
				.engine.model.inventory.Update iv;
				a:.engine.model.account.Remargin[];

				cnd:o[`okind]=0;
				/ cnd:[((o[`okind]=0) or all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])] or
				/ 		all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])]) and in'[1;o[`execInst]]);
						
				mkt:o where cnd;
				.engine.logic.trade.Match[mkt];

				lmt:o where not cnd;
				.engine.model.order.CreateOrder lmt;

				.engine.EmitA[`inventory;t;iv];
				.engine.EmitA[`account;t;a];
				.engine.EmitA[`order;t;o];
		};

.engine.logic.order.AmendOrder:{
				dlt:(-/)(c`oqty;o`oqty);
				iv:.engine.model.inventory.Get[];
				iv[`ordQty]+:dlt;
				iv[`ordVal]:prd[f[`fqty`fprice]];
				iv[`ordLoss]:min[prd[i`mkprice;iv`ordQty]-iv[`ordVal];0];

				cnd:o[`okind]=0;
				mkt:o where cnd;
				.engine.logic.trade.Match[mkt];

				lmt:o where not cnd;
				.engine.model.order.CreateOrder lmt;

				.engine.EmitA[`inventory;t;iv];
				.engine.EmitA[`account;t;a];
				.engine.EmitA[`order;t;o];
		};

.engine.logic.order.CancelOrder:{
				dlt:neg[c`oQty];
				iv:.engine.model.inventory.Get[];
				iv[`ordQty]+:dlt;
				iv[`ordVal]:prd[f[`fqty`fprice]];
				iv[`ordLoss]:min[prd[i`mkprice;iv`ordQty]-iv[`ordVal];0];

				.engine.model.account.Remargin[];

				.engine.model.account.UpdateAccount a;
				.engine.model.inventory.UpdateInventory iv;
				.engine.model.instrument.UpdateInstrument i;
				.engine.model.order.AddOrder o;

				cnd:o[`okind]=0;
				mkt:o where cnd;
				.engine.logic.trade.Match[mkt];

				lmt:o where not cnd;
				.engine.model.order.CreateOrder lmt;

				// add depth, add 
				.engine.logic.orderbook.Level[]

				.engine.EmitA[`inventory;t;iv];
				.engine.EmitA[`account;t;a];
				.engine.EmitA[`order;t;o];
		};


.engine.logic.order.CancelAllOrders:{
				dlt:neg[sum[c`oQty]];
				iv:.engine.model.inventory.GetInventory[];
				iv[`ordQty]+:dlt;
				iv[`ordVal]:prd[f[`fqty`fprice]];
				iv[`ordLoss]:min[prd[i`mkprice;iv`ordQty]-iv[`ordVal];0];

				.engine.model.account.Remargin[];

				.engine.model.account.UpdateAccount a;
				.engine.model.inventory.UpdateInventory iv;
				.engine.model.instrument.UpdateInstrument i;
				.engine.model.order.RemoveOrder o;

				// add depth, add 
				.engine.logic.orderbook.Level[]

				.engine.EmitA[`inventory;t;iv];
				.engine.EmitA[`account;t;a];
				.engine.EmitA[`order;t;o];
    };

