
.engine.valid.account.Withdraw:{
	// 
	x:.engine.Purge[x;enlist(<;`wit;0);0;"Withdraw is less than min withdrawal amount"];
	x:.engine.Purge[x;enlist(>;`wit;10000);0;"Withdraw is greater than max withdrawal amount"];

	// TODO link account
	/ x:.engine.Purge[x;enlist(<;`aId.bal;0);0;"Order account has no balance"];
	/ x:.engine.Purge[x;enlist();0;"Order account has insufficient available balance"];
	/ x:.engine.Purge[x;enlist();0;"Account has been disabled"];
	/ x:.engine.Purge[x;enlist();0;"Account has been locked for liquidation"];
	x 
	};

.engine.valid.account.Deposit:{
	.bam.dx:x;
	x:.engine.Purge[x;enlist(<=;`aId.bal;0);0;"Order account has no balance"];
	x 
	};

.engine.valid.account.Leverage:{

	acc:?[x;();0b;`aId`time`bal`froz`avail!(
		`aId;`time;`aId.bal;`aId.froz;
		(`.engine.logic.account.GetAvailable;
			`aId.bal;
			(+;`aId.lng.mm;`aId.srt.mm);
			(+;`aId.lng.upnl;`aId.srt.upnl);
			(+;`aId.lng.ordQty;`aId.srt.ordQty);
			(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];

	x:.engine.Purge[x;enlist();0;"Order account has no balance"];
	x:.engine.Purge[x;enlist();0;"Order account has insufficient available balance"];
	x:.engine.Purge[x;enlist();0;"Account has been disabled"];
	x:.engine.Purge[x;enlist();0;"Account has been locked for liquidation"];
	x  
	};
