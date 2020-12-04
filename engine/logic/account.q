
// TODO add fee
// Fill account
.engine.logic.account.Fill :{[t;i;a;f] // TODO simple select
				iv:.engine.model.inventory.GetInventory[((=;`side;f`side);(=;`aId;a`aId))];

				/ ppc:.engine.logic.contract.PricePerContract[i[`cntTyp];f`price;i`faceValue];
				/ mpc:.engine.logic.contract.PricePerContract[i[`cntTyp];i`mkprice;i`faceValue];
				dlt:$[f`reduce;neg[f`qty];f`qty];

				// TODO make contract agnostic
				iv[`ordQty]-:f[`qty];
				iv[`ordVal]-:7h$prd[f[`qty`price]];
				iv[`ordLoss]:max[(7h$(prd[(iv`ordQty;i`mkprice)]-iv[`ordVal]);0)];
				iv[`amt]+:dlt;
				iv[`totalEntry]+:max[(dlt;0)];

				// Calc
				iv[`execCost]+: .engine.logic.contract.ExecCost[
						i[`cntTyp];
						f[`price];
						f[`qty];
						i[`smul]]; 

				/ / Calculates the average price of entry for 
				/ / the current postion, used in calculating 
				/ / realized and unrealized pnl.
				iv[`avgPrice]: .engine.logic.contract.AvgPrice[
						i[`cntTyp];
						iv[`isig];
						iv[`execCost];
						iv[`totalEntry];
						i[`smul]]; 

				/ / If the fill reduces the position, calculate the 
				/ / resultant pnl 
				if[f[`reduce];iv[`rpnl]+:.engine.logic.contract.RealizedPnl[
						i[`cntTyp];
						f[`qty];
						f[`price];
						iv[`isig];
						iv[`avgPrice];
						i[`faceValue];
						i[`smul]]];

				/ // If the inventory is reduced to zero reset the folowing
				/ // values in the inventory.
    		if[abs[iv[`amt]]=0;iv[`avgPrice`execCost`totalEntry]:0];

				/ / If the position is changed, calculate the resultant
				/ / unrealized pnl
				iv[`upnl]: .engine.logic.contract.UnrealizedPnl[ // TODO
						i[`cntTyp]; 
						i[`mkprice];
						i[`faceValue];
						i[`smul];
						iv[`amt];
						iv[`isig];
						iv[`avgPrice]];	

				// TODO 
				feetier:.engine.model.feetier.GetFeeTier[];
				risktier:.engine.model.risktier.GetRiskTier[];

				// 
				cost:feetier[$[f[`ismaker];`mkrfee;`tkrfee]] * f[`qty];

				// Derive the cost resulting from commisison
				iv[`rpnl]-:`long$(cost*f[`qty]);

				// Update datums
				.engine.model.account.UpdateAccount a;
				.engine.model.inventory.UpdateInventory iv;
				.engine.model.instrument.UpdateInstrument i;

				// Emit events
				.engine.Emit[`account;t;a];
				.engine.Emit[`inventory;t;iv];
				};


.engine.logic.account.Withdraw:{[i;a;w]
				if[a[`bal]<=0;.engine.Purge[w;0;"Order account has no balance"]];
				if[a[`available]<=0;.engine.Purge[w;0;"Order account has insufficient available balance"]];
				if[a[`state]=1;.engine.Purge[w;0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[w;0;"Account has been locked for liquidation"]];
				a[`wit]+:w`wit;
				feetier:.engine.model.feetier.GetFeeTier[];
				a[`mkrfee]:feetier[`mkrfee];
				a[`tkrfee]:feetier[`tkrfee];

				risktier:.engine.model.risktier.GetRiskTier[];
				a[`imr]:risktier[`imr];
				a[`mmr]:risktier[`mmr];

				// pos order margin
				a[`avail]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);

				.engine.model.account.UpdateAccount a;

				.engine.Emit[`account;t;a];
				};

.engine.logic.account.Deposit:{[i;a;d]
				if[a[`state]=1;.engine.Purge[d;0;"Account has been disabled"]];
				a[`dep]+:d`dep;
				feetier:.engine.model.feetier.GetFeeTier[];
				a[`mkrfee]:feetier[`mkrfee];
				a[`tkrfee]:feetier[`tkrfee];

				risktier:.engine.model.risktier.GetRiskTier[];
				a[`imr]:risktier[`imr];
				a[`mmr]:risktier[`mmr];

				// pos order margin
				a[`avail]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);

				.engine.model.account.UpdateAccount a;

				.engine.Emit[`account;t;a];
				};

.engine.logic.account.Leverage:{[i;a;l]
				if[a[`bal]<=0;.engine.Purge[l;0;"Order account has no balance"]];
				if[a[`available]<=0;.engine.Purge[l;0;"Order account has insufficient available balance"]];
				if[a[`state]=1;.engine.Purge[l;0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[l;0;"Account has been locked for liquidation"]];
				a[`leverage]:l`leverage;
				feetier:.engine.model.feetier.GetFeeTier[];
				a[`mkrfee]:feetier[`mkrfee];
				a[`tkrfee]:feetier[`tkrfee];

				risktier:.engine.model.risktier.GetRiskTier[];
				a[`imr]:risktier[`imr];
				a[`mmr]:risktier[`mmr];

				// pos order margin
				a[`avail]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);

				.engine.model.account.UpdateAccount a;

				.engine.Emit[`account;t;a];
				};











