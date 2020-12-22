
.engine.logic.account.GetFeetier:{[avol]
	 ft:select[1;<vol] from .engine.model.feetier.Feetier where (vol>avol) or ((i=0) and (vol>avol));
   `.engine.model.feetier.Feetier$((0!ft)`ftId)
   };

.engine.logic.account.GetRisktier:{[ivamt;ivlev]
	 rt:select[1;<amt] from .engine.model.risktier.Risktier where (amt>ivamt) or ((i=0) and (amt>ivamt));
   `.engine.model.risktier.Risktier$((0!rt)`rtId)
   };

.engine.logic.account.GetAvailable:{[bal;mm;upnl;oqty;oloss]
      bal-(mm+upnl)+(oqty-oloss)
    };

// TODO 
.engine.logic.account.Liquidate:{
		x[`status]:1;
		.engine.model.account.Update x;
		x
	};

// TODO check formatting of events
.engine.logic.account.Withdraw:{
			acc:?[x;();0b;`aId`time`froz`wit`bal`avail!(
				`aId;`time;`aId.froz;
				(+;`aId.wit;`wit);	
				(-;`aId.bal;`wit);	
				(`.engine.logic.account.GetAvailable;
					(-;`aId.bal;`wit);
					(+;`aId.lng.mm;`aId.srt.mm);
					(+;`aId.lng.upnl;`aId.srt.upnl);
					(+;`aId.lng.ordQty;`aId.srt.ordQty);
					(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];
			.engine.model.account.Update acc;
			.engine.E .event.Account[acc]; 
			.engine.E .event.Withdraw[x]; 
			};

// TODO check formatting of events
.engine.logic.account.Deposit:{
			acc:?[x;();0b;`aId`time`froz`dep`bal`avail!(
				`aId;`time;`aId.froz;
				(+;`aId.dep;`dep);	
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;
					(+;`aId.bal;`dep);
					(+;`aId.lng.mm;`aId.srt.mm);
					(+;`aId.lng.upnl;`aId.srt.upnl);
					(+;`aId.lng.ordQty;`aId.srt.ordQty);
					(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];
			.engine.model.account.Update acc;
			.engine.E .event.Account[acc]; 
			.engine.E .event.Deposit[x]; 
			};

// TODO check formatting of events multiple lev update
.engine.logic.account.Leverage:{
			/ lng:?[x;();0b;()]
			/ srt:?[x;();0b;()]

			acc:?[x;();0b;`aId`time`bal`froz`avail!(
				`aId;`time;`aId.bal;`aId.froz;
				(`.engine.logic.account.GetAvailable;
					`aId.bal;
					(+;`aId.lng.mm;`aId.srt.mm);
					(+;`aId.lng.upnl;`aId.srt.upnl);
					(+;`aId.lng.ordQty;`aId.srt.ordQty);
					(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];
			.engine.model.account.Update acc;
			.engine.E .event.Account[acc]; 
			};


.engine.logic.account.Settings:{

			};





