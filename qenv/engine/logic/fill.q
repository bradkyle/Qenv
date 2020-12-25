
// TODO move to fill file
// TODO add fee
// Fill account
// TODO add posval
// TODO total ent to zero
// TODO     		/if[abs[iv[`amt]]=0;iv[`avgPrice`execCost`totalEntry]:0];
.engine.logic.fill.Fill:{ // TODO simple select
				.bam.ivx:x;
				iv:![.bam.ivx;();0b;`avgPrice`execCost`ordLoss`ordVal`ordQty`amt`totEnt!(
					((';(`.engine.logic.contract;::;enlist`AvgPriceDeriv));`iId.cntTyp;`side;`price;`qty;`ivId.totEnt;`iId.smul); 
					((';(`.engine.logic.contract;::;enlist`ExecCost));`iId.cntTyp;`price;`qty;`iId.smul); 
					(-;`ivId.ordLoss;((';(`.engine.logic.contract;::;enlist`Loss));`iId.cntTyp;`iId.mkprice;`qty;`price));
					(-;`ivId.ordVal;((';(`.engine.logic.contract;::;enlist`Value));`iId.cntTyp;`qty;`price)); // TODO contract dependent
					(-;`ivId.ordQty;`qty);
					(+;`ivId.amt;`qty);
					((+/);`ivId.totEnt;`qty))];
				.bam.iv1:iv;

				iv:?[iv;();0b;`aId`side`time`avgPrice`execCost`ordLoss`ordVal`ordQty`amt`totEnt`upnl`rpnl!(
					`aId;`side;`time;`avgPrice;`execCost;`ordLoss;`ordVal;`ordQty;`amt;`totEnt;
					((';(`.engine.logic.contract;`iId.cntTyp;enlist`UnrealizedPnl));`iId.cntTyp;`amt;`side;`avgPrice;`iId.mkprice;`iId.faceValue;`iId.smul);
					((';(`.engine.logic.contract;`iId.cntTyp;enlist`RealizedPnl));`iId.cntTyp;`qty;`price;`side;`avgPrice;`iId.faceValue;`iId.smul)
					)];

				.bam.iv:iv;
				.engine.model.inventory.Update flip iv; 
				.engine.E .event.Inventory[iv];
				.engine.E .event.Fill[x] 
				};

