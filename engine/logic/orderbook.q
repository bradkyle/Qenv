
.engine.logic.orderbook.Level :{[i;l]
        ld:`side`price`qty!flip l[`datum];
        c:0!.engine.model.orderbook.GetLevel[enlist(=;`price;ld`price)]; //TODO impl max depth

        // Update the depth 
        // change to get levels
        // TODO uj new event
        // ?[`.order.OrderBook;((=;`side;1);(<;1000;(+\;`vqty)));0b;`price`side`qty`vqty`svqty!(`price;`side;`qty;`vqty;(+\;`vqty))]
        state:`time xasc 0!uj[lj[`side`price xgroup d;`side`price xgroup ob];`side`price xgroup o]; // TODO grouping

        dlts:1_'(deltas'[raze'[flip[raze[enlist(state`qty`nqty)]]]]);
        .depth.test.state:state;
        state[`tgt]: last'[state`nqty]; // TODO change to next? 
        .depth.test.OBf:.order.OrderBook;
        .depth.test.dlts:dlts;

        // Derive the hidden dlts as merely the sum of detected
        // hidden order quantities at each level, because they 
        // are derived from trades, they can only be increased.
        if[count[state`nhqty]>0;state[`hqty]+:sum'[.util.PadM[state`nhqty]]];

        dneg:sum'[{x where[x<0]}'[dlts]];
        $[(count[dneg]>0);[
                // Deltas in visqty etc 
                msk:raze[.util.PadM[{x#1}'[count'[state`orderId]]]];
                // Pad state into a matrix
                // for faster operations
                padcols:(`offset`size`leaves`reduce`orderId`side, // TODO make constant?
                    `accountId`instrumentId`price`status);
                (state padcols):.util.PadM'[state padcols];
                .depth.test.pstate:state;

                maxN:max count'[state`offset];
                tmaxN:til maxN;
                numLvls:count[state`offset];

                shft:sum[state`offset`leaves]; // the sum of the order offsets and leaves
                mxshft:max'[shft];
                .depth.test.shft:shft;

                // The Minimum offset should be the minimum shft
                // of the preceeding orders in the queue i.e. so
                // they don't overlap and provided there exists
                // a hidden order qty it should represent this
                // offset (hidden order qty derived from data)
                // is always put at the front of the queue.
                mnoffset: (0,'-1_'(state`leaves))+raze[.util.PadM[state`hqty]]; // TODO this should be nshft
                .depth.test.mnoffset:mnoffset;

                // Derive the non agent qtys that
                // make up the orderbook // TODO add hqty, iqty to this.
                // HQTY is excluded from this because the hqty is derived
                // from historic data and as such the nascent cancellations
                // are functionally ignored.
                notAgentQty:flip .util.PadM[raze'[(
                    0^state[`offset][;0]; // Use the first offset as the first non agent qty
                    .util.Clip[0^state[`offset][;1_(tmaxN)] - 0^shft[;-1_(tmaxN)]]; //
                    .util.Clip[state[`vqty]-mxshft] // last qty - maximum shift // TODO
                    )]];
                .depth.test.notAgentQty:notAgentQty;
                .depth.test.ob:.order.OrderBook;

                // Derive the deltas in the agent order offsets as if there
                // were a uniform distribution of cancellations throughout
                // the queue.
                // Because the offset is cumulative i.e. offsets further back
                // in the queue are progressively more affected by the changes
                // in the offsets of previous orders, the cumulative sum of the
                // offsets is used to derive the offsetdlts
                offsetdlts: sums'[-1_'(floor[(notAgentQty%(sum'[notAgentQty]))*dneg])]; // TODO sums
                
                // Offset deltas are derived adn added to the current offset
                noffset: {?[x>y;x;y]}'[mnoffset;state[`offset] + offsetdlts];
                nshft:   state[`leaves]+noffset;
                
                // Calculate the new vis qty
                nvqty:  sum'[raze'[flip[raze[enlist(state`tgt`displayqty)]]]]; // TODO make faster
                mxnshft:max'[nshft];
                lsttime:max'[state`time]; // TODO apply to each order
                numordlvl:count'[noffset];

                // Update the orders
                ocols:`orderId`price`offset`leaves`displayqty`status`time;
                .engine.model.order.UpdateOrders[ocols!(0^raze'[.util.PadM'[(
                        state`orderId;
                        raze[{x#y}'[numordlvl;state`price]]; // TODO make faster/fix
                        noffset;
                        state`leaves;
                        state`displayqty;
                        state`status;
                        raze[{x#y}'[numordlvl;lsttime]])]][;where[msk]])];
                // TODO emit events

                lvlcols:`price`side`tgt`hqty`iqty`vqty`time;
                .engine.model.orderbook.UpdateLevels[lvlcols!(0^raze'[.util.PadM'[(
                        state`price;
                        state`side;
                        state`tgt;
                        state`hqty;
                        state`iqty;
                        nvqty;
                        lsttime)]])];
                // TODO emit events

            ];[
                state[`vqty]:  sum'[raze'[flip[raze[enlist(state`tgt`displayqty)]]]];                
                lvlcols:`price`side`tgt`hqty`iqty`vqty`time;                
                .engine.model.orderbook.UpdateLevels[flip(raze'[(
                        state`price;
                        state`mside;
                        nqty;
                        nhqty;
                        niqty;
                        nvqty)])];
                // TODO emit Eventss

            ]];

    };
