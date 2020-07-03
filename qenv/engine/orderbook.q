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
            
            // C
            $[((count dlt)>0 & (count getOrders[side])); // TODO check
            [
                numLvls:count qtys;
                maxNumUpdates: 0;
                offsets: getOffsets[side]; // TODO padding
                sizes: getSizes[side]; // TODO padding

                / Calculate the shifted offsets, which infers
                / the amount of space between each offset
                shft: sizes + offsets;

                / Initialize non agent quantities matrix
                / The first column is set to the first lvl_offset
                / The last column is set to the size of the level minus the size of the last offset + order size
                / adn all levels in between this are set to the lvl_offsets minus the shifted offset 
                nonAgentQtys: (numLvls, maxNumUpdates+1)#0;
                nonAgentQtys[;0]: offsets[;0];
                nonAgentQtys[;1:maxNumUpdates]: (offsets[;1] - shft[;-1]); //TODO clip etc
                nonAgentQtys[;-1]:(qtys - shft[;-1]) // TODO clip etc.

                lvlNonAgentQtys: sum flip nonAgentQtys;
                derivedDeltas: floor[(nonAgentQtys%lvlNonAgentQtys)*dlt][::;-1];

                // Update the new offsets to equal the last
                // offsets + the derived deltas
                newOffsets: (offsets + derivedDeltas) // TODO clip etc
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

// Limit Order Logic
// -------------------------------------------------------------->

// Market Order and Trade Logic
// -------------------------------------------------------------->

