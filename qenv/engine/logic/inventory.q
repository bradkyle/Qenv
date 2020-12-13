
// TODO move to fill file
// TODO add fee
// Fill account
// TODO add posval
// TODO     		/if[abs[iv[`amt]]=0;iv[`avgPrice`execCost`totalEntry]:0];
.engine.logic.inventory.Fill:{ // TODO simple select
				x:flip x;
				iv:flip ![![x;();0b;`kind`avgPrice`execCost`ordLoss`ordVal`ordQty`amt`totEnt!(
						(enlist`inventory);
						((';`.engine.logic.contract.AvgPrice);`iId.cntTyp;`side;`ivId.execCost;`ivId.totEnt;`iId.smul); // TODO dependent
						((';`.engine.logic.contract.ExecCost);`iId.cntTyp;`price;`qty;`iId.smul);
						(-;`ivId.ordLoss;(`.engine.logic.contract.Loss;`iId.mkprice;`qty;((+/);`qty;`price)));
						(-;`ivId.ordVal;((*/);`qty;`price)); // TODO contract dependent
						(-;`ivId.ordQty;`qty);
						(+;`ivId.amt;`qty);
						((+/);`ivId.totEnt;`qty)
				)];
				();0b;`upnl`rpnl!(
				((';`.engine.logic.contract.UnrealizedPnl);`iId.cntTyp;`iId.mkprice;`iId.faceValue;`iId.smul;`ivId.amt;`side;`ivId.avgPrice);
				((';`.engine.logic.contract.RealizedPnl);`iId.cntTyp;`qty;`price;`side;`ivId.avgPrice;`iId.faceValue;`iId.smul))];
				.bam.iv:iv;
				.engine.model.inventory.Update flip scl[`aId`side`ordQty`ordVal`ordLoss`amt`avgPrice`execCost`totEnt`upnl`rpnl;iv];

				// Account, Fill
				.engine.Emit .event.Inventory[(15h$iv`time;flip iv`aId`side;7h$iv`aId)];
				.engine.Emit .event.Fill[(15h$x`time;flip x`aId`side;7h$x`aId)];
				};

