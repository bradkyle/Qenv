
.engine.valid.account.Withdraw:{
				/ if[a[`bal]<=0;.engine.Purge[w;0;"Order account has no balance"]];
				/ if[a[`available]<=0;.engine.Purge[w;0;"Order account has insufficient available balance"]];
				/ if[a[`state]=1;.engine.Purge[w;0;"Account has been disabled"]];
				/ if[a[`state]=2;.engine.Purge[w;0;"Account has been locked for liquidation"]];
				x 
				}

.engine.valid.account.Deposit:{
				/ if[a[`state]=1;.engine.Purge[d;0;"Account has been disabled"]];
				x 
				};

.engine.valid.account.Leverage:{
				/ if[a[`bal]<=0;.engine.Purge[l;0;"Order account has no balance"]];
				/ if[a[`available]<=0;.engine.Purge[l;0;"Order account has insufficient available balance"]];
				/ if[a[`state]=1;.engine.Purge[l;0;"Account has been disabled"]];
				/ if[a[`state]=2;.engine.Purge[l;0;"Account has been locked for liquidation"]];
				x  
				};
