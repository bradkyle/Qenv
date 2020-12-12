
// TODO move to fill file
// TODO add fee
// Fill account
.engine.logic.inventory.Fill:{ // TODO simple select

				show x;
				.bam.x:x;

				iv:?[?[x;();0b;
						(
							();
							();
							()
						)];();0b;
					(
					();
					(`.engine.logic.contract.UnrealizedPnl;`cntTyp;`mkprice;`faceValue;`smul;`amt;`side;`avgPrice);
					(`.engine.logic.contract.RealizedPnl;`iId.cntTyp;`qty;`price;`side;`ivId.avgPrice;`iId.faceValue;`iId.smul)
					)];

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
							iId.smul]]),
					avgPrice:.engine.logic.contract.AvgPrice[
							iId.cntTyp,
							side,
							ivId.execCost, // TODO defer
							ivId.totalEntry, // TODO defer
							iId.smul],
					execCost:ivId.execCost+.engine.contract.ExecCost[
						.iId.cntTyp,
						price,
						qty,
						.iId.smul],


					from x;

				// // If the inventory is reduced to zero reset the folowing
				// // values in the inventory.
    		/if[abs[iv[`amt]]=0;iv[`avgPrice`execCost`totalEntry]:0];

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

