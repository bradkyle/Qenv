
// U
// Update 
.engine.logic.instrument.Funding:{[t;i;x]
				// i[`funding]
				fundingrate:last x;

				iv:.engine.model.inventory.GetInventory[enlist(<;`amt;0)];
				if[count[iv]>0;[
					// TODO make simpler
					fnd:0!select 
						amtInMarket: sum[amt],
						fundingCost:((min[(fundingrate;0)]*(amt*side)) + (max[(fundingrate;0)]*(amt*side)))
						by aId from enlist iv;  

					a:.engine.model.account.GetAccount[fnd`aId];
					a:.engine.logic.account.Remargin[i;a];

					.engine.model.account.UpdateAccount a;
					.engine.model.inventory.UpdateInventory iv;
					.engine.Emit[`account;t;a];
					.engine.Emit[`inventory;t;iv];
				]];

				// Update instrument
				.engine.model.instrument.UpdateInstrument i;
				.engine.Emit[`funding;t;x];
			};

//   
.engine.logic.instrument.MarkPrice:{[t;i;x]
				markprice:last x;
				i[`mkprice]:markprice;

				iv:.engine.model.inventory.GetInventory[enlist(<;`amt;0)];
				if[count[iv]>0;[
					// TODO make simpler
					upl:.engine.logic.contract.UnrealizedPnl[
							i[`contractType];
							i[`mkprice];
							i[`faceValue];
							i[`sizeMultiplier]];

					upm:0!select 
						amtInMarket: sum[amt],
						upnl:upl[amt;side;avgPrice]
						by aId from enlist iv;  

					a:.engine.model.account.GetAccount[upm`aId];
					a:.engine.logic.account.Remargin[i;a];

					.engine.model.account.UpdateAccount a;
					.engine.model.inventory.UpdateInventory iv;
					.engine.Emit[`account;t;a];
					.engine.Emit[`inventory;t;iv];
				]];

				// 
				.engine.model.instrument.UpdateInstrument i;
				.engine.Emit[`mark;t;x];
	};

.engine.logic.instrument.Settlement:{[t;i;x]
				iv:.engine.model.inventory.GetInventory[enlist(<;`amt;0)];
				if[count[iv]>0;[
					a[`mrg]+:iv[`rpnl];
					iv[`rpnl]:0;

					.engine.model.account.UpdateAccount a;
					.engine.model.inventory.UpdateInventory iv;
					.engine.Emit[`account;t;a];
					.engine.Emit[`inventory;t;iv];
				]];

				.engine.model.instrument.UpdateInstrument i;
				.engine.Emit[`settlement;t;x];
	};


.engine.logic.instrument.PriceLimit:{[t;i;x]
				highest:last x[0];
				lowest:last x[1];
				i[`plmth]:highest;
				i[`plmtl]:lowest;

				o:.engine.model.order.GetOrder[];
				if[o;[
						// cancel orders, send respective updates
				]];

				.engine.model.instrument.UpdateInstrument i;
				.engine.Emit[`pricelimit;t;x];
	};
