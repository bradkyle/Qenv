
// Update 
.engine.logic.instrument.Funding:{
			ivn:?[ivn;();0b;`aId`side`amt!(
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
			.engine.Emit .event.Account[acc]; 
			.engine.Emit .event.Inventory[ivn]; 
			.engine.Emit .event.Funding[x]; 
		};

// Apply mark price update 
.engine.logic.instrument.MarkPrice:{
			ivn:?[ivn;();0b;`aId`side`amt!(
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
			.engine.Emit .event.Account[acc]; 
			.engine.Emit .event.Inventory[ivn]; 
			.engine.Emit .event.Mark[x]; 
	};

.engine.logic.instrument.Settlement:{
			ivn:?[ivn;();0b;`aId`side`amt!(
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
			.engine.Emit .event.Account[acc]; 
			.engine.Emit .event.Inventory[ivn]; 
			.engine.Emit .event.Settlement[x]; 
	};


.engine.logic.instrument.PriceLimit:{
	o:?[];

		.engine.model.instrument.Update i;
		if[count[o]>0;.engine.logic.order.CancelOrder[o]];

		.engine.Emit .event.PriceLimit[x]; 
	};










