
// Update 
// TODO by account Id
.engine.logic.instrument.Funding:{
			// Update and emit inventory
			ivn:?[`.engine.model.inventory.Inventory;enlist(>;`amt;0);0b;
				`aId`side`time`amt`avgPrice`upnl`rpnl!(
				`aId;`side;x`time;`amt;`avgPrice;`upnl;
				(-;`rpnl;(*;(sum;x`fundingrate);`amt))	
			)];
			.engine.model.inventory.Update ivn;
			.engine.E .event.Inventory[ivn]; 

			// Update and emit accounts
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

			// Emit funding event
			.engine.E .event.Funding[x]; 
		};

// Apply mark price update 
// TODO update instrument		
.engine.logic.instrument.Mark:{
			// Update and emit inventory
			ivn:?[`.engine.model.inventory.Inventory;enlist(>;`amt;0);0b;
				`aId`side`time`amt`avgPrice`rpnl`upnl!(
				`aId;`side;`time;`amt;`avgPrice;`rpnl;
				(-;`upnl;0)	
			)];
			.engine.model.inventory.Update ivn;
			.engine.E .event.Inventory[ivn]; 
			
			// Update and emit accounts
			acc:?[ivn;();0b;`aId`time`froz`bal`avail!(
				`aId;`time;`aId.froz;`aId.bal;
				(`.engine.logic.account.GetAvailable;
					`aId.bal;
					(+;`aId.lng.mm;`aId.srt.mm);
					(+;`aId.lng.upnl;`aId.srt.upnl);
					(+;`aId.lng.ordQty;`aId.srt.ordQty);
					(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];
			.engine.model.account.Update acc;
			.engine.E .event.Account[acc]; 

			// Emit mark event 
			.engine.E .event.Mark[x]; 
	};

// TODO update instrument		
.engine.logic.instrument.Settlement:{
			// Update and emit inventory
			ivn:?[`.engine.model.inventory.Inventory;enlist(>;`amt;0);0b;
				`aId`side`time`amt`avgPrice`rpnl`upnl!(
				`aId;`side;`time;`amt;`avgPrice;`rpnl;
				(-;`upnl;0)	
			)];
			.engine.model.inventory.Update ivn;
			.engine.E .event.Inventory[ivn]; 
			
			// TODO by account Id
			// Update and emit account
			acc:?[ivn;();0b;`aId`time`froz`bal`avail!(
				`aId;`time;`aId.froz;`aId.bal;
				(`.engine.logic.account.GetAvailable;
					`aId.bal;
					(+;`aId.lng.mm;`aId.srt.mm);
					(+;`aId.lng.upnl;`aId.srt.upnl);
					(+;`aId.lng.ordQty;`aId.srt.ordQty);
					(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];
			.engine.model.account.Update acc;
			.engine.E .event.Account[acc]; 

			// Emit Settlement Event 
			.engine.E .event.Settlement[x]; 
	};


.engine.logic.instrument.PriceLimit:{
		o:?[`.engine.model.order.Order;(();());0b;()];

		.engine.model.instrument.Update i;
		if[count[o]>0;.engine.logic.order.CancelOrder[o]];

		.engine.E .event.PriceLimit[x]; 
	};










