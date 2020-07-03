\l order.q
\d .orderbook
// Instantiate a singleton class of Orderbook
// qtys: represent the different level quantities at their given prices
// agentOffsets: represent the given offsets of a set of agent(s') orders 
// agentSizes: represent the given order sizes of a set of agent(s') orders
// agentOrders: represent a batch of agent orders;
Bids: `qtys`agentOffsets`agentSizes`agentOrders!()
Asks: `qtys`agentOffsets`agentSizes`agentOrders!()
OrderBook:`BUY`SELL!(Bids;Asks);

MakeDepthUpdateEvent :{[]
    :();
    }


MakeTradeEvent  :{[]

        :MakeEvent[];
};

// Orderbook Utilities
// -------------------------------------------------------------->

// Sets the order qtys on a given side to the target
getQtys  : {[side]:.orderbook.OrderBook[side][`qtys]};
updateQtys  : {[side;nxt].[`.orderbook.OrderBook;side,`qtys;,;nxt]};

// Sets the order qtys on a given side to the target
getOffsets  : {[side]:.orderbook.OrderBook[side][`agentOffsets]};
updateOffsets  : {[side;nxt].[`.orderbook.OrderBook;side,`agentOffsets;,;nxt]};

// Sets the order qtys on a given side to the target
getSizes  : {[side]:.orderbook.OrderBook[side][`agentSizes]};
updateSizes  : {[side;nxt].[`.orderbook.OrderBook;side,`agentSizes;,;nxt]};

// Sets the order qtys on a given side to the target
getOrders  : {[side]:.orderbook.OrderBook[side][`agentOrders]};

// Sets all values to 0 in list or matrix
// where value is less than zero (negative)
clip :{[x](x>0)*abs x}; // TODO move to util

// Converts a list of lists into a equidimensional
// i.e. equal dimensional matrix
padm  :{[x]:x,'(max[c]-c:count each x)#'0}[x]

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
                maxNumUpdates: max count flip offsets;

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
                nonAgentQtys[;1+til maxNumUpdates]: clip[(offsets[;1] - lshft)]; //TODO clip etc
                nonAgentQtys[;lpad]:clip[qtys - lshft]; // TODO clip etc.

                lvlNonAgentQtys: sum flip nonAgentQtys;
                derivedDeltas: floor[(nonAgentQtys%lvlNonAgentQtys)*dlt][::;-1];

                // Update the new offsets to equal the last
                // offsets + the derived deltas
                newOffsets: clip[offsets + derivedDeltas] // TODO clip etc
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
    :MakeDepthEvent[;nextAsks;nextBids];
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
                        .orderbook.OrderBook[negSide][`qtys][price] -:qty;
                    ];
                    events,:.orderbook.MakeTradeEvent[time;side;qty;price];
                    decrementOffsets[negSide, price; qty];
                    qty:0;
                ];[
                
                    qty-:smallestOffset;

                    $[isAgent;
                        // If the order was made by an agent the first level of
                        // the orderbook should represent the change otherwise not
                        // captured.
                        .orderbook.OrderBook[negSide][`qtys][price] -:smallestOffset;
                    ];
                    // Make a trade event that represents the trade taking up the
                    // offset space;
                    events,:.orderbook.MakeTradeEvent[time;side;qty;price];
                    nextAgentOrder: exec from .order.Order where id=smallestOffsetId;
                    $[qty>=nextAgentOrder[`osize];
                        [
                            // If the quantity to be traded is greater than or
                            // equal to the next agent order, fill the agent order
                            // updating its state and subsequently removing it from
                            // the local buffer, adding fill to account and creating
                            // respective trade event. 
                            events,:fillLimitOrder[nextAgentOrder[`id];time]; // TODO update
                            events,:.account.ApplyFill[];
                            events,:.orderbook.MakeTradeEvent[];
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
                    bestQty: .orderbook.OrderBook[negSide][`qtys][price];
                    $[qty<=bestQty;[
                        .orderbook.OrderBook[negSide][`qtys][price] -:qty; // TODO update lvl qty
                        events,: .orderbook.MakeTradeEvent[];
                        events,: .account.ApplyFill[];
                        qty:0;
                    ];[
                        delete .orderbook.OrderBook[negSide][`qtys][price];
                        events,:.orderbook.MakeTradeEvent[]; // TODO
                        events,:.account.ApplyFill[]; // TODO
                        qty-:bestQty;
                    ]]
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
    :qty events;       
};


// Limit Order Logic
// -------------------------------------------------------------->