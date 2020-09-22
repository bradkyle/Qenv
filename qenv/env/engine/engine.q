
// TODO rate limits
// TODO random placement of hidden/iceberg orders 
// TODO random noise added to liquidation.
// TODO move validation into engine
// TODO add slight noise to trades and orderbook updates
// TODO convert/multiply in engine
.engine.WaterMark:0n;

// TODO dropped response etc.
/*******************************************************
// TODO deleverage probability
// represents the offset in milliseconds
// check if flip is right
// TODO rate limit, return order and time, make sure ingress events in order
// TODO supported events types
// TODO rate limits etc.
.engine.Engine:(
    [engineId                   :`long$()];
    instrumentId                : `.instrument.Instrument();
    isConfigured                : `boolean$();
    loadSheddingProbability     : `float$();
    placeOrderOffsetMu          : `float$(); 
    placeOrderOffsetSigma       : `float$();
    placeBatchOffsetMu          : `float$();
    placeBatchOffsetSigma       : `float$();
    cancelOrderOffsetMu         : `float$(); 
    cancelOrderOffsetSigma      : `float$(); 
    cancelOrderBatchOffsetMu    : `float$(); 
    cancelOrderBatchOffsetSigma : `float$(); 
    cancelAllOrdersOffsetMu     : `long$(); 
    cancelAllOrdersOffsetSigma  : `long$(); 
    amendOrderOffsetMu          : `long$(); 
    amendBatchOffsetSigma       : `long$();
    commonOffset                : `long$(); 
    eventCount                  : `long$()
    );

.engine.Requests        :(

    );

.engine.Purge           :{

    };

.engine.PurgeNot        :{

    };

.engine.PurgeConvert    :{

    };

// Because the Environment for all practical purposes
// only uses one instrument, this function returns the
// primary instance of Instrument for which all actions
// relate and are configured by.
/  @return (Instrument) The primary instance of instrument
.engine.getInstrument   :{
    $[0 in key[.instrument.Instrument];:.instrument.Instrument@0;'UNSET_PRIMARY_INSTRUMENT]; // TODO check
    };

// TODO get account, get order etc.
// TODO error handling

// TODO add randomization based upon current probability 
// of order being placed due to overload etc.
// TODO check within max and min orders, run validation etc.

/ Engine specific logic
/ -------------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessDepthUpdateEvents :{[e]

    e:.engine.Purge[e;count'[e`datum]<>4;0;"Invalid schema"];

    e:`side`price`nqty`nhqty!events;
    e[`instrumentId]:`.instrument.Instrument!0;    

    // TODO processing
    
    if[count[e]>0;.order.ProcessDepth . e];

    };

// Process New Iceberg events?

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessNewTradeEvents :{[e]
    // This function assumes that a trade was derived from data and not an agent

    e:.engine.Purge[e;count'[e`datum]<>2;0;"Invalid schema"];

    e:`accountId`side`fillqty`reduce!e`datum;

    e[`instrumentId]:`.instrument.Instrument!0;    

    if[count[e]>0;.order.ProcessTrade . e];
    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessMarkUpdateEvents :{[e]

    e:.engine.Purge[e;count'[e`datum]<>2;0;"Invalid schema"];

    e:`markPrice`basis!e;

    e[`instrumentId]:`.instrument.Instrument!0;

    if[count[e]>0;[
            // Essentially find the deltas in the mark price provided
            // and derive a change in the unrealized pnl, triggering
            // liquidations where neccessary
            .account.UpdateMarkPrice . e;

            // Where appliccable trigger stop orders 
            // TODO add a delay in placement of orders
            .order.UpdateMarkPrice . e;

            // Inspect the account tables for any insolvent accounts.
            .liquidation.InspectAccounts ;
            
        ]];

    
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessSettlementEvents :{[e]

    e:.engine.Purge[e;count'[e`datum]<>3;0;"Invalid schema"];

    e:`settlement; // TODO
    e[`instrumentId]:`.instrument.Instrument!0;
    

    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessFundingEvents :{[e]

    e:.engine.Purge[e;count'[e`datum]<>3;0;"Invalid schema"];

    e:`fundingRate`nextFundingRate`nextFundingtime!e;

    e[`instrumentId]:`.instrument.Instrument!0;

    if[count[e]>0;[
        .account.ApplyFunding . e;
        .instrument.UpdateFunding . e;
        ]];    
    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessNewPriceLimitEvents :{[e] // 
    e:.engine.Purge[e;count'[e`datum]<>2;0;"Invalid schema"];
    // TODO type checks
    // TODO just derive last price limits from e
    e:`upricelimit`lpricelimit!e;

    e[`instrumentId]:`.instrument.Instrument!0;

    if[count[e]>0;.instrument.UpdateMarkPrice . e];    
    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessNewOrderEvents :{[e] // Requires accountId
    / accountIds:key .account.Account; 
    // TODO check all count=12
    // TODO do validation here
    // $[any[in[e[`orderId`clOrdId];key[.order.Order]`orderId]];
    
    // check max batch order amends
     // Filter e where col count<>12
    
    e:.engine.Purge[e;count'[e`datum]<>13;0;"Invalid schema"];

    // In live version would get instrument here
    // filter e by type
    // TODO increment request counts!

    // TODO add execInst
    e:(`accountId`price`side`otype,
    `timeinforce`execInst`size`limitprice`stopprice,
    `reduce`trigger`displayqty)!raze'[e`datum]; // TODO remove raze

    e[`instrumentId]:`.instrument.Instrument!0;
    i:e[`instrumentId];
    // TODO type conversions
    / e:.engine.PurgeConvert[e;e[`otype];7h;0;"Invalid otype"];
    / e:.engine.PurgeConvert[e;e[`side];7h;0;"Invalid otype"];
    / e:.engine.PurgeConvert[e;e[`side];7h;0;"Invalid otype"];

     // Routine validation
    e:.engine.PurgeNot[e;e[`otype] in .pipe.common.ORDERKIND;0;"Invalid otype"];
    e:.engine.PurgeNot[e;e[`side]  in .pipe.common.ORDERSIDE;0;"Invalid side"];
    e:.engine.PurgeNot[e;e[`timeinforce]  in .pipe.common.TIMEINFORCE;0;"Invalid timeinforce"]; // TOOD fill

    // Instrument specific validation        
    e:.engine.PurgeNot[e;e[`price] < i[`minPrice];0;"Invalid price: price<minPrice"];
    e:.engine.PurgeNot[e;e[`price] > i[`maxPrice;0;"Invalid price: price>maxPrice"];
    e:.engine.PurgeNot[e;e[`size] < i[`minSize];0;"Invalid size: size<minSize"]; 
    e:.engine.PurgeNot[e;e[`size] > i[`maxSize];0;"Invalid size: size>maxSize"];
    e:.engine.PurgeNot[e;(e[`price] mod i[`tickSize])<>0;0;"Invalid tickSize"];
    e:.engine.PurgeNot[e;(e[`size] mod i[`lotSize])<>0;0;"Invalid lotSize"];

    // fill null then validate
    e[`limitprice]:0^e[`limitprice];
    e[`stopprice]:0^e[`stopprice];
    e[`trigger]:0^e[`trigger];
    e[`timeinforce]:0^e[`timeinforce];
    e[`reduce]:0b^e[`reduce];
    e[`displayqty]:e[`size]^e[`displayqty];
    e[`execInst]:enlist[0]^e[`execInst];
    
    e:.engine.PurgeNot[e;e[`displayqty] < i[`minSize];0;"Invalid displayqty: size<minSize"];
    e:.engine.PurgeNot[e;e[`displayqty] > i[`maxSize];0;"Invalid displayqty: size>maxSize"];
    e:.engine.PurgeNot[e;(e[`displayqty] mod i[`lotSize])<>0;0;"Invalid displayqty lot size"];
    e:.engine.PurgeNot[e;all[e[`execInst] in .pipe.common.EXECINST];0;"Invalid tickSize"];

    // TODO all in .common.ExecInst
    // TODO 1 in execIns
    e:.engine.PurgeNot[e;all[e[`execInst] in .pipe.common.EXECINST];0;"Invalid execInst"];

    // Run purge operations on market orders
    e:.engine.NestedPurgeNot[e;e[`otype] = 0]; 

    // Run purge operation on stop limit orders
    e:.engine.NestedPurgeNot[e;e[`otype]  in (2 3)]; 

    // Purge all orders that have execInst of post only and would cross bid ask spread
    e:.engine.PurgeNot[e;(all[(e[`side]<0),(i[`bestBidPrice]>=e[`price]),i[`hasLiquidityBuy]] or
        all[(e[`side]>0),(i[`bestAskPrice]<=e[`price]),i[`hasLiquiditySell]]) and (1 in e[`execInst]);
        0;"Order had execInst of postOnly"];

    e:.engine.PurgeNot[e;e[`accountId] in key[.account.Account];0;"Invalid account"];

    // TODO convert order accountId to mapping
    e[`accountId]:`.account.Account!e[`accountId];
    a:e[`accountId];

    e:.engine.Purge[e;a[`balance]<=0;0;"Order account has no balance"];
    e:.engine.Purge[e;a[`available]<=0;0;"Order account has insufficient available balance"];
    e:.engine.Purge[e;a[`state]=1;0;"Account has been disabled"];
    e:.engine.Purge[e;a[`state]=2;0;"Account has been locked for liquidation"];

    // Derive the sum of the margin that will be required
    // for each order to be filled and filter out the orders
    // for which their respective account has insufficient 
    // balance.
    premium:(e[`side]*(i[`markprice]-e[`price]));

    // TODO derive better
    // derive the instantaneous loss that will be incurred for each order
    // placement and thereafter derive the cumulative loss for each order
    // filter out orders that attribute to insufficient balance where neccessary
    a[`openBuyLoss]:(min[0,(i[`markPrice]*a[`openBuyQty])-a[`openBuyValue]] | 0); // TODO convert to long
    a[`openSellLoss]:(min[0,(i[`markPrice]*a[`openSellQty])-a[`openSellValue]] |0); // TODO convert to long
    a[`openLoss]:(sum[a`openSellLoss`openBuyLoss] | 0); // TODO convert to long
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0); // TODO convert to long

    a[`available]<a[`initMarginReq] // filter orders where resultant available is less than initMarginReq

    // Create probabalistic dropout of orders according to some loadshedding coefficient.

    // new order order fields 
    // (`accountId`clOid`price`side`otype`timeinforce`size`limitprice`stopprice`reduce`trigger`displayqty) = 12 fields
    if[count[o]>0;.order.NewOrder . e];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessAmendOrderEvents :{[e] // Requires accountId
    // check max batch order amends
     // Filter e where col count<>12
    
    e:.engine.Purge[e;count'[e`datum]<>13;0;"Invalid schema"];

    // In live version would get instrument here
    // filter e by type
    // TODO increment request counts!

    // TODO add execInst
    e:(`orderId`clId`accountId`price`side`otype,
    `timeinforce`execInst`leaves`limitprice`stopprice,
    `reduce`trigger`displayqty)!raze'[e`datum]; // TODO remove raze

    e[`instrumentId]:`.instrument.Instrument!0;
    i:e[`instrumentId];
    // TODO type conversions
    / e:.engine.PurgeConvert[e;e[`otype];7h;0;"Invalid otype"];
    / e:.engine.PurgeConvert[e;e[`side];7h;0;"Invalid otype"];
    / e:.engine.PurgeConvert[e;e[`side];7h;0;"Invalid otype"];

    // TODO get orderId with clId

     // Routine validation
    e:.engine.PurgeNot[e;e[`orderId] in key[.order.Order];0;"Invalid orderId"];
    
    e[`orderId]:`.order.Order!e[`orderId];

    // TODO fill current orders with new order events
    e:

    e:.engine.PurgeNot[e;e[`otype] in .pipe.common.ORDERKIND;0;"Invalid otype"];
    e:.engine.PurgeNot[e;e[`side]  in .pipe.common.ORDERSIDE;0;"Invalid side"];
    e:.engine.PurgeNot[e;e[`timeinforce]  in .pipe.common.TIMEINFORCE;0;"Invalid timeinforce"]; // TOOD fill

    // Instrument specific validation        
    e:.engine.PurgeNot[e;e[`price] < i[`minPrice];0;"Invalid price: price<minPrice"];
    e:.engine.PurgeNot[e;e[`price] > i[`maxPrice;0;"Invalid price: price>maxPrice"];
    e:.engine.PurgeNot[e;e[`size] < i[`minSize];0;"Invalid size: size<minSize"]; 
    e:.engine.PurgeNot[e;e[`size] > i[`maxSize];0;"Invalid size: size>maxSize"];
    e:.engine.PurgeNot[e;(e[`price] mod i[`tickSize])<>0;0;"Invalid tickSize"];
    e:.engine.PurgeNot[e;(e[`size] mod i[`lotSize])<>0;0;"Invalid lotSize"];

    // fill null then validate
    e[`limitprice]:0^e[`limitprice];
    e[`stopprice]:0^e[`stopprice];
    e[`trigger]:0^e[`trigger];
    e[`timeinforce]:0^e[`timeinforce];
    e[`reduce]:0b^e[`reduce];
    e[`displayqty]:e[`leaves]^e[`displayqty];
    e[`execInst]:enlist[0]^e[`execInst];
    
    e:.engine.PurgeNot[e;e[`displayqty] < i[`minSize];0;"Invalid displayqty: size<minSize"];
    e:.engine.PurgeNot[e;e[`displayqty] > i[`maxSize];0;"Invalid displayqty: size>maxSize"];
    e:.engine.PurgeNot[e;(e[`displayqty] mod i[`lotSize])<>0;0;"Invalid displayqty lot size"];
    e:.engine.PurgeNot[e;all[e[`execInst] in .pipe.common.EXECINST];0;"Invalid tickSize"];

    // TODO all in .common.ExecInst
    // TODO 1 in execIns
    e:.engine.PurgeNot[e;all[e[`execInst] in .pipe.common.EXECINST];0;"Invalid execInst"];

    // Run purge operations on market orders
    e:.engine.NestedPurgeNot[e;e[`otype] = 0]; 

    // Run purge operation on stop limit orders
    e:.engine.NestedPurgeNot[e;e[`otype]  in (2 3)]; 

    // Purge all orders that have execInst of post only and would cross bid ask spread
    e:.engine.PurgeNot[e;(all[(e[`side]<0),(i[`bestBidPrice]>=e[`price]),i[`hasLiquidityBuy]] or
        all[(e[`side]>0),(i[`bestAskPrice]<=e[`price]),i[`hasLiquiditySell]]) and (1 in e[`execInst]);
        0;"Order had execInst of postOnly"];

    e:.engine.PurgeNot[e;e[`accountId] in key[.account.Account];0;"Invalid account"];

    // TODO convert order accountId to mapping
    e[`accountId]:`.account.Account!e[`accountId];
    a:e[`accountId];

    e:.engine.Purge[e;a[`balance]<=0;0;"Order account has no balance"];
    e:.engine.Purge[e;a[`available]<=0;0;"Order account has insufficient available balance"];
    e:.engine.Purge[e;a[`state]=1;0;"Account has been disabled"];
    e:.engine.Purge[e;a[`state]=2;0;"Account has been locked for liquidation"];

    // Derive the sum of the margin that will be required
    // for each order to be filled and filter out the orders
    // for which their respective account has insufficient 
    // balance.
    premium:(e[`side]*(i[`markprice]-e[`price]));

    // TODO derive better
    // derive the instantaneous loss that will be incurred for each order
    // placement and thereafter derive the cumulative loss for each order
    // filter out orders that attribute to insufficient balance where neccessary
    a[`openBuyLoss]:(min[0,(i[`markPrice]*a[`openBuyQty])-a[`openBuyValue]] | 0); // TODO convert to long
    a[`openSellLoss]:(min[0,(i[`markPrice]*a[`openSellQty])-a[`openSellValue]] |0); // TODO convert to long
    a[`openLoss]:(sum[a`openSellLoss`openBuyLoss] | 0); // TODO convert to long
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0); // TODO convert to long

    a[`available]<a[`initMarginReq] // filter orders where resultant available is less than initMarginReq

    // Create probabalistic dropout of orders according to some loadshedding coefficient.

    // new order order fields 
    // (`accountId`clOid`price`side`otype`timeinforce`size`limitprice`stopprice`reduce`trigger`displayqty) = 12 fields
    if[count[o]>0;.order.NewOrder . e];
    
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessCancelOrderEvents :{[e] // Requires accountId
    e:.engine.Purge[e;count'[e`datum]<>3;0;"Invalid schema"];

    e:`accountId`orderId`clOrdId!e;

    e:.engine.PurgeNot[e;e`accountId in key[.account.Account];0;"Invalid account"];
    
    if[count[oId]>0;.order.CancelOrder . e];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessCancelAllEvents :{[e] // Requires accountId
    e:.engine.Purge[e;count'[e`datum]<>1;0;"Invalid schema"];
    
    e:enlist[`accountId]!enlist[e];

    e:.engine.PurgeNot[e;e`accountId in key[.account.Account];0;"Invalid account"];

    // TODO convert order accountId to mapping

    e:.engine.Purge[e;e[`accountId][`balance]<=0;0;"Order account has no balance"];
    e:.engine.Purge[e;e[`accountId][`available]<=0;0;"Order account has insufficient available balance"];
    e:.engine.Purge[e;e[`accountId][`state]=1;0;"Account has been disabled"];
    e:.engine.Purge[e;e[`accountId][`state]=2;0;"Account has been locked for liquidation"];

    if[count[aId]>0;.order.CancelAllOrders . e];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessWithdrawEvents :{[e]
    e:.engine.Purge[e;count'[e`datum]<>2;0;"Invalid schema"];

    e:`accountId`withdrawamt!e`datum;
    e[`instrumentId]:`.instrument.Instrument!0;

    e:.engine.PurgeNot[e;e[`accountId] in key[.account.Account];0;"Invalid account"];

    // TODO convert order accountId to mapping

    e:.engine.Purge[e;e[`accountId][`balance]<=0;0;"account has no balance"];
    e:.engine.Purge[e;e[`accountId][`available]<=0;0;"account has insufficient available balance"];
    e:.engine.Purge[e;e[`accountId][`state]=1;0;"Account has been disabled"];
    e:.engine.Purge[e;e[`accountId][`state]=2;0;"Account has been locked for liquidation"];

    // Calculate the cumulative sum of withdraws
    // and filter withdraws where the amount would
    // exceed the available account balance
    e:.engine.Purge[e;
        sums'[`accountId xgroup e]>e[`account][`withdrawable];
        0;"Account has been locked for liquidation"];    

    if[count[e]>0;.order.Withdraw . e];
    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessDepositEvents :{[e] // Requires accountId (this would be passive in production)
    i:.engine.getInstrument[];

    e:.engine.Purge[e;count'[e`datum]<>2;0;"Invalid schema"];

    e:`accountId`depositamt!e`datum;
    e[`instrumentId]:`.instrument.Instrument!0;

    e:.engine.Purge[e;not[e[`accountId] in key[.account.Account]];0;"Invalid account"];
    e:.engine.Purge[e;e[`accountId][`state]=1;0;"Account has been disabled"];
    e:.engine.Purge[e;e[`accountId][`state]=2;0;"Account has been locked for liquidation"];

    if[count[d]>0;.account.Deposit . e];
    };


/ Extern Signal processing and randomization
/ -------------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessSignalEvents :{[e] // Requires accountId
    .pipe.egress.AddBatch[e]; // TODO add noise/dropout/randomization
    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessLiquidationEvents :{[e]
    // TODO check    
    .pipe.egress.AddLiquidationEvent[];
    };

/ Public Event .engine.Processing logic (Writes)
/ -------------------------------------------------------------------->

// TODO instrument, leverage
// TODO events after watermark
// TODO probabalistic rejection of events
// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessEvents :{ // WRITE EVENTS TODO remove liquidation events?
    newwm: max x`time;
    $[null[.engine.WaterMark] or [newwm>.engine.WaterMark];[
        {
            k:x`f;
            $[k=0; .engine.ProcessDepthUpdateEvents[x];     // DEPTH
            k=1; .engine.ProcessNewTradeEvents[x];        // TRADE
            k=2; .engine.ProcessMarkUpdateEvents[x];      // MARK
            k=3; .engine.ProcessSettlementEvents[x];      // SETTLEMENT
            k=4; .engine.ProcessFundingEvents[x];         // FUNDING
            k=5; .engine.ProcessLiquidationEvents[x];     // LIQUIDATION
            k=8; .engine.ProcessOrderEvents[x];           // ORDER
            k=9; .engine.ProcessNewPriceLimitEvents[x];   // PRICELIMIT
            k=10;.engine.ProcessWithdrawEvents[x];        // WITHDRAW
            k=11;.engine.ProcessDepositEvents[x];         // DEPOSIT
            k=16;.engine.ProcessSignalEvents[x];         // SIGNAL
            'INVALID_EVENT_KIND];
        }'[0!(`f xgroup update f:{sums((<>) prior x)}kind from `time xasc x)];
        .engine.WaterMark:newwm;
    ];'WATERMARK_HAS_PASSED];
    // TODO pop events
    };

/ Main Setup Function
/ -------------------------------------------------------------------->

// Retreives the important information from account, inventory, orders
// Instrument, liquidation etc.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.Info    :{[aids] 
        :(
            select from .account.Account where accountId in aids;
            select from .account.Inventory where accountId in aids; 
            .engine.Engine;
            .order.Order; // TODO get accoutn
            .instrument.Instrument
        );
    };


 
// Resets engine state 
// Sets up the engine, active instrument,
// Initializes agent and respective inventory config
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.Reset   :{[config]
    .util.table.dropAll[(`.order.Order`.order.OrderBook,
                `.instrument.Instrument`.account.Account,
                `.inventory.Inventory)];

    // Instantiate instrument with 
    // given config.
    .instrument.NewInstrument[config[`instrument]];
    
    // Instantiate the given set 
    // of accounts.
    // TODO loop over config
    a:.account.NewAccount[config[`account]];

    // TODO set accountId
    .account.NewInventory[config[`shortInventory]];
    .account.NewInventory[config[`longInventory]];
    .account.NewInventory[config[`bothInventory]];

    // TODO update engine
    .engine.NewEngine[config`engine];

    };


