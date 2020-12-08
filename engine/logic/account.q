
.engine.logic.account.GetFeetier:{[avol]
			ft:first (select[1;<vol] ftId from .engine.model.feetier.Feetier where (vol>avol) or i=0)[`ftId];
			`.engine.model.feetier.Feetier$ft
	  };

.engine.logic.account.GetRisktier:{[ivnamt]
			rt:first (select[1;<rtId] rtId from .engine.model.risktier.Risktier where (amt>ivnamt) or i=0)[`rtId];
			`.engine.model.risktier.Risktier$rt
		};

.engine.logic.account.GetAvailable:{[bal;mm;upnl;oqty;oloss]
			bal-(mm+upnl)+(ordQty-ordLoss)
		};

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
		![`.engine.model.account.Account;];
				a:.engine.model.account.Get[x`aId];
				a[`wit]+:x[`withdraw];
				a[`bal]-:x[`withdraw];
				a:.engine.logic.account.Remargin[a];
				.engine.model.account.Update a;
				.engine.EmitA[`account;t;a];
				};

.engine.logic.account.Deposit:{
				a:.engine.model.account.Get[x`aId];
				a[`dep`bal]+:x`dep;
				a:.engine.logic.account.Remargin[x`aId;a];
				.engine.model.account.Update a;
				.engine.EmitA[`account;t;a];
				};

.engine.logic.account.Leverage:{
				a:.engine.model.account.Get[x`aId];
				a[`leverage]:x`lev;
				a:.engine.logic.account.Remargin[x;a];
				.engine.model.account.Update a;
				.engine.EmitA[`account;t;a];
				};











