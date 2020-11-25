
// Update 
.engine.logic.instrument.Funding:{
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
.engine.logic.instrument.MarkPrice:{
				iv:?[`inventory;enlist(<;`amt;0);enlist(`accountId)!enlist(`accountId);()];

				// TODO make simpler
				upl:.engine.logic.contract.UnrealizedPnl[
						i[`contractType];
						i[`markPrice];
						i[`faceValue];
						i[`sizeMultiplier]];

				f:0!select 
				amtInMarket: sum[amt],
				unrealizedPnl: upl'[amt;isignum;avgPrice] 
						from iv;  

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

.engine.logic.instrument.Settlement:{
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


.engine.logic.instrument.PriceLimit:{
				i:.engine.model.intrument.GetInstrument[];
				i[`plmth]:x[`highest];
				i[`plmtl]:x[`lowest];
				.engine.model.instrument.UpdateInstrument i;

				.engine.Emit[`instrument] iv;
	};
