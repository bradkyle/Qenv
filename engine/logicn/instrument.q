
.instrument.Funding:{
		iv:?[];

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
		iv:?[];

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
	a:?[];
	iv:?[];

				};

.instrument.PriceLimit:{
	.instrument,:()
				};
