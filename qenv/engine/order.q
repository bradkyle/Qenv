\l account.q
\d .order
\l util.q

orderCount:0;

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
Order: (
    [price:`int$(); orderId:`long$()]
    accountId       : `.account.Account$();
    side            : `.order.ORDERSIDE$();
    otype           : `.order.ORDERTYPE$();
    offset          : `int$();
    timeinforce     : `.order.TIMEINFORCE$();
    size            : `int$(); / multiply by 100
    leaves          : `int$();
    filled          : `int$();
    limitprice      : `int$(); / multiply by 100
    stopprice       : `int$(); / multiply by 100
    status          : `.order.ORDERSTATUS$();
    time            : `datetime$();
    isClose         : `boolean$();
    trigger         : `.order.STOPTRIGGER$();
    execInst        : `.order.EXECINST$());

ordSubmitFields: cols[.order.Order] except `orderId`leaves`filled`status`time;

isActiveLimit:{[side; validPrices]
              :((>;`size;0);
               (in;`status;enlist[`NEW`PARTIALFILLED]);
               (in;`price;validPrices);
               (=;`otype;`.order.ORDERTYPE$`LIMIT);
               };

AddNewOrderEvent   :{[]

    }

AddOrderUpdateEvent :{[]

    }

AddBatchOrderEvent   :{[]

    }

AddCancelAllOrdersEvent :{[]

    }


// OrderBook
// =====================================================================================>

// Instantiate a singleton class of Orderbook
// qtys: represent the different level quantities at their given prices
// offsets: represent the given offsets of a set of agent(s') orders 
// sizes: represent the given order sizes of a set of agent(s') orders
// `.order.OrderBook upsert ([price:(`int$((1000+til 20),(1000-til 20)))] side:(20#`.order.ORDERSIDE$`SELL),(20#`.order.ORDERSIDE$`BUY);qty:(`int$(40#1000)))
OrderBook:(
    [price      :`int$()]
    side        :`.order.ORDERSIDE$(); 
    qty         :`int$());

AddDepthUpdateEvent :{[side;size;price;time]
    :.event.AddEvent[time;`UPDATE;`DEPTH;depth];
    };


AddTradeEvent  :{[side;qty;price;time]
    :.event.AddEvent[time;`NEW;`TRADE;trade];
    };

// Orderbook Utilities
// -------------------------------------------------------------->



ProcessDepthUpdate  : {[event]
    // Derive the deltas for each level given the new update
    // If has bids and asks and orders update orderbook else simply insert last events
    // return a depth event for each. (add randomizeation)
    event:flip event;
    odrs:?[.order.Order;.order.isActiveLimit[u[`price]];0b;()];
    $[(count[event]>0) and (count[odrs]>0);
      [
          u:0!(`price xgroup flip select time, price:datum[;0][;1], size:datum[;0][;2], side:datum[;0][;0] from event);
          
          // get all negative deltas then update the offsets of each order 
          // down to a magnitude that is directly proportional to the non
          // agent order volume at that level.
          ob:{select price, last size, last side, d:sum{x where[x<0]}deltas size by side, price from x} each u;
          dneg:ob where[ob[`d]<0];           
          
          // If the number of negative deltas and order
          // count is greater than 0, update the offsets.
          if[(count[dneg]>0);[
            odrs:0!(`price xgroup odrs);
            offsets: PadM[odrs[`offset]];
            sizes: PadM[odrs[`size]]; 
            maxNumUpdates: max count'[offsets];

            / Calculate the shifted offsets, which infers
            / the amount of space between each offset
            shft: sizes + offsets;
            lshft: shft[;count shft];
            lpad: maxNumUpdates+1;

            lvlNonAgentQtys: sum'[nonAgentQtys];
            derivedDeltas: floor[(nonAgentQtys%lvlNonAgentQtys)*dlt][::;-1];

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
             
      ];
      [
         `.order.OrderBook upsert flip(price:nxt[`price]; side:count[nxt]#`.order.ORDERSIDE$s; size:last'[nxt[`size]]); 
      ]];
    / `price xgroup flip select time, price:datum[;0][;1], size:datum[;0][;2] from (e@2)
    / asks:`price xgroup select time, price:datum[;0][;1], size:datum[;0][;2] from event where[(d[`datum][;0][;0])=`SELL]
    / processSideUpdate[`SELL;event[`datum][`asks]]; d where[(d[`datum][;0][;0])=`SELL]
    / processSideUpdate[`BUY;event[`datum][`bids]]; d where[(d[`datum][;0][;0])=`BUY]
    / AddDepthEvent[nextAsks;nextBids];
    };


// Limit Order Manipulation CRUD Logic
// -------------------------------------------------------------->


// Adds an agent order with its given details to the state
// reserves order margin (checks that account has enough margin) 
NewOrder       : {[o;time];
    // TODO append failures to events and return.
    // TODO if account is hedged and order is close the order cannot be larger than the position
    o:ordSubmitFields!o[ordSubmitFields];
    if[null o[`timeinforce];o[`timeinforce]:`NIL];
    if[null o[`isClose];o[`isClose]:0b];
    if[null o[`execInst];o[`execInst]:()];
    if[null o[`accountId]; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    if[not (o[`side] in .order.ORDERSIDE); :.event.AddFailure[time;`INVALID_ORDER_SIDE;"Invalid side"]]; // TODO make failure event.
    if[not (o[`otype] in .order.ORDERTYPE); :.event.AddFailure[time;`INVALID_ORDER_TYPE;"Invalid order type"]]; // TODO make failure event.
    if[not (o[`timeinforce] in .order.TIMEINFORCE); :.event.AddFailure[time;`INVALID_TIMEINFORCE;"Invalid timeinforce"]]; // TODO make failure event.
    if[not (all o[`execInst] in .order.EXECINST); :.event.AddFailure[time;`INVALID_EXECINST;"Invalid order type"]]; // TODO make failure event.

    $[(o[`otype] in `STOP_MARKET`STOP_LIMIT) and null[o[`trigger]];o[`trigger]:`MARK;o[`trigger]:`NIL];
    $[(o[`otype] in `STOP_MARKET`STOP_LIMIT) and null[o[`stopprice]];:.event.AddFailure[time;`INVALID;""];o[`stopprice]:0f];
    $[(o[`otype] =`STOP_LIMIT) and null[o[`limitprice]];:.event.AddFailure[time;`INVALID;""];o[`limitprice]:0f];

    // Instrument related validation
    ins:.instrument.GetActiveInstrument[];
    if[(o[`price] mod ins[`tickSize])<>0;:.event.AddFailure[time;`INVALID_ORDER_TICK_SIZE;""]];
    if[o[`price]>ins[`maxPrice];:.event.AddFailure[time;`INVALID_ORDER_PRICE;""]];
    if[o[`price]<ins[`minPrice];:.event.AddFailure[time;`INVALID_ORDER_PRICE;""]];
    if[o[`size]>ins[`maxOrderSize];:.event.AddFailure[time;`INVALID_ORDER_SIZE;("The order size:",string[o[`size]]," is larger than the max size:", string[ins[`maxOrderSize]])]];
    if[o[`size]<ins[`minOrderSize];:.event.AddFailure[time;`INVALID_ORDER_SIZE;""]];

    // Account related validation
    if[not(o[`accountId] in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[o[`accountId]]," could not be found"]];

    acc:.account.Account@o[`accountId];
    if[o[`isClose] and (order[`otype] in `LIMIT`MARKET)
        ((o[`side]=`SHORT and (o[`size]> acc[`netShortPosition])) or
        (o[`side]=`LONG and (o[`size]> acc[`netLongPosition])));
        :.event.AddFailure[time;`INVALID_ORDER_SIZE; "Close order larger than position"]];

    if[(acc[`orderCount]+1) > ins[`maxOpenOrders];:.event.AddFailure[time;`MAX_OPEN_ORDERS;""]];
    if[(acc[`currentQty] >);:.event.AddFailure[time;`MAX_OPEN_ORDERS;""]];

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
    o[`orderId]:orderCount+1;
    // TODO set offset
    // TODO check orderbook has liquidity
    // TODO add initial margin order margin logic etc.
    $[o[`otype]=`LIMIT;
        [
            $[((o[`side]=`SELL) and (o[`price] < ins[`bestBidPrice])) or 
              ((o[`side]=`BUY) and (o[`price] > ins[`bestAskPrice]));
                [
                    $[`PARTICIPATEDONTINITIATE in o[`execInst];
                        [
                            .event.AddFailure[time;`PARTICIPATE_DONT_INITIATE;"Order had execInst of participate dont initiate"];
                        ];
                        [
                            processCross[ // The order crosses the bid ask spread.
                                o[`side];
                                o[`size];
                                1b;
                                o[`accountId];
                                o[`isClose];
                                time];
                        ]
                    ]
                ];
                [
                    // add orderbook references
                    // TODO update order init margin etc.
                    // TODO update order margin etc.
                    // todo if there is a row at price and qty is greater than zero
                    qty:.order.OrderBook[o[`price]][`qty];
                    o[`offset]: $[not null[qty];qty;0f];

                    // Update the account with the respective
                    // order premium etc.
                    // TODO implement order margin here

                    // TODO make better
                    o[`execInst]:`ALLORNONE;
                    o[`leaves]: o[`size];
                    o[`filled]: 0f;
                    o[`status]: `NEW;
                    o[`time]: time;
                    `.order.Order insert o;
                    / events:events,.order.MakeNewOrderEvent[];
                    / events:events,.account.MakeAccountUpdateEvent[]
                ]
            ];
        ];
      o[`otype]=`MARKET;
        [
            processCross[
                o[`side];
                o[`size];
                1b;
                event[`accountId]];
        ];
      o[`otype]=`STOP_MARKET;
        [
            // todo if close 
            / `order.Order insert order;
            show "STOP_MARKET";
        ];
      o[`otype]=`STOP_LIMIT;
        [
            // todo if close
            / `order.Order insert order;
            show "STOP_LIMIT";
        ];
      [
          0N;
      ]
    ];
    };

NewOrderBatch   :{[accountId;orders]
    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    // Account related validation
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[orderId]," could not be found"]];

    NewOrder each orders;
    };

CancelOrder    :{[accountId;orderId]
    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    // Account related validation
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[orderId]," could not be found"]];

    // TODO fix
    if[not(orderId in key .order.Order);
        :.event.AddFailure[time;`INVALID_ORDERID;"An order with the id:",string[orderId]," could not be found"]];

    // If the order does not belong to the account
    if[not()];

    update status:`.order.ORDERSTATUS$`CANCELLED from `.order.Order where id=orderId;
    };

CancelOrderBatch :{[accountId;orderIds]
    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    // Account related validation
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[orderId]," could not be found"]];

    CancelOrder each orders;
    };

CancelAllOrders :{[accountId]
    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    // Account related validation
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[orderId]," could not be found"]];

    update status:`.order.ORDERSTATUS$`CANCELLED from `.order.Order where accountId=accountId;
    };

AmendOrder      :{[accountId;order]
    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    
    // Account related validation
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[orderId]," could not be found"]];

    update status:`.order.ORDERSTATUS$`CANCELLED from `.order.Order where accountId=accountId;    
    };


AmendOrderBatch      :{[accountId;orders]
    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    // Account related validation
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[orderId]," could not be found"]];

    AmendOrder each orders;
    };


/ Update Market Orders

// Market Order and Trade Logic
// -------------------------------------------------------------->

// TODO increment occurance of self execution
// Executes a given trade an updates the orderbook and accounts/inventory
// accordingly;
// if the orderbook has agent orders
//      - trade will not execute an agent order
//          - if the trade was made by an agent
//      - trade will execute an agent order
//          - if the trade was made by an agent
//          - if the trade execution is larger than the agent order
//          - if the trade execution is smaller than the agent order
// if the orderbook does not have agent orders
//      - if the trade was made by an agent
//          - if the trade is larger than best qty
//          - if the trade is smaller than the best size
//      - if the trade was not made by an agent
// TODO compactify!
// TODO immediate or cancel, 
// TODO add randomization. agg trade?
fillTrade   :{[side;qty;isClose;isAgent;accountId;time]
        nside: NegSide[side];
        // TODO checking price is not more/less than best price
        / minOffset:exec 
        $[(exec sum qty from .order.OrderBook where side=nside)=0;
            [:.event.AddFailure[time;`NO_LIQUIDITY;"There are no ",string[nside]," orders to match with the market order"]];
            [
                price:exec min price from .order.OrderBook where side=nside;
                hasAgentOrders:(count select from .order.Order where side=nside)>0;
                $[hasAgentOrders;
                    [
                        // TODO check that the min offset in this instance only pertains to the price+side
                        nxt:exec from .order.Order where side=nside, price=price, offset=min offset; //TODO derive price 
                        // If the orderbook possesses agent orders
                        $[qty <= nxt[`offset];
                            [
                                // If the quantity left to trade is less than the 
                                // smallest agent offset i.e. not agent orders will
                                // be filled.
                                if[isAgent;
                                    // If the market order was placed by an agent.
                                    .account.ApplyFill[
                                        qty;
                                        price;
                                        side;
                                        time;
                                        isClose;
                                        0b; // not isMaker
                                        accountId];
                                    fill:qty; // TODO remove 
                                    update qty:qty-fill from `.order.OrderBook where side=nside, price=price;
                                ];
                                .order.AddTradeEvent[side;qty;price;time];
                                update offset:offset-qty from `.order.Order where side=nside, price=price;
                                qty:0;
                            ];
                            [
                                // 
                                qty-:nxt[`offset];

                                // Make a trade event that represents the trade taking up the
                                // offset space;
                                .order.AddTradeEvent[side;nxt[`offset];price;time]; 
                                $[qty>=nxt[`size];
                                    [
                                        show 99#"H";
                                        // If the quantity to be traded is greater than or
                                        // equal to the next agent order, fill the agent order
                                        // updating its state and subsequently removing it from
                                        // the local buffer, adding fill to account and creating
                                        // respective trade event. // TODO if order made by agent!
                                        // TODO completely fill limit order
                                        .account.ApplyFill[
                                            nxt[`size],
                                            price;
                                            nside;
                                            time;
                                            nxt[`isClose];
                                            1b; // not isMaker
                                            nxt[`accountId]];

                                        if[isAgent;
                                            // If the order was made by an agent the first level of
                                            // the orderbook should represent the change otherwise not
                                            // captured.
                                            decrementQty[side;price;smallestOffset]; 
                                            .account.ApplyFill[
                                                qty,
                                                price;
                                                side;
                                                time;
                                                isClose;
                                                0b; // not isMaker
                                                accountId
                                            ];
                                        ];

                                        .order.AddTradeEvent[];
                                        qty-:nxt[`size];
                                    ];
                                    [
                                        // If the quantity to be traded is less than the next agent
                                        // order, update it to partially filled and apply fills, 
                                        // make trade events etc.
                                        nxt[`size]-: qty;
                                        // TODO Update order
                                        updateOrder[nxt;time];
                                        .account.ApplyFill[
                                            qty;
                                            price;
                                            nside;
                                            time;
                                            nxt[`isClose];
                                            1b; // isMaker
                                            nxt[`accountId]
                                        ];

                                        if[isAgent;
                                            // If the order was made by an agent the first level of
                                            // the orderbook should represent the change otherwise not
                                            // captured.
                                            update qty:qty-nxt[`offset] from `.order.OrderBook where side=nside, price=price;
                                            .account.ApplyFill[
                                                qty,
                                                price;
                                                side;
                                                time;
                                                isClose;
                                                0b; // not isMaker
                                                accountId
                                            ];
                                        ];
                                        .order.AddTradeEvent[side;`float$qty;price;time];
                                        qty:0;
                                    ]
                                ]
                            ]
                        ]
                    ];
                    [
                        // If the orderbook does not currently possess agent orders.
                        $[isAgent;
                            [
                                // If the order was placed by an agent.
                                bestQty: exec first qty from .order.OrderBook where side=nside, price=price;
                                $[bestQty>0;
                                    $[qty<=bestQty;
                                        [
                                            nqty:bestQty-qty;
                                            update qty:nqty from `.order.OrderBook where side=nside, price=price;
                                            .order.AddTradeEvent[side;bestQty;price;time];
                                            .account.ApplyFill[
                                                    qty;
                                                    price;
                                                    side;
                                                    time;
                                                    isClose;
                                                    0b; // not isMaker
                                                    accountId];
                                            qty:0;
                                        ];
                                        [
                                            // Because the market order/trade is larger than the best qty at this level
                                            // the level of the orderbook is to be removed and the resultant size of the
                                            // trade should be equal to the size of the bestQty
                                            delete from `.order.OrderBook where side=nside, price=price; // TODO orderbook update etc.
                                            .order.AddTradeEvent[side;bestQty;price;time]; // TODO
                                            .account.ApplyFill[
                                                    bestQty;
                                                    price;
                                                    side;
                                                    time;
                                                    isClose;
                                                    0b; // not isMaker
                                                    accountId]; // TODO
                                            qty-:bestQty;
                                        ]
                                    ];
                                    [
                                        // There is no best qty i.e. the market order cannot be
                                        // filled because there is no liquidity.
                                        :0N
                                    ]
                                ];
                            ];
                            [
                                // Considering the orderbook updates already 
                                // represent the change due to trades, simply
                                // make a trade event and revert the qty to be 
                                // traded.
                                .order.AddTradeEvent[side;`float$qty;price;time];
                                qty:0;
                            ]
                        ]
                    ]
            ]
        ]
    ];
    };


// Processes a market order that was either derived from an agent or 
// was derived from a market trade stream and returns the resultant
// set of events.
processCross     :{[side;leaves;isAgent;accountId;isClose;time] 
        while [(
            (leaves>0) and 
            count[.order.Order@[exec min price by side from .order.OrderBook]]>0
        );fillTrade[side;leaves;isClose;isAgent;accountId;time]];
    };



// Processes a trade that was not made by an agent
// i.e. it was derived from an exchange data stream.
// event conforms 
ProcessTradeEvent  : {[event] // TODO change to events.
        / show price;
        / show size;
        / show time;
        // TODO price invariant?
        // TODO check for limit stop orders.
        / show 99#"=";
        $[count[.order.Order]>0;
            [
              // If has agent orders at best ask/bid
              while [(
                (leaves>0) and 
                count[.order.Order@[exec min price by side from .order.OrderBook]]>0
                );fillTrade[side;leaves;isClose;isAgent;accountId;time]];
            ];
            [
                // todo reinsert all trade events into buffer
                0n;
            ]
        ];
    };


// Update Mark Price
// -------------------------------------------------------------->

// Updates the orderbook mark price and subsequently
// checks if any stop orders or liquidations have
// occurred as a result of the mark price change.
UpdateMarkPrice : {[markPrice;time]
    update markPrice:markPrice from `.instrument.Instrument;
    // TODO check for liquidations
    / liquidateInvs: select from .account.inventory
        / where ;

    activatedStops:select from .order.Order 
        where otype in (`STOP_LIMIT`STOPMARKET), 
        (side=`SELL and price>stopprice),
        (sid`BUY and price<stopprice);

    };