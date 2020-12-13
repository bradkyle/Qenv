
/ vdlt:prd[o[`oqty`price]]; // TODO contract specific 
/ lsdlt:min[(((dlt*i[`mkprice])-vdlt);0)];
// Events will be passed with aId
.engine.logic.order.New:{
				.engine.logic.inventory.ApplyOrderDelta[o`oqty;o`price;];

				cnd:o[`okind]=0;
				/ cnd:[((o[`okind]=0) or all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])] or
				/ 		all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])]) and in'[1;o[`execInst]]);
						
				.engine.logic.trade.Match ?[];

				.engine.model.order.CreateOrder o; 

				.engine.EmitA[`inventory;t;iv];
				.engine.EmitA[`account;t;a];
				.engine.EmitA[`order;t;o];
		};

.engine.logic.order.Amend:{
				c:.engine.model.order.Get[];
				.engine.logic.inventory.ApplyOrderDelta[(-/)(c`oqty;o`oqty);o`price];

				cnd:o[`okind]=0;
				mkt:o where cnd;
				.engine.logic.trade.Match[mkt];

				lmt:o where not cnd;
				.engine.model.order.CreateOrder lmt;

				.engine.EmitA[`inventory;t;iv];
				.engine.EmitA[`account;t;a];
				.engine.EmitA[`order;t;o];
		};

.engine.logic.order.Cancel:{
				c:.engine.model.order.Get[enlist(|;();())];
				.engine.model.order.RemoveOrder c`oId;

				// add depth, add 
				.engine.logic.orderbook.Level[]

				.engine.logic.inventory.ApplyOrderDelta[neg[sum[c`oQty]];x`price];
				.engine.model.account.Remargin[];

				.engine.EmitA[`inventory;t;iv];
				.engine.EmitA[`account;t;a];
				.engine.EmitA[`order;t;o];
		};


.engine.logic.order.CancelAll:{
				c:.engine.model.order.Get[enlist(=;`aId;x`aId)];
				.engine.model.order.RemoveOrder c`oId;

				// add depth, add 
				.engine.logic.orderbook.Level[]

				.engine.logic.inventory.ApplyOrderDelta[neg[sum[c`oQty]];x`price];
				.engine.model.account.Remargin[];

				.engine.EmitA[`inventory;t;iv];
				.engine.EmitA[`account;t;a];
				.engine.EmitA[`order;t;o];
    };

