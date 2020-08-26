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

// TODO remove cols
// TODO clean
AddNewOrderEvent   :{[order;time] // TODO convert to list instead of dict
    :.event.AddEvent[time;`NEW;`ORDER;order];
    }

AddUpdateOrderEvent :{[order;time] // TODO convert to list instead of dict
    :.event.AddEvent[time;`UPDATE;`ORDER;order];
    }
 
AddCancelOrderEvent :{[order;time] // TODO convert to list instead of dict
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
    qty         :`long$();
    vqty      :`long$());

maxPrice: ?[.order.OrderBook; (); `side; (max;`price)];
minPrice: ?[.order.OrderBook; (); `side; (min;`price)];

bestBid:{exec max price from .order.OrderBook where side=`BUY};
bestAsk:{exec min price from .order.OrderBook where side=`SELL};
bestSidePrice:{$[x=`SELL;:bestAsk[];bestBid[]]};

DeriveThenAddDepthUpdateEvent :{[time] // TODO check // TODO convert to list instead of dict
    :.event.AddEvent[time;`UPDATE;`DEPTH;(select price,side,vqty from .order.OrderBook)];
    };

AddDepthUpdateEvent :{[depth;time] // TODO convert to list instead of dict
    :.event.AddEvent[time;`UPDATE;`DEPTH;depth];
    };

AddTradeEvent  :{[trade;time] // TODO convert to list instead of dict
    :.event.AddEvent[time;`NEW;`TRADE;trade];
    };

// Orderbook Utilities
// -------------------------------------------------------------->

// TODO simplify into update statement like ProcessTrade
// Processes a set of updates to the orderbook, (does not infer updates from levels, merely prices)
ProcessDepthUpdateEvent  : {[event] // TODO validate time, kind, cmd, etc.

    // Derive the deltas for each level given the new update
    // If has bids and asks and orders update orderbook else simply insert last events
    // return a depth event for each. (add randomizeation)
    lt:exec last time from event;
    event:flip event;
    $[not (type event[`time])~15h;[.logger.Err["Invalid event time"]; :0b];]; //todo erroring
    $[not (type event[`intime])~15h;[.logger.Err["Invalid event intime"]; :0b];]; // todo erroring

    // TODO check prices don't cross
    nxt:0!(`side`price xgroup select time, side:datum[;0], price:datum[;1], size:datum[;2] from event);
    // TODO do validation on nxt;

    // TODO remove reduncancy
    odrs:?[.order.Order;.order.isActiveLimit[nxt[`price]];0b;()];
    $[(count[odrs]>0);
      [
          // SHOULD COMBINE INTERNAL REPRESENTATION OF DEPTH AND AGENT ORDER AMOUNTS.
          // get all negative deltas then update the offsets of each order 
          // down to a magnitude that is directly proportional to the non
          // agent order volume at that level. 

        / .order.O:.order.Order;
        / .order.B:.order.OrderBook;
        / .order.E:event;

          state:0!update
            vqty: {?[x>y;x;y]}'[mxshft;nvqty] // todo take into account mxnshift
          from update
            mxshft:max'[nshft],
            nvqty: sum'[raze'[flip[raze[enlist(tgt;pleaves)]]]]
          from update
            nshft: pleaves+noffset
          from update
            noffset: {?[x>y;x;y]}'[mnoffset;poffset + offsetdlts]
          from update
            offsetdlts: -1_'(floor[(nagentQty%(sum'[nagentQty]))*dneg]) // Simulates even distribution of cancellations
          from update
            nagentQty: flip PadM[raze'[(poffset[;0]; Clip[poffset[;1_(til first maxN)] - shft[;-1_(til first maxN)]];Clip[qty-max'[shft]])]], // TODO what qty is this referring to
            mnoffset: (0,'-1_'(shft))
          from update
            tgt: last'[size],
            dneg:sum'[{x where[x<0]}'[dlts]],
            shft:pleaves+poffset
          from update
            dlts:1_'(deltas'[raze'[flip[raze[enlist(qty;size)]]]]),
            nqty: last'[size],
            poffset:PadM[offset],
            pleaves:PadM[leaves],
            porderId:PadM[orderId],
            paccountId:PadM[accountId],
            pprice:PadM[oprice],
            maxN:max count'[offset],
            numLvls:count[offset] 
          from  (((`side`price xgroup select time, side:datum[;0], price:datum[;1], size:datum[;2] from event) lj (`side`price xgroup .order.OrderBook)) lj (select 
            oqty:sum leaves, 
            oprice: price,
            oside: side,
            leaves, 
            offset, 
            orderId, 
            accountId
            by side, price from .order.Order where otype=`LIMIT, status in `PARTIALFILLED`NEW, size>0));

        /   .order.S:state;
    
          `.order.OrderBook upsert (select price, side, qty:tgt, vqty from state where vqty>0);

          `.order.Order upsert (select from (select 
                price:raze[pprice], 
                orderId:raze[porderId], 
                offset:raze[noffset] from state) where orderId in raze[state[`orderId]]);

            dllvl:(select price,side from state where vqty<=0);
            if[count[dllvl]>0;{delete from `.order.OrderBook where price=x[`price], side=x[`side]}'[dllvl]];

            / dupd:select visQty,side by price from state;
      ];
      [
         `.order.OrderBook upsert ([price:nxt[`price]] side:last'[nxt[`side]]; qty:last'[nxt[`size]]; vqty:last'[nxt[`size]]); 
         delete from `.order.OrderBook where qty<=0;
      ]];

    };


// Process Trades/Market Orders
// -------------------------------------------------------------->

// Updates the state of the orderbook, orders, accounts, inventory etc. when a
// trade occurs
// Update for batch trades?
ProcessTrade    :{[instrumentId;side;fillQty;reduceOnly;isAgent;accountId;tim]
    // TODO validate trade

    nside: .order.NegSide[side]; // TODO check if has agent orders on side, move into one select/update statement // TODO filtering on orders
    state:0!update
                vqty: {?[x>y;x;y]}'[mxshft;nvqty] // todo take into account mxnshift
            from update
                nvqty: sum'[raze'[flip[raze[enlist(tgt;pleaves)]]]], // TODO make simpler
                nagentQty: flip PadM[raze'[(0^poffset[;0];Clip[0^poffset[;1_(til first maxN)] - 0^nshft[;-1_(til first maxN)]];Clip[qty-mxshft])]],
                nfilled: psize - nleaves,
                accdlts: pleaves - nleaves
            from update
                mxshft:{$[x>1;max[y];x=1;y;0]}'[maxN;nshft],
                noffset: Clip[poffset-rp],
                nleaves: {?[x>z;(y+z)-x;y]}'[rp;pleaves;poffset]
            from update
                nshft:pleaves+poffset
            from update 
                poffset:PadM[offset],
                psize:PadM[size],
                pleaves:PadM[leaves],
                preduceOnly:PadM[reduceOnly],
                porderId:PadM[orderId],
                paccountId:PadM[accountId],
                pinstrumentId:PadM[instrumentId],
                pprice:PadM[oprice],
                pstatus:PadM[status],
                maxN:max count'[offset],
                numLvls:count[offset] 
            from {$[x=`BUY;`price xasc y;`price xdesc y]}[nside;select from (
                    update
                        tgt:qty-rp
                    from update 
                        rp:?[pqty<fillQty;pqty;fillQty]^rp // TODO max fillqty lvl qty
                            from update 
                                rp: (thresh-prev[thresh])-(thresh-fillQty) // The amount that is filled at the given level
                                from update
                                    thresh:sums qty
                                    from update 
                                        pqty: qty+(0^oqty)
                                        from 0!((select from .order.OrderBook where side=nside) uj (select 
                                            oqty:sum leaves, 
                                            oprice: price,
                                            leaves, 
                                            size, 
                                            offset, 
                                            orderId, 
                                            accountId, 
                                            instrumentId,
                                            status,
                                            reduceOnly 
                                            by price from .order.Order where otype=`LIMIT, side=nside, status in `PARTIALFILLED`NEW, size>0)) // TODO add instrument id
                    ) where qty>=tgt];

    // If any agent orders have been updated
    // update agent orders and apply fills respectively.
    if [(count[raze[state[`porderId]]]>0);[
        
        // Derive updates to orders and upsert them
        // TODO testing, move to unit and make simpler
        ordUpd: select price,orderId,offset,leaves,status from 
        (update
            status:`.order.ORDERSTATUS$`FILLED
            from (update 
                status:`.order.ORDERSTATUS$`PARTIALFILLED
                from (select 
                price:raze[pprice], 
                orderId:raze[porderId], 
                offset:raze[noffset], 
                leaves:Clip[raze[nleaves]], 
                partial:`boolean$(raze[(sums'[poffset]<=rp)-(nshft<=rp)]), 
                filled:`boolean$(raze[(poffset<=rp)and(nshft<=rp)]),
                status:raze[pstatus] from state) where partial)where filled) where orderId in raze[state[`orderId]];
        
        `.order.Order upsert ordUpd;

        // update 

        // TODO Update the new open cost of the orders with respect to the mark price 

        // Derive account fills from state and call .acount Apply fill for each.
        // order in the order book.
        accFlls:select from (update
            side:nside,
            time:tim, // TODO update time.
            isMaker:1b,
            insId:instrumentId 
            from (select 
                raze[porderId], // todo remove
                raze[paccountId],
                raze[pprice],
                raze[nfilled],
                raze[preduceOnly] from state)) where (nfilled>0), (paccountId in raze[state[`accountId]]);

        if[count[accFlls]>0;[ 
            if [isAgent;[
                if[accountId in accFlls[`paccountId];[
                    sflls:exec n:count i, qty:sum[abs[nfilled]] from accFlls where paccountId=accountId;
                    .account.IncSelfFill[
                        accountId;
                        sflls[`n];
                        sflls[`qty]]];
                    ];
                ]];

            flls:0!select by 
                paccountId, 
                pprice,
                side,
                isMaker, 
                preduceOnly from accFlls;


            // 
            {.account.ApplyFill[
                x[`paccountId];
                x[`insId];
                x[`side];
                x[`time];
                x[`preduceOnly];
                x[`isMaker];
                x[`pprice];
                x[`nfilled]]}'[flls];
            ]];
        ]];

    trades:select
        price:raze[numtd#'price],
        raze[qty] 
        from update
            numtd:count'[qty]
        from update 
            qty:{s:sums[y];Clip[?[(x-s)>=0;y;x-(s-y)]]}'[rp;splt] 
            from select side, price, rp,  
            splt:{$[count[x];1_(raze raze'[0,(0^x);y]);y]}'[pleaves;nagentQty] from state;

    // Calculate trade qtys
    // calculated seperately from orders on account of non agent trades.
    {.order.AddTradeEvent[(
        y[`side]; 
        y[`price]; 
        y[`qty]);x]}[tim]'[select side, price, qty from trades where qty>0];

    if[isAgent and (count[trades]>0);[
        // TODO reduce to one query

        flls:0!select 
            accountId, 
            instrumentId, 
            price:last price, 
            qty: sum qty,
            side:.order.NegSide[side],
            time:tim,
            reduceOnly:reduceOnly,
            isMaker:0b
            by side,price from trades;

        {.account.ApplyFill[
            x[`accountId];
            x[`instrumentId];
            x[`side];
            x[`time];
            x[`reduceOnly];
            x[`isMaker];
            x[`price];
            x[`qty]]}'[flls];
        
        ]];

    `.order.OrderBook upsert (select price, side, qty:tgt, vqty from state);
    delete from `.order.OrderBook where price in (exec price from state where tgt<=0);
    .order.DeriveThenAddDepthUpdateEvent[tim]; 
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
    if[null[o[`timeinforce]];o[`timeinforce]:`NIL];
    if[null[o[`reduceOnly]];o[`reduceOnly]:0b];
    if[null[o[`execInst]];o[`execInst]:`NIL];
    if[null[o[`trigger]];o[`trigger]:`NIL];
    if[null[o[`instrumentId]]; (.event.AddFailure[time;`INVALID_INSTRUMENTID;"isntrumentId is null"]; 'INVALID_INSTRUMENTID)];
    if[null[o[`accountId]]; (.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]; 'INVALID_ACCOUNTID)];

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

    acc:.account.Account@o[`accountId]; // TODO get account leverage setting

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
                            .order.ProcessTrade[
                                o[`instrumentId];
                                o[`side];
                                o[`size];
                                o[`reduceOnly];
                                1b;
                                event[`accountId];
                                time];
                        ]
                    ];
                ];
                [
                    // add orderbook references
                    // todo if there is a row at price and qty is greater than zero
                    // TODO recalculate the total order open cost with respect to the mark price
                    .account.UpdateInitialMargin[
                        o[`side];
                        o[`price];
                        o[`size];
                        o[`reduceOnly];
                        o[`accountId]];
                    
                    // TODO make better
                    `.order.Order upsert o;
                    update vqty:vqty+o[`leaves] from `.order.OrderBook where price=o[`price], side=o[`side];
                    .order.AddNewOrderEvent[o;time];
                    .order.DeriveThenAddDepthUpdateEvent[time]; 
                    .order.O:.order.OrderBook;
                ]
            ];
        ];
      o[`otype]=`MARKET;
        [
            .order.ProcessTrade[
                o[`instrumentId];
                o[`side];
                o[`size];
                o[`reduceOnly];
                1b;
                event[`accountId];
                time];
        ];
      o[`otype]=`STOP_MARKET;
        [
            // Stop orders are a brokerage function
            // todo if close 
            // TODO checks etc.
            `.order.Order upsert order;
        ];
      o[`otype]=`STOP_LIMIT;
        [
            // Stop orders are a brokerage function
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
    // TODO recalculate the total order open cost with respect to the mark price

    / if[not[.account.UpdateOpenOrderState[neg[corder[`leaves]];corder[`side];corder[`price];acc;ins];
        / :.event.AddFailure[time;`MAX_OPEN_ORDERS;""]];

    update status:`.order.ORDERSTATUS$`CANCELLED, leaves:0 from `.order.Order where orderId=order[`orderId];

    // Update agent order offsets to represent the change
    update offset:offset-order[`leaves] from `.order.Order where price=order[`price] and offset<=order[`offset];


    .order.AddUpdateOrderEvent[o;time];
    / .account.UpdateOpenOrderState[];
    .order.DeriveThenAddDepthUpdateEvent[time]; 
    };

// TODO update for batch operations
CancelAllOrders :{[accountId;time]
    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    // Account related validation
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[orderId]," could not be found"]];

    CancelOrder'[select from .order.Order where accountId=accountId];
    // TODO recalculate the total order open cost with respect to the mark price
    };

// TODO update for batch operations
// TODO allowed update cols
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
                // TODO recalculate the total order open cost with respect to the mark price

                .account.UpdateOpenOrderState[];
                .order.DeriveThenAddDepthUpdateEvent[time];
            ];
            [
                // assumes that this order is the last order in the offset
                // and as such does not update other offsets.
                if[null[order[`offset]];[
                    qty:(.order.OrderBook@order[`price])[`qty];
                    order[`offset]: $[not null[qty];qty;0]]];
                // TODO recalculate the total order open cost with respect to the mark price
                
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
// TODO select by trigger
UpdateMarkPrice : {[markPrice;instrumentId;time]
    ins:.instrument.Instrument@instrumentId; 
    // TODO recalculate the total order open cost with respect to the mark price
    orders:triggerStop select from .order.Order 
        where otype in (`STOP_LIMIT`STOPMARKET), 
        (side=`SELL and price>stopprice),
        (sid`BUY and price<stopprice);
    
    / update otype:{}
    .order.NewOrder[time] orders;

    };