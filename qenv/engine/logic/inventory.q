
.engine.logic.inventory.OrderDelta:{[]
	  
	  
	  };

.engine.logic.inventory.ApplyOrderDelta:{[]
		  
		};

// TODO move to fill file
// TODO add fee
// Fill account
.engine.logic.inventory.Fill:{ // TODO simple select

				show x;
				.bam.x:x;

			 show select 	
			 		amt:iv.amt+$[reduce;neg[qty];qty],
					totalEntry:iv.totalEntry+max[($[reduce;neg[qty];qty],0)],
					ordLoss:ordLoss - .engine.logic.contract.Loss[],
					ordQty:ivId.ordQty - qty,
					ordVal:ivId.ordVal - .engine.logic.contract.Value[qty;price],
					rpnl: ivId.rpnl + sum(
						?[ismaker; aId.ft.mkrfee; aId.ft.tkrfee]*x[`qty];
						$[not reduce;0;.engine.logic.contract.RealizedPnl[
							iId.cntTyp;
							qty;
							price;
							side;
							ivId.avgPrice;
							iId.faceValue;
							iId.smul]])
					from x;

				/// Derive the cost resulting from commisison
				/fee:first ?[x;();();$[x[`ismaker];`aId.ft.mkrfee;`aId.ft.tkrfee]];
				/cost:fee * x[`qty];
				/iv[`rpnl]-:`long$(cost*x[`qty]);

				/// Calc
				/iv[`execCost]+: .engine.logic.contract.ExecCost[
				/		i[`cntTyp];
				/		x[`price];
				/		x[`qty];
				/		i[`smul]]; 

				// / Calculates the average price of entry for 
				// / the current postion, used in calculating 
				// / realized and unrealized pnl.
				/iv[`avgPrice]: .engine.logic.contract.AvgPrice[
				/		i[`cntTyp];
				/		iv[`isig];
				/		iv[`execCost];
				/		iv[`totalEntry];
				/		i[`smul]]; 

				// / If the fill reduces the position, calculate the 
				// / resultant pnl 
				/if[x[`reduce];iv[`rpnl]+:.engine.logic.contract.RealizedPnl[
				/		i[`cntTyp];
				/		x[`qty];
				/		x[`price];
				/		iv[`isig];
				/		iv[`avgPrice];
				/		i[`faceValue];
				/		i[`smul]]];

				// // If the inventory is reduced to zero reset the folowing
				// // values in the inventory.
    		/if[abs[iv[`amt]]=0;iv[`avgPrice`execCost`totalEntry]:0];

				// / If the position is changed, calculate the resultant
				// / unrealized pnl
				/iv[`upnl]: .engine.logic.contract.UnrealizedPnl[ 
				/		i[`cntTyp]; 
				/		i[`mkprice];
				/		i[`faceValue];
				/		i[`smul];
				/		iv[`amt];
				/		iv[`isig];
				/		iv[`avgPrice]];	

				///TODO posVal

				/// Remargin account
				/a:.engine.logic.account.Remargin[i;a];

				/// Update datums
				/.engine.model.account.Update a;
				/.engine.model.inventory.Update iv;

				/// Emit events
				/.engine.EmitA[`account;t;a`aId;a];
				/.engine.EmitA[`inventory;t;iv`aId;iv];
				};

