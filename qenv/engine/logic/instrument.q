
// Update 
.engine.logic.instrument.Funding:{
			ivn:?[`.engine.model.inventory.Inventory;();0b;
				`aId`side`time`rpnl!(
				`aId;`side;`time;
				(-;`rpnl;0)	
			)];
			
			ivn[`aId]:`.engine.model.account.Account$ivn[`aId];
			acc:?[x;();0b;`aId`time`froz`bal`avail!(
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
			.engine.E .event.Funding[x]; 
		};

// Apply mark price update 
.engine.logic.instrument.MarkPrice:{
			ivn:?[`.enigne.model.inventory.Inventory;();0b;
		  `aId`side`rpnl`posVal`time!(
				($;`.engine.model.account.Account;`aId);`side;
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

			acc:?[ivn;();0b;`kind`dep`bal`avail!(
				(+;`aId.dep;`dep);	
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

			.engine.model.account.Update acc;
			.engine.model.inventory.Update ivn;
			.engine.model.instrument.Update ins

			// Update instrument
			.engine.E .event.Account[acc]; 
			.engine.E .event.Inventory[ivn]; 
			.engine.E .event.Mark[x]; 
	};

.engine.logic.instrument.Settlement:{
			ivn:?[`.enigne.model.inventory.Inventory;();0b;
		  `aId`side`rpnl`posVal`time!(
				($;`.engine.model.account.Account;`aId);`side;
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

			acc:?[ivn;();0b;`kind`dep`bal`avail!(
				(+;`aId.dep;`dep);	
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

			.engine.model.account.Update acc;
			.engine.model.inventory.Update ivn;
			.engine.model.instrument.Update ins

			// Update instrument
			.engine.E .event.Account[acc]; 
			.engine.E .event.Inventory[ivn]; 
			.engine.E .event.Settlement[x]; 
	};


.engine.logic.instrument.PriceLimit:{
		o:?[];

		.engine.model.instrument.Update i;
		if[count[o]>0;.engine.logic.order.CancelOrder[o]];

		.engine.E .event.PriceLimit[x]; 
	};










