
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

			show value ?[`.engine.model.feetier.Feetier;
				enlist(|;((&;(&;(>;`vol;x`vol);(>;`bal;x`bal));(>;`ref;x`ref)));
				(=;`i;(*:;`i)));();eny[`ftId;(first;`ftId)]]; 

			// Update the account fee tiers
			x[`ft]:first ?[`.engine.model.feetier.Feetier;
				enlist(|;((&;(&;(>;`vol;x`vol);(>;`bal;x`bal));(>;`ref;x`ref)));
				(=;`i;(*:;`i)));();()][`ftId]; 

			tot:first value ?[x;();();eny[`a;((+\);`srt.amt;`lng.amt)]];
			show tot;

			// TODO derive leverage
			// Update the account risk tiers
			x[`rt]:first [?[`.engine.model.risktier.Risktier;
					enlist(|;(>;`amt;tot);(=;`i;(*:;`i)));();()]][`rtId];

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











