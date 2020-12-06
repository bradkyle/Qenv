
// TODO set max price for sums
// Hidden order qty i.e. derived from data 
// is always at the front of the queue.
// Iceberg orders placed by agents have a 
// typical offset and function like normal orders
// except they aren't visible.
.engine.logic.trade.Take:{[s;t;i;x]
    // Get the current levels for the side  
    s:0!.engine.model.orderbook.GetLevel[((in;`side;side);(>;`qty;0);(<;(+\;`qty);sum[m`qty]))]; //TODO impl max depth

    aqty:sum[s[`iqty`hqty`vqty]];
    thresh:sums[aqty];

    // Join the opposing side of the orderbook with the current agent orders
    // at that level, creating the trade effected s
    aqty:sum[s[`iqty`hqty`vqty]];
    thresh:sums[aqty];
    rp:(thresh-prev[thresh])-(thresh-m`size);
    s[`thresh]:thresh; 

    // Derive the amount that will be replaced per level
    s[`rp]:min[(t[`size];first[aqty])]^rp; // TODO check that rp is correct

    // Get the current active orders at the prices 
    o:.engine.model.order.GetOrder[(
        (=;`okind;1);
        (in;`price;s[`price] where (s[`rp]>0));
        (in;`status;(0 1));(>;`oqty;0))];

    $[count[o]>0;[
        s:0!{$[x>0;desc[y];asc[y]]}[neg[m`side];ij[1!s;`price xgroup (update oprice:price, oside:side from o)]]; 
        msk:raze[.util.PadM[{x#1}'[count'[s`orderId]]]];

        // Pad s into a matrix
        // for faster operations
        / padcols:(`offsem`size`lqty`dqty`reduce`orderId`side, // TODO make constant?
        /     `accountId`instrumentId`price`status);
        / (s padcols):.util.PadM'[s padcols]; // TODO make faster?

        // Useful counts 
        maxN:max count'[s`offset];
        tmaxN:til maxN;
        numLvls:count[s`offset];

        // TODO new display qty
        // Calculate new shifts and max shifts
        shft:sum[s`offsem`lqty]; // the sum of the order offsets and lqty
        mxshft:{$[x>1;max[y];x=1;y;0]}'[maxN;shft]; // the max shft for each price

        // TOOD update comments
        // The delta in the visual qty is equal to sum of the change in the open display qty
        // and the total fill qty that isnt used to fill the hqty or iqty of the previous
        // queue instantiation.
        // The qty on the other hand is equal to the sum of the amount of the visual qty
        // that isn't made up of the new dqty. 

        // Derive the new quantitites that are representative of the change in the s
        // of the orders and orderbook when the given trade occurs.
        nhqty:          .util.Clip[(-/)s`hqty`rp]; // Derive the new hidden qty
        nlqty:          .util.Clip[{?[x>z;(y+z)-x;y]}'[s`rp;s`lqty;s`offset]]; // TODO faster/fix
        ndqty:          .util.Clip[{?[((x<y) and (y>0));x;y]}'[s[`dqty];nlqty]]; // TODO faster/fix
        niqty:          sum'[nlqty-ndqty]; // The new order invisible qty = lqty - display qty
        displaydlt:     (ndqty-s[`dqty]); // Derive the change in the order display qty
        lqtydlt:        (nlqty-s[`lqty]); // Derive the change in the order lqty
        hqtydlt:        (nhqty-s[`hqty]); // Derive the change in hidden order qty
        noffset:        .util.Clip[((-/)s`offsem`rp)]; // Subtract the replaced amount and clip<0 (offset includes hqty)
        nqty:           .util.Clip[((-/)s`qty`rp)-(sum'[lqtydlt]+hqtydlt)]; // qty -rp - qty attributed to other qtys
        nvqty:          nqty+sum'[ndqty]; // Derive the new visible qty as order display qty + the new qty from above
        nshft:          nlqty+noffset; // 
        nmxshft:        {$[x>1;max[y];x=1;y;0]}'[maxN;nshft]; // the max shft for each price TODO make faster
        nfilled:        s[`oqty] - nlqty; // New amount that is filled (in total)
        accdlts:        s[`lqty] - nlqty; // The new amounts that will attribute to fills.
        nobupd:         count[nhqty];

        // Derived the boolean representation of partially and 
        // fully filled orders within the matrix of orders referenced
        // above. They should not overlap.f
        // get fully filled and then set all others that dont conform to 
        // partially filled, by simple exclusion conditional.
        nstatus:1*((s[`offset]<=s[`rp])and(nshft<=s[`rp])); // todo mask
        nstatus+:2*((sums[s[`offset]]<=s[`rp])and not nstatus); // todo mask

        // Derive the non agent qty's from the s such that quantities
        // such as the visible resultant trades can be derived etc.
        notAgentQty: .util.PadM[raze'[flip(
                0^s[`hqty]; // hidden qty
                0^(s[`offset][;0] - 0^s[`hqty]); // first offset
                .util.Clip[0^s[`offset][;1_(tmaxN)] - 0^shft[;-1_(tmaxN)]]; // middle offset + shft
                .util.Clip[s[`vqty]-mxshft] // last qty - maximum shift
            )]];

        // Derive the splt which is the combination of the lqty of all orders at 
        // a level with the interspaced display qty etc. which is used to derive the
        // disparate quantities of trades that occur at a given price level.
        splt:{$[count[x];1_(raze raze'[(2#0),(0^x);y]);y]}'[s`lqty;notAgentQty];

        // Derives the non-zero trade qtys that occur as a result of the replaced amount 
        // returns the quantities by price level.
        tqty:{s:sums[y];q:.util.Clip[?[(x-s)>=0;y;x-(s-y)]];q where[q>0]}'[s`rp;splt]; 
        numtds:count[raze[tqty]];
        numtdslvl:count'[tqty];
        // TODO move into own function.
        s[`mside]:nside; // TODO changes
        s[`side]:m`side; // TODO changes
 
        // Derive and apply trades
        // -------------------------------------------------->

        // TODO emit trade events
        .engine.Emit[`trade] raze'[( // TODO derive the prices at each level before
                numtds#s`tside; // more accurate derivation
                raze[{x#y}'[numtdslvl;s`price]]; // more accurate derivation
                tqty;
                numtds#m`time)];
        
        // Derive and apply order updates
        // -------------------------------------------------->
        
        // Derives the set of order updates that will occur
        // as a result of the trade and amends them 
        // accordingly
				o:raze'[(s`orderId;s`oprice;noffset;nlqty;ndqty;nstatus;s`time)][;where[msk]];
        .engine.model.order.UpdateOrder o;
        .engine.Emit[`order;t;o];
        
 
        // Derive and apply Executions
        // -------------------------------------------------->

        // Check to see if the lqty of any maker orders
        // hase been update by deriving the delta and if there
        // exists any where the delta is not 0 pass those through
        // to the .order.applyMakerFills function.
        flldlt:(nlqty-s`lqty);
        isfll:raze[flldlt]<>0;
        if[any[isfll];[
                nfll:count[flldlt];
								x:raze'[(
                    i`iId;
                    s`acc;
                    s`oside;
                    s`oprice;
                    abs[flldlt];
                    s`reduce;
                    nfll#m`time)];
                .engine.logic.account.Fill[x];
            ]];

        // Derive and apply order book updates
        // -------------------------------------------------->
        l:raze'[(s`price;s`mside;nqty;nhqty;niqty;nvqty;nobupd#m`time)];
        .engine.model.orderbook.UpdateLevel l;
        .engine.Emit[`depth;t;l];


        ];[

        ]];

        // Return the fills that would have occurred
        // Apply the set of fills that would satisfy the 
        // amount of liquidity that is being removed from
        // the orderbook.
        .engine.logic.fill.ApplyFills[raze'[(
                numLvls#ciId; // instrumentId
                numLvls#caId; // accountId
                state`tside; 
                state`price;
                sum'[tqty];
                count[tqty]#reduce;
                numLvls#fillTime)]]
    
    };

// TODO process multiple trades
.engine.logic.trade.Trade:{[t;i;x]
        s:(x[;0]>0);
        b:x where s;
        a:x where not s;
        .engine.logic.trade.Take[1;t where b;i;x where b];
        .engine.logic.trade.Take[-1;t where a;i;x where a];
    };


.engine.logic.trade.Match:{[i;a;m]
        s:(x[;0]>0);
        b:x where s;
        a:x where not s;
        f:();
        f,:.engine.logic.trade.Take[1;t where b;i;x where b];
        f,:.engine.logic.trade.Take[-1;t where a;i;x where a];
      
        // Derive and apply Executions
        // -------------------------------------------------->

        // Apply the set of fills that would satisfy the 
        // amount of liquidity that is being removed from
        // the orderbook.
        if[count[f]>0;.engine.logic.account.Fill[f]];
    };








