

.engine.logic.account.DeriveAvailable							:{[a]
    / a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);
				  
    };

// Fill account
.engine.logic.account.Fill :{[i;a;f]
				iv:.engine.model.inventory.GetInventory[];
				iv[`ordQty]-:f[`fqty];
				iv[`ordVal]:prd[f[`fqty`fprice]];
				iv[`ordLoss]:min[prd[i`mkprice;iv`ordQty]-iv[`ordVal];0];
				iv[`posQty]+:f[`fdlt];
				iv[totalEntry]+:max[f`dlt;0];

				// Calc
				iv[`execCost]+: .engine.logic.contract.ExecCost[
						i[`cntTyp];
						f[`fprice];
						f[`fqty]]; 

				/ / Calculates the average price of entry for 
				/ / the current postion, used in calculating 
				/ / realized and unrealized pnl.
				iv[`avgPrice]: .engine.logic.contract.AvgPrice[
						i[`cntTyp];
						iv[`isig];
						iv[`execCost];
						iv[`totalEntry]];

				/ / If the fill reduces the position, calculate the 
				/ / resultant pnl 
				if[f[`fdlt]>0;iv[`rpnl]+:.engine.logic.contract.RealizedPnl[
						i[`cntTyp];
						f[`fqty];
						f[`fprice];
						iv[`isig];
						iv[`avgPrice];
						i[`faceValue]]];

				/ // If the inventory is reduced to zero reset the folowing
				/ // values in the inventory.
    		if[abs[iv[`posQty]]=0;iv[`avgPrice`execCost`totalEntry]:0];

				/ / If the position is changed, calculate the resultant
				/ / unrealized pnl
				iv[`upnl]:.engine.logic.contract.UnrealizedPnl[ // TODO
						i[`cntTyp]; 
						iv[`posQty];
						iv[`isig];
						iv[`avgPrice];
						i[`markPrice];
						i[`faceValue]];

				// 
				iv[`posVal]:0;
				a[`mkrfee`tkrfee]:.engine.model.feetier.FeeTier[][`mkrfee`tkrfee];
				a[`imr`mmr]:.engine.model.risktier.RiskTier[][`imr`mmr];
				a[`avail]:.engine.logic.account.DeriveAvailable[];

				.engine.model.account.UpdateAccount a;
				.engine.model.inventory.UpdateInventory iv;
				.engine.model.instrument.UpdateInstrument i;

				.engine.Emit[`account] a;
				.engine.Emit[`inventory] iv;
				.engine.Emit[`instrument] i;
				};


.engine.logic.account.Withdraw:{[i;a;w]
				a:.engine.model.account.GetAccount[];
				if[a[`bal]<=0;[0;"Order account has no balance"]];
				if[a[`available]<=0;[0;"Order account has insufficient available balance"]];
				if[a[`state]=1;[0;"Account has been disabled"]];
				if[a[`state]=2;[0;"Account has been locked for liquidation"]];
				a[`widdraw]+:withdrawn;
				a[`mkrfee`tkrfee]:.engine.model.feetier.FeeTier[][`mkrfee`tkrfee];
				a[`imr`mmr]:.engine.model.risktier.RiskTier[][`imr`mmr];

				// pos order margin
				a[`avail]:.engine.logic.account.DeriveAvailable[];

				.engine.model.account.UpdateAccount a;

				.engine.Emit[`account] a;
				};

.engine.logic.account.Deposit:{[i;a;d]
				a:.engine.model.account.GetAccount[];
				if[a[`state]=1;[0;"Account has been disabled"]];
				a[`deposited]+:deposited;
				a[`imr`mmr]:.engine.model.risktier.RiskTier[][`imr`mmr];
				a[`mkrfee`tkrfee]:.engine.model.feetier.FeeTier[][`mkrfee`tkrfee];

				// pos order margin
				a[`avail]:.engine.logic.account.DeriveAvailable[];

				.engine.model.account.UpdateAccount a;

				.engine.Emit[`account] a;
				};

.engine.logic.account.Leverage:{[i;a;l]
				a:.engine.model.account.GetAccount[];
				if[a[`bal]<=0;[0;"Order account has no balance"]];
				if[a[`available]<=0;[0;"Order account has insufficient available balance"]];
				if[a[`state]=1;[0;"Account has been disabled"]];
				if[a[`state]=2;[0;"Account has been locked for liquidation"]];
				a[`leverage]:leverage;
				a[`mkrfee`tkrfee]:.engine.model.feetier.FeeTier[][`mkrfee`tkrfee];
				a[`imr`mmr]:.engine.model.risktier.RiskTier[][`imr`mmr];

				// pos order margin
				a[`avail]:.engine.logic.account.DeriveAvailable[];

				.engine.model.account.UpdateAccount a;

				.engine.Emit[`account] a;
				};











