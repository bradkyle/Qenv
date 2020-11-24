
.instrument.Funding:{
	  iv:?[`inventory;enlist(<;`amt;0);enlist(`accountId)!enlist(`accountId);()];

		// TODO make simpler
    f:0!select 
    amtInMarket: sum[amt],
    fundingCost:((min[(x[`fundingRate];0)]*(amt*isignum)) + (max[(x[`fundingRate];0)]*(amt*isignum)))
        by accountId from iv;  
		
		a:?[];
		a[`imr]:0;
		a[`mmr]:0;
		a[`avail]:()

			};

.instrument.MarkPrice:{
	  iv:?[`inventory;enlist(<;`amt;0);enlist(`accountId)!enlist(`accountId);()];

		// TODO make simpler
    upl:.engine.logic.contract.UnrealizedPnl[
            i[`contractType];
            i[`markPrice];
            i[`faceValue];
            i[`sizeMultiplier]];

    f:0!select 
        amtInMarket: sum[amt],
        unrealizedPnl: upl'[amt;isignum;avgPrice] 
            from iv;  
		
		// TODO loss due to orders
		a:?[];
		a[`imr]:0;
		a[`mmr]:0;
		a[`avail]:()

	};

.instrument.Settlement:{
	iv:?[`inventory;enlist(<;`amt;0);0b;()];
	a:?[`account;enlist(in;`aId;iv[`ivId]);0b;()];
	a[`mrg]+:iv[`rpnl];
	iv[`rpnl]:0;
	};

.instrument.PriceLimit:{
	![`instrument;enlist();0b;`plmts`plmtb!x[`plmts`plmtb]]
	};
