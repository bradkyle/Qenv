
.engine.valid.order.New:{
	// TODO fkey to instrument
	x:.engine.Purge[x;enlist(>;(count;`i);10);0;"Invalid batch size: batch size > max batch size"];
	x:.engine.Purge[x;enlist(<;`price;`iId.mnPrice);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(>;`price;`iId.mxPrice);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(<;`oqty;`iId.mnQty);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(>;`oqty;`iId.mxQty);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(<;`dqty;`iId.mnQty);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(>;`dqty;`iId.mxQty);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(<>;(mod;`price;`iId.ticksize);0);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(<>;(mod;`lprice;`iId.ticksize);0);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(<>;(mod;`oqty;`iId.lotsize);0);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(<>;(mod;`dqty;`iId.lotsize);0);0;"Invalid price: price<mnPrice"];
	/ x:.engine.Purge[x;enlist();0;"Order had execInst of immediate or cancel"];
	/ if[((o[`okind]=0) or all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])] or
 	/ all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])]) and in'[1;o[`execInst]]);

	// TODO fkey to account
	x:.engine.Purge[x;enlist();0;"Order account has no balance"];
	x:.engine.Purge[x;enlist();0;"Order account has insufficient available balance"];
	x:.engine.Purge[x;enlist();0;"Account has been disabled"];
	x:.engine.Purge[x;enlist();0;"Account has been locked for liquidation"];

	// TODO check has available resources
	acc:?[x;();0b;`aId`time`bal`rt`ft`avail!(
			`aId;`time;`aId.bal;
			(`.engine.logic.account.GetRisktier;(+;`aId.lng.amt;`aId.srt.amt);(+;`aId.lng.lev;`aId.srt.lev));
			(`.engine.logic.account.GetFeetier;`aId.vol);
			(`.engine.logic.account.GetAvailable;
				`aId.bal;
				(+;`aId.lng.mm;`aId.srt.mm);
				(+;`aId.lng.upnl;`aId.srt.upnl);
				(+;`aId.lng.ordQty;`aId.srt.ordQty);
				(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];

	// where account 
	x:.engine.Purge[x;enlist();0;"Insufficient available margin to place new order"];
	x:.engine.Purge[x;enlist();0;"Resultant leverage exceeds allowed leverage"];

	// Placement of order would result in immediate liquidation
	x:.engine.Purge[x;enlist();0;"Account has been locked for liquidation"];

	// Return if 
	if[count[x]=0;:0b;:x]
	};

.engine.valid.order.Amend:{
	// TODO fkey to instrument
	x:.engine.Purge[x;enlist(>;(count;`i);10);0;"Invalid batch size: batch size > max batch size"];
	x:.engine.Purge[x;enlist(<;`price;`iId.mnPrice);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(>;`price;`iId.mxPrice);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(<;`oqty;`iId.mnQty);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(>;`oqty;`iId.mxQty);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(<;`dqty;`iId.mnQty);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(>;`dqty;`iId.mxQty);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(<>;(mod;`price;`iId.ticksize);0);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(<>;(mod;`lprice;`iId.ticksize);0);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(<>;(mod;`oqty;`iId.lotsize);0);0;"Invalid price: price<mnPrice"];
	x:.engine.Purge[x;enlist(<>;(mod;`dqty;`iId.lotsize);0);0;"Invalid price: price<mnPrice"];
	/ x:.engine.Purge[x;enlist();0;"Order had execInst of immediate or cancel"];
	/ if[((o[`okind]=0) or all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])] or
 	/ all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])]) and in'[1;o[`execInst]]);

	// TODO fkey to account
	x:.engine.Purge[x;enlist();0;"Order account has no balance"];
	x:.engine.Purge[x;enlist();0;"Order account has insufficient available balance"];
	x:.engine.Purge[x;enlist();0;"Account has been disabled"];
	x:.engine.Purge[x;enlist();0;"Account has been locked for liquidation"];

	// TODO check has available resources
	acc:?[x;();0b;`aId`time`bal`rt`ft`avail!(
			`aId;`time;`aId.bal;
			(`.engine.logic.account.GetRisktier;(+;`aId.lng.amt;`aId.srt.amt);(+;`aId.lng.lev;`aId.srt.lev));
			(`.engine.logic.account.GetFeetier;`aId.vol);
			(`.engine.logic.account.GetAvailable;
				`aId.bal;
				(+;`aId.lng.mm;`aId.srt.mm);
				(+;`aId.lng.upnl;`aId.srt.upnl);
				(+;`aId.lng.ordQty;`aId.srt.ordQty);
				(+;`aId.lng.ordLoss;`aId.srt.ordLoss)))];

	// where account 
	x:.engine.Purge[x;enlist();0;"Insufficient available margin to place new order"];
	x:.engine.Purge[x;enlist();0;"Resultant leverage exceeds allowed leverage"];

	// Placement of order would result in immediate liquidation
	x:.engine.Purge[x;enlist();0;"Account has been locked for liquidation"];

	// Return if 
	if[count[x]=0;:0b;:x]
	};

.engine.valid.order.Cancel:{
				/ c:.engie.logic.order.Get[`oId`cId;o`oId`cId];
				/ if[null[c];.engine.Purge[o;0;"Order not found"]];
				/ if[not[c[`state] in ()];.engine.Purge[o;0;"cancel order with terminal state"]];
				/ o:c^o;

				/ if[a[`state]=1;.engine.Purge[0;"Account has been disabled"]];
				/ if[a[`state]=2;.engine.Purge[0;"Account has been locked for liquidation"]];
				x  
				};

.engine.valid.order.CancelAll:{
				/ c:.engie.logic.order.Get[`aId`state;(a`aId;0)];
				/ if[null[c];.engine.Purge[o;0;"No orders found"]];
				/ if[not[c[`state] in ()];.engine.Purge[o;0;"cancel order with terminal state"]];

				/ if[a[`state]=1;.engine.Purge[0;"Account has been disabled"]];
				/ if[a[`state]=2;.engine.Purge[0;"Account has been locked for liquidation"]];
				x
				};
