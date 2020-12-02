
.engine.logic.orderbook._Level :{[i;l]
        if[count[l`datum]=3;ld:`side`price`qty!l`datum];
        / show price;
        / show side
        c:0!.engine.model.orderbook.GetLevel[enlist(=;`price;ld`price)]; //TODO impl max depth
        / dlts:deltas'[(l`hqty`qty;c`hqty`qty)];
        // TODO chenge to any dlts
        $[(count[c]>0);[
                o:.engine.model.order.GetOrder[enlist()];
                show o;
                $[count[o]>0;[
                        n:count[o];
                        tn:til n;

                        // Get the shift
                        shft:sum'[o`offset`leaves]; // the sum of the order offsets and leaves
                        mxshft:max[shft];

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

                        .engine.model.order.UpdateOrder o;
                        .engine.model.orderbook.UpdateLevel l;

                ];[
                        .engine.model.orderbook.UpdateLevel l;
                ]];
                // todo derive visible qty 
                // todo remove if o
                cl:`side`price`qty`time;
                .engine.Emit[`orderbook;cl!l[cl]];
        ];[
                / No update occurs, should emit?
                .engine.model.orderbook.OrderBook,: flip ld;
                / .engine.model.orderbook.UpdateLevel[];
                / .engine.Emit[`orderbook] l;
        ]];

        / .engine.model.orderbook.PruneOrderBook[];
        / .engine.model.order.PruneOrders[];        
        };

.engine.logic.orderbook.Level:{[i;l] .engine.logic.orderbook._Level[i]'[flip l]}