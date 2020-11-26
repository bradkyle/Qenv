
// Update 
.engine.logic.instrument.Funding:{[i;x]
				iv:.engine.model.inventory.GetInventory[()];
				// TODO make simpler
				fnd:0!select 
				amtInMarket: sum[amt],
				fundingCost:((min[(x[`fundingRate];0)]*(amt*isignum)) + (max[(x[`fundingRate];0)]*(amt*isignum)))
				by accountId from iv;  

				a:.engine.model.account.GetAccount[fnd`accountId];
				a[`imr`mmr]:.engine.logic.account.DeriveRiskTier[][`imr`mmr];
				a[`mkrfee`tkrfee]:.engine.logic.account.DeriveFeeTier[][`mkrfee`tkrfee];
				a[`avail]:.engine.logic.account.DeriveAvailable[];

				.engine.model.account.UpdateAccount a;
				.engine.model.inventory.UpdateInventory iv;
				.engine.model.instrument.UpdateInstrument i;

				.engine.Emit[`account] a;
				.engine.Emit[`inventory] iv;
				.engine.Emit[`instrument] iv;
			};

//  
.engine.logic.instrument.MarkPrice:{[i;x]
				i[`mkprice]:x;
				iv:.engine.model.inventory.GetInventory[(<;`amt;0)];

				// TODO make simpler
				upl:.engine.logic.contract.UnrealizedPnl[
						i[`contractType];
						i[`mkprice];
						i[`faceValue];
						i[`sizeMultiplier]];

				(upl;iv) fby iv[`aId];

				a:.engine.model.account.GetAccount[distinct iv`aId];
				a[`imr`mmr]:.engine.logic.account.DeriveRiskTier[][`imr`mmr];
				a[`mkrfee`tkrfee]:.engine.logic.account.DeriveFeeTier[][`mkrfee`tkrfee];
				a[`avail]:.engine.logic.account.DeriveAvailable[];

				.engine.model.account.UpdateAccount a;
				.engine.model.inventory.UpdateInventory iv;
				.engine.model.instrument.UpdateInstrument i;

				.engine.Emit[`account] a;
				.engine.Emit[`inventory] iv;
				.engine.Emit[`instrument] iv;
	};

.engine.logic.instrument.Settlement:{[i;x]
				iv:.engine.model.inventory.GetInventory[()];
				a:.engine.model.account.GetAccount[fnd`accountId];
				a[`mrg]+:iv[`rpnl];
				iv[`rpnl]:0;
				a[`imr`mmr]:.engine.logic.account.DeriveRiskTier[][`imr`mmr];
				a[`mkrfee`tkrfee]:.engine.logic.account.DeriveFeeTier[][`mkrfee`tkrfee];
				a[`avail]:.engine.logic.account.DeriveAvailable[];

				.engine.model.account.UpdateAccount a;
				.engine.model.inventory.UpdateInventory iv;
				.engine.model.instrument.UpdateInstrument i;

				.engine.Emit[`account] a;
				.engine.Emit[`inventory] iv;
				.engine.Emit[`instrument] iv;
	};


.engine.logic.instrument.PriceLimit:{[i;x]
				i:.engine.model.intrument.GetInstrument[];
				i[`plmth]:x[`highest];
				i[`plmtl]:x[`lowest];
				.engine.model.instrument.UpdateInstrument i;

				.engine.Emit[`instrument] iv;
	};
