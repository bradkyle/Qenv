\l account.q
\d .order
\l util.q

BAM:();
orderCount:0;

multiply:{x[y]:`long$(x[y]*z);:x};

// Order
// =====================================================================================>
/*******************************************************
/ order related enumerations  
ORDERSIDE      :   `BUY`SELL;

ORDERTYPE   :   (`MARKET;       / executed regardless of price
                `LIMIT;         / executed only at required price
                `STOP_MARKET;   / executed as market order once stop price reached
                `STOP_LIMIT;
                `REMAINDERLIMIT;
                `PEGGED);   / executed as limit order once stop price reached
//TODO trailing stop order

ORDERSTATUS :   (`NEW;          / begining of life cycle
                `PARTIALFILLED; / partially filled
                `FILLED;        / fully filled
                `FAILED;        / failed due to expiration etc
                `UNTRIGGERED;
                `TRIGGERED;
                `CANCELLED);     / user or system cancel

TIMEINFORCE :   (`GOODTILCANCEL;     / good til user manual cancellation (max 90days)
                `IMMEDIATEORCANCEL; / fill immediately or cancel, allow partially fill
                `FILLORKILL;        / fill immediately or cancel, full fill only 
                `NIL);

STOPTRIGGER :   `LIMIT`MARK`INDEX`NIL; 
EXECINST    :   `PARTICIPATEDONTINITIATE`ALLORNONE`REDUCEONLY`NIL;   

orderMandatoryFields    :`accountId`side`otype`size;

// TODO change price type to int, longs etc.
// TODO allow for data derived i.e. exchange market orders.
Order: (
    [price:`long$(); orderId:`long$()]
    clId            :`long$();
    instrumentId    : `.instrument.Instrument$();
    accountId       : `.account.Account$();
    side            : `.order.ORDERSIDE$();
    otype           : `.order.ORDERTYPE$();
    offset          : `long$();
    timeinforce     : `.order.TIMEINFORCE$();
    size            : `long$(); / multiply by 100
    leaves          : `long$();
    filled          : `long$();
    limitprice      : `long$(); / multiply by 100
    stopprice       : `long$(); / multiply by 100
    status          : `.order.ORDERSTATUS$();
    time            : `datetime$();
    reduceOnly         : `boolean$();
    trigger         : `.order.STOPTRIGGER$();
    execInst        : `.order.EXECINST$());

ClRef :([] orderId: `.order.Order$());

orderCount:0;
ordSubmitFields: cols[.order.Order] except `orderId`leaves`filled`status`time;

NegSide: {:$[x=`.order.ORDERSIDE$`SELL;`.order.ORDERSIDE$`BUY;`.order.ORDERSIDE$`SELL]}

isActiveLimit:{:((>;`size;0);
               (in;`status;enlist[`NEW`PARTIALFILLED]);
               (in;`price;x);
               (=;`otype;`.order.ORDERTYPE$`LIMIT))};

// TODO clean
AddNewOrderEvent   :{[order;time]
    :.event.AddEvent[time;`NEW;`ORDER;order];
    }

AddUpdateOrderEvent :{[order;time]
    :.event.AddEvent[time;`UPDATE;`ORDER;order];
    }
 
AddCancelOrderEvent :{[order;time]
    :.event.AddEvent[time;`DELETE;`ORDER;order];
    }


// OrderBook
// =====================================================================================>

// Instantiate a singleton class of Orderbook
// qtys: represent the different level quantities at their given prices
// the events will be generated using the sum of the quantities and the 
// orderbook sizes at each price.
// `.order.OrderBook upsert ([price:(`long$((1000+til 20),(1000-til 20)))] side:(20#`.order.ORDERSIDE$`SELL),(20#`.order.ORDERSIDE$`BUY);qty:(`long$(40#1000)))
OrderBook:(
    [price      :`long$()]
    side        :`.order.ORDERSIDE$(); 
    qty         :`long$());

maxPrice: ?[.order.OrderBook; (); `side; (max;`price)];
minPrice: ?[.order.OrderBook; (); `side; (min;`price)];

bestBid:{exec max price from .order.OrderBook where side=`BUY};
bestAsk:{exec min price from .order.OrderBook where side=`SELL};
bestSidePrice:{$[x=`SELL;:bestAsk[];bestBid[]]};

DeriveThenAddDepthUpdateEvent :{[time] // TODO check
    :.event.AddEvent[time;`UPDATE;`DEPTH;(.order.OrderBook pj (select sum leaves by side,price from .order.Order))];
    };

AddDepthUpdateEvent :{[depth;time]
    :.event.AddEvent[time;`UPDATE;`DEPTH;(`side`size`price!depth)];
    };

AddTradeEvent  :{[trade;time]
    :.event.AddEvent[time;`NEW;`TRADE;(`side`size`price!trade)];
    };

// Orderbook Utilities
// -------------------------------------------------------------->

// TODO partial vs full book update.
ProcessDepthUpdate  : {[event] // TODO validate time, kind, cmd, etc.
    // Derive the deltas for each level given the new update
    // If has bids and asks and orders update orderbook else simply insert last events
    // return a depth event for each. (add randomizeation)
    event:flip event;
    nxt:0!(`price xgroup select time, side:datum[;0], price:datum[;1], size:datum[;2] from event);

    // TODO do validation on nxt;

    odrs:?[.order.Order;.order.isActiveLimit[nxt[`price]];0b;()];
    $[(count[odrs]>0);
      [
          // SHOULD COMBINE INTERNAL REPRESENTATION OF DEPTH AND AGENT ORDER AMOUNTS.
          // get all negative deltas then update the offsets of each order 
          // down to a magnitude that is directly proportional to the non
          // agent order volume at that level.
          ob:{select price, last size, last side, d:sum{x where[x<0]}deltas size by side, price from x} each nxt;
          dneg:ob where[ob[`d]<0];           
          
          // If the number of negative deltas and order
          // count is greater than 0, update the offsets.
          if[(count[dneg]>0);[
            odrs:0!(`price xgroup odrs);
            offsets: PadM[odrs[`offset]];
            sizes: PadM[odrs[`leaves]]; 
            maxN: max count'[offsets];
            numLvls:count[offsets]; // TODO check

            / Calculate the shifted offsets, which infers
            / the amount of space between each offset
            shft: sizes + offsets; 

            maxNl:til maxN;

            // Non Agent Qtys
            n:(numLvls,(maxN+1))#0;
            n[;0]: offsets[;0];
            n[;-1_(1+maxNl)]: Clip(offsets[;1_maxNl] - shft[;-1_maxNl]);
            n[;maxN]: Clip(qtys-max'[shft]);

            // SUm non agent qtys by lvl
            nl: sum'[n];

            // Derived deltas represents an equal distribution of 
            // orders throughout the book.
            derivedDeltas: floor[(n%nl)*dlt][::;-1];

            // Update the new offsets to equal the last
            // offsets + the derived deltas
            newOffsets: Clip[offsets + derivedDeltas];
            // Combine the new offsets with the respective offset ids in an 
            // update statement that will update the respective offsets.
            update offset:newOffsets from `.order.Order where orderId in ordrs[`orderId]; // TODO update
            
            // considering no changes have been made to the sizes of the given orders
            // the new shft would be the new offsets + the previous sizes
            newShft:sizes + newOffsets;

            // Update the orderbook lvl qtys to represent the change                
            // Replace all instances of the update with the maximum shft (offset + size)
            // for each price whereby the update is smaller than the given shft (offset+size)
            // ensures that an accurate representation is kept. 
            nxtQty:value[nxt];
            maxShft:max'[newShft];
            update qty:?[nxtQty>maxShft;nxtQty;maxShft] from `.order.OrderBook where price in key[nxt];
          ]];

          // TODO update orderbook
          // TODO emit orderbook snapshot
      ];
      [
         `.order.OrderBook upsert ([price:nxt[`price]] side:last'[nxt[`side]]; qty:last'[nxt[`size]]); 
      ]];
    / `price xgroup flip select time, price:datum[;0][;1], size:datum[;0][;2] from (e@2)
    / asks:`price xgroup select time, price:datum[;0][;1], size:datum[;0][;2] from event where[(d[`datum][;0][;0])=`SELL]
    / processSideUpdate[`SELL;event[`datum][`asks]]; d where[(d[`datum][;0][;0])=`SELL]
    / processSideUpdate[`BUY;event[`datum][`bids]]; d where[(d[`datum][;0][;0])=`BUY]
    / AddDepthEvent[nextAsks;nextBids];
    .order.DeriveThenAddDepthUpdateEvent[(exec last time from nxt)]; 

    };


// Process Trades/Market Orders
// -------------------------------------------------------------->
 
// Updates the state of the orderbook, orders, accounts, inventory etc. when a
// trade occurs
ProcessTrade    :{[instrumentId;side;fillQty;reduceOnly;isAgent;accountId;time]
    // TODO validate trade
    
    nside: .order.NegSide[side]; // TODO check if has agent orders on side, move into one select/update statement // TODO filtering on orders
    ns:deriveNextState[];

    // If any agent orders have been updated
    // update agent orders and apply fills respectively.
    if [(count[raze[ns[`orderIds]]]>0);[
        `.order.Order upsert deriveOrderUpdates[];
        .account.ApplyFill deriveAccountFills[]
        ]];

    // Calculate trade qtys
    // calculated seperately from orders on account of non agent trades.
    .order.AddTradeEvent deriveTrades[lt]

    if[isAgent;[
        // TODO reduce to one query
        if[accountId in flls[`accountId];.account.IncSelfFill[
            accountId;
            (count'[select by accountId from f where qty>0]@1);
            (exec sum qty from f where qty>0 and accountId=1)]];

        .account.ApplyFill[
            qty;
            price;
            side;
            time;
            reduceOnly;
            0b;
            accountId];
        ]];

    delete from `.order.OrderBook where price in (exec price from lt where tgt<=0);
    .order.DeriveThenAddDepthUpdateEvent[time]; 
    };

// Invokes ProcessTrade with an event i.e. from historical data
ProcessTradeEvent   :{[event] ProcessTrade[]};

// Limit Order Manipulation CRUD Logic
// -------------------------------------------------------------->


// Adds an agent order with its given details to the state
// reserves order margin (checks that account has enough margin) 
NewOrder       : {[o;time];
    // TODO append failures to events and return.
    // TODO if account is hedged and order is close the order cannot be larger than the position
    o:ordSubmitFields!o[ordSubmitFields];
    if[null o[`timeinforce];o[`timeinforce]:`NIL];
    if[null o[`reduceOnly];o[`reduceOnly]:0b];
    if[null o[`execInst];o[`execInst]:`NIL];
    if[null o[`trigger];o[`trigger]:`NIL];
    if[null o[`instrumentId]; (.event.AddFailure[time;`INVALID_INSTRUMENTID;"isntrumentId is null"]; 'INVALID_INSTRUMENTID)];
    if[null o[`accountId]; (.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]; 'INVALID_ACCOUNTID)];

    if[not (o[`side] in .order.ORDERSIDE); :.event.AddFailure[time;`INVALID_ORDER_SIDE;"Invalid side"]]; // TODO make failure event.
    if[not (o[`otype] in .order.ORDERTYPE); :.event.AddFailure[time;`INVALID_ORDER_TYPE;"Invalid order type"]]; // TODO make failure event.
    if[not (o[`timeinforce] in .order.TIMEINFORCE); :.event.AddFailure[time;`INVALID_TIMEINFORCE;"Invalid timeinforce"]]; // TODO make failure event.
    if[not (all o[`execInst] in .order.EXECINST); :.event.AddFailure[time;`INVALID_EXECINST;"Invalid order type"]]; // TODO make failure event.
    if[(o[`otype]=`LIMIT) and null[o[`price]];(.event.AddFailure[time;`INVALID_ORDER_PRICE;"price not set"]; 'INVALID_ORDER_PRICE)];
    if[not (o[`side] in .order.ORDERSIDE); :.event.AddFailure[time;`INVALID_ORDER_SIDE;"Invalid side"]]; // TODO make failure event.

    $[(o[`otype] in `STOP_MARKET`STOP_LIMIT) and null[o[`trigger]];o[`trigger]:`MARK;o[`trigger]:`NIL];
    $[(o[`otype] in `STOP_MARKET`STOP_LIMIT) and null[o[`stopprice]];:.event.AddFailure[time;`INVALID;""];o[`stopprice]:0f];
    $[(o[`otype] =`STOP_LIMIT) and null[o[`limitprice]];:.event.AddFailure[time;`INVALID;""];o[`limitprice]:0f];

    // Instrument related validation
    if[not(o[`instrumentId] in key .instrument.Instrument);
        :.event.AddFailure[time;`INVALID_INSTRUMENTID;"An instrument with the id:",string[o[`instrumentId]]," could not be found"]];

    // Instrument related validation
    ins:.instrument.Instrument@o[`instrumentId];
    if[((`float$o[`price]) mod ins[`tickSize])<>0;(.event.AddFailure[time;`INVALID_ORDER_TICK_SIZE;"not right"]; 'INVALID_ORDER_TICK_SIZE)];
    if[o[`price]>ins[`maxPrice];(.event.AddFailure[time;`INVALID_ORDER_PRICE;"not right"]; 'INVALID_ORDER_PRICE)];
    if[o[`price]<ins[`minPrice];(.event.AddFailure[time;`INVALID_ORDER_PRICE;"not right"]; 'INVALID_ORDER_PRICE)];
    if[o[`size]>ins[`maxOrderSize];(.event.AddFailure[time;`INVALID_ORDER_SIZE;"not right"]; 'INVALID_ORDER_SIZE)];
    if[o[`size]<ins[`minOrderSize];(.event.AddFailure[time;`INVALID_ORDER_SIZE;"not right"]; 'INVALID_ORDER_SIZE)]; // TODO should signal?

    // Account related validation
    if[not(o[`accountId] in key .account.Account);(.event.AddFailure[time;`INVALID_ACCOUNTID;"not right"]; 'INVALID_ACCOUNTID)];

    acc:.account.Account@o[`accountId];

    if[o[`reduceOnly] and (o[`otype] in `LIMIT`MARKET) and
        (((o[`side]=`SELL) and (o[`size]> acc[`netShortPosition])) or
        ((o[`side]=`BUY) and (o[`size]> acc[`netLongPosition])));
        (.event.AddFailure[time;`INVALID_ORDER_SIZE;"Close order larger than position"]; 'INVALID_ORDER_SIZE)];
    if[(acc[`orderCount]+1) > ins[`maxOpenOrders];:.event.AddFailure[time;`MAX_OPEN_ORDERS;""]];

    m:ins[`priceMultiplier];
    o:multiply[o;`limitprice`stopprice`price;m];
    o[`execInst]:`.order.EXECINST$o[`execInst];
    o[`trigger]:`.order.STOPTRIGGER$o[`trigger];
    o[`otype]:`.order.ORDERTYPE$o[`otype];
    o[`side]:`.order.ORDERSIDE$o[`side];
    o[`timeinforce]:`.order.TIMEINFORCE$o[`timeinforce];
    o[`status]: (`.order.ORDERSTATUS$`NEW);

    o[`leaves]: o[`size];
    o[`filled]: 0;
    o[`time]: time;
    o[`orderId]:.order.orderCount+:1;

    if[(not null[o[`clId]]) and ((exec count clId from .order.Order where clId=o[`clId])>0);
     (.event.AddFailure[time;`DUPLICATE_CLID;"duplicated clid"]; 'DUPLICATE_CLID)];
    if[null[o[`clId]];o[`clId]:`long$0n];

    if[null[o[`offset]];[
        qty:(.order.OrderBook@o[`price])[`qty];
        o[`offset]: $[not null[qty];qty;0]]];

    // TODO only if Limit order or market order
    / if[not[.account.ValidateOrderStateDelta[o[`leaves];o[`price];acc;ins]]; 
        / :.event.AddFailure[time;`MAX_OPEN_ORDERS;""]];

    // calculate initial margin requirements of order

    // TODO 
    / Duplicate clOrdID
    / Invalid orderID
    / Duplicate orderID
    / Invalid symbol
    / Instruments do not match
    / Instrument not listed for trading yet
    / Instrument expired
    / Instrument has no mark price
    / Accounts do not match
    / Invalid account
    / Account is suspended
    / Account has no [XBt]
    / Invalid ordStatus (trying to amend a canceled or filled order)
    / Invalid triggered
    / Invalid workingIndicator
    / Invalid side
    / Invalid orderQty or simpleOrderQty
    / Invalid simpleOrderQty
    / Invalid orderQty
    / Invalid simpleLeavesQty
    / Invalid simpleCumQty
    / Invalid leavesQty
    / Invalid cumQty
    / Invalid avgPx
    / Invalid price
    / Invalid price tickSize
    / Invalid displayQty
    / Unsupported ordType
    / Unsupported pegPriceType
    / Invalid pegPriceType for ordType
    / Invalid pegOffsetValue for pegPriceType
    / Invalid pegOffsetValue tickSize
    / Invalid stopPx for ordType
    / Invalid stopPx tickSize
    / Unsupported timeInForce
    / Unsupported execInst
    / Invalid execInst
    / Invalid ordType or timeInForce for execInst
    / Invalid displayQty for execInst
    / Invalid ordType for execInst
    / Unsupported contingencyType
    / Invalid clOrdLinkID for contingencyType
    / Invalid multiLegReportingType
    / Invalid currency
    / Invalid settlCurrency

    mPrice::exec min price by side from 0!.order.OrderBook;
    // TODO set offset
    // TODO check orderbook has liquidity
    // TODO add initial margin order margin logic etc.
    // TODO check position smaller than order
    bestAsk:.order.bestAsk[];
    bestBid:.order.bestBid[];

    $[o[`otype]=`LIMIT;
        [
            $[((o[`side]=`SELL) and not[null[bestBid]] and (o[`price] < bestBid)) or 
              ((o[`side]=`BUY) and not[null[bestAsk]] and (o[`price] > bestAsk));
                [ 
                    $[`PARTICIPATEDONTINITIATE in o[`execInst];
                        [
                            :.event.AddFailure[time;`PARTICIPATE_DONT_INITIATE;"Order had execInst of participate dont initiate"];
                        ];
                        [
                            o[`otype]: `MARKET;
                            .order.NewOrder[o;time];
                        ]
                    ]
                ];
                [
                    // add orderbook references
                    // TODO update order init margin etc.
                    // TODO update order margin etc.
                    // todo if there is a row at price and qty is greater than zero
                    
                    // TODO make better
                    `.order.Order upsert o;
                    .order.AddNewOrderEvent[o;time];
                    .account.UpdateOpenOrderState[];
                    .order.DeriveThenAddDepthUpdateEvent[time]; 

                ]
            ];
        ];
      o[`otype]=`MARKET;
        [
            .order.ProcessTrade[
                o[`side];
                o[`size];
                1b;
                event[`accountId]];
        ];
      o[`otype]=`STOP_MARKET;
        [
            // todo if close 
            // TODO checks etc.
            `.order.Order upsert order;
        ];
      o[`otype]=`STOP_LIMIT;
        [
            // todo if close
            // TODO checks etc.
            `.order.Order upsert order;
        ];
      [:.event.AddFailure[time;`INVALID_ORDTYPE;"The order had an invalid otype"]]];
    };

// TODO define granularity of update events.
// TODO
CancelOrder    :{[order;time]
    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    // Account related validation
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[orderId]," could not be found"]];

    // TODO fix
    if[not(order[`orderId] in key[.order.Order][`orderId]);
        :.event.AddFailure[time;`INVALID_ORDERID;"An order with the id:",string[orderId]," could not be found"]];

    // Replace order with order from store
    corder:exec from .order.Order where orderId=order[`orderId];

    // If the order does not belong to the account    

    // other validations

    / if[not[.account.UpdateOpenOrderState[neg[corder[`leaves]];corder[`side];corder[`price];acc;ins];
        / :.event.AddFailure[time;`MAX_OPEN_ORDERS;""]];

    update status:`.order.ORDERSTATUS$`CANCELLED, leaves:0 from `.order.Order where orderId=order[`orderId];

    // Update agent order offsets to represent the change
    update offset:offset-order[`leaves] from `.order.Order where price=order[`price] and offset<=order[`offset];


    .order.AddUpdateOrderEvent[o;time];
    / .account.UpdateOpenOrderState[];
    .order.DeriveThenAddDepthUpdateEvent[time]; 
    };

CancelAllOrders :{[accountId;time]
    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    // Account related validation
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[orderId]," could not be found"]];

    CancelOrder (select from .order.Order where accountId=accountId);
    };

// TODO
AmendOrder      :{[order;time]

    order:ordSubmitFields!order[ordSubmitFields];
    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    
    // TODO leaves cannot be larger than qty.
    // Account related validation
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[orderId]," could not be found"]];

    corder:exec from .order.Order where orderId=order[`orderId];
    delta: order[`leaves]-corder[`leaves];

    / if[not[.account.ValidateOrderStateDelta[delta;order[`price];acc;ins];
            / :.event.AddFailure[time;`MAX_OPEN_ORDERS;""]];

    $[((order[`size]=0)or(order[`leaves]=0));
        .order.CancelOrder[order;time];
        $[((order[`price]=corder[`price])and(order[`side]=corder[`side])and(order[`leaves]<=corder[`leaves])); // TODO check equality
            [
                update offset:offset-delta from `.order.Order where price=order[`price] and offset<=order[`offset];

                `.order.Order upsert order;
                .order.AddUpdateOrderEvent[order;time];

                .account.UpdateOpenOrderState[];
                .order.DeriveThenAddDepthUpdateEvent[time];
            ];
            [
                // assumes that this order is the last order in the offset
                // and as such does not update other offsets.
                if[null[order[`offset]];[
                    qty:(.order.OrderBook@order[`price])[`qty];
                    order[`offset]: $[not null[qty];qty;0]]];
                
                `.order.Order upsert order;
                .order.AddUpdateOrderEvent[order;time];

                .account.UpdateOpenOrderState[];
                .order.DeriveThenAddDepthUpdateEvent[time];
            ]]];
    };


// Update Mark Price
// -------------------------------------------------------------->

triggerStop    :{[stop]
    $[stop[`otype]=`STOP_LIMIT;
        [
            // TODO update stop to triggered
            :ordSubmitFields!();
        ];
      stop[`otype]=`STOP_MARKET;
        [
            // TODO update stop to triggered
            :ordSubmitFields!();
        ];
        [On]
    ];
    };

// Updates the orderbook mark price and subsequently
// checks if any stop orders or liquidations have
// occurred as a result of the mark price change.
UpdateMarkPrice : {[markPrice;instrumentId;time]
    ins:.instrument.Instrument@instrumentId;

    orders:triggerStop select from .order.Order 
        where otype in (`STOP_LIMIT`STOPMARKET), 
        (side=`SELL and price>stopprice),
        (sid`BUY and price<stopprice);
    
    / update otype:{}
    .order.NewOrder[time] orders;

    };