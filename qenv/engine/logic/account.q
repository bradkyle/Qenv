
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
		.engine.model.account.Update[];
		// Partial Liquidation
		$[(a[`rt][`id]>=3);[
				.engine.EmitA[];
				.engine.model.liquidation.Create[lq];
				.engine.logic.order.New[]	
				];[
				.engine.EmitA[];
				.engine.model.liquidation.Create[lq];
				.engine.logic.order.New[]	
				]];
		x	
	};

//
.engine.logic.account.Remargin :{
			update 
			ft:.engine.logic.account.GetFeetier[vol],
			rt:.engine.logic.account.GetRisktier[lng.amt+srt.amt],
			avail:.engine.logic.account.GetAvailable[
				bal;lng.mm+srt.mm;lng.upnl+srt.upnl;
				lng.ordQty+srt.ordQty;lng.ordLoss+srt.ordLoss]
			from x
	  };

.engine.logic.account.Withdraw:{
			update
				wit:wit+x[`withdrawn],
				bal:bal-x[`withdrawn],
				avail:.engine.logic.account.GetAvailable[
					bal-x[`withdrawn],
					lng.mm+srt.mm,
					lng.upnl+srt.upnl,
					lng.ordQty+srt.ordQty,
					lng.ordLoss+srt.ordLoss]
				from `.engine.model.account.Account where aId=x[`aId];
			.engine.EmitA[`account;t;a]
			};

.engine.logic.account.Deposit:{
			update
				dep:dep+x[`deposit],
				bal:bal+x[`deposit],
				avail:.engine.logic.account.GetAvailable'[
					bal+x[`deposit],
					lng.mm+srt.mm,
					lng.upnl+srt.upnl,
					lng.ordQty+srt.ordQty,
					lng.ordLoss+srt.ordLoss]
				rt:.engine.logic.account.GetRisktier'[lng.amt+srt.amt;bal%(lng.amt+srt.amt)]
				from `.engine.model.account.Account where aId=x[`aId];
			.engine.EmitA[`account;t;a];
			};

.engine.logic.account.Leverage:{
			update
				lev:x[`leverage],
				avail:.engine.logic.account.GetAvailable'[
					bal+x[`deposit],
					lng.mm+srt.mm,
					lng.upnl+srt.upnl,
					lng.ordQty+srt.ordQty,
					lng.ordLoss+srt.ordLoss]
				rt:.engine.logic.account.GetRisktier'[lng.amt+srt.amt;bal%(lng.amt+srt.amt)]
				from `.engine.model.account.Account where aId=x[`aId];
			.engine.EmitA[`account;t;a];
			};











