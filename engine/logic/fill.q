
// TODO add fee
// Fill account
.engine.logic.account.Fill :{ // TODO simple select

				a:.engine.model.inventory.Get[enlist(=;`aId;x`aId)];
				iv:.engine.model.inventory.Get[((=;`side;x`side);(=;`aId;x`aId))];

				/ ppc:.engine.logic.contract.PricePerContract[i[`cntTyp];f`price;i`faceValue];
				/ mpc:.engine.logic.contract.PricePerContract[i[`cntTyp];i`mkprice;i`faceValue];
				dlt:$[x`reduce;neg[x`qty];x`qty];
				iv[`amt]+:dlt;
				iv[`totalEntry]+:max[(dlt;0)];

				// derive the order values 
				val:.engine.logic.contract.Value[x`qty;x`price];
				iv[`ordLoss]-:.engine.logic.contract.Loss[i`mkprice;x`qty;val];
				iv[`ordQty]-:x`qty;
				iv[`ordVal]-:val;

				// Derive the cost resulting from commisison
				fee:first ?[x;();();$[x[`ismaker];`aId.ft.mkrfee;`aId.ft.tkrfee]];
				cost:fee * x[`qty];
				iv[`rpnl]-:`long$(cost*x[`qty]);

				// Calc
				iv[`execCost]+: .engine.logic.contract.ExecCost[
						i[`cntTyp];
						x[`price];
						x[`qty];
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
				if[x[`reduce];iv[`rpnl]+:.engine.logic.contract.RealizedPnl[
						i[`cntTyp];
						x[`qty];
						x[`price];
						iv[`isig];
						iv[`avgPrice];
						i[`faceValue];
						i[`smul]]];

				/ // If the inventory is reduced to zero reset the folowing
				/ // values in the inventory.
    		if[abs[iv[`amt]]=0;iv[`avgPrice`execCost`totalEntry]:0];

				/ / If the position is changed, calculate the resultant
				/ / unrealized pnl
				iv[`upnl]: .engine.logic.contract.UnrealizedPnl[ 
						i[`cntTyp]; 
						i[`mkprice];
						i[`faceValue];
						i[`smul];
						iv[`amt];
						iv[`isig];
						iv[`avgPrice]];	

				//TODO posVal

				// Remargin account
				a:.engine.logic.account.Remargin[i;a];

				// Update datums
				.engine.model.account.Update a;
				.engine.model.inventory.Update iv;

				// Emit events
				.engine.EmitA[`account;t;a`aId;a];
				.engine.EmitA[`inventory;t;iv`aId;iv];
				};

