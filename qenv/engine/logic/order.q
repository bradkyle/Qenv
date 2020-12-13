
/ vdlt:prd[o[`oqty`price]]; // TODO contract specific 
/ lsdlt:min[(((dlt*i[`mkprice])-vdlt);0)];
// Events will be passed with aId
.engine.logic.order.New:{
				ins:	![];

				acc: 	![];

				ivn: 	![];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;
				.engine.EmitA[`order;t;o];

				.engine.EmitA[`instrument;t;iv];
				.engine.EmitA[`inventory;t;iv];
				.engine.EmitA[`account;t;a];
		};

.engine.logic.order.Amend:{
				ord: ();

				ins:	![];

				acc: 	![];

				ivn: 	![];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;
				.engine.EmitA[`order;t;o];

				.engine.EmitA[`instrument;t;iv];
				.engine.EmitA[`inventory;t;iv];
				.engine.EmitA[`account;t;a];
		};

.engine.logic.order.Cancel:{
				ins:	![];

				acc: 	![];

				ivn: 	![];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;
				.engine.EmitA[`order;t;o];

				.engine.EmitA[`instrument;t;iv];
				.engine.EmitA[`inventory;t;iv];
				.engine.EmitA[`account;t;a];
		};


.engine.logic.order.CancelAll:{
				ins:	![];

				acc: 	![];

				ivn: 	![];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;
				.engine.EmitA[`order;t;o];

				.engine.EmitA[`instrument;t;iv];
				.engine.EmitA[`inventory;t;iv];
				.engine.EmitA[`account;t;a];
    };

