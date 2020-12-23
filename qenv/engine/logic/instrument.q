
// Update 
.engine.logic.instrument.Funding:{
			// Update and emit inventory
			ivn:?[`.engine.model.inventory.Inventory;enlist(>;`amt;0);0b;
				`aId`side`time`amt`avgPrice`upnl`rpnl!(
				`aId;`side;last x`time;`amt;`avgPrice;`upnl;
				(-;`rpnl;(*;(sum;x`fundingrate);`amt))	
			)];
			.bam.ivn:ivn;

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
.engine.logic.instrument.Mark:{
			// Update and emit inventory
			ivn:?[`.engine.model.inventory.Inventory;enlist(>;`amt;0);0b;
				`aId`side`time`amt`avgPrice`rpnl`upnl!(
				`aId;`side;`time;`amt;`avgPrice;`rpnl;
				((';`.engine.logic.contract.UnrealizedPnl);
				`iId.cntTyp;`iId.mkprice;`iId.faceValue;`iId.smul;`amt;`side;`avgPrice)
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

			// Emit mark event 
			.engine.E .event.Mark[x]; 
	};

// Apply settlement
.engine.logic.instrument.Settlement:{
			// Update and emit inventory
			ivn:?[`.engine.model.inventory.Inventory;enlist(>;`amt;0);0b;
				`aId`side`time`amt`avgPrice`rpnl`upnl!(
				`aId;`side;`time;`amt;`avgPrice;`rpnl;
				(-;`upnl;0)	
			)];
			.engine.model.inventory.Update ivn;
			.engine.E .event.Inventory[ivn]; 
			
			// Update and emit account
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

			// Emit Settlement Event 
			.engine.E .event.Settlement[x]; 
	};

// Apply price limits
.engine.logic.instrument.PriceLimit:{

		// Update and emit instrument
		i:?[x;();0b;`iId`highest`lowest!(
			(7h$;`iId);
			`highest;
			`lowest)];
		.engine.model.instrument.Update i;

		// Get all orders passed price limits
		o:?[`.engine.model.order.Order;enlist(|;
			(&;(=;`side;1);(>;`price;last x`highest));
			(&;(=;`side;-1);(<;`price;last x`lowest))
		);0b;()];
		if[count[o]>0;.engine.logic.order.Cancel[o]];

		// Emit PriceLimit Event
		.engine.E .event.PriceLimit[x]; 
	};










