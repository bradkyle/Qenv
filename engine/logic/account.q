
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
			tot:exec (+\)(lng.amt;srt.amt) from x;
			ft:value select[1;<vol] ftId from .engine.model.feetier.Feetier where (vol>x`vol) or i=0;
			rt:value select[1;<rtId] rtId from .engine.model.risktier.Risktier where (amt>tot) or i=0;
			x[`ft]:`.engine.model.feetier.Feetier$ft;
			x[`rt]:`.engine.model.risktier.Risktier$rt;

			update 
			  avail:((bal-
					((lng.mm + srt.mm) + (lng.upnl + srt.upnl)) + 
			  	((lng.ordQty+srt.ordQty)-(lng.ordLoss+srt.ordLoss))) | 0)
				from x
	  };

.engine.logic.account.Withdraw:{
				a:.engine.model.account.Get[x`aId];
				a[`wit]+:x`wit;
				a[`bal]-:x`wit;
				a:.engine.logic.account.Remargin[x;a];
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











