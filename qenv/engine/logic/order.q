
/ vdlt:prd[o[`oqty`price]]; // TODO contract specific 
/ lsdlt:min[(((dlt*i[`mkprice])-vdlt);0)];
// Events will be passed with aId
.engine.logic.order.New:{

				ivn: 	?[x;();0b;`aId`side`ordLoss`ordVal`ordQty!(
					`aId;`side;
					(+;`ivId.ordLoss;);
					(+;`ivId.ordVal;);
					(+;`ivId.ordQty;);
					)];

				acc: ?[ivn;();0b;`aId`avail`rt!(
					`aId;
					(`.engine.logic.account.GetAvailable);
					(`.engine.logic.account.GetRiskTier)
					)];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;

				.engine.logic.trade.Match ?[o;();0b;()];
				.engine.model.order.CreateOrder x; 

				.engine.E .event.Account[acc]; 
				.engine.E .event.Inventory[ivn]; 
				.engine.E .event.Order[x]; 
		};

.engine.logic.order.Amend:{
				x: .model.Order[![x;]]

				ivn: 	.model.Inventory[?[x;();0b;`aId`side`ordLoss`ordVal`ordQty!(
					`aId;`side;
					(+;`ivId.ordLoss;);
					(+;`ivId.ordVal;);
					(+;`ivId.ordQty;);
					)]];

				acc: .model.Account[?[ivn;();0b;`aId`avail`rt!(
					`aId;
					(`.engine.logic.account.GetAvailable);
					(`.engine.logic.account.GetRiskTier)
					)]];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;
				.enigne.model.instrument.Update ins;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;

				.engine.E .event.Account[acc]; 
				.engine.E .event.Inventory[ivn]; 
				.engine.E .event.Order[x]; 
		};

.engine.logic.order.Cancel:{
				ivn: 	.model.Inventory[?[x;();0b;`aId`side`ordLoss`ordVal`ordQty!(
					`aId;`side;
					(-;`ivId.ordLoss;);
					(-;`ivId.ordVal;);
					(-;`ivId.ordQty;);
					)]];

				acc: .model.Account[?[ivn;();0b;`aId`avail`rt!(
					`aId;
					(`.engine.logic.account.GetAvailable);
					(`.engine.logic.account.GetRiskTier)
					)]];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;

				.engine.E .event.Account[acc]; 
				.engine.E .event.Inventory[ivn]; 
				.engine.E .event.Order[x]; 
		};


.engine.logic.order.CancelAll:{
				ivn: 	.model.Inventory[?[x;();0b;`aId`side`ordLoss`ordVal`ordQty!(
					`aId;`side;0;0;0
					)]];

				acc: .model.Account[?[ivn;();0b;`aId`avail`rt!(
					`aId;
					(`.engine.logic.account.GetAvailable);
					(`.engine.logic.account.GetRiskTier)
					)]];

				.engine.model.account.Update acc;
				.engine.model.inventory.Update ivn;

				.engine.logic.trade.Match ?[o;();0b;()];

				.engine.model.order.CreateOrder l; 
				.engine.model.orderbook.Update o;

				.engine.E .event.Account[acc]; 
				.engine.E .event.Inventory[ivn]; 
				.engine.E .event.Order[x]; 
    };

