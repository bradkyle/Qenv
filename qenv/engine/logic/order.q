
/ vdlt:prd[o[`oqty`price]]; // TODO contract specific 
/ lsdlt:min[(((dlt*i[`mkprice])-vdlt);0)];
// Events will be passed with aId
.engine.logic.order.New:{
				// Update inventory and emit events
			  ivn: 	?[x;();0b;`aId`side`time`amt`avgPrice`upnl`rpnl`ordLoss`ordVal`ordQty!(
				`aId;`side;`time;`ivId.amt;`ivId.avgPrice;`ivId.upnl;`ivId.rpnl;
					(+;`ivId.ordLoss;0);
					(+;`ivId.ordVal;0);
					(+;`ivId.ordQty;0)
					)];
				.engine.model.inventory.Update ivn;
				.engine.E .event.Inventory[ivn]; 

				// Update account and emit events
				acc:?[x;();0b;`aId`time`froz`bal`rt`ft`avail!(
				`aId;`time;`aId.froz;`aId.bal;
				(`.engine.logic.account.GetRisktier;(+;`aId.lng.amt;`aId.srt.amt);(+;`aId.lng.lev;`aId.srt.lev));
				(`.engine.logic.account.GetFeetier;`aId.vol);
				(`.engine.logic.account.GetAvailable;
					`aId.bal;
					(+;`aId.lng.mm;`aId.srt.mm);
					(+;`aId.lng.upnl;`aId.srt.upnl);
					(+;`aId.lng.ordQty;`aId.srt.ordQty);
					(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];
				.engine.model.account.Update acc;
				.engine.E .event.Account[acc]; 

				// New order should be matched
				.engine.logic.match.Match[x];
		};

.engine.logic.order.Amend:{
				/ x: .model.Order[![x;]]

				// Update inventory and emit events
			  ivn: 	?[x;();0b;`aId`side`time`amt`avgPrice`upnl`rpnl`ordLoss`ordVal`ordQty!(
				`aId;`side;`time;`ivId.amt;`ivId.avgPrice;`ivId.upnl;`ivId.rpnl;
					(+;`ivId.ordLoss;0);
					(+;`ivId.ordVal;0);
					(+;`ivId.ordQty;0)
					)];
				.engine.model.inventory.Update ivn;
				.engine.E .event.Inventory[ivn]; 

				// Update account and emit events
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

				// Amend order should be matched
				.engine.logic.match.Match[x];
		};

.engine.logic.order.Cancel:{

				// Update inventory and emit events
			  ivn: 	?[x;();0b;`aId`side`time`amt`avgPrice`upnl`rpnl`ordLoss`ordVal`ordQty!(
				`aId;`side;`time;`ivId.amt;`ivId.avgPrice;`ivId.upnl;`ivId.rpnl;
					(+;`ivId.ordLoss;0);
					(+;`ivId.ordVal;0);
					(+;`ivId.ordQty;0)
					)];
				.engine.model.inventory.Update ivn;
				.engine.E .event.Inventory[ivn]; 

				// Update account and emit events
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

				// Cancel order should delete order
				.engine.model.order.Delete[x];
				/ .engine.E .event.Order[];
		};

.engine.logic.order.CancelAll:{

				// Update inventory and emit events
			  ivn: 	?[x;();0b;`aId`side`time`amt`avgPrice`upnl`rpnl`ordLoss`ordVal`ordQty!(
				`aId;`side;`time;`ivId.amt;`ivId.avgPrice;`ivId.upnl;`ivId.rpnl;
					(+;`ivId.ordLoss;0);
					(+;`ivId.ordVal;0);
					(+;`ivId.ordQty;0)
					)];
				.engine.model.inventory.Update ivn;
				.engine.E .event.Inventory[ivn]; 

				// Update account and emit events
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

				// Cancel all orders should delete orders
				.engine.model.order.Delete[x];
				/ .engine.E .event.Order[];
    };

