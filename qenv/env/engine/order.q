
.order.orderCount:0;

// TODO randomize placement of hidden orders.
// TODO change price type to int, longs etc.
// TODO allow for data derived i.e. exchange market orders. 
// TODO move offset into seperate table?
.order.Order: (
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
.order.OrderBook:(
    [price      :`long$()]  // price
    side        :`long$();  // side
    qty         :`long$(); // data qty
    hqty        :`long$(); // hidden qty
    iqty        :`long$(); // iceberg qty
    vqty      :`long$()); // Visible qty

/ Bitmex
/ A buy Limit Order for 10 contracts with a Limit Price of 100 will be submitted to the market. 
/ Only a bid for 1 contract will be visible to other traders. If someone submits a sell Order 
/ for 3 contracts at 100 then 3 contracts will be executed from this order. After that, 
/ another bid for 1 contract will appear at 100 to other traders. As such, there will now be 
/ 7 contracts left remaining, with 1 only visible.

// OKEX
/ The system will automatically place an iceberg order. 
/ The amount of each order will be the single order average. 
/ The order price will be the latest buy price* (1-price variance). 
/ Once the order completely filled, a new order will be placed. 
/ When the last market price exceeds 2*(order variance), the previous order would be cancelled 
/ and a new one will be placed.
/ When the amount traded equals the total order amount, the iceberg trade has been filled. 
/ When the last market price exceeds the highest buy price of 20,000 US Dollars, the iceberg 
/ order would be temporarily halted.
/ After the price falls down to 20,000 US Dollars, the iceberg order would be recommenced.

// Process Depth update
// -------------------------------------------------------------->
// TODO update best bid + best ask
// TODO uniform decrease / increase of hidden order qty with updates
// that don't represent this?
// TODO move to C for increased speed.
// TODO make functionality for representing hidden/iceberg orders!!!
// TODO what happens when orderbook jumps such that the orders are no longer valid, increment the occurance of this! Perhaps randomize?
// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.order.ProcessDepth        :{[instrument;nxt] //TODO fix and test, hidden order
    odrs:?[.order.Order;.util.cond.isActiveLimitB[nxt`price];0b;()];
    .order.test.NXT:nxt;
    $[count[odrs]>0;[
        // TODO uj new event
        // ?[`.order.OrderBook;((=;`side;1);(<;1000;(+\;`vqty)));0b;`price`side`qty`vqty`svqty!(`price;`side;`qty;`vqty;(+\;`vqty))]
        state:uj[?[`.order.OrderBook;(=;`side;nside);0b;()]; // TODO grouping
        ?[`.order.Order;.util.cond.isActiveLimit[();nside];0b;()];`price;()]; // TODO grouping

        .order.test.state:state;
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
        .order.OrderBook,:(state`price`side`tgt`hqty`iqty`vqty); // TODO fix here
    ];[.order.OrderBook,:last'[nxt`price`side`nxtqty`nxthqty`nxtiqty`nxtqty]]]; // TODO fix

    // Delete all out of bounds depths, depths that are empty 
    // i.e. where vqty + hqty = 0
    / ![`.order.OrderBook;.util.cond.bookPrune[];0;`symbol$()];  TODO pruning functionality
    / .order.test.OB:.order.OrderBook;
    // Return the orderbook update to the egress pipe
    .pipe.egress.AddDepthEvent[?[`.order.OrderBook;.util.cond.bookUpdBounds[];0b;()];time]; 
    };


// Process Trades/Market Orders
// -------------------------------------------------------------->
// TODO udpate best bid + best ask
// TODO move to C for increased speed.
// TODO add junk order to taker, hidden to taker etc.
// TODO add iceberg/hidden logic
// TODO add execution event type
// Constructs matrix representation of trades that need to take place 
// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory // TODO make viable for batch insertions!
.order.ProcessTrade        :{[instrument;account;td] // TODO fix and test, change instrument to i, account to a
    side:td[0];fillQty:td[1];reduce: td[2];fillTime:td[3];
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

    // TODO make better
    state[`hqty]:state`qty;
    state[`iqty]:state`qty;

    .order.test.state:state;

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
        .pipe.egress.AddOrderUpdatedEvent[]; // Emit events for all 

        // Make order updates
        mflls:[];

        if[count[mflls]>0;[
            if[isagnt and (account[`accountId] in mflls[`accountId]);
                .account.IncSelfFill[accountId;count[mflls];sum[sflls`filled]]];
                .account.ApplyFill[account;instrument;side] mflls; // TODO change to take order accountIds, and time!
                ]];
  
        .pipe.egress.AddTradeEvent[[];time]; // TODO derive trades

        if[isagnt;.account.ApplyFill[[]]]; // TODO

        .order.OrderBook,:flip(state`price`side`tgt`hqty`iqty`vqty); // TODO fix here
    ];if[count[state]>0;[.order.OrderBook,:flip(state`price`side`tgt`hqty`iqty`vqty)]]]; // TODO fix
    
    
    // Delete all out of bounds depths, depths that are empty 
    // i.e. where vqty + hqty = 0
    / ![`.order.OrderBook;.util.cond.bookPrune[];0;`symbol$()];  TODO pruning functionality
    / .order.test.OB:.order.OrderBook;
    // Return the orderbook update to the egress pipe
    .pipe.egress.AddDepthEvent[?[`.order.OrderBook;.util.cond.bookUpdBounds[];0b;()];time]; // TODO remove for partial book updates

    // TODO update last price
    };

// Process New Orders
// -------------------------------------------------------------->

// New Order Adds an order to the orderbook.
/  @param i     (Instrument) The instrument for which this order is placed
/  @param o     (Order) The order that is being placed.
/  @param a    (Account) The account to which this order belongs.
/  @param time (datetime) The time at which this order was placed.
/  @return (Inventory) The new updated inventory
.order.NewOrder            :{[i;a;o] 
    // TODO validation?
    k:o[`otype];
    show k;
    res:$[k=0;[ // MARKET ORDER
            .order.ProcessTrade[i;a;o`side;o`size;o`reduce;o`time];
            // TODO add events
          ]; 
          k=1;[ // LIMIT ORDER
                // IF the order is present, amend order, if amended to 0 remove
                // TODO left over order, limit order placed as taker in other side book.
                // If the order crosses the bid/ask spread
                // i.e. 
                // sell order <= best bid  
                // buy order >= best ask 
                // process the order as a trade.
                $[(((o[`side]<0) and (i[`bestBidPrice]>=o[`price])) or 
                    ((o[`side]>0) and (i[`bestAskPrice]<=o[`price])));
                    .order.ProcessTrade[i;a;o`side;o`size;o`reduce;o`time];
                    [
                        o[`orderId]:(.order.orderCount+:1);
                        .order.Order,:o;
                    ]];

          ]; 
          (k in (1,2));[ // STOP_LIMIT_ORDER, STOP_MARKET_ORDER
              // IF the order is present, amend order, if amended to 0 remove
              // Stop orders do not modify state of 
              // the orderbook and thus can be inserted
              // as such.
              .order.Order,:o;
         ]; 
         'INVALID_ORDER_TYPE]; 
    // Prune engine orders to increase speed
    / ![`.order.Order;.util.cond.EnginePruneOrd[];0;`symbol$()];
    };

// Process New Orders
// -------------------------------------------------------------->

// Amend Order modifies a given order.
// Takes the place of cancel logic when an order amount is amended to zero.
/  @param i     (Instrument) The instrument for which this order is placed
/  @param o     (Order) The order that is being placed.
/  @param a    (Account) The account to which this order belongs.
/  @param time (datetime) The time at which this order was placed.
/  @return (Inventory) The new updated inventory
.order.AmendOrder            :{[i;a;o] 
    // TODO validation?
    k:o[`otype];
    show k;
    res:$[k=0;[ // MARKET ORDER
            .order.ProcessTrade[i;a;o`side;o`size;o`reduce;o`time];
            // TODO add events
          ]; 
          k=1;[ // LIMIT ORDER
                // IF the order is present, amend order, if amended to 0 remove
                 // TODO check
                  
          ]; 
          (k in (1,2));[ // STOP_LIMIT_ORDER, STOP_MARKET_ORDER
              // IF the order is present, amend order, if amended to 0 remove
              // Stop orders do not modify state of 
              // the orderbook and thus can be inserted
              // as such.
              .order.Order,:o;
         ]; 
         'INVALID_ORDER_TYPE]; 
    // Prune engine orders to increase speed
    / ![`.order.Order;.util.cond.EnginePruneOrd[];0;`symbol$()];
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
.order.ExecuteStop         :{[instrument;time;stop]
    // Add the order to the ingress pipeline in order to represent
    // the time it would take for the order to execute (stop orders are
    // a brokerage function)
    .pipe.ingress.AddPlaceOrderEvent[stop;time]; // TODO add delay
    .pipe.egress.AddOrderUpdateEvent[stop;time]; 
    ![`.order.Order;enlist(=;`orderId;stop`orderId);0;`symbol$()]; // Delete order from local orderBook
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.order.CheckStopOrders   :{[instrument;time]
    .order.ExecuteStop[instrument;time]'[?[`.order.OrderBook;.util.cond.isActiveStop[];0b;()]];
    };

