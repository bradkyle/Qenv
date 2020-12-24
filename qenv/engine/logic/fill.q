
// TODO move to fill file
// TODO add fee
// Fill account
// TODO add posval
// TODO     		/if[abs[iv[`amt]]=0;iv[`avgPrice`execCost`totalEntry]:0];
.engine.logic.fill.Fill:{ // TODO simple select
				.bam.ivx:x;
				iv:![x;();0b;`avgPrice`execCost`ordLoss`ordVal`ordQty`amt`totEnt!(
						(.engine.logic.contract;`iId.cntTyp;enlist`AvgPriceDeriv;`side;`price;`qty;`ivId.totEnt;`iId.smul); 
						(.engine.logic.contract;`iId.cntTyp;enlist`ExecCost;`price;`qty;`iId.smul); 
						(-;`ivId.ordLoss;(.engine.logic.contract;`iId.cntTyp;enlist`Loss;`iId.mkprice;`qty;`price));
						(-;`ivId.ordVal;((*/);`qty;`price)); // TODO contract dependent
						(-;`ivId.ordQty;`qty);
						(+;`ivId.amt;`qty);
						((+/);`ivId.totEnt;`qty))];
				.bam.iv1:iv;

				iv:?[iv;();0b;`aId`side`time`avgPrice`execCost`ordLoss`ordVal`ordQty`amt`totEnt`upnl`rpnl!(
					`aId;`side;`time;`avgPrice;`execCost;`ordLoss;`ordVal;`ordQty;`amt;`totEnt;
					(.engine.logic.contract;`iId.cntTyp;enlist`UnrealizedPnl;`amt;`side;`avgPrice;`iId.mkprice;`iId.faceValue;`iId.smul);
					(.engine.logic.contract;`iId.cntTyp;enlist`RealizedPnl;`qty;`price;`side;`avgPrice;`iId.faceValue;`iId.smul)
					)];

				.bam.iv:iv;
				.engine.model.inventory.Update flip iv; 
				.engine.E .event.Inventory[iv];
				.engine.E .event.Fill[x] 
				};

