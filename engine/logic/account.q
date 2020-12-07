
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



			x:update 
			  avail:((bal-
					((lng.mm + srt.mm) + (lng.upnl + srt.upnl)) + 
			  	((lng.ordQty+srt.ordQty)-(lng.ordLoss+srt.ordLoss))) | 0)
				from x;

			/ a[`avail]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);
			x
	  };

.engine.logic.account.Withdraw:{
				a[`wit]+:w`wit;
				a:.engine.logic.account.Remargin[i;a];

				.engine.model.account.Update a;
				.engine.EmitA[`account;t;a];
				};

.engine.logic.account.Deposit:{
				a[`dep]+:d`dep;
				feetier:.engine.model.feetier.GetFeeTier[];
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











