
// TODO move to fill file
// TODO add fee
// Fill account
.engine.logic.inventory.Fill:{ // TODO simple select

				show x;
				.bam.x:x;

				iv:?[?[x;();0b;
						(
							(`.engine.logic.contract.UnrealizedPnl;`cntTyp;`mkprice;`faceValue;`smul;`amt;`side;`avgPrice);
							(`.engine.logic.contract.RealizedPnl;`iId.cntTyp;`qty;`price;`side;`ivId.avgPrice;`iId.faceValue;`iId.smul)
						)];();0b;
					(
					(`.engine.logic.contract.AvgPrice);
					(`.engine.logic.contract.ExecCost);
					(`.engine.logic.contract.Loss);
					(`.engine.logic.contract.Value);
					(`ordLoss);
					(`ordQty);
					(`ordVal);
					(`amt);
					(sum;`ivId.totalEntry;(max;dlt;0))
					)];

				.engine.model.inventory.Update iv;
				.engine.EmitA[`inventory;];

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

    		/if[abs[iv[`amt]]=0;iv[`avgPrice`execCost`totalEntry]:0];

				///TODO posVal

				};

