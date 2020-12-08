
// Update 
.engine.logic.instrument.Funding:{
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

// Apply mark price update 
.engine.logic.instrument.MarkPrice:{
				markprice:last x;
				![];

				.engine.logic.inventory.ApplyMarkPrice[];
				.engine.logic.account.ApplyRemargin[];

				.engine.Emit[`mark;last t;last x];
				.engine.Emit[`inventory;last t;last x];
				.engine.Emit[`mark;last t;last x];
	};

.engine.logic.instrument.Settlement:{
				iv:.engine.model.inventory.Get[enlist(<;`amt;0)];
				if[count[iv]>0;[
					a:.engine.model.account.Get[iv`aId];
					a[`bal]+:iv[`rpnl];
					iv[`rpnl]:0;

					.engine.model.account.Update a;
					.engine.model.inventory.Update iv;
					.engine.Emit[`account;t;a];
					.engine.Emit[`inventory;t;iv];
				]];

				.engine.model.instrument.Update i;
				.engine.Emit[`settlement;t;x];
	};


.engine.logic.instrument.PriceLimit:{
				highest:last x[0];
				lowest:last x[1];
				i[`plmth]:highest;
				i[`plmtl]:lowest;
				.engine.model.instrument.Update i;
				.engine.Emit[`pricelimit;t;x];

				o:.engine.model.order.Get[(|;
					(=;`side;(&;1;((';~:;<);`price;i`highest)));
					(=;`side;(&;-1;((';~:;>);`price;i`lowest)))
					)];

				if[count[o]>0;.engine.logic.order.CancelOrder[o]];
	};










