
.engine.logic.account.Liquidate:{
		a[`status]:1;
		lq:();
		.engine.model.liquidation.Create[];


		
	};


.engine.logic.account.Remargin :{
	  
			// TODO 
			feetier:.engine.model.feetier.Get[()];
			risktier:.engine.model.risktier.Get[()];

			x[`feetier]:feetier`ftId;
			x[`riktier]:risktier`rtId;

			// lng.mm = 
			x:update 
			  avail:((bal-
					((lng.mm + srt.mm) + (lng.upnl + srt.upnl)) + 
			  	((lng.ordQty+srt.ordQty)-(lng.ordLoss+srt.ordLoss))) | 0)
				from x;

			x
	  };

.engine.logic.account.Withdraw:{
				a[`wit]+:w`wit;
				a[`bal]-:w`wit;
				a:.engine.logic.account.Remargin[i;a];

				.engine.model.account.Update a;
				.engine.EmitA[`account;t;a];
				};

.engine.logic.account.Deposit:{
				a[`dep`bal]+:d`dep;
				a:.engine.logic.account.Remargin[i;a];

				.engine.model.account.Update a;
				.engine.EmitA[`account;t;a];
				};

.engine.logic.account.Leverage:{
				a[`leverage]:l`leverage;
				a:.engine.logic.account.Remargin[i;a];

				.engine.model.account.Update a;
				.engine.EmitA[`account;t;a];
				};











