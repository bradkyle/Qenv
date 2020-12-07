
// TODO add fee
// Fill account
.engine.logic.account.Fill :{ // TODO simple select
				iv:.engine.model.inventory.Get[((=;`side;f`side);(=;`aId;f`aId))];

				/ ppc:.engine.logic.contract.PricePerContract[i[`cntTyp];f`price;i`faceValue];
				/ mpc:.engine.logic.contract.PricePerContract[i[`cntTyp];i`mkprice;i`faceValue];
				dlt:$[f`reduce;neg[f`qty];f`qty];
				iv[`amt]+:dlt;
				iv[`totalEntry]+:max[(dlt;0)];

				// TODO make contract agnostic
				iv[`ordQty]-:f[`qty];
				iv[`ordVal]-:7h$prd[f[`qty`price]];
				iv[`ordLoss]:max[(7h$(prd[(iv`ordQty;i`mkprice)]-iv[`ordVal]);0)];

				// Calculate fees
				fee:first ?[f;();();$[f[`ismaker];`aId.ft.mkrfee;`aId.ft.tkrfee]];
				cost:fee * f[`qty];

				// Derive the cost resulting from commisison
				iv[`rpnl]-:`long$(cost*f[`qty]);

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

				// Remargin account
				a:.engine.logic.account.Remargin[i;a];

				// Update datums
				.engine.model.account.Update a;
				.engine.model.inventory.Update iv;

				// Emit events
				.engine.EmitA[`account;t;a`aId;a];
				.engine.EmitA[`inventory;t;iv`aId;iv];
				};

