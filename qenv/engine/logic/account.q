
.engine.logic.account.GetFeetier:{[avol]
   ft:select[1;<vol] from .engine.model.feetier.Feetier where (vol>a) or ((i=0) and (vol>a));
   `.engine.model.feetier.Feetier$((0!ft)`ftId)
   };

.engine.logic.account.GetRisktier:{[ivnamt;ivlev]
   rt:select[1;<amt] from .engine.model.risktier.Risktier where (amt>a) or ((i=0) and (amt>a));
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
			.bam.w:acc;
			.engine.model.account.Update acc;
			.engine.E .event.Account[acc]; 
			.engine.E .event.Withdraw[x]; 
			};

// TODO check formatting of events
.engine.logic.account.Deposit:{
			acc:?[x;();0b;`aId`time`dep`bal`avail!(
				`aId;`time;
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
			acc:?[x;();0b;`aId`time`lev`avail!(
				`aId;`time;`lev;	
				 (`.engine.logic.account.GetAvailable;
					`aId.bal;
					(+;`aId.lng.mm;`aId.srt.mm);
					(+;`aId.lng.upnl;`aId.srt.upnl);
					(+;`aId.lng.ordQty;`aId.srt.ordQty);
					(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];
			.engine.model.account.Update acc;
			.engine.E .event.Account[acc]; 
			};







