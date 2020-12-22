
/ vdlt:prd[o[`oqty`price]]; // TODO contract specific 
/ lsdlt:min[(((dlt*i[`mkprice])-vdlt);0)];
// Events will be passed with aId
.engine.logic.order.New:{
			  ivn: 	?[x;();0b;`aId`side`time`amt`avgPrice`upnl`rpnl`ordLoss`ordVal`ordQty!(
				`aId;`side;`time;`ivId.amt;`ivId.avgPrice;`ivId.upnl;`ivId.rpnl;
					(+;`ivId.ordLoss;0);
					(+;`ivId.ordVal;0);
					(+;`ivId.ordQty;0)
					)];
				.engine.model.inventory.Update ivn;
				.engine.E .event.Inventory[ivn]; 

				acc:?[x;();0b;`aId`time`froz`bal`avail!(
				`aId;`time;`aId.froz;`aId.bal;
				(`.engine.logic.account.GetAvailable;
					`aId.bal;
					(+;`aId.lng.mm;`aId.srt.mm);
					(+;`aId.lng.upnl;`aId.srt.upnl);
					(+;`aId.lng.ordQty;`aId.srt.ordQty);
					(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];
				.engine.model.account.Update acc;
				.engine.E .event.Account[acc]; 

				.engine.logic.match.Match[x];
		};

.engine.logic.order.Amend:{
				/ x: .model.Order[![x;]]
			  ivn: 	?[x;();0b;`aId`side`time`amt`avgPrice`upnl`rpnl`ordLoss`ordVal`ordQty!(
				`aId;`side;`time;`ivId.amt;`ivId.avgPrice;`ivId.upnl;`ivId.rpnl;
					(+;`ivId.ordLoss;0);
					(+;`ivId.ordVal;0);
					(+;`ivId.ordQty;0)
					)];
				.engine.model.inventory.Update ivn;
				.engine.E .event.Inventory[ivn]; 

				acc:?[x;();0b;`aId`time`froz`bal`avail!(
				`aId;`time;`aId.froz;`aId.bal;
				(`.engine.logic.account.GetAvailable;
					`aId.bal;
					(+;`aId.lng.mm;`aId.srt.mm);
					(+;`aId.lng.upnl;`aId.srt.upnl);
					(+;`aId.lng.ordQty;`aId.srt.ordQty);
					(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];
				.engine.model.account.Update acc;
				.engine.E .event.Account[acc]; 

				.engine.logic.match.Match[x];
		};

.engine.logic.order.Cancel:{
			  ivn: 	?[x;();0b;`aId`side`time`amt`avgPrice`upnl`rpnl`ordLoss`ordVal`ordQty!(
				`aId;`side;`time;`ivId.amt;`ivId.avgPrice;`ivId.upnl;`ivId.rpnl;
					(+;`ivId.ordLoss;0);
					(+;`ivId.ordVal;0);
					(+;`ivId.ordQty;0)
					)];
				.engine.model.inventory.Update ivn;
				.engine.E .event.Inventory[ivn]; 

				acc:?[x;();0b;`aId`time`froz`bal`avail!(
				`aId;`time;`aId.froz;`aId.bal;
				(`.engine.logic.account.GetAvailable;
					`aId.bal;
					(+;`aId.lng.mm;`aId.srt.mm);
					(+;`aId.lng.upnl;`aId.srt.upnl);
					(+;`aId.lng.ordQty;`aId.srt.ordQty);
					(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];
				.engine.model.account.Update acc;
				.engine.E .event.Account[acc]; 

		};

.engine.logic.order.CancelAll:{
				ivn: 	?[x;();0b;`aId`side`time`ordLoss`ordVal`ordQty!(
					`aId;`side;`time;
					(+;`ivId.ordLoss;0);
					(+;`ivId.ordVal;0);
					(+;`ivId.ordQty;0)
					)];

				// TODO rt
				ivn[`aId]:`.engine.model.account.Account$ivn[`aId];
			  acc:?[ivn;();0b;`aId`time`froz`bal`avail!(
				`aId;`time;`aId.froz;`aId.bal;
				(`.engine.logic.account.GetAvailable;
					`aId.bal;
					(+;`aId.lng.mm;`aId.srt.mm);
					(+;`aId.lng.upnl;`aId.srt.upnl);
					(+;`aId.lng.ordQty;`aId.srt.ordQty);
					(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;

				// TODO remove orders
				.engine.E .event.Account[acc]; 
				.engine.E .event.Inventory[ivn]; 
				.engine.E .event.Order[x]; 
    };

