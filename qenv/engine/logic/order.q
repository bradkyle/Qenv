
/ vdlt:prd[o[`oqty`price]]; // TODO contract specific 
/ lsdlt:min[(((dlt*i[`mkprice])-vdlt);0)];
// Events will be passed with aId
.engine.logic.order.New:{
				acc: 	![x;();0b;`aId`avail`rt()];

				ivn: 	![x;();0b;`ordLoss`ordVal`ordQty`lev!(

					)];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;
				.engine.EmitA[`order;t;o];

				.engine.Emit .event.Account[]; 
				.engine.Emit .event.Inventory[]; 
				.engine.Emit .event.Order[]; 
		};

.engine.logic.order.Amend:{
				x: ?[] ^ x;

				acc: 	![x;();0b;`aId`avail`rt()];

				ivn: 	![x;();0b;`ordLoss`ordVal`ordQty`lev!(

					)];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;
				.engine.EmitA[`order;t;o];

				.engine.Emit .event.Account[]; 
				.engine.Emit .event.Inventory[]; 
				.engine.Emit .event.Order[]; 
		};

.engine.logic.order.Cancel:{
				acc: 	![x;();0b;`aId`avail`rt()];

				ivn: 	![x;();0b;`ordLoss`ordVal`ordQty`lev!(

					)];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;
				.engine.EmitA[`order;t;o];

				.engine.Emit .event.Account[]; 
				.engine.Emit .event.Inventory[]; 
				.engine.Emit .event.Order[]; 
		};


.engine.logic.order.CancelAll:{
				acc: 	![x;();0b;`aId`avail`rt()];

				ivn: 	![x;();0b;`ordLoss`ordVal`ordQty`lev!(

					)];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;
				.engine.EmitA[`order;t;o];

				.engine.Emit .event.Account[]; 
				.engine.Emit .event.Inventory[]; 
				.engine.Emit .event.Order[]; 
    };

