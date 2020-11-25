
.engine.services.trade.Trade:{
    nside:neg[side];
    isagnt:count[account]>0;
    
    ciId:instrument`instrumentId; // TODO use accountref
    caId:account`accountId;
    
    // Join the opposing side of the orderbook with the current agent orders
    // at that level, creating the trade effected state
    state:0!?[`.order.OrderBook;enlist(=;`side;nside);0b;()];  
    aqty:sum[state[`iqty`hqty`vqty]];
    thresh:sums[aqty];
    rp:(thresh-prev[thresh])-(thresh-fillQty);
    state[`thresh]:thresh; 
    // Derive the amount that will be replaced per level
    rp1:min[fillQty,first[aqty]]^rp; // TODO check that rp is correct
    state[`rp]:rp1; 
    state:state[where (state`rp)>0];

    // TODO select by offset aswell
		ordrs:.engine.model.orders.GetOrders[];
    
    // Hidden order qty i.e. derived from data 
    // is always at the front of the queue.
    // Iceberg orders placed by agents have a 
    // typical offset and function like normal orders
    // except they aren't visible.

    // TODO count orders where filled >0;

    $[count[odrs]>0;[
        state:0!{$[x>0;desc[y];asc[y]]}[neg[side];ij[1!state;`price xgroup (update oprice:price, oside:side from odrs)]]; 
        msk:raze[.util.PadM[{x#1}'[count'[state`orderId]]]];
        state[`accountId`instrumentId]:7h$(state[`accountId`instrumentId]);
        // Pad state into a matrix
        // for faster operations
        padcols:(`offset`size`leaves`displayqty`reduce`orderId`side, // TODO make constant?
            `accountId`instrumentId`price`status);
        (state padcols):.util.PadM'[state padcols]; // TODO make faster?
        .trade.test.pstate:state;

        // Useful counts 
        maxN:max count'[state`offset];
        tmaxN:til maxN;
        numLvls:count[state`offset];

        // TODO new display qty
        // Calculate new shifts and max shifts
        shft:sum[state`offset`leaves]; // the sum of the order offsets and leaves
        mxshft:{$[x>1;max[y];x=1;y;0]}'[maxN;shft]; // the max shft for each price

        // TOOD update comments
        // The delta in the visual qty is equal to sum of the change in the open display qty
        // and the total fill qty that isnt used to fill the hqty or iqty of the previous
        // queue instantiation.
        // The qty on the other hand is equal to the sum of the amount of the visual qty
        // that isn't made up of the new displayqty. 

        // Derive the new quantitites that are representative of the change in the state
        // of the orders and orderbook when the given trade occurs.
        nhqty:          .util.Clip[(-/)state`hqty`rp]; // Derive the new hidden qty
        nleaves:        .util.Clip[{?[x>z;(y+z)-x;y]}'[state`rp;state`leaves;state`offset]]; // TODO faster/fix
        ndisplayqty:    .util.Clip[{?[((x<y) and (y>0));x;y]}'[state[`displayqty];nleaves]]; // TODO faster/fix
        niqty:          sum'[nleaves-ndisplayqty]; // The new order invisible qty = leaves - display qty
        displaydlt:     (ndisplayqty-state[`displayqty]); // Derive the change in the order display qty
        leavesdlt:      (nleaves-state[`leaves]); // Derive the change in the order leaves
        hqtydlt:        (nhqty-state[`hqty]); // Derive the change in hidden order qty
        noffset:        .util.Clip[((-/)state`offset`rp)]; // Subtract the replaced amount and clip<0 (offset includes hqty)
        nqty:           .util.Clip[((-/)state`qty`rp)-(sum'[leavesdlt]+hqtydlt)]; // qty -rp - qty attributed to other qtys
        nvqty:          nqty+sum'[ndisplayqty]; // Derive the new visible qty as order display qty + the new qty from above
        nshft:          nleaves+noffset; // 
        nmxshft:        {$[x>1;max[y];x=1;y;0]}'[maxN;nshft]; // the max shft for each price TODO make faster
        nfilled:        state[`size] - nleaves; // New amount that is filled (in total)
        accdlts:        state[`leaves] - nleaves; // The new amounts that will attribute to fills.
        nobupd:         count[nhqty];

        // Derived the boolean representation of partially and 
        // fully filled orders within the matrix of orders referenced
        // above. They should not overlap.f
        // get fully filled and then set all others that dont conform to 
        // partially filled, by simple exclusion conditional.
        nstatus:1*((state[`offset]<=state[`rp])and(nshft<=state[`rp])); // todo mask
        nstatus+:2*((sums[state[`offset]]<=state[`rp])and not nstatus); // todo mask

        // Derive the non agent qty's from the state such that quantities
        // such as the visible resultant trades can be derived etc.
        notAgentQty: .util.PadM[raze'[flip(
                0^state[`hqty]; // hidden qty
                0^(state[`offset][;0] - 0^state[`hqty]); // first offset
                .util.Clip[0^state[`offset][;1_(tmaxN)] - 0^shft[;-1_(tmaxN)]]; // middle offset + shft
                .util.Clip[state[`vqty]-mxshft] // last qty - maximum shift
            )]];

        // Derive the splt which is the combination of the leaves of all orders at 
        // a level with the interspaced display qty etc. which is used to derive the
        // disparate quantities of trades that occur at a given price level.
        splt:{$[count[x];1_(raze raze'[(2#0),(0^x);y]);y]}'[state`leaves;notAgentQty];

        // Derives the non-zero trade qtys that occur as a result of the replaced amount 
        // returns the quantities by price level.
        tqty:{s:sums[y];q:.util.Clip[?[(x-s)>=0;y;x-(s-y)]];q where[q>0]}'[state`rp;splt]; 
        numtds:count[raze[tqty]];
        numtdslvl:count'[tqty];
        // TODO move into own function.
        state[`mside]:nside; // TODO changes
        state[`tside]:side; // TODO changes
 
        // Derive and apply trades
        // -------------------------------------------------->

        // TODO emit trade events
        / .order.applyNewTrades . raze'[( // TODO derive the prices at each level before
        /         numtds#state`tside; // more accurate derivation
        /         raze[{x#y}'[numtdslvl;state`price]]; // more accurate derivation
        /         tqty;
        /         numtds#fillTime)];
        
        // Derive and apply order updates
        // -------------------------------------------------->
        
        // Derives the set of order updates that will occur
        // as a result of the trade and amends them 
        // accordingly
				.engine.model.order.UpdateOrder'[raze'[(
                state`orderId;
                state`oprice;
                noffset;
                nleaves;
                ndisplayqty;
                nstatus;
                state`time)][;where[msk]]];
        // Todo emit events
 
        // Derive and apply Executions
        // -------------------------------------------------->

        // Apply the set of fills that would satisfy the 
        // amount of liquidity that is being removed from
        // the orderbook.
        .engine.logic.account.Fill[raze'[(
                numLvls#ciId; // instrumentId
                numLvls#caId; // accountId
                state`tside; 
                state`price;
                sum'[tqty];
                count[tqty]#reduce;
                numLvls#fillTime)]];
         
        // Check to see if the leaves of any maker orders
        // hase been update by deriving the delta and if there
        // exists any where the delta is not 0 pass those through
        // to the .order.applyMakerFills function.
        flldlt:(nleaves-state`leaves);
        isfll:raze[flldlt]<>0;
        if[any[isfll];[
								.engine.logic.account.Fill[raze'[(
                    state`instrumentId;
                    state`accountId;
                    state`oside;
                    state`oprice;
                    abs[flldlt];
                    state`reduce;
                    state`time)][;where[msk and isfll]]]; 
            ]];
        // emit fill events

        // Derive and apply order book updates
        // -------------------------------------------------->
        .engine.logic.orderbook.Level'[raze'[(
                state`price;
                state`mside;
                nqty;
                nhqty;
                niqty;
                nvqty;
                nobupd#fillTime)]];
        // emit depth update events

    ];if[count[state]>0;[
        // If no orders exist in the orderbook 
        // and yet the trade still executes
        // TODO test
        .engine.logic.orderbook.Level'[raze'[(
                state`price;
                state`mside;
                nqty;
                nhqty;
                niqty;
                nvqty)]];
        // emit depth update events        
    ]]];
    
    };



