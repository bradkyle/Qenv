
// Update 
.engine.logic.instrument.Funding:{

			ins:flip ![x;();0b;`kind`wit`bal`avail!(
				`fundingrate;	
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

			ivn:flip ![x;();0b;`kind`wit`bal`avail!(
				`fundingrate;	
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
			.engine.EmitA[`account;t;a];
			.engine.EmitA[`inventory;t;iv];
			.engine.Emit[`funding;t;x];
		};

// Apply mark price update 
.engine.logic.instrument.MarkPrice:{
			i:flip ![x;();0b;`kind`wit`bal`avail!(
				`fundingrate;	
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

			ivn:flip ![x;();0b;`kind`wit`bal`avail!(
				`fundingrate;	
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
			.engine.EmitA[`account;t;a];
			.engine.EmitA[`inventory;t;iv];
			.engine.Emit[`funding;t;x];
	};

.engine.logic.instrument.Settlement:{
			i:flip ![x;();0b;`kind`wit`bal`avail!(
				`fundingrate;	
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
			)];

			ivn:flip ![x;();0b;`kind`wit`bal`avail!(
				`fundingrate;	
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
			.engine.EmitA[`account;t;a];
			.engine.EmitA[`inventory;t;iv];
			.engine.Emit[`funding;t;x];
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

		.engine.Emit[`pricelimit;t;x];
	};










