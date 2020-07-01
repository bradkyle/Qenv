// TODO simulate slippage

// Transient Logic (Both Agent & Environment)
// --------------------------------------------------->

/------------------------>
/ agent limit order logic



getLvlQty           :{[]};

// Removes a given qty from all orders at a price level
// whereby the removed qty 
decrementOffsets    :{[side;price;qty] .schema.OrderBook[side][`agentOffsets][price][;1]-:qty}; // TODO test





getLimitOrder       :{[]};
removeLimitOrder    : {[orderId]
    events:();
    .schema.OrderBook[side][`qtys][price] -: size;
    delete .schema.OrderBook[side][`agentOffsets][orderId]; // delete the offset pertaining to the agent order
    delete .schema.OrderBook[side][`agentSizes][orderId]; // remove the qty pertaining to the agent order.
    delete from `.schema.Order where orderId=orderId;
    decrementOffsets[side;price;size]; // decrement all other agent orders thus representing the change in their respective offsets
    events,:removeOrderMargin();
    :events;
};

// A simplified order update function that 
updateLimitOrder    : {[side;price;size;]
    events:();
    $[]
};

// Adds an agent order with its given details to the state
// reserves order margin (checks that account has enough margin)
// 
addLimitOrder       : {[side;price;size;time;agentid;cmd];
    events:();
    orderid: 0
    events,: reserveOrderMargin(); // TODO add extra id reference
    .schema.OrderBook[side][`agentOffsets][price]:.schema.OrderBook[side][`qtys][price];
    .schema.OrderBook[side][`agentSizes][orderId]: size;
    `.schema.Order insert ();
    events,:.global.MakeOrderEvent[];
    :events
};

// Environment Event Processing Logic
// --------------------------------------------------->

fillTrade   :{[side;qty;time;isAgent;agentId]
        events:();
        price:0;
        negSide: $[side=`SELL;`BUY;`SELL];
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
                        events,: .account.ApplyFill[]
                        .schema.OrderBook[negSide][`qtys][price] -:qty;
                    ];
                    events,:.global.MakeTradeEvent[time;side;qty;price];
                    decrementOffsets[negSide, price; qty];
                    qty:0;
                ];[
                
                    qty-:smallestOffset;

                    $[isAgent;
                        // If the order was made by an agent the first level of
                        // the orderbook should represent the change otherwise not
                        // captured.
                        .schema.OrderBook[negSide][`qtys][price] -:smallestOffset;
                    ];
                    // Make a trade event that represents the trade taking up the
                    // offset space;
                    events,:.global.MakeTradeEvent[time;side;qty;price];
                    nextAgentOrder: exec from .schema.Order where id=smallestOffsetId;
                    $[qty>=nextAgentOrder[`osize];
                        [
                            // If the quantity to be traded is greater than or
                            // equal to the next agent order, fill the agent order
                            // updating its state and subsequently removing it from
                            // the local buffer, adding fill to account and creating
                            // respective trade event. 
                            events,:fillLimitOrder[nextAgentOrder[`id];time]; // TODO update
                            events,:.account.ApplyFill[];
                            events,:.global.MakeTradeEvent[];
                            qty-:nextAgentOrder[`size];
                        ];
                        [
                            // If the quantity to be traded is less than the next agent
                            // order, update it to partially filled and apply fills, 
                            // make trade events etc.
                            events,:updateLimitOrder[nextAgentOrder[`id]; abs(nextAgentOrder[`osize]-qty);time]; // TODO update
                            events,:.account.ApplyFill[
                                qty;
                                price;
                                negSide;
                                time;
                                nextAgentOrder[`onlyClose];
                                1b;
                                nextAgentOrder[`accountId]
                            ]; // TODO
                            events,:.global.MakeTradeEvent[];
                            qty:0;
                        ];
                    ];
                ]];
            ];
            [
                // If the orderbook does not currently possess agent orders.
                $[isAgent;[
                    // If the order was placed by an agent.
                    bestQty: .schema.OrderBook[negSide][`qtys][price];
                    $[qty<=bestQty;[
                        .schema.OrderBook[negSide][`qtys][price] -:qty; // TODO update lvl qty
                        events,: .global.MakeTradeEvent[];
                        events,: .account.ApplyFill[];
                        qty:0;
                    ];[
                        delete .schema.OrderBook[negSide][`qtys][price];
                        events,:.global.MakeTradeEvent[]; // TODO
                        events,:.account.ApplyFill[]; // TODO
                        qty-:bestQty;
                    ]]
                ];[
                    // Considering the orderbook updates already 
                    // represent the change due to trades, simply
                    // make a trade event and revert the qty to be 
                    // traded.
                    events,:.global.MakeTradeEvent[];
                    qty:0;
                ]];
            ];
    ];
    :qty events;       
};

getAvailable{[side]

};

// Processes a market order that was either derived from an agent or 
// was derived from a market trade stream and returns the resultant
// set of events.
processCross     :{[events; side;leaves;isAgent;agentId] 
    while [leaves < getAvailable[event.datum.side] & leaves>0;events,:fillTrade[side;leaves;event]];
    :events;
};

// Processes a trade that was not made by an agent
// i.e. it was derived from an exchange data stream.
ProcessTradeEvent  : {[event]
    :processCross[();event[`datum][`side];event[`datum][`size];0b;0N];
};


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
processSideUpdate   :{[side;nxt]
    qtys:orderbook[side].qtys
    dlt:nxt-qtys;
    dlt:where[dlt<>0]#dlt;
    $[(count dlt)>0 & (count orderbook[side].agentOrderCount); // TODO check

        numLvls:count qtys;
        maxNumUpdates: 0;
        offsets: orderbook[side].agentOrderOffsets; // TODO padding
        sizes: orderbook[side].agentOrderSizes; // TODO padding

        shft: sizes + offsets;

        nonAgentQtys: (numLvls, maxNumUpdates+1)#0;

        lvlNonAgentQtys: 0
        derivedDeltas: 0

        // Update the new offsets to equal the last
        // offsets + the derived deltas
        orderbook[side].agentOrderOffsets: (offsets + derivedDeltas)

    ];
    :orderbook[side].qtys:
};

ProcessDepthUpdate  : {[event]
    // Derive the deltas for each level given the new update
    nextAsks:processSideUpdate[`SELL;event[`datum][`asks]];
    nextBids:processSideUpdate[`BUY;event[`datum][`bids]];
    :.global.MakeDepthEvent[event.time;nextAsks;nextBids];
};

// Agent Order Event Processing Logic
// --------------------------------------------------->

// TODO
NewLimitOrder   :  {[event]
    events:(); // todo functional processing
    o: event[`datum];
    $[.schema.ValidateOrder[o];
        [
            $[(price mod .global.TICKSIZE)<>0;:.global.MakeFailureEvent[]];
            $[size<.global.MAXSIZE;:.global.MakeFailureEvent[]];
            $[size<.global.MAXSIZE;:.global.MakeFailureEvent[]];
            $[size<.global.MAXSIZE;:.global.MakeFailureEvent[]];

            $[(side=`SELL and price < orderbook[`bestBidPrice]) | (side=`BUY and price > orderbook[`bestAskPrice]);
                [
                    $[`PARTICIPATEDONTINITIATE in o[`execInst];
                        events,:.global.MakeFailureEvent[];
                        events,:processCross[
                        events;
                        event[`datum][`side];
                        event[`datum][`size];
                        1b;
                        event[`agentId]
                    ]]
                ];
                [events,:addLimitOrder[side;price;size;time;agentid;cmd]]
            ];
        ];
        [events,:.schema.MakeFailureEvent[]]
    ]
    :events;
};

AmendLimitOrder    :{[event]
    events:();
    events,:updateLimitOrder();
    :events;
};

CancelLimitOrder    :{[]
    events:();
    events,:removeLimitOrder();
    :events;
};

CancelLimitOrderBatch   :{[]
    events:();
    events,:CancelLimitOrder each orderIds
};

CancelAllLimitOrders    :{[]

};

NewMarketOrder  :   {[event]

};

