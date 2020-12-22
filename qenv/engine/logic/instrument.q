
// Update 
// TODO by account Id
.engine.logic.instrument.Funding:{
			ivn:?[`.engine.model.inventory.Inventory;enlist(>;`amt;0);0b;
				`aId`side`time`amt`avgPrice`upnl`rpnl!(
				`aId;`side;x`time;`amt;`avgPrice;`upnl;
				(-;`rpnl;(*;(sum;x`fundingrate);`amt))	
			)];
			.engine.model.inventory.Update ivn;
			.engine.E .event.Inventory[ivn]; 
			acc:?[`.engine.model.account.Account;enlist(|;(>;`lng.amt;0);(>;`srt.amt;0));0b;`aId`time`froz`bal`avail!(
				`aId;`time;`froz;`bal;
				(`.engine.logic.account.GetAvailable;
					`bal;
					(+;`lng.mm;`srt.mm);
					(+;`lng.upnl;`srt.upnl);
					(+;`lng.ordQty;`srt.ordQty);
					(+;`lng.ordLoss;`srt.ordLoss)))];
			.engine.model.account.Update acc;
			.engine.E .event.Account[acc]; 
			.engine.E .event.Funding[x]; 
		};

// Apply mark price update 
// TODO update instrument		
.engine.logic.instrument.Mark:{
			ivn:?[`.engine.model.inventory.Inventory;enlist(>;`amt;0);0b;
				`aId`side`time`amt`avgPrice`rpnl`upnl!(
				`aId;`side;`time;`amt;`avgPrice;`rpnl;
				(-;`upnl;0)	
			)];
			
			// TODO by account Id
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
			/ .engine.model.instrument.Update ins

			// Update instrument
			.engine.E .event.Account[acc]; 
			.engine.E .event.Inventory[ivn]; 
			.engine.E .event.Mark[x]; 
	};

.engine.logic.instrument.Settlement:{
			// TODO update instrument		
			ivn:?[`.engine.model.inventory.Inventory;enlist(>;`amt;0);0b;
				`aId`side`time`amt`avgPrice`rpnl`upnl!(
				`aId;`side;`time;`amt;`avgPrice;`rpnl;
				(-;`upnl;0)	
			)];
			
			// TODO by account Id
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
			/ .engine.model.instrument.Update ins

			// Update instrument
			.engine.E .event.Account[acc]; 
			.engine.E .event.Inventory[ivn]; 
			.engine.E .event.Settlement[x]; 
	};


.engine.logic.instrument.PriceLimit:{
		o:?[`.engine.model.order.Order;(();());0b;()];

		.engine.model.instrument.Update i;
		if[count[o]>0;.engine.logic.order.CancelOrder[o]];

		.engine.E .event.PriceLimit[x]; 
	};










