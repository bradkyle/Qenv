
// TODO smaller ping orders and hidden orders!
// Allow for strategies like bursts on market orders
// constant sniffers etc.
// create iceberg orders etc.
// TODO increasing distribution (exp, log, normal) (bucketed/levelled)
// TODO decreasing distribution (exp, log, normal) (bucketed/levelled)
// TODO flat distribution   (bucketed/levelled)


// Base Event Creation Utilities
// ---------------------------------------------------------------------------------------->
/ `clId`accountId`price`side`otype,
/ `timeinforce`execInst`size`limitprice`stopprice,
/ `reduce`trigger`displayqty
/ (0;0;1000;-1;1;0;0;1;0;0;0;0;1)
.state.adapter.ordCols:`clOid`aId`price`lprice`sprice`trig`tif`okind`oskind`state`oqty`dqty`lqty`einst`reduce;

.state.adapter.cancelOrders : {[t;e]
    `time`kind`datum!(t;`cancelorder;e[.state.adapter.ordCols])
    };

.state.adapter.amendOrders : {[t;e]
    `time`kind`datum!(t;`amendorder;e[.state.adapter.ordCols])
    };

.state.adapter.newOrders : {[t;e]
    `time`kind`datum!(t;`neworder;e[.state.adapter.ordCols])
    };

.state.adapter.createDeposit            : {[t;e]
        // 14; // DEPOSIT
        // `NEW:0
        if[not[count[e]>0];:];
        e:value flip e;
        enlist `time`kind`datum!(t;`deposit;e)
    };

.state.adapter.createWithdraw           : {[t;e]
        // 13; // WITHDRAW
        // `NEW:0
        if[not[count[e]>0];:];
        e:value flip e;
        enlist `time`kind`datum!(t;`withdraw;e)
    };

// Amount distribution logic
// ---------------------------------------------------------------------------------------->
.state.adapter.t1:{1+til[x]}
.state.adapter.t2:{2+til[x]}
.state.adapter.frac:{x%sum[xs]};
.state.adapter.ramfrac:{xbar[z;((1+x)%sum[x+1])*y]};

.state.adapter.amtdist:()!();

// Given a total amount and the number of groups in which to distribute
// the order quantities return the increasing linear distribution of
// qty for the given set of groups in order.
.state.adapter.increasingLinearDistribution                     :{[amt;num;lotsize]
        l:.state.adapter.t1[num];
        .state.adapter.ramfrac[l;amt;lotsize]
    };
.state.adapter.amtdist[`lininc]:.state.adapter.increasingLinearDistribution;

// Given a total amount and the number of groups in which to distribute
// the order quantities return the decreasing linear distribution of
// qty for the given set of groups in order.
.state.adapter.decreasingLinearDistribution                     :{[amt;num;lotsize]
        reverse .state.adapter.increasingLinearDistribution[amt;num;lotsize]
    };
.state.adapter.amtdist[`lindec]:.state.adapter.decreasingLinearDistribution;

// Given a total amount and the number of groups in which to distribute
// the order quantities return the increasing exponential distribution of
// qty for the given set of groups in order.
.state.adapter.increasingExponentialDistribution                :{[amt;num;lotsize]
        l:exp .state.adapter.t1[num];
        .state.adapter.ramfrac[l;amt;lotsize]
    };
.state.adapter.amtdist[`expinc]:.state.adapter.increasingExponentialDistribution;

// Given a total amount and the number of groups in which to distribute
// the order quantities return the decreasing exponential distribution of
// qty for the given set of groups in order.
.state.adapter.decreasingExponentialDistribution                :{[amt;num;lotsize]
        reverse .state.adapter.increasingExponentialDistribution[amt;num;lotsize]
    };
.state.adapter.amtdist[`expdec]:.state.adapter.increasingExponentialDistribution;

// Given a total amount and the number of groups in which to distribute
// the order quantities return the increasing logarithmic distribution of
// qty for the given set of groups in order.
.state.adapter.increasingLogarithmicDistribution                :{[amt;num;lotsize]
        l:log .state.adapter.t2[num];
        .state.adapter.ramfrac[l;amt;lotsize]
    };
.state.adapter.amtdist[`loginc]:.state.adapter.increasingLogarithmicDistribution;

// Given a total amount and the number of groups in which to distribute
// the order quantities return the decreasing logarithmic distribution of
// qty for the given set of groups in order.
.state.adapter.decreasingLogarithmicDistribution                :{[amt;num;lotsize]
        reverse .state.adapter.increasingLogarithmicDistribution[amt;num;lotsize]
    };
.state.adapter.amtdist[`logdec]:.state.adapter.decreasingLogarithmicDistribution;

// Just creates a ~quadratic distribution
// Given a total amount and the number of groups in which to distribute
// the order quantities return the normal distribution of
// qty for the given set of groups in order. TODO do actual normal distribution
.state.adapter.normalDistribution                               :{[amt;num;lotsize]
        l:num#(til[floor[num%2]+1],reverse til[floor[num%2]]);
        .state.adapter.ramfrac[l;amt;lotsize]
    };
.state.adapter.amtdist[`norm]:.state.adapter.normalDistribution;

// Given a total amount and the number of groups in which to distribute
// the order quantities return the flat distribution of
// qty for the given set of groups in order.
.state.adapter.flatDistribution                                 :{[amt;num;lotsize]
        .state.adapter.ramfrac[num#1;amt;lotsize]
    };
.state.adapter.amtdist[`flat]:.state.adapter.flatDistribution;

// Price Distribution Utilities
// ---------------------------------------------------------------------------------------->
// Buckets are a tuple of low and high // todo add midprice?
.state.adapter.pricedist:()!();

// Generates a set of buckets according to
// a uniform distribution of price throughout the
// orderbook .i.e: (0,2),(2,4),(4,6),(6,8) etc.
/  @param mnprice  (Long) The minimum price at which the distribution should start
/  @param ticksize (Long) The minimum interval (can be aggregated) of price allowed 
/  @param num      (Long) The number of levels to generate 
/  @return         (List[Long]) The uniformal price distribution. // TODO change to linears
.state.adapter.uniformalPriceDistribution                      :{[mnprice;bucketsize;ticksize;num;isignum]
        mnprice+((bucketsize*til[num];bucketsize*.state.adapter.t1[num])*(ticksize*isignum)) // Derive the distribution of prices
    };
.state.adapter.pricedist[`uniform]:.state.adapter.uniformalPriceDistribution;

// Generates a set of buckets according to
// a exponential distribution of price throughout the
// orderbook .i.e: (0,1),(1,2),(2,4),(4,8) etc.
/  @param mnprice  (Long) The minimum price at which the distribution should start
/  @param ticksize (Long) The minimum interval (can be aggregated) of price allowed 
/  @param num      (Long) The number of levels to generate 
/  @return         (List[Long]) The exponential price distribution.
.state.adapter.exponentialPriceDistribution                    :{[mnprice;bucketsize;ticksize;num;isignum]
        mnprice+((xexp[.state.adapter.t1[num];bucketsize];xexp[.state.adapter.t2[num];bucketsize])*(ticksize*isignum))
    };
.state.adapter.pricedist[`exp]:.state.adapter.exponentialPriceDistribution;

// Generates a set of buckets according to
// a uniform distribution of price throughout the
// orderbook .i.e: (0,4),(4,8),(8,10),(10,11) etc.
/  @param mnprice  (Long) The minimum price at which the distribution should start
/  @param ticksize (Long) The minimum interval (can be aggregated) of price allowed 
/  @param num      (Long) The number of levels to generate 
/  @return         (List[Long]) The logarithmic price distribution.
.state.adapter.logarithmicPriceDistribution                    :{[mnprice;bucketsize;ticksize;num;isignum]
        mnprice+((xlog[.state.adapter.t1[num];bucketsize];xlog[.state.adapter.t2[num];bucketsize])*(ticksize*isignum))
    };    
.state.adapter.pricedist[`log]:.state.adapter.logarithmicPriceDistribution;

// assumes prices are long
// Generates a set of buckets according to
// a percentage distribution of price throughout the
// orderbook 
/  @param mnprice  (Long) The minimum price at which the distribution should start
/  @param exbkt    (Long) The bucket specific exponent 
/  @param ticksize (Long) The minimum interval (can be aggregated) of price allowed 
/  @param num      (Long) The number of levels to generate 
/  @param isignum  (Long) The side 
/  @param mxfrac   (Long) The maximum fraction
/  @return         (List[Long]) The logarithmic price distribution.
.state.adapter.expPcntPriceDistribution:{[mnprice;exbkt;ticksize;num;isignum;mxfrac]
    if[(mxfrac>1) or (mxfrac<0);'INVALID_MXFRAC];
    if[ticksize<1;'INVALID_TICKSIZE];
    e:xexp[.state.adapter.t1[num];exbkt];
    x:mnprice+(neg[isignum]*((mxfrac*(e%sum[e]))*mnprice));
    distinct (mnprice,floor[x])
    };
.state.adapter.pricedist[`expcnt]:.state.adapter.expPcntPriceDistribution;

// Flattening Utils
// ---------------------------------------------------------------------------------------->

// Creates the set of market orders that will serve to 
// flatten the current active amount of the given inventory.
.state.adapter.createFlattenSideMarketOrders            :{[aId;side]
    ivn:.state.sideOpenInventory[aId;side];
    nside:neg[side];
    :.state.adapter.createMarketOrder[aId;side;ivn`amt];
    };

// Creates the set of market orders that will serve to 
// flatten the current active amount of all inventories for
// a given account.
.state.adapter.createFlattenAllMarketOrders             :{[aId] // TODO LENGTH ERROR !!!!!!!!!!!!!!
    / ivn:.state.allOpenInventory[aId]; // T
    / :$[count[ivn]>0;(.state.adapter.createMarketOrder[aId]'[neg[ivn`side];ivn`amt]);()];
    ()
    };

// Creates the set of limit orders that will serve to 
// flatten the current active amount of the given inventory.
// it will be assumed that the orders will be placed at the
// best price/bucket.
.state.adapter.createFlattenSideLimitOrders             :{[aId;side] // TODO add time
    ivn:.state.allOpenInventory[aId]; // T
    bestprice:0;
    :if[count[ivn]>0;(.state.adapter.createLimitOrder[aId;
        .util.NegIvnSide[ivn`side];
        bestprice;
        ivn`amt])];
    };

// Creates the set of limit orders that will serve to 
// flatten the current active amount of all inventories for
// a given account.
// it will be assumed that the orders will be placed at the
// best price/bucket.
.state.adapter.createFlattenAllLimitOrders              :{[aId] // TODO add time
    ivn:.state.getOpenInventory[aId]; // T
    bestprice:0;
    :if[count[ivn]>0;(.state.adapter.createLimitOrder[aId]'[
        .util.NegIvnSide[ivn`side];
        bestprice;
        ivn`amt])];
    };


// General Order Placement Utilities
// ---------------------------------------------------------------------------------------->

.state.adapter.createEventBatches :{[r;fn;t;bs]
    e:fn[t]'[r]; 
    / :(bs cut e)
    e
    };

.state.adapter.reduceDeltas                                         :{

    rred:raze{[x] // TODO flatten // TODO check time priority TODO add round off to lot size
        x[`tgt`lvlqty]:0^x[`tgt`lvlqty];
        dlt:abs[(-/)x`tgt`lvlqty];
        thresh:sums[x`leaves];
        rp:(thresh-prev[thresh])-(thresh-dlt); 
        x[`rp]:min[dlt,x`leaves]^rp; // TODO change to neg?
        :flip x}'[0!select from dltState where lvlqty>tgt];
      
    };

.state.adapter.increaseDeltas                                       :{
    rinc:raze{[x] // TODO flatten
        x[`tgt`lvlqty]:0^x[`tgt`lvlqty];
        x[`reduce`orderId`leaves`time`oprice`otype`accountId]:(
            enlist'[x`reduce`orderId`leaves`time`oprice`otype`accountId]);
        x[`rp]:abs[(-/)x`tgt`lvlqty];
        :flip x}'[0!select from dltState where lvlqty<tgt];
    rinc[`accountId]:aId;
    rinc[`otype]:1;
    };

// TODO test
// Used for amelierating the difference between a
// target distribution of orders and the current distribution
// of limit orders in the order book.
// TODO better amend logic, clean logic, check max orders, min order size, max order size etc.
// TODO check time priority
// mdd;mad;time;prices;sides;reduces;tgts
.state.adapter.createDeltaEvents                                    :{
    c:a:n:();

    bk:update bkt:til count bktP from `bktP xasc flip[`bktP`side`reduce`tgt!(prices;sides;reduces;tgts)];

    curr:select orderId,leaves,lvlqty:sum leaves,time,oprice:price,accountId by 
    bkt:bk[`bktP] bin price, side, reduce // TODO move logic to state
        from .state.CurrentOrders where accountId=aId;

    dltState:curr uj (`bkt`side`reduce xkey bk);

    // Derive reduce orders
    // ------------------------------------------>
    rred:.state.adapter.reduceDeltas[];

    if[count[rred]>0;[
            c,:(select accountId, orderId from rred where tgt=0);
            $[amd;[
                a,:(select accountId, orderId, oprice, tgt from rred where (tgt<>0), tgt<=leaves);    
            ];[
                c,:(select accountId, orderId from rred where (tgt<>0), tgt<=leaves);
                n,:(select accountId, price:bktPmid, size:tgt, reduce from rred where (tgt<>0), tgt<=leaves); // TODO if too many are open
        ]]]];

    // Derive increase orders
    // ------------------------------------------>
    rinc:.state.adapter.increaseDeltas[];

    // TODO if too many are open
    if[count[rinc]>0;n,:(select aId:accountId, price:bktPmid, oqty:tgt, reduce from rinc where tgt>0)];

    // Compose Events 
    // ------------------------------------------>
    // TODO post processing
    // TODO rate limiting of inter batch requests
    e:(); // TODO randomize batch size?
        
    // todo group into batches (time offset of 0)
    if[count[c]>0;e,:.state.adapter.createEventBatches[c;.state.adapter.cancelOrders;time;10]]; 

    // todo group into batches (time offset of ~2)
    if[amd and (count[a]>0);e,:.state.adapter.createEventBatches[a;.state.adapter.amendOrders;time;10]]; 

    // todo group into batches (time offset of ~2)
    if[count[n]>0;e,:.state.adapter.createEventBatches[n;.state.adapter.newOrders;time;10]]; 
    e
  };

// TODO testing
// Derives the delta between the current outstanding/leaves
// order quantity at a given price level and the static target
// "desired" order quantity at that price level and generates
// the set of amend/new/cancel order requests that need to take
// place in order to ameliarate the difference.
// Bucketing order qty's prevents needless order update requests
// that inevitably occur in volatile markets. mside=major side
// amd;aId;time;num;bkttyp;mside;dsttyp;amts;reduces;bktsize;ticksize;mxfrac
.state.adapter.createBucketLimitOrdersDeltaDistribution             :{
        bmprice:.state.bestSidePrice[mside];
        boprice:.state.bestSidePrice[neg mside];

        // Derive price distribution
        prc:();
        if[(count[amts]>0) and bmprice;prc,:.state.adapter.expPcntPriceDistribution[bmprice;bktsize;ticksize;num-1;mside;mxfrac]];
        if[(count[amts]>1) and boprice;prc,:.state.adapter.expPcntPriceDistribution[boprice;bktsize;ticksize;num-1;neg mside;mxfrac]];
        show prc;

        // Derive size distribution
        dsts:();
        if[(count[amts]>0) and bmprice;dsts,:.state.adapter.amtdist[first dsttyp][first amts;num;mside]];
        if[(count[amts]>1) and boprice;dsts,:.state.adapter.amtdist[dsttyp[1]][amts[1];num;neg[mside]]];

        red:sid:();
        if[(count[amts]>0) and bmprice;[red,:(num#first[reduces]);sid,:(num#mside)]];
        if[(count[amts]>1) and boprice;[red,:(num#reduces[1]);sid,:(num#neg[mside])]];

        // create delta events from target
        $[count[dsts]>0;:.state.adapter.createDeltaEvents[amd;aId;time;prc;sid;red;dsts];:()];
    };
 
 
// Macro Action Utilities
// ---------------------------------------------------------------------------------------->
// Macro actions are useful when it is assumed that the agent has an effect on what
// the market percieves. .i.e. if there is 1000 market sell orders taking place
// this might indicate others to sell as well perhaps playing into an iceberg limit
// order. This behavior is obviousely complex and as such should be relegated to later
// stages of development.
 
.state.adapter.constructMacroMarketFn                  :{[aId;time;dur;side;num;amt;reduce]
    / ts:{x + (y * z)}[.z.z;(`timespan$(0D00:01:00.000000000)%10)]'[til 10]; 
    ts:{x + (y * z)}[time;dur%num]'[til num];
    mo:num#enlist[`accountId`side`amt`reduce!(aId;side;amt%num;reduce)]; // TODO make cleaner
    .state.adapter.newOrders . (time;mo)
    };


.state.adapter.marketOrderWrapper                      :{[aId;time;side;amt;reduce]
    mo:enlist`accountId`side`amt`reduce!(aId;side;amt;reduce); // TODO make cleaner  
    .state.adapter.newOrders[time;mo]
    };
 
// Action Adapter Mapping // TODO convert to batch, descriptions
// ---------------------------------------------------------------------------------------->

/ kind=0;.state.adapter.increasingLinearDistribution[amt;num;lotsize];
/ kind=1;.state.adapter.decreasingLinearDistribution[amt;num;lotsize];
/ kind=4;.state.adapter.increasingExponentialDistribution[amt;num;lotsize];
/ kind=5;.state.adapter.decreasingExponentialDistribution[amt;num;lotsize];
/ kind=6;.state.adapter.increasingLogarithmicDistribution[amt;num;lotsize];
/ kind=7;.state.adapter.decreasingLogarithmicDistribution[amt;num;lotsize]; // TODO prob
/ kind=8;.state.adapter.normalDistribution[amt;num;lotsize];
/ kind=9;.state.adapter.flatDistribution[amt;num;lotsize];

.state.adapter.deriveTradingMargin    :{[aId;useFraction]
    a:.state.CurrentAccount@aId; // TODO move logic to state
    0^((a[`balance]*useFraction) - ((-/)a[`balance`available]))
    };

// TODO leverage update
// TODO check reduce and side is functional i.e. reduce side=side
// HEDGED PATHFINDER                // TODO more action permutations. reverse,combo,macro etc
.state.adapter.HedgedPathFinder       :{[encouragement;time;aId;a]
        events:();
        numBuckets:10;
        useFraction:0.5;
        dur:`timespan$(0D00:01:00.000000000);
        .state.adapter.penalty:0; 

        // amd;aId;num;bucketkind;amts;distkinds
        // Creates a set of post only market orders at given levels.
        // amd of zero entails that amend orders will be used.
        limitfn:.state.adapter.createBucketLimitOrdersDeltaDistribution[
                (0b;aId;time;numBuckets;(1;1))]; 

        // Creates a single market order
        marketfn:.state.adapter.marketOrderWrapper[aId;time];
        
        // Creates a set of temporially distributed market orders
        macromarketfn:.state.adapter.constructMacroMarketFn[aId;time;dur];

        // Creates the set of events that will serve to flatten
        // the current outstanding positions of the agent
        flatfn:.state.adapter.createFlattenAllMarketOrders;

        // get short and long ivn 
        samt:.state.getShortAmt[aId];
        lamt:.state.getLongAmt[aId];
        tdamt:.state.adapter.deriveTradingMargin[aId;useFraction];

        // TODO derive hedged logic
        events,:$[a=0;[.state.adapter.penalty+:encouragement; ()];
          a=1;   marketfn[1;lamt;1b];                   // market open long;
          a=2;   macromarketfn[1;10;tdamt;0b];          // macro market open long;
          a=3;   limitfn[1;(`expinc;`expinc);(tdamt;samt);01b];     // aggressive open long close short;
          a=4;   limitfn[1;(`lininc;`lininc);(tdamt;samt);01b];     // conservative open long close short;
          a=5;   limitfn[1;`expinc;tdamt;0b];                 // aggressive open long;
          a=6;   limitfn[1;`lininc;tdamt;0b];                 // conservative open long;
          a=7;   limitfn[1;`lininc;lamt;1b];                  // conservative close long;
          a=8;   limitfn[1;`expinc;lamt;1b];                  // aggressive close long;
          a=9;   macromarketfn[1;10;lamt;1b];           // market close long;
          a=10;  marketfn[1;lamt;1b];                   // market close long;
          a=11;  flatfn[aId];                     // flatten position with market orders
          a=12;  marketfn[-1;samt;1b];                  // market close short;
          a=13;  macromarketfn[-1;10;lamt;1b];          // market close short;
          a=14;  limitfn[-1;`expinc;samt;1b];                 // aggressive close short;
          a=15;  limitfn[-1;`lininc;samt;1b];                 // conservative close short;
          a=16;  limitfn[-1;`lininc;tdamt;0b];                // conservative open short;
          a=17;  limitfn[-1;`expinc;tdamt;0b];                // aggressive open short;
          a=18;  limitfn[-1;(`lindec;`lindec);(tdamt;lamt);01b];    // conservative open short close long;
          a=19;  limitfn[-1;(`expinc;`expinc);(tdamt;lamt);01b];    // aggressive open short close long;
          a=20;  macromarketfn[-1;10;tdamt;0b];         // macro market open short; 
          a=21;  marketfn[-1;samt;1b];                  // market open short; 
          'INVALID_ACTION];
        events
    };

 
// Main Adapt Function
// ---------------------------------------------------------------------------------------->

// TODO error handling
// Converts a scalar action representing a target state
// to which the agent will effect a transition into
// its representative amalgamation of events by way
// of an adapter. // TODO pair with state account repr
.state.adapter.Adapt :{[encouragement; time; actions]
    :raze{.Q.trp[.state.adapter.HedgedPathFinder[0.0;x;y];z;{show["error: ",x,"\nbacktrace:\n",.Q.sbt y]}]}[time]'[actions[;0];actions[;1]];
    };

