
// U
.engine.logic.instrument.liquidate:{[t;i;a]
		a[`status]:1;
		lq:();
		.engine.model.liquidation.AddLiquidation[];
		
	};

// Update 
.engine.logic.instrument.Funding:{[t;i;x]
				// i[`funding]

				iv:.engine.model.inventory.GetInventory[()];
				if[iv;[
					// TODO make simpler
					fnd:0!select 
						amtInMarket: sum[amt],
						fundingCost:((min[(x[`fundingRate];0)]*(amt*isignum)) + (max[(x[`fundingRate];0)]*(amt*isignum)))
						by aId from iv;  

					a:.engine.model.account.GetAccount[fnd`accountId];
					a[`imr`mmr]:.engine.logic.account.DeriveRiskTier[][`imr`mmr];
					a[`mkrfee`tkrfee]:.engine.logic.account.DeriveFeeTier[][`mkrfee`tkrfee];
					a[`avail]:.engine.logic.account.DeriveAvailable[];

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
				i[`mkprice]: last x`datum;

				iv:.engine.model.inventory.GetInventory[enlist(<;`amt;0)];
				if[iv;[
					// TODO make simpler
					upl:.engine.logic.contract.UnrealizedPnl[
							i[`contractType];
							i[`mkprice];
							i[`faceValue];
							i[`sizeMultiplier]];

					a:.engine.model.account.GetAccount[distinct iv`aId];
					a[`imr`mmr]:.engine.logic.account.DeriveRiskTier[][`imr`mmr];
					a[`mkrfee`tkrfee]:.engine.logic.account.DeriveFeeTier[][`mkrfee`tkrfee];
					a[`avail]:.engine.logic.account.DeriveAvailable[];

					a:.engine.logic.instrument.liquidate[i;a where[a[`avail]<i[`]]];

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
				// i[`funding]

				iv:.engine.model.inventory.GetInventory[enlist(<;`amt;0)];
				if[iv;[
					a[`mrg]+:iv[`rpnl];
					iv[`rpnl]:0;
					a[`imr`mmr]:.engine.logic.account.DeriveRiskTier[][`imr`mmr];
					a[`mkrfee`tkrfee]:.engine.logic.account.DeriveFeeTier[][`mkrfee`tkrfee];
					a[`avail]:.engine.logic.account.DeriveAvailable[];

					.engine.model.account.UpdateAccount a;
					.engine.model.inventory.UpdateInventory iv;
					.engine.Emit[`account;t;a];
					.engine.Emit[`inventory;t;iv];
				]];

				.engine.model.instrument.UpdateInstrument i;
				.engine.Emit[`settlement;t;x];
	};


.engine.logic.instrument.PriceLimit:{[t;i;x]
				i[`plmth]:x[`highest];
				i[`plmtl]:x[`lowest];

				o:.engine.model.order.GetOrder[];
				if[o;[
						// cancel orders, send respective updates
				]];

				.engine.model.instrument.UpdateInstrument i;
				.engine.Emit[`pricelimit;t;x];
	};
