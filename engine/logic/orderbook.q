
.engine.logic.orderbook.Level :{[t;i;l]
        s:`side`price`nqty!flip l;
        / ld[`time]:l`time;
        / show price;
        / show side
        c:0!.engine.model.orderbook.GetLevel[enlist(in;`price;l`price)]; //TODO impl max depth
        / dlts:deltas'[(l`hqty`qty;c`hqty`qty)];
        // TODO chenge to any dlts
        $[(count[c]>0);[
                dlts:1_'(deltas'[raze'[flip[raze[enlist(state`qty`nqty)]]]]);
                dneg:sum'[{x where[x<0]}'[dlts]];
                if[count[dneg]>0;[
                        o:.engine.model.order.GetOrder[((=;`okind;1);(in;`price;l`price);(in;`status;(0 1));(>;`oqty;0))];
                        if[count[o]>0;[
                                s:`time xasc 0!uj[lj[`side`price xkey d;`side`price xkey c];`side`price xgroup o]; // TODO grouping
                                // Deltas in visqty etc 
                                msk:raze[.util.PadM[{x#1}'[count'[state`orderId]]]];
                                // Pad state into a matrix
                                // for faster operations
                                padcols:(`offset`size`leaves`reduce`orderId`side, // TODO make constant?
                                    `accountId`instrumentId`price`status);
                                (state padcols):.util.PadM'[state padcols];

                                maxN:max count'[state`offset];
                                tmaxN:til maxN;
                                numLvls:count[state`offset];

                                shft:sum[state`offset`leaves]; // the sum of the order offsets and leaves
                                mxshft:max'[shft];

                                // The Minimum offset should be the minimum shft
                                // of the preceeding orders in the queue i.e. so
                                // they don't overlap and provided there exists
                                // a hidden order qty it should represent this
                                // offset (hidden order qty derived from data)
                                // is always put at the front of the queue.
                                mnoffset: (0,'-1_'(state`leaves))+raze[.util.PadM[state`hqty]]; // TODO this should be nshft

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
                                .engine.model.order.UpdateOrder[ocols!(0^raze'[.util.PadM'[(
                                        state`orderId;
                                        raze[{x#y}'[numordlvl;state`price]]; // TODO make faster/fix
                                        noffset;
                                        state`leaves;
                                        state`displayqty;
                                        state`status;
                                        raze[{x#y}'[numordlvl;lsttime]])]][;where[msk]])];

                                lvlcols:`price`side`tgt`hqty`iqty`vqty`time;
                                .engine.model.orderbook.UpdateLevel[lvlcols!(0^raze'[.util.PadM'[(
                                        state`price;
                                        state`side;
                                        state`tgt;
                                        state`hqty;
                                        state`iqty;
                                        nvqty;
                                        lsttime)]])];

                                / .engine.Emit[`depth;l[`time];cl!ld[cl]];
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
                                // todo derive visible qty 
                                // todo remove if o
                                / cl:`price`time`side`qty;
                                / .engine.Emit[`depth;l[`time];cl!ld[cl]];
                        ]];
                ]];
        ];[
                / No update occurs, should emit?
                .engine.model.orderbook.Orderbook,:enlist `price`side`qty`hqty`iqty`vqty!(ld`price;ld`side;ld`qty;0;0;0);
                cl:`price`time`side`qty;
                .engine.Emit[`depth;l[`time];cl!ld[cl]];
        ]];

        / .engine.model.orderbook.PruneOrderBook[];
        / .engine.model.order.PruneOrders[];        
        };

