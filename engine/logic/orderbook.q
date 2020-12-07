
.engine.logic.orderbook.Level :{
        / ld[`time]:l`time;
        / show price;
        / show side
        c:0!.engine.model.orderbook.Get[enlist(in;`price;s`price)]; //TODO impl max depth
        / dlts:deltas'[(l`hqty`qty;c`hqty`qty)];
        // TODO chenge to any dlts
        $[(count[c]>0);[
                s[`nqty]:s`qty;
                s:lj[`side`price xgroup s;`side`price xkey c];
                dlts:(-/)(0!s)[`qty`nqty];
                dneg:sum'[{x where[x<0]}'[dlts]];
                $[any[dneg<0];[ // TODO also check for side
                        p:key[s]`price;
                        o:.engine.model.order.Get[((=;`okind;1);(in;`price;p);(in;`state;(0 1));(>;`oqty;0))];
                        op:distinct (0!o)`price;
                        cnd:in[p;op] and (dneg<0);
                        crs:(0!s) where not cnd;

                        // TODO get last qty by time check!!!
                        cl:`price`side`qty;
                        .engine.model.orderbook.Update[flip cl!crs[cl]];
                        .engine.Emit[`depth]'[last'[crs`time];flip crs[cl]];

                        if[any[cnd];[
                                s:(0!s) where cnd;        
                                s[`iId]:i[`iId];
                                s[`time]:max'[s`time];
                                dneg:dneg where cnd;
                                // upsert non order levels here
                                s:`time xasc 0!lj[`side`price xgroup o;`side`price xkey s]; // TODO grouping

                                // Deltas in visqty etc 
                                msk:raze[.util.PadM[{x#1}'[count'[s`oId]]]];

                                // Pad state into a matrix
                                // for faster operations
                                pdcl:`oId`side`price`offset`oqty`lqty`reduce`acc`state;
                                (s pdcl):.util.PadM'[s pdcl];

                                //  
                                maxN:max count'[s`offset];
                                tmaxN:til maxN;
                                numLvls:count[s`offset];

                                // 
                                shft:sum[s`offset`lqty]; // the sum of the order offsets and leaves
                                mxshft:max'[shft];

                                // The Minimum offset should be the minimum shft
                                // of the preceeding orders in the queue i.e. so
                                // they don't overlap and provided there exists
                                // a hidden order qty it should represent this
                                // offset (hidden order qty derived from data)
                                // is always put at the front of the queue.
                                mnoffset: (0,'-1_'(s`lqty))+raze[.util.PadM[s`hqty]]; // TODO this should be nshft

                                // Derive the non agent qtys that
                                // make up the orderbook // TODO add hqty, iqty to this.
                                // HQTY is excluded from this because the hqty is derived
                                // from historic data and as such the nascent cancellations
                                // are functionally ignored.
                                notAgentQty:flip .util.PadM[raze'[(
                                    0^s[`offset][;0]; // Use the first offset as the first non agent qty
                                    .util.Clip[0^s[`offset][;1_(tmaxN)] - 0^shft[;-1_(tmaxN)]]; //
                                    .util.Clip[s[`vqty]-mxshft] // last qty - maximum shift // TODO
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
                                noffset: {?[x>y;x;y]}'[mnoffset;s[`offset] + offsetdlts];
                                nshft:   s[`lqty]+noffset;
                                
                                // Calculate the new vis qty
                                nvqty:  sum'[raze'[flip[raze[enlist(s`tgt`displayqty)]]]]; // TODO make faster
                                mxnshft:max'[nshft];
                                lsttime:max'[s`time]; // TODO apply to each order
                                numordlvl:count'[noffset];

                                // Update the orders
                                ocols:`oId`price`offset;
                                .engine.model.order.Update[flip ocols!raze'[.util.PadM'[(
                                        s`oId;
                                        raze[{x#y}'[numordlvl;s`price]]; // TODO make faster/fix
                                        noffset;
                                        )]][;where[msk]]];

                                // TODO update vqty
                                // TODO derive nqty rather
                                lvlcols:`price`side`qty`hqty`iqty`vqty;
                                .engine.model.orderbook.Update[flip lvlcols!raze'[.util.PadM'[(
                                        s`price;
                                        s`side;
                                        s`qty;
                                        s`hqty;
                                        s`iqty;
                                        nvqty)]]];

                                .engine.Emit[`depth]'[s[`time];flip s[`price`side`qty]];
                        ]];
                ];[
                        cl:`price`side`qty;
                        .engine.model.orderbook.Update[flip cl!s[cl]];
                        .engine.Emit[`depth]'[t;flip s[cl]];
                ]];
        ];[
                / No update occurs, should emit?
                cl:`price`side`qty;
                .engine.model.orderbook.Update[flip cl!s[cl]];
                .engine.Emit[`depth]'[t;flip s[cl]];
        ]];

        .engine.model.orderbook.Delete[enlist(<=;(+;`qty;(+;`hqty;(+;`iqty;`vqty)));0)]; //TODO impl max depth
        };

