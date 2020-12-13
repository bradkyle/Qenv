
.engine.valid.order.New:{
				/ $[(if[((o[`okind]=0) or all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])] or
				/ 		all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])]) and in'[1;o[`execInst]]);
				/ 		[
				/ 			.engine.logic.trade.Match[i;a;o];
				/ 		];[
				/ 			.engine.model.order.CreateOrder o;
				/ 			.engine.logic.orderbook.Level[select sum oqty by side, price from o]
				/ 		]];
				/ if[count[x]>10;:.engine.Purge[x;first x`time;"Invalid batch size: batch size > max batch size"]];
				/ if[x[`price] < i[`mnPrice];:.engine.Purge[x;t;"Invalid price: price<mnPrice"]];
				/ if[x[`price] > i[`mxPrice];:.engine.Purge[x;t;"Invalid price: price>mxPrice"]];
				/ if[x[`xqty] < i[`mnSize];:.engine.Purge[x;t;"Invalid oqty: oqty<minqty"]];
				/ if[x[`oqty] > i[`mxSize];:.engine.Purge[x;t;"Invalid oqty: oqty>maxqty"]];
				/ if[(x[`price] mod i[`ticksize])<>0;:.engine.Purge[x;t;"Invalid ticksize"]]; 
				/ if[(o[`oqty] mod i[`lotsize])<>0;:.engine.Purge[x;t;"Invalid lotsize"]];
				/ if[x[`dqty] < i[`mnSize];:.engine.Purge[x;t;"Invalid dqty: dqty<minsize"]];
				/ if[x[`dqty] > i[`mxSize];:.engine.Purge[x;t;"Invalid dqty: dqty>maxsize"]];
				/ if[(x[`dqty] mod i[`lotsize])<>0;.engine.Purge[x;t;"Invalid dqty lot oqty"]]; 

				/ // Account validations
				/ if[a[`bal]<=0;:.engine.Purge[x;t;"Order account has no balance"]];
				/ if[a[`avail]<=0;:.engine.Purge[x;t;"Order account has insufficient available balance"]];
				/ if[a[`state]=1;:.engine.Purge[x;t;"Account has been disabled"]];
				/ if[a[`state]=2;:.engine.Purge[o;t;"Account has been locked for liquidation"]];
				x				  
				};

.engine.valid.order.Amend:{
				// Instrument validations
				/ if[x[`price] < i[`mnPrice];.engine.Purge[x;0;"Invalid price: price<mnPrice"]];
				/ if[x[`price] > i[`mxPrice];.engine.Purge[x;0;"Invalid price: price>mxPrice"]];
				/ if[x[`oqty] < i[`minOqty];.engine.Purge[x;0;"Invalid oqty: oqty<minOqty"]];
				/ if[x[`oqty] > i[`maxOqty];.engine.Purge[x;0;"Invalid oqty: oqty>maxOqty"]];
				/ if[(x[`price] mod i[`tickOqty])<>0;.engine.Purge[x;0;"Invalid tickOqty"]]; 
				/ if[(x[`oqty] mod i[`lotOqty])<>0;.engine.Purge[x;0;"Invalid lotOqty"]];
				/ if[x[`dqty] < i[`minOqty];.engine.Purge[x;0;"Invalid dqty: oqty<minOqty"]];
				/ if[x[`dqty] > i[`maxOqty];.engine.Purge[x;0;"Invalid dqty: oqty>maxOqty"]];
				/ if[(x[`dqty] mod i[`lotOqty])<>0;.engine.Purge[x;0;"Invalid dqty lot oqty"]]; 
				/ if[(all[((x[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])] or
				/ all[((x[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])]) and 
				/ in'[1;x[`execInst]];.engine.Purge[o;0;"Order had execInst xf postOnly"]];

				/ // Account validations
				/ if[?[x;();;.engine.Purge[0;"Order account has no balance"]];
				/ if[a[`available]<=0;.engine.Purge[0;"Order account has insufficient available balance"]];
				/ if[a[`state]=1;.engine.Purge[0;"Account has been disabled"]];
				/ if[a[`state]=2;.engine.Purge[0;"Account has been locked for liquidation"]];
				x
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
