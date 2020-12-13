
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

.engine.logic.account.Withdraw:{
			acc:.model.Account[flip ![x;();0b;`kind`wit`bal`avail!(
				(+;`aId.wit;`wit);	
				(-;`aId.bal;`wit);	
				(`.engine.logic.account.GetAvailable;)
				)]];
			.engine.model.account.Update acc;
			.engine.Emit .event.Account[acc]; 
			.engine.Emit .event.Withdraw[x]; 
			};

.engine.logic.account.Deposit:{
			acc:.model.Account[flip ![x;();0b;`kind`dep`bal`avail!(
				(+;`aId.dep;`dep);	
				(+;`aId.bal;`dep);	
				(`.engine.logic.account.GetAvailable;)
				)]];
			.engine.model.account.Update acc;
			.engine.Emit .event.Account[acc]; 
			.engine.Emit .event.Deposit[x]; 
			};

.engine.logic.account.Leverage:{
			acc:.model.Account[flip ![x;();0b;`kind`wit`bal`avail!(
				`lev;	
				();
				(`.engine.logic.account.GetAvailable;)
			)]];
			.engine.model.account.Update acc;
			.engine.Emit .event.Account[acc]; 
			};







