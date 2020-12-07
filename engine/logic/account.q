
.engine.logic.account.Liquidate:{
		a[`status]:1;
		lq:();
		.engine.model.liquidation.Create[];

		
	};


.engine.logic.account.Remargin :{
	  
			// TODO 
			feetier:.engine.model.feetier.Get[()];
			risktier:.engine.model.risktier.Get[()];

			/ a[`feetier]:feetier;
			/ a[`riktier]:risktier;

			/ a[`avail]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);
			a
	  };

.engine.logic.account.Withdraw:{
				if[a[`bal]<=0;.engine.Purge[w;0;"Order account has no balance"]];
				if[a[`available]<=0;.engine.Purge[w;0;"Order account has insufficient available balance"]];
				if[a[`state]=1;.engine.Purge[w;0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[w;0;"Account has been locked for liquidation"]];
				a[`wit]+:w`wit;
				a:.engine.logic.account.Remargin[i;a];

				.engine.model.account.Update a;
				.engine.EmitA[`account;t;a];
				};

.engine.logic.account.Deposit:{
				if[a[`state]=1;.engine.Purge[d;0;"Account has been disabled"]];
				a[`dep]+:d`dep;
				feetier:.engine.model.feetier.GetFeeTier[];
				a:.engine.logic.account.Remargin[i;a];

				.engine.model.account.Update a;
				.engine.EmitA[`account;t;a];
				};

.engine.logic.account.Leverage:{
				if[a[`bal]<=0;.engine.Purge[l;0;"Order account has no balance"]];
				if[a[`available]<=0;.engine.Purge[l;0;"Order account has insufficient available balance"]];
				if[a[`state]=1;.engine.Purge[l;0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[l;0;"Account has been locked for liquidation"]];
				a[`leverage]:l`leverage;
				a:.engine.logic.account.Remargin[i;a];

				.engine.model.account.Update a;
				.engine.EmitA[`account;t;a];
				};











