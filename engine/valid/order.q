
.engine.valid.order.NewOrder:{[]
				/ if[count[o]>10;:.engine.Purge[o;first x`time;"Invalid batch size: batch size > max batch size"]];
				if[o[`price] < i[`mnPrice];:.engine.Purge[o;t;"Invalid price: price<mnPrice"]];
				if[o[`price] > i[`mxPrice];:.engine.Purge[o;t;"Invalid price: price>mxPrice"]];
				if[o[`oqty] < i[`mnSize];:.engine.Purge[o;t;"Invalid oqty: oqty<minqty"]];
				if[o[`oqty] > i[`mxSize];:.engine.Purge[o;t;"Invalid oqty: oqty>maxqty"]];
				if[(o[`price] mod i[`ticksize])<>0;:.engine.Purge[o;t;"Invalid ticksize"]]; 
				if[(o[`oqty] mod i[`lotsize])<>0;:.engine.Purge[o;t;"Invalid lotsize"]];
				if[o[`dqty] < i[`mnSize];:.engine.Purge[o;t;"Invalid dqty: dqty<minsize"]];
				if[o[`dqty] > i[`mxSize];:.engine.Purge[o;t;"Invalid dqty: dqty>maxsize"]];
				if[(o[`dqty] mod i[`lotsize])<>0;.engine.Purge[o;t;"Invalid dqty lot oqty"]]; 

				// Account validations
				if[a[`bal]<=0;:.engine.Purge[o;t;"Order account has no balance"]];
				if[a[`avail]<=0;:.engine.Purge[o;t;"Order account has insufficient available balance"]];
				if[a[`state]=1;:.engine.Purge[o;t;"Account has been disabled"]];
				if[a[`state]=2;:.engine.Purge[o;t;"Account has been locked for liquidation"]];
				  
				};

.engine.valid.order.AmendOrder:{[]
				  
				// Instrument validations
				if[o[`price] < i[`mnPrice];.engine.Purge[o;0;"Invalid price: price<mnPrice"]];
				if[o[`price] > i[`mxPrice];.engine.Purge[o;0;"Invalid price: price>mxPrice"]];
				if[o[`oqty] < i[`minOqty];.engine.Purge[o;0;"Invalid oqty: oqty<minOqty"]];
				if[o[`oqty] > i[`maxOqty];.engine.Purge[o;0;"Invalid oqty: oqty>maxOqty"]];
				if[(o[`price] mod i[`tickOqty])<>0;.engine.Purge[o;0;"Invalid tickOqty"]]; 
				if[(o[`oqty] mod i[`lotOqty])<>0;.engine.Purge[o;0;"Invalid lotOqty"]];
				if[o[`dqty] < i[`minOqty];.engine.Purge[o;0;"Invalid dqty: oqty<minOqty"]];
				if[o[`dqty] > i[`maxOqty];.engine.Purge[o;0;"Invalid dqty: oqty>maxOqty"]];
				if[(o[`dqty] mod i[`lotOqty])<>0;.engine.Purge[o;0;"Invalid dqty lot oqty"]]; 
				if[(all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])] or
				all[((o[`side]<0);(i[`bestBidPrice]>=o[`price]);i[`hasLiquidityBuy])]) and 
				in'[1;o[`execInst]];.engine.Purge[o;0;"Order had execInst of postOnly"]];

				// Account validations
				if[a[`balance]<=0;.engine.Purge[0;"Order account has no balance"]];
				if[a[`available]<=0;.engine.Purge[0;"Order account has insufficient available balance"]];
				if[a[`state]=1;.engine.Purge[0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[0;"Account has been locked for liquidation"]];

				  
				};

.engine.valid.order.CancelOrder:{[]
				  
				c:.engie.logic.order.GetOrder[`oId`cId;o`oId`cId];
				if[null[c];.engine.Purge[o;0;"Order not found"]];
				if[not[c[`state] in ()];.engine.Purge[o;0;"cancel order with terminal state"]];
				o:c^o;

				if[a[`state]=1;.engine.Purge[0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[0;"Account has been locked for liquidation"]];
				  
				};

.engine.valid.order.CancelAll:{[]
				c:.engie.logic.order.GetOrder[`aId`state;(a`aId;0)];
				if[null[c];.engine.Purge[o;0;"No orders found"]];
				if[not[c[`state] in ()];.engine.Purge[o;0;"cancel order with terminal state"]];

				if[a[`state]=1;.engine.Purge[0;"Account has been disabled"]];
				if[a[`state]=2;.engine.Purge[0;"Account has been locked for liquidation"]];
				};
