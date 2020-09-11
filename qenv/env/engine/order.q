\l account.q
\l instrument.q
\d .order

BAM:();
orderCount:0;

// TODO randomize placement of hidden orders.
// TODO change price type to int, longs etc.
// TODO allow for data derived i.e. exchange market orders. 
// TODO move offset into seperate table?
Order: (
    [price:`long$(); orderId:`long$()]
    clId            : `long$();
    instrumentId    : `.instrument.Instrument$();
    accountId       : `.account.Account$();
    side            : `long$();
    otype           : `long$();
    offset          : `long$();
    timeinforce     : `long$();
    size            : `long$(); / multiply by 100
    leaves          : `long$();
    filled          : `long$();
    limitprice      : `long$(); / multiply by 100
    stopprice       : `long$(); / multiply by 100
    status          : `long$();
    time            : `datetime$();
    reduce          : `boolean$();
    trigger         : `long$();
    execInst        : `long$());


// OrderBook
// =====================================================================================>

// Instantiate a singleton class of Orderbook
// qtys: represent the different level quantities at their given prices
// the events will be generated using the sum of the quantities and the 
// orderbook sizes at each price.
// TODO add hidden/Iceberg qty
OrderBook:(
    [price      :`long$()]
    side        :`long$(); 
    qty         :`long$();
    hqty        :`long$();
    vqty      :`long$()); // TODO hQty: hidden qty

// Process Depth update
// -------------------------------------------------------------->

// TODO uniform decrease / increase of hidden order qty with updates
// that don't represent this?
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
ProcessDepth        :{[instrument;nxt;time] //TODO fix and test
    odrs:?[.order.Order;.util.cond.isActiveLimitB[nxt`price];0b;()];
    $[count[odrs]>0;[
        // TODO uj new event
        // ?[`.order.OrderBook;((=;`side;1);(<;1000;(+\;`vqty)));0b;`price`side`qty`vqty`svqty!(`price;`side;`qty;`vqty;(+\;`vqty))]
        state:uj[?[`.order.OrderBook;(=;`side;nside);0b;()]; // TODO grouping
        ?[`.order.Order;.util.cond.isActiveLimit[();nside];0b;()];`price;()]; // TODO grouping

        dlts:1_'(deltas'[raze'[flip[raze[enlist(qty;size)]]]]);

        state[`tgt]: last'[state`size]; // TODO change to next? 
        
        dneg:sum'[{x where[x<0]}'[dlts]];
        if[count[dneg]>0;[
                // Pad state into a matrix
                // for faster operations
                padcols:(`offset`size`leaves`reduce`orderId`side, // TODO make constant?
                    `accountId`instrumentId`price`status);
                (state padcols):.util.PadM'[state padcols];

                shft:sum[state`offset`leaves]; // the sum of the order offsets and leaves
                mxshft:max'[shft];
                mnoffset: (0,'-1_'(shft));

                // Derive the non agent qtys that
                // make up the orderbook
                nagentQty: flip .util.PadM[ // TODO check
                    raze'[(
                        0^state[`offset][;0]; // Use the first offset as the first non agent qty
                        .util.Clip[0^state[`offset][;1_(tmaxN)] - 0^shft[;-1_(tmaxN)]]; //
                        .util.Clip[state[`qty]-mxshft] // TODO change?
                    )]];

                offsetdlts: -1_'(floor[(nagentQty%(sum'[nagentQty]))*dneg]);
                noffset: {?[x>y;x;y]}'[mnoffset;poffset + offsetdlts];
                nshft:sum[state`leaves;noffset];
                
                // Calculate the new vis qty
                nvqty: sum'[raze'[flip[raze[enlist(state`tgt`leaves)]]]];
                mxnshft:max'[nshft];
                nvqty: {?[x>y;x;y]}'[mxnshft;nvqty];

                vqty: ?[mxnshft>nvqty;mxnshft;nvqty]; // The new visible quantity
            ]];
        .order.Order,:(); // TODO update orders
        .order.OrderBook,:(state`price`side`tgt`vqty); // TODO fix here
    ];[.order.OrderBook,:last'[nxt`price`side`qty`qty]]]; // TODO fix
    ![`.order.OrderBook;.util.cond.bookBounds[];0;`symbol$()]; // Delete all out of bounds depths
    .pipe.event.AddDepthEvent[?[`.order.OrderBook;.util.cond.bookBoundsO[];0b;()];time]; // TODO add snapshot update?
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
ProcessTrade        :{[instrument;account;side;fillQty;reduce;fillTime] // TODO fix and test
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
        padcols:(`offset`size`leaves`reduce`orderId`side, // TODO make constant?
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
        .order.Order,:(); // update where partial
        ![`.order.Order;.util.cond.bookBounds[];0;`symbol$()]; // Delete where filled
        .pipe.event.AddOrderUpdateEvent[]; // Emit events for all 

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
    ![`.order.OrderBook;.util.cond.bookBounds[];0;`symbol$()]; // Delete all out of bounds depths
    .pipe.event.AddDepthEvent[?[`.order.OrderBook;.util.cond.bookBoundsO[];0b;()];time]; // TODO add snapshot update?
    // TODO update last price
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
NewOrder            :{[i;a;o;time]
    k:o[;6];
    res:$[k=0;[ // MARKET ORDER
            .order.ProcessTrade[];
          ]; 
          k=1;[ // LIMIT ORDER
            .order.Order,:o;
          ]; 
          (k in (1,2));[
              // Stop orders do not modify state of 
              // the orderbook and thus can be inserted
              // as such.
              .order.Order,:o;
         ]; // STOP_LIMIT_ORDER
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
    k:o[;6];
    $[k=1;[
               // Limit order changes state of book
              
         ]; 
         (k in (1,2));[
              // Stop orders do not modify state of 
              // the orderbook.
              .order.Order,:o;
         ]; // STOP_LIMIT_ORDER
         'INVALID_ORDER_TYPE];
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
    k:o[;6];
    $[k=1;[
            // Limit order changes state of book
            .engine.ProcessNewTradeEvents[x];
        ]; 
        (k in (1,2));[
            // Stop orders do not modify state of 
            // the orderbook.
            ![`.order.Order;
            enlist(in;`orderId;o`orderId);0b;`symbol$()];
            .pipe.event.AddOrderCancelEvent[o;o`time];
        ]; // STOP_LIMIT_ORDER
        'INVALID_ORDER_TYPE];
    };


// Process Trades/Market Orders
// -------------------------------------------------------------->

// TODO should put events back into ingress queue.
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


// Apply Price Limits
// -------------------------------------------------------------->
