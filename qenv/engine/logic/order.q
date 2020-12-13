
/ vdlt:prd[o[`oqty`price]]; // TODO contract specific 
/ lsdlt:min[(((dlt*i[`mkprice])-vdlt);0)];
// Events will be passed with aId
.engine.logic.order.New:{
				acc: 	![];

				ivn: 	![];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;
				.engine.EmitA[`order;t;o];

				.engine.Emit AccountEvent[]; 
				.engine.Emit InventoryEvent[]; 
				.engine.Emit NewOrderEvent[]; 
		};

.engine.logic.order.Amend:{
				ord: ();

				acc: 	![];

				ivn: 	![];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;
				.engine.EmitA[`order;t;o];

				.engine.Emit AccountEvent[]; 
				.engine.Emit InventoryEvent[]; 
				.engine.Emit AmendOrderEvent[]; 
		};

.engine.logic.order.Cancel:{
				acc: 	![];

				ivn: 	![];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;
				.engine.EmitA[`order;t;o];

				.engine.Emit AccountEvent[]; 
				.engine.Emit InventoryEvent[]; 
				.engine.Emit CancelOrderEvent[]; 
		};


.engine.logic.order.CancelAll:{
				acc: 	![];

				ivn: 	![];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;
				.engine.EmitA[`order;t;o];

				.engine.Emit AccountEvent[]; 
				.engine.Emit InventoryEvent[]; 
				.engine.Emit CancelOrderEvent[]; 
    };

