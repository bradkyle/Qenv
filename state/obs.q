
// Feature Sets
// =====================================================================================================>

.state.obs.PublicFeatureSet   :{[fn;size;step]
    x:size#0f;
    :fn[]
    };

// Expects a table to be return that has
// accountId as the index 
.state.obs.PrivateFeatureSet  :{[fn;size;aIds;step] // size is features per account row
    x:(size*count[aIds])#0f;
    :fn[aIds]
    };

.state.obs.JoinFeatureV        :{[pfea;xfea]
    fea:0!((uj) over xfea[;0]);
    n:sum pfea[;1];
    fea[til n]:raze[pfea[;0]];
    :fea;
    };

// Pathfinder Feature Sets
// =====================================================================================================>

// Account Feature Sets
// ----------------------------------------->

.state.obs.fea.account        :.state.obs.PrivateFeatureSet[{
    c:`balance`available`frozen`maintMargin;
    acc:0^(?[.state.CurrentAccount;enlist(in;`accountId;x);enlist[`accountId]!enlist[`accountId];(c!c)]);
    if[count[acc]<count[x];acc,:{((`accountId,x)!(y,(4#0)))}[c]'[x where not[x in key[acc][`accountId]]]];
    :acc;
    };4];


// Inventory Feature Sets
// ----------------------------------------->

// TODO derive approx liquidation price  
.state.obs.fea.inventory      :.state.obs.PrivateFeatureSet[{
    c:`amt`realizedPnl`avgPrice`unrealizedPnl;
    crs:cross[x;-1 1];
    invn:?[`.state.CurrentInventory;enlist(in;`accountId;x);`accountId`side!`accountId`side;c!c];
    if[count[invn]<count[x*2];invn,:.bam.inv:{((`accountId`side,x)!(y,(4#0)))}[c]'[crs where not[crs in key[invn][`accountId`side]]]];
    if[count[invn]>0;invn:.util.Piv[0!invn;`accountId;`side;`amt`realizedPnl`unrealizedPnl]];
    :invn;
    };6];   


// Order Feature Sets
// ----------------------------------------->

// TODO derivation by accountId // TODO testing
// TODO add more features        
.state.obs.fea.order          :.state.obs.PrivateFeatureSet[{[aIds]
    // Bucketed limit order features
    bap:.state.bestAskPrice[];
    bbp:.state.bestBidPrice[];
    ticksize:0.1;
    bucketsize:2;
    num:10;
    ap:.state.adapter.exponentialPriceDistribution[bap;bucketsize;ticksize;num;-1];
    bp:.state.adapter.exponentialPriceDistribution[bbp;bucketsize;ticksize;num;1];
    aord:.state.limitLeavesByBucket[aIds;ap;-1]; // price descending asks // todo change to batch!
    bord:.state.limitLeavesByBucket[aIds;bp;1]; // price ascending bids 

    f:`accountId`bkt`side`reduce`price`mprice`xprice`leaves!();
    f[`accountId]:44#0;
    f[`bkt]:44#til 11;
    f[`reduce]:44#((22#0b),(22#1b));
    f[`side]:44#((11#-1),(11#1));
    f[`price]:44#asc[distinct[raze ap]]; // TODO add bp
    fea:`accountId`bkt`side`reduce xkey flip[.util.Filt[`accountId`bkt`side`reduce`price;f]];
    fea:0^((uj) over (fea;aord;bord));
    fea:.util.Piv[0!fea;`accountId;`bkt`side`reduce;`leaves];
    :fea
    };44];

// Depth Feature Sets
// ----------------------------------------->

.state.obs.fea.depth         :.state.obs.PublicFeatureSet[{
    // Derives the set of features that pertain to the current bucketed prices
    bap:.state.bestAskPrice[];
    bbp:.state.bestBidPrice[];
    ticksize:0.1;
    bucketsize:2;
    num:10;
    ap:.state.adapter.exponentialPriceDistribution[bap;bucketsize;ticksize;num;-1];
    bp:.state.adapter.exponentialPriceDistribution[bbp;bucketsize;ticksize;num;1];
    asks:.state.bucketedDepth[ap;-1]; // price descending asks // todo
    bids:.state.bucketedDepth[bp;1]; // price ascending bids
    f:`bkt`side`price`mprice`xprice`size!();
    f[`bkt]:22#til 11;
    f[`side]:22#((11#-1),(11#1));
    f[`price]:22#asc[distinct[raze ap]]; // TODO add bp
    fea:`bkt`side xkey flip[.util.Filt[`bkt`side`price;f]];  
    fea:0!(0^((uj) over (fea;asks;bids)));
    :(fea where fea[`bkt]<>-1)`size; // TODO add better features, filter where not in buckets
    / bestask:min asks;
    / bestbid:max bids;
    / asksizes:asks`size;
    / askprices:asks`price;
    / sumasksizes:sum asksizes;
    / bidsizes:bids`size;
    / bidprices:bids`price;
    / sumbidsizes:sum bidsizes;
    / bestbidsize:bestbid`size;
    / bestasksize:bestask`size;
    / bestaskprice:bestask`price;
    / bestbidprice:bestbid`price;
    / midprice:avg[bestaskprice,bestbidprice];
    / spread:(-/)(bestaskprice,bestbidprice);
    / bidsizefracs:bidsizes%sumbidsizes;
    / asksizefracs:asksizes%sumasksizes;
    / depthfrac:sumbidsizes%sumasksizes;
    / :raze[(
    /     bidsizefracs, // num
    /     asksizefracs, // num
    /     depthfrac, // num
    /     spread, // 1
    /     midprice, // 1
    /     bestaskprice, // 1
    /     bestbidprice, // 1
    /     bestasksize, // 1
    /     bestbidsize // 1
    / )];
    };24];

// Trade Feature Sets
// -----------------------------------------> // TODO better modularity

// TODO add more ? 
.state.obs.fea.trade         :.state.obs.PublicFeatureSet[{
    buys:select[100;>time] price, size from .state.TradeEventHistory where side=1, time>(max[time]-`minute$5); // todo remove
    sells:select[100;>time] price, size from .state.TradeEventHistory where side=-1, time>(max[time]-`minute$5); // todo remove
    :raze[(
        count[buys];
        count[sells];
        avg[5#buys`price];
        avg[15#buys`price];
        avg[30#buys`price];
        avg[buys`price];
        max[5#buys`price];
        max[15#buys`price];
        max[30#buys`price];
        max[buys`price];
        min[5#buys`price];
        min[15#buys`price];
        min[30#buys`price];
        min[buys`price];
        last[buys`price];
        avg[5#sells`price];
        avg[15#sells`price];
        avg[30#sells`price];
        avg[sells`price];
        max[5#sells`price];
        max[15#sells`price];
        max[30#sells`price];
        max[sells`price];
        min[5#sells`price];
        min[15#sells`price];
        min[30#sells`price];
        min[sells`price];
        last[sells`price];
        avg[5#buys`size];
        avg[15#buys`size];
        avg[30#buys`size];
        avg[buys`size];
        max[5#buys`size];
        max[15#buys`size];
        max[30#buys`size];
        max[buys`size];
        min[5#buys`size];
        min[15#buys`size];
        min[30#buys`size];
        min[buys`size];
        last[buys`size];
        sum[buys`size]; 
        avg[5#sells`size];
        avg[15#sells`size];
        avg[30#sells`size];
        avg[sells`size];
        max[5#sells`size];
        max[15#sells`size];
        max[30#sells`size];
        max[sells`size];
        min[5#sells`size];
        min[15#sells`size];
        min[30#sells`size];
        min[sells`size];
        last[sells`size];
        sum[sells`size]
    )];
    };56];


// Mark Feature Sets
// ----------------------------------------->

.state.obs.fea.mark          :.state.obs.PublicFeatureSet[{
    // Mark Price Features
    markprice:((last[.state.MarkEventHistory]`markprice) | 0f);
    lastprice:((last[.state.TradeEventHistory]`price) | 0f);
    basis:lastprice-markprice;
    raze[(
        markprice;
        basis
    )]
    };2];

// Funding Feature Sets
// ----------------------------------------->

.state.obs.fea.funding      :.state.obs.PublicFeatureSet[{
    funding:last[.state.FundingEventHistory];
    countdown:.util.TimeDiffMin[funding`fundingtime;.state.watermark]; // TODO get delta in time
    .state.obs.test.funding:funding;
    raze[(
        (funding[`fundingrate]  | 0f);
        (countdown | 0f)
    )]
    };2];


// Main Derive Function
// =====================================================================================================>
// =====================================================================================================>
  
// TODO join fea set
.state.obs.derive: {[step;aIds] // TODO make faster? // TODO fill values with blanks (0f), make faster
    pfea:( // public feature vector
    .state.obs.fea.depth[step],
    .state.obs.fea.trade[step],
    .state.obs.fea.mark[step],
    .state.obs.fea.funding[step]
    );

    xfea:(); // private feature vectors
    xfea:.state.obs.fea.account[aIds;step];
    xfea:xfea uj .state.obs.fea.inventory[aIds;step];
    xfea:xfea uj .state.obs.fea.order[aIds;step];
    xfea:0!({raze'[x]}'[xfea]);
    xfea[`$string'[til count[pfea]]]:pfea;
    xfea[`step]:step;
    xfea
    };
 
// GetObs derives a feature vector from the current state which it
// then fills and removes inf etc from.
// it then checks if the state Feature Buffer has been initialized
// with the respective feature columns, or else it initializes it.
// when the feature buffer is set up it will proceed to upsert the 
// features into the Feature buffer. It then calls .ml.minmax scaler
// to normalize the given features (FOR EACH ACCOUNT) such that the
// observations can be passed back to the agents etc.
/  @param step     (Long) The current environment step
/  @param aIds     (Long) The accountIds for which to get observations.
/  @return         (List) The normalized observation vector for each 
/                         account
/ cols[fea] except `accountId // TODO make more efficient, move to C etc
.state.obs.GetObs :{[step;lookback;aIds]
    show aIds;
    .bam.aIds:aIds;
    fea:.state.obs.derive[step;aIds];
    .bam.fea:fea;
    if[((step=0) or (count[.state.FeatureBuffer]<count[aIds]));[
            // If the env is on the first step then generate 
            // a lookback buffer (TODO with decreasing noise?)
            // backwards (randomized fill of buffer)
            {x[`step]-:y;x:`accountId`step xkey x;x:0f^`float$(x);.state.FeatureBuffer,:{x+:x*rand 0.001;x}x}[fea]'[til[lookback]];
    ]];
    fea:`accountId`step xkey fea;
    fea:0f^`float$(fea);
    .state.FeatureBuffer,:fea;
    .bam.fb:.state.FeatureBuffer;
   / :last'[flip'[.ml.minmaxscaler'[{raze'[x]}'[`accountId xgroup (enlist[`step] _ (`step xasc 0!.state.FeatureBuffer))]]]]
    :last'[flip'[{raze'[x]}'[`accountId xgroup (enlist[`step] _ (`step xasc 0!.state.FeatureBuffer))]]]
    };


