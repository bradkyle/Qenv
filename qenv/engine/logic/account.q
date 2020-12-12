
.engine.logic.account.GetFeetier:{[avol]
   ft:select[1;<vol] from .engine.model.feetier.Feetier where (vol>a) or ((i=0) and (vol>a));
   `.engine.model.feetier.Feetier$((0!ft)`ftId)
   };

.engine.logic.account.GetRisktier:{[ivnamt;ivlev]
   rt:select[1;<amt] from .engine.model.risktier.Risktier where (amt>a) or ((i=0) and (amt>a));
   `.engine.model.risktier.Risktier$((0!rt)`rtId)
   };

.engine.logic.account.GetAvailable:{[bal;mm;upnl;oqty;oloss]
      bal-(mm+upnl)+(oqty-oloss)
    };

.engine.logic.account.Liquidate:{[t;i;a]
		a[`status]:1;
		lq:();
		.engine.model.liquidation.AddLiquidation[];
	};

.engine.logic.account.Remargin :{[i;a]
	  
			// TODO 
			feetier:.engine.model.feetier.Get[];
			risktier:.engine.model.risktier.Get[];

			a[`feetier]:feetier;
			a[`riktier]:risktier;

			a[`avail]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);
			a
	  };

// TODO add fee
// Fill account
.engine.logic.account.Fill :{[t;i;a;f] // TODO simple select
				iv:.engine.model.inventory.Get[((=;`side;f`side);(=;`aId;a`aId))];

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


				a:.engine.logic.account.Remargin[i;a];

				// 
				cost:feetier[$[f[`ismaker];`mkrfee;`tkrfee]] * f[`qty];

				// Derive the cost resulting from commisison
				iv[`rpnl]-:`long$(cost*f[`qty]);

				// Update datums
				.engine.model.account.Update a;
				.engine.model.inventory.Update iv;
				.engine.model.instrument.Update i;

				// Emit events
				.engine.Emit[`account;t;a];
				.engine.Emit[`inventory;t;iv];
				};


.engine.logic.account.Withdraw:{[t;i;a;w]
				if[a[`bal]<=0;.engine.Purge[w;0;"Order account has no balance"]];
				if[a[`available]<=0;.engine.Purge[w;0;"Order account has insufficient available balance"]];
				if[a[`state]=1;.engine.Purge[w;0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[w;0;"Account has been locked for liquidation"]];
				a[`wit]+:w`wit;
				a:.engine.logic.account.Remargin[i;a];

				.engine.model.account.Update a;
				.engine.Emit[`account;t;a];
				};

.engine.logic.account.Deposit:{[t;i;a;d]
				if[a[`state]=1;.engine.Purge[d;0;"Account has been disabled"]];
				a[`dep]+:d`dep;
				feetier:.engine.model.feetier.GetFeeTier[];
				a:.engine.logic.account.Remargin[i;a];

				.engine.model.account.Update a;
				.engine.Emit[`account;t;a];
				};

.engine.logic.account.Leverage:{[t;i;a;l]
				if[a[`bal]<=0;.engine.Purge[l;0;"Order account has no balance"]];
				if[a[`available]<=0;.engine.Purge[l;0;"Order account has insufficient available balance"]];
				if[a[`state]=1;.engine.Purge[l;0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[l;0;"Account has been locked for liquidation"]];
				a[`leverage]:l`leverage;
				a:.engine.logic.account.Remargin[i;a];

				.engine.model.account.Update a;
				.engine.Emit[`account;t;a];
				};











