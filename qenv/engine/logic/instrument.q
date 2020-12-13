
// Update 
.engine.logic.instrument.Funding:{

			ins:flip ![x;();0b;`kind`wit`bal`avail!(
				`fundingrate;	
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

			// TODO select from  inventory where open 
			ivn:.engine.model.inventory.Get[enlist(>;`amt;0)];
			ivn:flip ![ivn;();0b;`aId`side`amt!(
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

			acc:flip ![ivn;();0b;`kind`dep`bal`avail!(
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
			i:flip ![x;();0b;`kind`wit`bal`avail!(
				`fundingrate;	
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

			// TODO check if can uj
			ivn:.engine.model.inventory.Get[enlist(>;`amt;0)];
			ivn:flip ![ivn;();0b;`aId`side`amt!(
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

			acc:flip ![x;();0b;`kind`dep`bal`avail!(
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
			i:flip ![x;();0b;`kind`wit`bal`avail!(
				`fundingrate;	
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

			ivn:.engine.model.inventory.Get[enlist(>;`amt;0)];
			ivn:flip ![ivn;();0b;`aId`side`amt!(
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

			acc:flip ![x;();0b;`kind`dep`bal`avail!(
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
		i:flip ![x;();0b;`kind`wit`bal`avail!(
				`fundingrate;	
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

		o:flip ![?[]];	

		.engine.model.instrument.Update i;
		if[count[o]>0;.engine.logic.order.CancelOrder[o]];

		.engine.Emit .event.PriceLimit[x]; 
	};










