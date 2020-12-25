
// TODO allow for multiple args
.engine.logic.account.GetFeetier:{[avol]
		avol:first avol;
	  ft:select[1;<vol] from .engine.model.feetier.Feetier where (vol>avol) or ((i=0) and (vol>avol));
   	`.engine.model.feetier.Feetier$((first 0!ft)`ftId)
   };

// TODO allow for multiple args
.engine.logic.account.GetRisktier:{[ivamt;ivlev]
		ivamt:first ivamt;
	  rt:select[1;<amt] from .engine.model.risktier.Risktier where (amt>ivamt) or ((i=0) and (amt>ivamt));
   	`.engine.model.risktier.Risktier$((first 0!rt)`rtId)
   };

.engine.logic.account.GetAvailable:{[bal;mm;upnl;oqty;oloss]
      bal-(mm+upnl)+(oqty-oloss)
    };


// TODO rt ft etc.
.engine.logic.account.Withdraw:{
			acc:?[x;();0b;`aId`time`froz`wit`rt`ft`bal`avail!(
				`aId;`time;`aId.froz;
				(+;`aId.wit;`wit);	
				((';`.engine.logic.account.GetRisktier);(+;`aId.lng.amt;`aId.srt.amt);(+;`aId.lng.lev;`aId.srt.lev));
				((';`.engine.logic.account.GetFeetier);`aId.vol);
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

.engine.logic.account.Deposit:{
			acc:?[x;();0b;`aId`time`froz`dep`bal`rt`ft`avail!(
				`aId;`time;`aId.froz;
				(+;`aId.dep;`dep);	
				(+;`aId.bal;`dep);	
				((';`.engine.logic.account.GetRisktier);(+;`aId.lng.amt;`aId.srt.amt);(+;`aId.lng.lev;`aId.srt.lev));
				((';`.engine.logic.account.GetFeetier);`aId.vol);
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

// TODO update inventory
.engine.logic.account.Leverage:{
			acc:?[x;();0b;`aId`time`bal`rt`ft`avail!(
				`aId;`time;`aId.bal;
				((';`.engine.logic.account.GetRisktier);(+;`aId.lng.amt;`aId.srt.amt);(+;`aId.lng.lev;`aId.srt.lev));
				((';`.engine.logic.account.GetFeetier);`aId.vol);
				(`.engine.logic.account.GetAvailable;
					`aId.bal;
					(+;`aId.lng.mm;`aId.srt.mm);
					(+;`aId.lng.upnl;`aId.srt.upnl);
					(+;`aId.lng.ordQty;`aId.srt.ordQty);
					(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];
			.engine.model.account.Update acc;
			.engine.E .event.Account[acc]; 
			};

