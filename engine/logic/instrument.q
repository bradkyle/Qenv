
// Update 
.engine.logic.instrument.Funding:{
				update 
				  	fundingrate:x[`fundingrate] 
				  	from `.engine.model.instrument.Instrument
						where iId=x[`iId];

				update
						rpnl:rpnl+(posVal * x[`fundingRate] * side)
						from `.engine.model.inventory.Inventory
						where iId=x[`iId] and amt>0;

				update
						avail:0
						from `.engine.model.account.Account 
						where iId=x[`iId] and ((lng.amt>0) or (srt.amt>0));

				// Update instrument
				.engine.EmitA[`account;t;a];
				.engine.EmitA[`inventory;t;iv];
				.engine.Emit[`funding;t;x];
			};

// Apply mark price update 
.engine.logic.instrument.MarkPrice:{
				update 
				  	mkprice:x[`markprice] 
				  	from `.engine.model.instrument.Instrument
						where iId=x[`iId];

				update 
					  upl:.engine.logic.contract.UnrealizedPnl[
								iId.cntTyp,	
								iId.mkprice,
								iId.faceValue,
								iId.smul,
								amt,
								side,
								avgPrice]
						from `.engine.model.inventory.Inventory 
						where (iId=x`iId) and (amt>0);

				update
						avail:0
						from `.engine.model.account.Account 
						where iId=x[`iId] and ((lng.amt>0) or (srt.amt>0));

				.engine.EmitA[`account;last t;last x];
				.engine.EmitA[`inventory;last t;last x];
				.engine.Emit[`mark;last t;last x];
	};

.engine.logic.instrument.Settlement:{
				update 
					bal:bal+(lng.rpnl+srt.rpnl)
				from `.engine.model.account.Account;

				update
					rpnl:0
				from `.engine.model.inventory.Inventory;

				.engine.Emit[`account;t;a];
				.engine.Emit[`inventory;t;iv];
				.engine.Emit[`settlement;t;x];
	};


.engine.logic.instrument.PriceLimit:{
				update 
					highest:x[`highest], 
					lowest:x[`lowest] 
				  from `.engine.model.instrument.Instrument
					where iId=x[`iId];

				.engine.Emit[`pricelimit;t;x];

				o:.engine.model.order.Get[(|;
					(=;`side;(&;1;((';~:;<);`price;i`highest)));
					(=;`side;(&;-1;((';~:;>);`price;i`lowest)))
					)];

				if[count[o]>0;.engine.logic.order.CancelOrder[o]];
	};










