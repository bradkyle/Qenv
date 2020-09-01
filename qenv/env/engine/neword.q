
// Common Utilities
// -------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
deriveOrderUpdates  :{[rp;nshft;poffset;nleaves;porderId;pprice]
    
    raze[pprice];
    raze[porderId];
    raze[poffset];
    Clip[raze[nleaves]]
    raze[pstatus]

    // Delete from orderbook where in filled, cancelled, triggered etc.
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
deriveAccountFills  :{
    
    };

applyAccountFills   :{
    flls:.order.deriveAccountFills[];
    if[count[flls]>0;[
        .order.applyFillWrapper[flls];
        .order.incSelfFillWrapper[flls];
        ]];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
applyPublicTrades :{[pleaves;nagentQty;rp]
    splt:{$[count[x];1_(raze raze'[0,(0^x);y]);y]}'[pleaves;nagentQty];
    qty:{s:sums[y];Clip[?[(x-s)>=0;y;x-(s-y)]]}'[rp;splt];
    numtd:count'[qty];


    };


// Process Depth update
// -------------------------------------------------------------->

// TODO move to C for increased speed.
// TODO make functionality for representing hidden/iceberg orders!!!
// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
ProcessDepth        :{[]

    // TODO uj new event
    // ?[`.order.OrderBook;((=;`side;1);(<;1000;(+\;`vqty)));0b;`price`side`qty`vqty`svqty!(`price;`side;`qty;`vqty;(+\;`vqty))]
    state:uj[?[`.order.OrderBook;(=;`side;nside);0b;()]; // TODO grouping
       ?[`.order.Order;.util.cond.isActiveLimit[();nside];0b;()];`price;()]; // TODO grouping

    dlts:1_'(deltas'[raze'[flip[raze[enlist(qty;size)]]]]);
    nqty: last'[size];
    poffset:PadM[offset];
    pleaves:PadM[leaves];
    porderId:PadM[orderId];
    paccountId:PadM[accountId];
    pprice:PadM[oprice];
    maxN:max count'[offset];
    numLvls:count[offset];

    tgt: last'[size]; 
    dneg:sum'[{x where[x<0]}'[dlts]];
    shft:pleaves+poffset;

    nagentQty: flip PadM[raze'[(
        poffset[;0]; 
        Clip[poffset[;1_(til first maxN)] - shft[;-1_(til first maxN)]];
        Clip[qty-max'[shft]]
        )]]; // TODO what qty is this referring to
    mnoffset: (0,'-1_'(shft));

    offsetdlts: -1_'(floor[(nagentQty%(sum'[nagentQty]))*dneg]);

    noffset: {?[x>y;x;y]}'[mnoffset;poffset + offsetdlts];
    nshft: pleaves+noffset;
    nvqty: sum'[raze'[flip[raze[enlist(tgt;pleaves)]]]]
    vqty: {?[x>y;x;y]}'[mxshft;nvqty] // todo take into account mxnshift

    .order.applyOrderUpdates[ // TODO 
        pprice;
        porderId;
        noffset;
        pleaves;
        pstatus;
        ();()];

    .order.applyNewOrderBook[
        state`price;
        state`side;
        tgt;
        vqty]; 
    };


// Process Trades/Market Orders
// -------------------------------------------------------------->
// TODO move to C for increased speed.
// Constructs matrix representation of trades that need to take place 
// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory // TODO make viable for batch insertions!
ProcessTrade        :{[instrument;account;side;fillQty;reduce;fillTime]
    nside:neg[side];
    isagnt:not[null[account]];
    // Join the opposing side of the orderbook with the current agent orders
    // at that level, creating the trade effected state
    state:![
        ?[`.order.OrderBook;
          enlist(=;`side;nside);0b;`price`side`qty`vqty`svqty!(`price;`side;`qty;`vqty;(+\;`vqty))];();0b;
          `price`side`qty`vqty`rp!(`price;`side;`qty;`vqty;(-;(-;`svqty;(:':;`svqty));(-;`svqty;fillQty)))];

    // Derive the amount that will be replaced per level
    state[`rp]:min[fillQty,first[state]`vqty]^(state`rp);
    state:state[where (state`rp)>0];
    state[`tgt]:(-/)state`qty`rp;
    odrs:?[.order.Order;.util.cond.isActiveLimit[nside;state`price];0b;()];

    $[count[odrs]>0;[
        state:0!{$[x>0;desc[y];asc[y]]}[neg[side];lj[1!state;`price xgroup odrs]]; 
        msk:count'[state`orderId];

        // Pad state into a matrix
        // for faster operations
        padcols:(`offset`size`leaves`reduce`orderId, // TODO make constant?
            `accountId`instrumentId`price`status);
        (state padcols):.util.PadM'[state padcols];

        // Useful counts 
        maxN:max count'[state`offset];
        tmaxN:til maxN;
        numLvls:count[state`offset];

        // Calculate new shifts and max shifts
        shft:sum[state`offset`leaves]; // the sum of the order offsets and leaves
        mxshft:{$[x>1;max[y];x=1;y;0]}'[maxN;shft]; // the max shft for each price
        noffset: .util.Clip[(-/)state`offset`rp]; // Subtract the replaced amount and clip<0
        nleaves: {?[x>z;(y+z)-x;y]}'[state`rp;state`leaves;state`offset]; // TODO faster

        // Calculate the new vis qty
        nvqty: sum'[raze'[flip[raze[enlist(state`tgt`leaves)]]]];

        // Derive the non agent qtys that
        // make up the orderbook
        nagentQty: flip .util.PadM[ // TODO check
            raze'[(
                0^state[`offset][;0]; // Use the first offset as the first non agent qty
                .util.Clip[0^state[`offset][;1_(tmaxN)] - 0^shft[;-1_(tmaxN)]]; //
                .util.Clip[state[`qty]-mxshft]
            )]];
        / nfilled: psize - nleaves; // New amount that is filled
        accdlts: state[`leaves] - nleaves; // The new Account deltas
        vqty: ?[mxshft>nvqty;mxshft;nvqty]; // The new visible quantity

        // Derived the boolean representation of partially and 
        // fully filled orders within the matrix of orders referenced
        // above. They should not overlap.
        partfilled:`boolean$(raze[(sums'[poffset]<=rp)-(nshft<=rp)]); // todo mask
        fullfilled: `boolean$(raze[(poffset<=rp)and(nshft<=rp)]); // todo mask 
        ordUpd:();
        .order.Order,:ordUpd;

        // Make order updates
        mflls:[];

        if[count[mflls]>0;[
            if[isagnt and (account[`accountId] in mflls[`accountId]);
                .account.IncSelfFill[accountId;count[mflls];sum[sflls`filled]]];
                .account.ApplyFill[account;instrument;side] mflls; // TODO change to take order accountIds, and time!
                ]];
  
        .pipe.event.AddTradeEvent[[];time]; // TODO derive trades

        if[isagnt;.account.ApplyFill[[]]]; // TODO

        .order.OrderBook,:(state`price`side`tgt`vqty); // TODO fix here
    ];[.order.OrderBook,:(state`price`side`tgt`vqty)]]; // TODO fix
    ![`.order.OrderBook;enlist(<=;`vqty;0);0;`symbol$()];
    .pipe.event.AddDepthEvent[]; // TODO add snapshot update?
    };

// Process New Orders
// -------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param i     (Instrument) The instrument for which this order is placed
/  @param o     (Order) The order that is being placed.
/  @param a    (Account) The account to which this order belongs.
/  @param time (datetime) The time at which this order was placed.
/  @return (Inventory) The new updated inventory
NewOrder            :{[i;o;a;time]
    k:o`type;
    res:$[k=0;  [.order.MarketOrder[x]]; // MARKET ORDER
          k=1;  [.order.LimitOrder[x]]; // LIMIT ORDER
          k=2;  [.order.StopOrder[x]]; // STOP_MARKET_ORDER
          k=3;  [.order.StopOrder[x]]; // STOP_LIMIT_ORDER
          'INVALID_ORDER_TYPE];
    .pipe.event.AddNewOrderEvent[res;time];
    };


// Process Amend Orders
// -------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
AmendOrder          :{[i;o;a;time]
    k:o`type;
    res:$[k=0;  [.engine.MarketOrder[x]]; // MARKET ORDER
          k=1;  [.engine.LIMIT[x]]; // LIMIT ORDER
          k=2;  [.engine.ProcessMarkUpdateEvents[x]]; // STOP_MARKET_ORDER
          k=3;  [.engine.ProcessMarkUpdateEvents[x]]; // STOP_LIMIT_ORDER
          'INVALID_ORDER_TYPE];
    .pipe.event.AddOrderUpdateEvent[res;time];
    };

// Process Cancel Orders
// -------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
CancelOrder         :{[i;o;a;time]
    k:o`type;
    res:$[k=0;  [.engine.ProcessDepthUpdateEvents[x]]; // MARKET ORDER
          k=1;  [.engine.ProcessNewTradeEvents[x]]; // LIMIT ORDER
          k=2;  [.engine.ProcessMarkUpdateEvents[x]]; // STOP_MARKET_ORDER
          k=3;  [.engine.ProcessMarkUpdateEvents[x]]; // STOP_LIMIT_ORDER
          'INVALID_ORDER_TYPE];
    .pipe.event.AddOrderCancelEvent[res;time];
    };


// Process Trades/Market Orders
// -------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
ExecuteStop         :{[instrument;time;stop]

    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
CheckStopOrders   :{[instrument;time]
    ExecuteStop[instrument;time]'[?[`.order.OrderBook;.util.cond.isActiveStop[];0b;()]];
    };