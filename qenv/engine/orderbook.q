\l order.q
\d .orderbook
\l util.q

// Instantiate a singleton class of Orderbook
// qtys: represent the different level quantities at their given prices
// offsets: represent the given offsets of a set of agent(s') orders 
// sizes: represent the given order sizes of a set of agent(s') orders
OrderBook:([price:`float$()]side:`.order.ORDERSIDE$();qty:`float$();offsets:();sizes:());

MakeDepthUpdateEvent :{[]
    :();
    };


MakeTradeEvent  :{[]
    :();
    };

// Orderbook Utilities
// -------------------------------------------------------------->

// Sets the order qtys on a given side to the target
getQtys         : {[side]:exec qty by price from .orderbook.OrderBook where side=side};
updateQtys      : {[side;nxt]:0};


updateQtys      : {[side;nxt].[`.orderbook.OrderBook;side,`qtys;,;nxt]};
bestQty         : {[side]x:getQtys[side];$[(count x)>0;:x[min key x];0N]};
getQtyByPrice   : {[side;price]x:getQtys[side];$[(count x)>0 & price in (key x);:x[price];0N]};
decremetQty     : {[side;price;decqty]x:getQtys[side];$[(count x)>0;:x[min key x];0N]};
updateQty       : {[side;price;qty]x:getQtys[side];$[(count x)>0;:x[min key x];0N]};
removeQty       : {[side;price]x:getQtys[side];$[(count x)>0;:x[min key x];0N]};
getAvailableQty : {[side]:sum value getQtys[side]};
/ orderbook.OrderBook[negSide][`qtys][price] -:

// Sets the order qtys on a given side to the target
getOffsets  : {[side]:.orderbook.OrderBook[side][`agentOffsets]};
addNewOffset  : {[side;price;offset;orderId].[`.orderbook.OrderBook;side,`agentOffsets,price;,;(offset,orderId)]};
genNewOffset  : {[side;price]:addNewOffset[side;price;getQtyByPrice[side;price]]};
updateOffsets  : {[side;nxt].[`.orderbook.OrderBook;side,`agentOffsets;,;nxt]};
/ decrementOffsets    :{[side;price;qty] .schema.OrderBook[side][`agentOffsets][price][;1]-:qty}; // TODO test

// Sets the order qtys on a given side to the target
getSizes  : {[side]:.orderbook.OrderBook[side][`agentSizes]};
addNewSize  : {[side;price;size]:[`.orderbook.OrderBook;side,`agentSizes,price;,;size]};
updateSizes  : {[side;nxt].[`.orderbook.OrderBook;side,`agentSizes;,;nxt]};

newLvl{[price;side;qty;offsets;sizes]
    l:lvlCols!()
    lvl[`price]:price;
    }


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
processSideUpdate   :{[side;nxt]
    / $[not (type nxt)=99h; :0b]; //
    / $[not (side in .order.ORDERSIDE); :0b];
    // TODO prices cannot overlap

    // Retrieve the latest snapshot from the orderbook
    qtys:getQtys[side];

    // Generate the set of differences between the current
    // orderbook snapshot and the target (nxt) snapshot
    // to which the orderbook is to transition.
    $[(count qtys)>0;
        [
            // TODO only calculate if has agent orders
            dlt:nxt-qtys;

            // Remove all levels that aren't supposed to change
            dlt:where[dlt<>0]#dlt;
            
            // If the orderbook contains agent limit orders then
            // update the current offsets.
            $[((count dlt)>0 & (count getOrders[side])); // TODO check
            [
                numLvls:count qtys;
                offsets: padm[getOffsetQtys[side]]; // TODO padding
                sizes: padm[getSizes[side]]; // TODO padding
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
                nonAgentQtys[;1+til maxNumUpdates]: clip[(offsets[;1] - lshft)]; 
                nonAgentQtys[;lpad]:clip[qtys - lshft]; 

                lvlNonAgentQtys: sum'[nonAgentQtys];
                derivedDeltas: floor[(nonAgentQtys%lvlNonAgentQtys)*dlt][::;-1];

                // Update the new offsets to equal the last
                // offsets + the derived deltas
                newOffsets: clip[offsets + derivedDeltas];
                updateOffsets[side;newOffsets];
            ];
            [updateQtys[side;nxt]]
            ];
        ];
        [updateQtys[side;nxt]]
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


// Adds an agent order with its given details to the state
// reserves order margin (checks that account has enough margin) 
NewOrder       : {[o;accountId;time];
    events:();
    
    if[null o[`side]; :`INVALID_SIDE];
    if[null o[`size] | o[`size]>0; :`INVALID_SIZE];
    if[null o[`otype]; :`INVALID_ORDER_TYPE];

    // TODO simplify
    o:default[o;`leaves;0];
    o:default[o;`isClose;0b];
    o:default[o;`status;`NEW];
    o:default[o;`time;time];
    o:default[o;`trigger;0N];
    o:default[o;`timeinforce;`GOODTILCANCEL];
    o:default[o;`limitprice;0];
    o:default[o;`stopprice;0];
    o[`accountId]:accountId;
    o[`orderId]:0;

    // TODO add initial margin order margin logic etc.

    // TODO kind agnostic
    genNewOffset[o[`side];o[`price];o[`orderId]];
    addNewSize[o[`side];o[`size];o[`price]];
    `order.Order insert order;
    :events;
    };

UpdateOrder    : {[order;time]
    events:();
    

    };

RemoveOrder    : {[orderId;time]
    events:();
    delete from `order.Order where orderId=orderId;
    :events;
    };


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
//          - if the trade is larger than best size
//          - if the trade is smaller than the best size
//      - if the trade was not made by an agent
fillTrade   :{[side;qty;time;isClose;isAgent;accountId]
        events:();
        price:0;
        nside: negSide[side];
        smallestOffset, smallestOffsetId :0;
        hasAgentOrders:(count .schema.Order)>0;
        $[hasAgentOrders;
            [
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
                        decrementQty[negSide;price;qty];
                    ];
                    events,:.orderbook.MakeTradeEvent[time;side;qty;price];
                    decrementOffsets[negSide, price; qty];
                    qty:0;
                ];[
                    // 
                    qty-:smallestOffset;

                    // Make a trade event that represents the trade taking up the
                    // offset space;
                    events,:.orderbook.MakeTradeEvent[time;side;qty;price];
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
                                negSide;
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

                            events,:.orderbook.MakeTradeEvent[];
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
                                negSide;
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

                            events,:.orderbook.MakeTradeEvent[];
                            qty:0;
                        ];
                    ];
                ]];
            ];
            [
                // If the orderbook does not currently possess agent orders.
                $[isAgent;[
                    // If the order was placed by an agent.
                    bestQty: getQtyByPrice[negSide;price];
                    $[bestQty>0;
                        $[qty<=bestQty;[
                            updateQty[qty]; // TODO update lvl qty
                            events,: .orderbook.MakeTradeEvent[];
                            events,:.account.ApplyFill[
                                    qty,
                                    price;
                                    side;
                                    time;
                                    isClose;
                                    0b; // not isMaker
                                    accountId
                            ];
                            qty:0;
                        ];[
                            removeQty[negSide;price];
                            events,:.orderbook.MakeTradeEvent[]; // TODO
                            events,:.account.ApplyFill[
                                    bestQty,
                                    price;
                                    side;
                                    time;
                                    isClose;
                                    0b; // not isMaker
                                    accountId
                            ]; // TODO
                            qty-:bestQty;
                        ]]
                        [:0N]
                    ];
                ];[
                    // Considering the orderbook updates already 
                    // represent the change due to trades, simply
                    // make a trade event and revert the qty to be 
                    // traded.
                    events,:.orderbook.MakeTradeEvent[];
                    qty:0;
                ]];
            ];
    ];
    :events;       
    };

// Processes a market order that was either derived from an agent or 
// was derived from a market trade stream and returns the resultant
// set of events.
processCross     :{[events;side;leaves;isAgent;accountId] 
    while [leaves < getAvailableQty[side] & leaves>0;events,:fillTrade[side;leaves;event]];
    :events;
    };

// Processes a trade that was not made by an agent
// i.e. it was derived from an exchange data stream.
ProcessTrade  : {[side;size;price;time]
    // TODO price invariant?
    :processCross[();side;size;0b;0N];
    };

//
NewMarketOrder  :{[side;size;price;agentId;isClose]

    };

// Limit Order PlaceMent Logic
// -------------------------------------------------------------->


// TODO
/ NewLimitOrder   :  {[event]
/     events:(); // todo functional processing
/     o: event[`datum];
/     $[.schema.ValidateOrder[o];
/         [
/             $[(price mod .global.TICKSIZE)<>0;:.global.MakeFailureEvent[]];
/             $[size<.global.MAXSIZE;:.global.MakeFailureEvent[]];
/             $[size<.global.MAXSIZE;:.global.MakeFailureEvent[]];
/             $[size<.global.MAXSIZE;:.global.MakeFailureEvent[]];

/             $[(side=`SELL and price < orderbook[`bestBidPrice]) | (side=`BUY and price > orderbook[`bestAskPrice]);
/                 [
/                     $[`PARTICIPATEDONTINITIATE in o[`execInst];
/                         events,:.global.MakeFailureEvent[];
/                         events,:processCross[
/                         events;
/                         event[`datum][`side];
/                         event[`datum][`size];
/                         1b;
/                         event[`agentId]
/                     ]]
/                 ];
/                 [events,:addLimitOrder[side;price;size;time;agentid;cmd]]
/             ];
/         ];
/         [events,:.schema.MakeFailureEvent[]]
/     ]
/     :events;
/     };

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

