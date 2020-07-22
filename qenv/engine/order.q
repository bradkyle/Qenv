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
                `CANCELED);     / user or system cancel

TIMEINFORCE :   (`GOODTILCANCEL;     / good til user manual cancellation (max 90days)
                `IMMEDIATEORCANCEL; / fill immediately or cancel, allow partially fill
                `FILLORKILL;        / fill immediately or cancel, full fill only 
                `NIL);

STOPTRIGGER :   `LIMIT`MARK`INDEX`NIL; 
EXECINST    :   `PARTICIPATEDONTINITIATE`ALLORNONE`REDUCEONLY;   

orderMandatoryFields    :`accountId`side`otype`size;

Order: (
    [price:`float$(); orderId:`long$()]
    clOrdId         : `long$();
    accountId       : `long$();
    side            : `.order.ORDERSIDE$();
    otype           : `.order.ORDERTYPE$();
    offset          : `float$();
    timeinforce     : `.order.TIMEINFORCE$();
    size            : `float$(); / multiply by 100
    leaves          : `float$();
    filled          : `float$();
    limitprice      : `float$(); / multiply by 100
    stopprice       : `float$(); / multiply by 100
    status          : `.order.ORDERSTATUS$();
    time            : `datetime$();
    isClose         : `boolean$();
    trigger         : `.order.STOPTRIGGER$();
    execInst        : `.order.EXECINST$()
    );

ordSubmitFields: cols[.order.Order] except `orderId`leaves`filled`status`time;

isActiveLimit:{[side; validPrices]
              :((>;`size;0);
               (in;`status;enlist[`FILLED`FAILED`CANCELED]);
               (in;`price;validPrices);
               (=;`otype;`.order.ORDERTYPE$`LIMIT);
               (=;`side;`.order.ORDERSIDE$side));
               };

MakeNewOrderEvent   :{[]

    }

MakeOrderUpdateEvent :{[]

    }

MakeBatchOrderEvent   :{[]

    }

MakeCancelAllOrdersEvent :{[]

    }


// OrderBook
// =====================================================================================>

// Instantiate a singleton class of Orderbook
// qtys: represent the different level quantities at their given prices
// offsets: represent the given offsets of a set of agent(s') orders 
// sizes: represent the given order sizes of a set of agent(s') orders
OrderBook:(
    [price      :`float$()]
    side        :`.order.ORDERSIDE$(); 
    qty         :`float$()
    );

MakeDepthUpdateEvent :{[depth;time]
    :MakeEvent[time;`UPDATE;`DEPTH;depth];
    };


MakeTradeEvent  :{[trade;time]
    :MakeEvent[time;`NEW;`TRADE;trade];
    };

tradeCols:`side`qty`price;

// Orderbook Utilities
// -------------------------------------------------------------->

// Sets the order qtys on a given side to the target
// ?[`OrderBook;(enlist(=;`side;enlist `SELL)); 0b; ()]

// Depth Update Logic
// -------------------------------------------------------------->

// Derives new agent order offsets for the entire side of the book.
// assumes that the lvl_offsets and lvl_sizes are sorted such that 
// each scalar column represents one order.
// lvl_qtys: total size of level
// lvl_deltas: change in the size of the given lvl
// lvl_sizes: the size of orders at a given lvl
// lvl_offsets: the offsets for the orders at a given lvl 
// Returns the new order offsets for all the agent orders
// and the resultant derived deltas (how much has each order 
// offset been changed)
// nxt is a dictionary of price:qty
// side is an enum (ORDERSIDE) of `BUY, `SELL 
// TODO do validation based on instrument
processSideUpdate   :{[side;nxt]
    nxtCount:count[nxt];

    if[not (type nxt)=99h; :0b];
    if[not (side in .order.ORDERSIDE); :0b];
    if[not (nxtCount>0); :0b];
    // TODO prices cannot overlap
    // asc desc for ask vs bid

    // Retrieve the latest snapshot from the orderbook
    qtys:exec qty by price from .order.OrderBook where side=side;
    // sanitize/preprocess

    // Generate the set of differences between the current
    // orderbook snapshot and the target (nxt) snapshot
    // to which the orderbook is to transition.
    $[count[qtys]>0;
        [
            // TODO only calculate if has agent orders
            // TODO sort qtys etc.
            // TODO remove levels where qty=0
            dlt:first'[nxt-qtys];
            
            // Remove all levels that aren't supposed to change 
            dlt:where[dlt<>0]#dlt;           
            numLvls:count dlt;

            // TODO grouping by price, orderId
            odrs:?[.order.Order;isActiveLimit[side;key dlt];0b;()];
            // If the orderbook contains agent limit orders then
            // update the current offsets.
            $[((numLvls>0) & (count[odrs]>0)); // TODO check
                [
                    offsets: PadM[odrs[`offset]]; // TODO padding
                    sizes: PadM[odrs[`size]]; // TODO padding
                    maxNumUpdates: max count'[offsets];

                    / Calculate the shifted offsets, which infers
                    / the amount of space between each offset
                    shft: sizes + offsets;
                    lshft: shft[;count shft];
                    lpad: maxNumUpdates+1;

                    / Initialize non agent quantities matrix
                    / The first column is set to the first lvl_offset
                    / The last column is set to the size of the level minus the size of the last offset + order size
                    / adn all levels in between this are set to the lvl_offsets minus the shifted offset 
                    nonAgentQtys: (numLvls, lpad)#0;
                    nonAgentQtys[;0]: offsets[;0];
                    nonAgentQtys[;1+til maxNumUpdates]: Clip[(offsets[;1] - lshft)]; 
                    nonAgentQtys[;lpad]:Clip[qtys - lshft]; 

                    lvlNonAgentQtys: sum'[nonAgentQtys];
                    derivedDeltas: floor[(nonAgentQtys%lvlNonAgentQtys)*dlt][::;-1];

                    // Update the new offsets to equal the last
                    // offsets + the derived deltas
                    newOffsets: Clip[offsets + derivedDeltas];
                    // Combine the new offsets with the respective offset ids in an 
                    // update statement that will update the respective offsets.
                    update offset:newOffsets from .order.Order where orderId in ordrs[`orderId]; // TODO update
                    
                    // considering no changes have been made to the sizes of the given orders
                    // the new shft would be the new offsets + the previous sizes
                    newShft:sizes + newOffsets;

                    // Update the orderbook lvl qtys to represent the change                
                    // Replace all instances of the update with the maximum shft (offset + size)
                    // for each price whereby the update is smaller than the given shft (offset+size)
                    // ensures that an accurate representation is kept. 
                    nxtQty:value[nxt];
                    maxShft:max'[newShft];
                    update qty:?[nxtQty>maxShft;nxtQty;maxShft] from .order.OrderBook where price in key[nxt]; // TODO update
                ];
                [
                    // No orders exist therefore a simple upsert 
                    `.order.OrderBook upsert ([] price:`float$key[nxt]; side:nxtCount#side; qty:`float$value[nxt]); 
                ]
            ];
        ]; 
        [
            / `.order.OrderBook upsert nxt; 
            `.order.OrderBook insert (`float$key[nxt];nxtCount#side;`float$value[nxt]); 
        ]
    ];
    };

ProcessDepthUpdate  : {[time;asks;bids]
    // Derive the deltas for each level given the new update
    processSideUpdate[`SELL;event[`datum][`asks]];
    processSideUpdate[`BUY;event[`datum][`bids]];
    :MakeDepthEvent[nextAsks;nextBids];
    };

// Limit Order Manipulation CRUD Logic
// -------------------------------------------------------------->

// Conditional Utilities
// -------------------------------------------------------------->
// conditional utilities define transition logic based upon the configuration defined for
// a given instrument i.e. the maintenence type and associated logic, fee type and associated
// logic, liquidation strategy and settlement type. 

/ reserveOrderMargin  : {[side;price;size;orderId;time]
/     // 
/     events:();
/     markPrice: 0;
/     faceValue: 0;
/     leverage:0;
/     $[side=`BUY & price>markPrice; 
/       premium:floor[(price-markPrice)*faceValue];
/       side=`SELL & price<markPrice;
/       premium:floor[(markPrice-price)*faceValue];
/       premium:0;
/     ];

/     $[side=`SELL & longOpenQty>sellOpenQty;
/      charged:max[size-(longOpenQty-sellOrderQty),0];
/      side=`BUY & shortOpenQty>buyOrderQty;
/      charged:max[size-(shortOpenQty-buyOrderQty),0];
/      charged:0;
/     ];
    
/     reserved: floor[((charged+(initialMarginCoefficient*charged*faceValue)+changed*premium)%price)%leverage];
/     $[(reserved<availableBalance) | (reserved=0);
/         [
/             orderMargin:reserved;
/             :1b;
/         ];
/         [:0b]
/     ];
/     :events;
/     };

/ / This is the minimum amount of margin you must maintain to avoid liquidation on your position.
/ / The amount of commission applicable to close out all your positions will also be added onto 
/ / your maintenance margin requirement.
/ deriveMainteneceMargin  : {[]

/     };

// Adds an agent order with its given details to the state
// reserves order margin (checks that account has enough margin) 
NewOrder       : {[o;time];
    events:();
    
    // TODO append failures to events and return.
    // TODO if account is hedged and order is close the order cannot be larger than the position
    o:ordSubmitFields!o[ordSubmitFields];
    if[null o[`timeinforce];o[`timeinforce]:`NIL];
    if[null o[`isClose];o[`isClose]:0b];
    if[null o[`execInst];o[`execInst]:()];
    if[null o[`accountId]; :MakeFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    if[not (o[`side] in .order.ORDERSIDE); :MakeFailure[time;`INVALID_ORDER_SIDE;"Invalid side"]]; // TODO make failure event.
    if[not (o[`otype] in .order.ORDERTYPE); :MakeFailure[time;`INVALID_ORDER_TYPE;"Invalid order type"]]; // TODO make failure event.
    if[not (o[`timeinforce] in .order.TIMEINFORCE); :MakeFailure[time;`INVALID_TIMEINFORCE;"Invalid timeinforce"]]; // TODO make failure event.
    if[not (all o[`execInst] in .order.EXECINST); :MakeFailure[time;`INVALID_EXECINST;"Invalid order type"]]; // TODO make failure event.

    $[(o[`otype] in `STOP_MARKET`STOP_LIMIT) and null[o[`trigger]];o[`trigger]:`MARK;o[`trigger]:`NIL];
    $[(o[`otype] in `STOP_MARKET`STOP_LIMIT) and null[o[`stopprice]];:MakeFailure[time;`INVALID;""];o[`stopprice]:0f];
    $[(o[`otype] =`STOP_LIMIT) and null[o[`limitprice]];:MakeFailure[time;`INVALID;""];o[`limitprice]:0f];

    // Instrument related validation
    ins:.instrument.GetActiveInstrument[];
    if[(o[`price] mod ins[`tickSize])<>0;:MakeFailure[time;`INVALID_ORDER_TICK_SIZE;""]];
    if[o[`price]>ins[`maxPrice];:MakeFailure[time;`INVALID_ORDER_PRICE;""]];
    if[o[`price]<ins[`minPrice];:MakeFailure[time;`INVALID_ORDER_PRICE;""]];
    if[o[`size]>ins[`maxOrderSize];:MakeFailure[time;`INVALID_ORDER_SIZE;("The order size:",string[o[`size]]," is larger than the max size:", string[ins[`maxOrderSize]])]];
    if[o[`size]<ins[`minOrderSize];:MakeFailure[time;`INVALID_ORDER_SIZE;""]];

    // Account related validation
    if[not(o[`accountId] in key .account.Account);:MakeFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[o[`accountId]]," could not be found"]];

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
                            events,:MakeFailure[time;`PARTICIPATE_DONT_INITIATE;"Order had execInst of participate dont initiate"];
                        ];
                        [
                            events,:processCross[ // The order crosses the bid ask spread.
                                events;
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
                    update 
                        openBuyPremium:0f,
                        openSellPremium:0f,
                        openBuyOrderQty:0,
                        openSellOrderQty:0,
                        orderMargin:0f,
                        frozen:0f,
                        available:0f from `.account.Account where accountId=o[`accountId]; 

                    // TODO make better
                    o[`execInst]:`ALLORNONE;
                    o[`leaves]: o[`size];
                    o[`filled]: 0f;
                    o[`status]: `NEW;
                    o[`time]: time;
                    `.order.Order insert o;
                    / events,:.order.MakeNewOrderEvent[];
                    / events,:.account.MakeAccountUpdateEvent[]
                ]
            ];
        ];
      o[`otype]=`MARKET;
        [
            events,:processCross[
                events;
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
    ];
    :events;
    };

updateOrder    : {[order;time]
    events:();
   
    :events;
    };

removeOrder    : {[orderId;time]
    events:();
    delete from `order.Order where orderId=orderId;
    :events;
    };

/ AmendLimitOrder    :{[event]
/     events:();
/     events,:updateLimitOrder();
/     :events;
/     };

/ CancelLimitOrder    :{[]
/     events:();
/     events,:removeLimitOrder();
/     :events;
/     };

/ CancelLimitOrderBatch   :{[]
/     events:();
/     events,:CancelLimitOrder each orderIds
/     };

/ CancelAllLimitOrders    :{[]

/     };

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
fillTrade   :{[side;qty;isClose;isAgent;accountId;time]
        events:();
        nside: NegSide[side];
        // TODO checking price is not more/less than best price
        $[(exec sum qty from .order.OrderBook where side=nside)=0;
            [:MakeFailure[time;`NO_LIQUIDITY;"There are no ",string[nside]," orders to match with the market order"]];
            [
                price:exec min price from .order.OrderBook where side=nside;
                hasAgentOrders:(count select from .order.Order where side=nside)>0;
                $[hasAgentOrders;
                    [
                        offset:exec min offset, price, orderId from .order.Order where side=nside & price=price; //TODO derive price 
                        
                        // If the orderbook possesses agent orders
                        $[qty <= smallestOffset;[
                            // If the quantity left to trade is less than the 
                            // smallest agent offset i.e. not agent orders will
                            // be filled.
                            $[isAgent;
                                // If the market order was placed by an agent.
                                events,:.account.ApplyFill[
                                    qty,
                                    price;
                                    side;
                                    time;
                                    isClose;
                                    0b; // not isMaker
                                    accountId
                                ];
                                decrementQty[nside;price;qty];
                            ];
                            events,:.order.MakeTradeEvent[time;side;qty;price];
                            decrementOffsets[nside, price; qty];
                            qty:0;
                        ];[
                            // 
                            qty-:smallestOffset;

                            // Make a trade event that represents the trade taking up the
                            // offset space;
                            events,:.order.MakeTradeEvent[time;side;qty;price];
                            nextAgentOrder: exec from .order.Order where id=smallestOffsetId;
                            $[qty>=nextAgentOrder[`size];
                                [
                                    // If the quantity to be traded is greater than or
                                    // equal to the next agent order, fill the agent order
                                    // updating its state and subsequently removing it from
                                    // the local buffer, adding fill to account and creating
                                    // respective trade event. // TODO if order made by agent!
                                    events,:fillLimitOrder[nextAgentOrder[`id];time]; // TODO update
                                    events,:.account.ApplyFill[
                                        nextAgentOrder[`size],
                                        price;
                                        nside;
                                        time;
                                        nextAgentOrder[`isClose];
                                        1b; // not isMaker
                                        nextAgentOrder[`accountId]
                                    ];

                                    $[isAgent;
                                        // If the order was made by an agent the first level of
                                        // the orderbook should represent the change otherwise not
                                        // captured.
                                        decrementQty[side;price;smallestOffset]; 
                                        events,:.account.ApplyFill[
                                            qty,
                                            price;
                                            side;
                                            time;
                                            isClose;
                                            0b; // not isMaker
                                            accountId
                                        ];
                                    ];

                                    events,:.order.MakeTradeEvent[];
                                    qty-:nextAgentOrder[`size];
                                ];
                                [
                                    // If the quantity to be traded is less than the next agent
                                    // order, update it to partially filled and apply fills, 
                                    // make trade events etc.
                                    nextAgentOrder[`size]-: qty;
                                    events,:updateLimitOrder[nextAgentOrder;time];
                                    events,:.account.ApplyFill[
                                        qty;
                                        price;
                                        nside;
                                        time;
                                        nextAgentOrder[`isClose];
                                        1b; // isMaker
                                        nextAgentOrder[`accountId]
                                    ];

                                    $[isAgent;
                                        // If the order was made by an agent the first level of
                                        // the orderbook should represent the change otherwise not
                                        // captured.
                                        decrementQty[side;price;smallestOffset]; 
                                        events,:.account.ApplyFill[
                                            qty,
                                            price;
                                            side;
                                            time;
                                            isClose;
                                            0b; // not isMaker
                                            accountId
                                        ];
                                    ];

                                    events,:.order.MakeTradeEvent[];
                                    qty:0;
                                ];
                            ];
                        ]];
                    ];
                    [
                        // If the orderbook does not currently possess agent orders.
                        $[isAgent;
                            [
                                // If the order was placed by an agent.
                                bestQty: exec first qty from .order.OrderBook where side=nside, price=price;
                                $[bestQty>0;
                                    $[qty<=bestQty;[
                                        nqty:bestQty-qty;
                                        update qty:nqty from `.order.OrderBook where side=nside, price=price;
                                        events,: .order.MakeTradeEvent[(tradeCols!(side;bestQty;price));time];
                                        events,:.account.ApplyFill[
                                                qty;
                                                price;
                                                side;
                                                time;
                                                isClose;
                                                0b; // not isMaker
                                                accountId];
                                        qty:0;
                                    ];[
                                        // Because the market order/trade is larger than the best qty at this level
                                        // the level of the orderbook is to be removed and the resultant size of the
                                        // trade should be equal to the size of the bestQty
                                        delete from `.order.OrderBook where side=nside, price=price;
                                        events,:.order.MakeTradeEvent[(tradeCols!(side;bestQty;price));time]; // TODO
                                        events,:.account.ApplyFill[
                                                bestQty;
                                                price;
                                                side;
                                                time;
                                                isClose;
                                                0b; // not isMaker
                                                accountId]; // TODO
                                        qty-:bestQty;
                                    ]];
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
                                events,:.order.MakeTradeEvent[(tradeCols!(side;`float$qty;price));time];
                                qty:0;
                            ]
                        ]
                    ]
            ]
        ]
    ];
    :events;       
    };


// Processes a market order that was either derived from an agent or 
// was derived from a market trade stream and returns the resultant
// set of events.
processCross     :{[events;side;leaves;isAgent;accountId;isClose;time] 
        $[0;
            [while [leaves>0;events,:fillTrade[side;leaves;isClose;isAgent;accountId;time]]];
            [:MakeFailure[time;`]]
        ];
        :events;
    };

// Processes a trade that was not made by an agent
// i.e. it was derived from an exchange data stream.
ProcessTrade  : {[side;size;price;time]
    // TODO price invariant?
    // TODO check for limit stop orders.
    :processCross[();side;size;0b;0N];
    };

// Updates the orderbook mark price and subsequently
// checks if any stop orders or liquidations have
// occurred as a result of the mark price change.
UpdateMarkPrice : {[markPrice;time]
    // TODO check for stop orders
    // TODO check for liquidations
    }