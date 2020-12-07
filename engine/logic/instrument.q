
// U
// Update 
.engine.logic.instrument.Funding:{[t;i;x]
				// i[`funding]
				fundingrate:last x;

				iv:.engine.model.inventory.Get[enlist(<;`amt;0)];
				if[count[iv]>0;[
					// TODO make simpler
					fnd:0!select 
						amtInMarket: sum[amt],
						fundingCost:((min[(fundingrate;0)]*(amt*side)) + (max[(fundingrate;0)]*(amt*side)))
						by aId from enlist iv;  

					a:.engine.model.account.Get[fnd`aId];
					a:.engine.logic.account.Remargin[i;a];

					.engine.model.account.Update a;
					.engine.model.inventory.Update iv;
					.engine.Emit[`account;t;a];
					.engine.Emit[`inventory;t;iv];
				]];

				// Update instrument
				.engine.model.instrument.Update i;
				.engine.Emit[`funding;t;x];
			};

//   
.engine.logic.instrument.MarkPrice:{[t;i;x]
				markprice:last x;
				i[`mkprice]:markprice;

				iv:.engine.model.inventory.Get[enlist(<;`amt;0)];
				if[count[iv]>0;[
					// TODO make simpler
					upl:.engine.logic.contract.UnrealizedPnl[
							i[`cntTyp];
							i[`mkprice];
							i[`faceValue];
							i[`smul]];

					upm:0!select 
						amtInMarket: sum[amt],
						upnl:upl'[amt;side;avgPrice]
						by aId from enlist iv;  

					a:.engine.model.account.Get[upm`aId];
					a:.engine.logic.account.Remargin[i;a];

					.engine.model.account.Update a;
					.engine.model.inventory.Update iv;
					.engine.Emit[`account;t;a];
					.engine.Emit[`inventory;t;iv];
				]];

				// 
				.engine.model.instrument.Update i;
				.engine.Emit[`mark;last t;last x];
	};

.engine.logic.instrument.Settlement:{[t;i;x]
				iv:.engine.model.inventory.Get[enlist(<;`amt;0)];
				if[count[iv]>0;[
					a:.engine.model.account.Get[iv`aId];
					a[`mrg]+:iv[`rpnl];
					iv[`rpnl]:0;

					.engine.model.account.Update a;
					.engine.model.inventory.Update iv;
					.engine.Emit[`account;t;a];
					.engine.Emit[`inventory;t;iv];
				]];

				.engine.model.instrument.Update i;
				.engine.Emit[`settlement;t;x];
	};


.engine.logic.instrument.PriceLimit:{[t;i;x]
				highest:last x[0];
				lowest:last x[1];
				i[`plmth]:highest;
				i[`plmtl]:lowest;

				/ o:.engine.model.order.Get[()];
				/ if[count[o]>0;[
				/ 		// cancel orders, send respective updates
				/ ]];

				.engine.model.instrument.Update i;
				.engine.Emit[`pricelimit;t;x];
	};
