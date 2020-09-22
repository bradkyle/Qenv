
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

.engine.Purge    :{

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
.engine.ProcessDepthUpdateEvents :{[events]
    instrument:.engine.getInstrument[];
    // Convert/multiply 
    
    lt:exec last time from events;
    events:flip events;
    $[not (type events[`time])~15h;[.logger.Err["Invalid event time"]; :0b];]; //todo erroring
    $[not (type events[`intime])~15h;[.logger.Err["Invalid event intime"]; :0b];]; // todo erroring

    // `side`price`nqty`nhqty`time

    nxt:0!(`side`price xgroup select time, side:datum[;0], price:datum[;1], size:datum[;2] from events);

    .order.ProcessDepth[];

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
.engine.ProcessNewTradeEvents :{[events]
    instrument:.engine.getInstrument[];
    
    d:events`datum;

    // TODO derive from account
    .order.ProcessTrade[instrument]'[d`account`side`fill`reduce`time];

    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessMarkUpdateEvents :{[events]
    instrument:.engine.getInstrument[];
    d:events`datum;
    instrument[`markPrice]:last[d]; // Derive the last mark price from the events
    .instrument.Instrument,:instrument;

    // Essentially find the deltas in the mark price provided
    // and derive a change in the unrealized pnl, triggering
    // liquidations where neccessary
    .account.CONTRACT.UpdateMarkPrice[instrument;d;events`time];

    // Where appliccable trigger stop orders 
    // TODO add a delay in placement of orders
    .order.UpdateMarkPrice[instrument;d;events`time];

    // Inspect the account tables for any insolvent accounts.
    .liquidation.InspectAccounts[instrument];
    
    .pipe.egress.AddMarkEvent[];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessSettlementEvents :{[events]
    instrument:.engine.getInstrument[];
    
    // Apply settlement to the given accounts
    // and their respective inventories, this 
    // would reset realized pnl into the balance
    .account.CONTRACT.ApplySettlement[instrument];

    .pipe.egress.AddSettlementEvent[];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessFundingEvents :{[events]
    instrument:.engine.getInstrument[];

    //  Apply funding the the open agent 
    // positions/inventory 
    .account.CONTRACT.ApplyFunding[instrument];

    .pipe.egress.AddFundingEvent[];
    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessNewPriceLimitEvents :{[events] // 
    instrument:.engine.getInstrument[];

    // TODO just derive last price limits from events
    pricelimits:events`datum;

    .instrument.UpdatePriceLimits[instrument;]; // TODO derive price limti
    .pipe.egress.AddPriceLimitEvent[instrument;];    
    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessNewOrderEvents :{[events] // Requires accountId
    i:.engine.getInstrument[];
    / accountIds:key .account.Account; 
    // TODO check all count=12
    // TODO do validation here
    // $[any[in[o[`orderId`clOrdId];key[.order.Order]`orderId]];
    
    // check max batch order amends
     // Filter events where col count<>12
    
    events:.engine.Purge[events;count'[events`datum]<>12;0;"Invalid schema"];

    // In live version would get instrument here
    // filter events by type
    // TODO increment request counts!

    // TODO add execInst
    o:(`accountId`price`side`otype,
    `timeinforce`execInst`size`limitprice`stopprice,
    `reduce`trigger`displayqty)!raze'[events`datum];

    // TODO type conversions

     // Routine validation
    o:.engine.PurgeNot[o;o[`otype] in .pipe.common.ORDERKIND;0;"Invalid otype"];
    o:.engine.PurgeNot[o;o[`side]  in .pipe.common.ORDERSIDE;0;"Invalid side"];
    o:.engine.PurgeNot[o;o[`timeinforce]  in .pipe.common.TIMEINFORCE;0;"Invalid timeinforce"]; // TOOD fill

    // Instrument specific validation        
    o:.engine.PurgeNot[o;o[`price] < ins[`minPrice];0;"Invalid price: price<minPrice"];
    o:.engine.PurgeNot[o;o[`price] > ins[`maxPrice;0;"Invalid price: price>maxPrice"];
    o:.engine.PurgeNot[o;o[`size] < ins[`minSize];0;"Invalid size: size<minSize"]; 
    o:.engine.PurgeNot[o;o[`size] > ins[`maxSize];0;"Invalid size: size>maxSize"];
    o:.engine.PurgeNot[o;(o[`price] mod i[`tickSize])<>0;0;"Invalid tickSize"];
    o:.engine.PurgeNot[o;(o[`size] mod i[`lotSize])<>0;0;"Invalid lotSize"];

    // fill null then validate
    o[`limitprice]:0^o[`limitprice];
    o[`stopprice]:0^o[`stopprice];
    o[`trigger]:0^o[`trigger];
    o[`timeinforce]:0^o[`timeinforce];
    o[`reduce]:0b^o[`reduce];
    o[`displayqty]:o[`size]^o[`displayqty];
    o[`execInst]:enlist[0]^o[`execInst];
    
    o:.engine.PurgeNot[o;o[`displayqty] < ins[`minSize];0;"Invalid displayqty: size<minSize"];
    o:.engine.PurgeNot[o;o[`displayqty] > ins[`maxSize];0;"Invalid displayqty: size>maxSize"];
    o:.engine.PurgeNot[o;(o[`displayqty] mod i[`lotSize])<>0;0;"Invalid displayqty lot size"];
    o:.engine.PurgeNot[o;all[o[`execInst] in .pipe.common.EXECINST];0;"Invalid tickSize"];

    // TODO all in .common.ExecInst
    // TODO 1 in execIns
    o:.engine.PurgeNot[o;all[o[`execInst] in .pipe.common.EXECINST];0;"Invalid execInst"];

    // Run purge operations on market orders
    o:.engine.NestedPurgeNot[o;o[`otype] = 0]; 

    // Run purge operation on stop limit orders
    o:.engine.NestedPurgeNot[o;o[`otype]  in (2 3)]; 

    // Purge all orders that have execInst of post only and would cross bid ask spread
    o:.engine.PurgeNot[o;(all[(o[`side]<0),(i[`bestBidPrice]>=o[`price]),i[`hasLiquidityBuy]] or
        all[(o[`side]>0),(i[`bestAskPrice]<=o[`price]),i[`hasLiquiditySell]]) and (1 in o[`execInst]);
        0;"Order had execInst of postOnly"];

    o:.engine.PurgeNot[o;o[`accountId] in key[.account.Account];0;"Invalid account"];

    // TODO convert order accountId to mapping

    o:.engine.Purge[o;o[`accountId][`balance]<=0;0;"Order account has no balance"];
    o:.engine.Purge[o;o[`accountId][`available]<=0;0;"Order account has insufficient available balance"];
    o:.engine.Purge[o;o[`accountId][`state]=1;0;"Account has been disabled"];
    o:.engine.Purge[o;o[`accountId][`state]=2;0;"Account has been locked for liquidation"];

    a:o[`accountId];

    // Derive the sum of the margin that will be required
    // for each order to be filled and filter out the orders
    // for which their respective account has insufficient 
    // balance.
    premium:(o[`side]*(i[`markprice]-o[`price]));

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
    .order.NewOrder[instrument;accounts;orders];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessAmendOrderEvents :{[events] // Requires accountId
    instrument:.engine.getInstrument[];
    // TODO do validation here
    // $[any[in[o[`orderId`clOrdId];key[.order.Order]`orderId]];
    orders:y`datum;

    // check max batch order amends

    // check max batch order amends
    count'[events`datum]<>12 // Filter events where col count<>12
    
    // Check if order exists
    // TODO increment request counts!

    // TODO add execInst
    o:(`accountId`price`side`otype,
    `timeinforce`size`limitprice`stopprice,
    `reduce`trigger`displayqty)!raze'[y`datum];

    //  

    // amend order fields
    // (`price`side`otype`timeinforce`size`limitprice`stopprice`reduce`trigger`displayqty)
    .order.AmendOrder[i;a;o];
    
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessCancelOrderEvents :{[events] // Requires accountId

    oIds:events`datum;
    
    .order.CancelOrder[i;a;oId];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessCancelAllEvents :{[events] // Requires accountId
    
    aIds:events`datum;

    aIds:.engine.PurgeNot[aIds;aIds in key[.account.Account];0;"Invalid account"];

    // TODO convert order accountId to mapping

    o:.engine.Purge[o;o[`accountId][`balance]<=0;0;"Order account has no balance"];
    o:.engine.Purge[o;o[`accountId][`available]<=0;0;"Order account has insufficient available balance"];
    o:.engine.Purge[o;o[`accountId][`state]=1;0;"Account has been disabled"];
    o:.engine.Purge[o;o[`accountId][`state]=2;0;"Account has been locked for liquidation"];

    .order.CancelAllOrders[i;a;oId];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessWithdrawEvents :{[events]
    instrument:.engine.getInstrument[]; // Requires accountId

    events:.engine.Purge[events;count'[events`datum]<>2;0;"Invalid schema"];

    w:`accountId`withdrawamt!events`datum;

    w:.engine.PurgeNot[w;w[`accountId] in key[.account.Account];0;"Invalid account"];

    // TODO convert order accountId to mapping

    w:.engine.Purge[w;w[`accountId][`balance]<=0;0;"account has no balance"];
    w:.engine.Purge[w;w[`accountId][`available]<=0;0;"account has insufficient available balance"];
    w:.engine.Purge[w;w[`accountId][`state]=1;0;"Account has been disabled"];
    w:.engine.Purge[w;w[`accountId][`state]=2;0;"Account has been locked for liquidation"];

    // Calculate the cumulative sum of withdraws
    // and filter withdraws where the amount would
    // exceed the available account balance
    w:.engine.Purge[w;
        sums'[`accountId xgroup w]>w[`account][`withdrawable];
        0;"Account has been locked for liquidation"];    

    .account.CONTRACT.Withdraw[i];
    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessDepositEvents :{[events] // Requires accountId (this would be passive in production)
    instrument:.engine.getInstrument[];

    events:.engine.Purge[events;count'[events`datum]<>2;0;"Invalid schema"];

    d:`accountId`depositamt!events`datum;

    d:.engine.Purge[d;not[d[`accountId] in key[.account.Account]];0;"Invalid account"];
    d:.engine.Purge[d;d[`accountId][`state]=1;0;"Account has been disabled"];
    d:.engine.Purge[d;d[`accountId][`state]=2;0;"Account has been locked for liquidation"];

    .account.CONTRACT.Deposit[instrument];
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
.engine.ProcessSignalEvents :{[events] // Requires accountId
    .pipe.egress.AddBatch[events]; // TODO add noise/dropout/randomization
    };


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.ProcessLiquidationEvents :{[events]
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


