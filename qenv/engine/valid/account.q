
.engine.valid.account.Withdraw:{
	x:.engine.Purge[x;enlist(<;`aId.bal;0);0;"Order account has no balance"];
	x:.engine.Purge[x;enlist();0;"Order account has insufficient available balance"];
	x:.engine.Purge[x;enlist();0;"Account has been disabled"];
	x:.engine.Purge[x;enlist();0;"Account has been locked for liquidation"];
	x 
	};

.engine.valid.account.Deposit:{
	x:.engine.Purge[x;enlist();0;"Order account has no balance"];
	x 
	};

.engine.valid.account.Leverage:{
	x:.engine.Purge[x;enlist();0;"Order account has no balance"];
	x:.engine.Purge[x;enlist();0;"Order account has insufficient available balance"];
	x:.engine.Purge[x;enlist();0;"Account has been disabled"];
	x:.engine.Purge[x;enlist();0;"Account has been locked for liquidation"];
	x  
	};
