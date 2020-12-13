
/ vdlt:prd[o[`oqty`price]]; // TODO contract specific 
/ lsdlt:min[(((dlt*i[`mkprice])-vdlt);0)];
// Events will be passed with aId
.engine.logic.order.New:{

				ivn: 	![x;();0b;`ordLoss`ordVal`ordQty!(
					(+;`ivId.ordLoss;);
					(+;`ivId.ordVal;);
					(+;`ivId.ordQty;);
					)];

				acc: 	![x;();0b;`aId`avail`rt()];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 

				.engine.Emit .event.Account[acc]; 
				.engine.Emit .event.Inventory[ivn]; 
				.engine.Emit .event.Order[x]; 
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

				.engine.Emit .event.Account[acc]; 
				.engine.Emit .event.Inventory[ivn]; 
				.engine.Emit .event.Order[x]; 
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

				.engine.Emit .event.Account[acc]; 
				.engine.Emit .event.Inventory[ivn]; 
				.engine.Emit .event.Order[x]; 
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

				.engine.Emit .event.Account[acc]; 
				.engine.Emit .event.Inventory[ivn]; 
				.engine.Emit .event.Order[x]; 
    };

