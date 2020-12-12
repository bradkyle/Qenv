
// TODO move to fill file
// TODO add fee
// Fill account
// TODO add posval
.engine.logic.inventory.Fill:{ // TODO simple select

				iv:?[?[x;();0b;(
							(`.engine.logic.contract.UnrealizedPnl;`cntTyp;`mkprice;`faceValue;`smul;`amt;`side;`avgPrice);
							(`.engine.logic.contract.RealizedPnl;`iId.cntTyp;`qty;`price;`side;`ivId.avgPrice;`iId.faceValue;`iId.smul)
					)];();0b;(
					(`.engine.logic.contract.AvgPrice);
					(`.engine.logic.contract.ExecCost);
					(-;`ivId.ordLoss;(`.engine.logic.contract.Loss;));
					(-;`ivId.ordVal;(`.engine.logic.contract.Value;));
					(-;`ivId.ordQty;qty);
					(+;`amt;`dlt);
					(sum;`ivId.totalEntry;(max;`dlt;0))
					)];

				.engine.model.inventory.Update iv;
				.engine.EmitA[`inventory;];

    		/if[abs[iv[`amt]]=0;iv[`avgPrice`execCost`totalEntry]:0];

				};

