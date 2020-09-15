
.order.orderCount:0;

// TODO randomize placement of hidden orders.
// TODO change price type to int, longs etc.
// TODO allow for data derived i.e. exchange market orders. 
// TODO move offset into seperate table?
.order.Order: ( // TODO add sorting attr by price
    [orderId        :`long$()]
    clId            : `long$();
    instrumentId    : `.instrument.Instrument$();
    accountId       : `.account.Account$();
    price           : `long$();
    side            : `long$();
    otype           : `long$();
    offset          : `long$();
    timeinforce     : `long$();
    size            : `long$(); / multiply by 100 etc
    leaves          : `long$();
    filled          : `long$();
    limitprice      : `long$(); / multiply by 100 etc
    stopprice       : `long$(); / multiply by 100 etc
    status          : `long$();
    time            : `datetime$();
    reduce          : `boolean$();
    trigger         : `long$();
    displayqty      : `long$(); // for iceberg/hidden orders
    pricevar        : `long$(); // for iceberg/hidden orders
    avgamt          : `long$(); // for iceberg/hidden orders
    execInst        : `long$());
.order.ordCols:cols .order.Order;

// OrderBook
// =====================================================================================>
/ ?[t;c;b;a;n;(g;cn)]     /select up to n records sorted by g on cn

// Instantiate a singleton class of Orderbook
// qtys: represent the different level quantities at their given prices
// the events will be generated using the sum of the quantities and the 
// orderbook sizes at each price.
// TODO add hidden/Iceberg qty
.order.OrderBook:(
    [price      :`long$()]  // price
    side        :`long$();  // side
    qty         :`long$(); // data qty
    hqty        :`long$(); // hidden qty  (only for data depth updates)
    iqty        :`long$(); // iceberg qty (only for agent orders)
    vqty      :`long$()); // Visible qty (including order qty)
.order.bookCols:cols .order.OrderBook;

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

// Hidden order logic
// Orders increasing at a given depth when the price no longer exists i.e. the
// price has been overtaken by the opposing side means that there was an inflow of
// orders at that price (after realistically applicable) in this instance it is assumed
// that the inflow would be post only and thus they are disregarded.
// Because hidden orders are derived from trades that have occurred and not through explicit
// data, it is principly added to the front of the queue during an update,  and thus
// all offsets are increased at the price level accordingly.

/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.order.ProcessDepth        :{[instrument;nxt] //TODO fix and test, hidden order
    odrs:?[.order.Order;.util.cond.isActiveLimitB[distinct nxt`price];0b;()]; // TODO batch update
    $[count[odrs]>0;[
        ob:0!(?[`.order.OrderBook;();0b;()]);
        // TODO uj new event
        // ?[`.order.OrderBook;((=;`side;1);(<;1000;(+\;`vqty)));0b;`price`side`qty`vqty`svqty!(`price;`side;`qty;`vqty;(+\;`vqty))]
        state:0!uj[`price xgroup ob;`price xgroup odrs]; // TODO grouping
        state[`bside]:ob[`side];
        dlts:1_'(deltas'[raze'[flip[raze[enlist(state`qty;state`size)]]]]);

        state[`tgt]: last'[state`size]; // TODO change to next? 
        nqty:last'[nxt`qty];
        
        dneg:sum'[{x where[x<0]}'[dlts]];
        if[count[dneg]>0;[
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
                mnoffset: (0,'-1_'(shft));

                // Derive the non agent qtys that
                // make up the orderbook // TODO add hqty, iqty to this.
                nagentQty: flip .util.PadM[ // TODO check
                    raze'[(
                        0^state[`offset][;0]; // Use the first offset as the first non agent qty
                        .util.Clip[0^state[`offset][;1_(tmaxN)] - 0^shft[;-1_(tmaxN)]]; //
                        .util.Clip[state[`qty]-mxshft] // TODO change?
                    )]];

                // Derive the deltas in the agent order offsets as if there
                // were a uniform distribution of cancellations throughout
                // the queue.
                offsetdlts: -1_'(floor[(nagentQty%(sum'[nagentQty]))*dneg]);

                noffset: {?[x>y;x;y]}'[mnoffset;state[`offset] + offsetdlts];
                nshft:state[`leaves]+noffset;
                
                // Calculate the new vis qty
                nvqty: sum'[raze'[flip[raze[enlist(state`tgt`leaves)]]]];
                mxnshft:max'[nshft];

                // Derive the new visible quantity
                nvqty: ?[mxnshft>nvqty;mxnshft;nvqty]; // The new visible quantity
                .order.Order,:flip(`orderId`offset!((raze[state`orderId];raze[noffset])[;where[msk]])); 
                .order.state.O2:.order.Order;

                .order.OrderBook,:raze'[flip(.order.bookCols!(state`price;state`bside;nvqty;nvqty;nvqty;nvqty))];
            ];[
                state[`bside]:first'[distinct'[state[`side]]];
                .order.OrderBook,:raze'[flip[0^(state`price`bside`tgt`hqty`iqty`vqty)]]; 
            ]];
        // TODO fix here
    ];[.order.OrderBook,:last'[nxt`price`side`nxtqty`nxthqty`nxtiqty`nxtqty]]]; // TODO fix

    // Delete all out of bounds depths, depths that are empty 
    // i.e. where vqty + hqty = 0
    / ![`.order.OrderBook;.util.cond.bookPrune[];0;`symbol$()];  TODO pruning functionality
    / .order.test.OB:.order.OrderBook;
    // Return the orderbook update to the egress pipe
    .pipe.egress.AddDepthEvent[?[`.order.OrderBook;.util.cond.bookUpdBounds[];0b;()];time]; 
    };


// Process Trades/Market Orders
// --------------------------------------------------------------> // Price limits merely stipulate maximum market order price
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
    isagnt:count[account]>0;
    // Join the opposing side of the orderbook with the current agent orders
    // at that level, creating the trade effected state
    state:0!?[`.order.OrderBook;enlist(=;`side;nside);0b;()];
    .order.test.state0:state;
    .order.test.OB1:.order.OrderBook;
    thresh1:sums[state[`qty]];
    aqty:sum[state[`iqty`hqty`vqty]];
    thresh:sums[aqty];
    rp:(thresh-prev[thresh])-(thresh-fillQty);
    state[`thresh]:thresh;
    .order.test.state:state;
    .order.test.rp:rp;
    .order.test.thresh:thresh;
    .order.test.thresh1:thresh1;
    // Derive the amount that will be replaced per level
    rp1:min[fillQty,first[aqty]]^rp;
    state[`rp]:rp1;
    .order.test.rp1:rp1;
    state:state[where (state`rp)>0];
    state[`tgt]:.util.Clip[(-/)state`qty`rp];
    odrs:?[.order.Order;.util.cond.isActiveLimit[nside;state`price];0b;()];
    .order.test.O:.order.Order;
    
    // Hidden order qty i.e. derived from data 
    // is always at the front of the queue.
    // Iceberg orders placed by agents have a 
    // typical offset and function like normal orders
    // except they aren't visible.

    .order.test.odrs:odrs;
    $[count[odrs]>0;[
        state:0!{$[x>0;desc[y];asc[y]]}[neg[side];ij[1!state;`price xgroup odrs]]; 
        msk:raze[.util.PadM[{x#1}'[count'[state`orderId]]]];

        // Pad state into a matrix
        // for faster operations
        padcols:(`offset`size`leaves`reduce`orderId`side, // TODO make constant?
            `accountId`instrumentId`price`status);
        (state padcols):.util.PadM'[state padcols];
        .order.test.pstate:state;

        // Useful counts 
        maxN:max count'[state`offset];
        tmaxN:til maxN;
        numLvls:count[state`offset];

        // TODO new display qty
        // Calculate new shifts and max shifts
        shft:sum[state`offset`leaves]; // the sum of the order offsets and leaves
        noffset: .util.Clip[(-/)state`offset`rp]; // Subtract the replaced amount and clip<0
        nleaves: .util.Clip[{?[x>z;(y+z)-x;y]}'[state`rp;state`leaves;state`offset]]; // TODO faster
        ndisplayqty:.util.Clip[{?[((x<y) and (y>0));x;y]}'[state[`displayqty];nleaves]]; // TODO faster

        nshft:nleaves+noffset;
        mxshft:{$[x>1;max[y];x=1;y;0]}'[maxN;nshft]; // the max shft for each price

        .order.test.nleaves:nleaves; // TODO move down
        
        // Calculate the new vis qty
        nvqty: sum'[raze'[flip[raze[enlist(state[`tgt],nleaves)]]]];
        .order.test.nvqty:nvqty;
        .order.test.nshft:nshft;
        // Derive the non agent qtys that
        // make up the orderbook
        nagentQty: flip .util.PadM[raze'[(
                0^state[`offset][;0]; // Use the first offset as the first non agent qty
                .util.Clip[0^state[`offset][;1_(tmaxN)] - 0^nshft[;-1_(tmaxN)]]; //
                .util.Clip[state[`qty]-mxshft]
            )]];
        .order.test.nagentQty:nagentQty;
        nfilled: state[`size] - nleaves; // New amount that is filled
        accdlts: state[`leaves] - nleaves; // The new Account deltas
        vqty: ?[mxshft>nvqty;mxshft;nvqty]; // The new visible quantity

        state[`hqty]:.util.Clip[(-/)state`hqty`rp];
        state[`iqty]:sum'[nleaves-ndisplayqty];

        // TODO check
        state[`vqty]:.order.test.pstate[`tgt]+sum[ndisplayqty];
        .order.test.vqty:vqty;
        .order.test.mxshft:mxshft;
        .order.test.accdlts:accdlts;
        .order.test.nfilled:nfilled;

        // Derived the boolean representation of partially and 
        // fully filled orders within the matrix of orders referenced
        // above. They should not overlap.f
        partfilled:`boolean$(raze[(sums'[state`offset]<=state[`rp])-(nshft<=state[`rp])]); // todo mask
        fullfilled: `boolean$(raze[(state[`offset]<=state[`rp])and(nshft<=state[`rp])]); // todo mask

        .order.test.nleaves:nleaves;
        .order.test.noffset:noffset;
        .order.test.msk:msk;
        .order.test.state1:state;
        // TODO update with displayqty
        .order.test.zn:`orderId`offset`leaves`displayqty!(raze[state`orderId];raze[noffset];raze[nleaves];raze[ndisplayqty]);
        .order.Order,:flip(`orderId`offset`leaves`displayqty!((raze[state`orderId];raze[noffset];raze[nleaves];raze[ndisplayqty])[;where[msk]]));  // update where partial
        / ![`.order.Order;.util.cond.bookBounds[];0;`symbol$()]; // Delete where filled
        .pipe.egress.AddOrderUpdatedEvent[]; // Emit events for all 
        // Make order updates
        mflls:flip(`accountId`price`qty`reduce!((raze[state`accountId];raze[state`price];raze[nfilled];raze[state[`reduce]])[;where[msk]]));
        .order.test.mflls:mflls;
        .order.test.zec:(account[`accountId] in mflls[`accountId]);
        .order.test.isagnt:isagnt;
        if[count[mflls]>0;[
            if[(isagnt and (account[`accountId] in mflls[`accountId]));
                .account.IncSelfFill[accountId;count[mflls];sum[sflls`filled]]];
                .account.ApplyFill[account;instrument;side] mflls; // TODO change to take order accountIds, and time!
                ]];
  
        .pipe.egress.AddTradeEvent[[];time]; // TODO derive trades

        if[isagnt;.account.ApplyFill[[]]]; // TODO

        state[`bside]:first'[distinct'[state[`side]]]; // TODO changes

        .order.test.obi:raze'[flip[0^(state`price`bside`tgt`hqty`iqty`vqty)]];
        .order.OrderBook,:raze'[flip[0^(state`price`bside`tgt`hqty`iqty`vqty)]];  // TODO fix here

        delete from `.order.OrderBook where (vqty+hqty+iqty)<=0;

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

// TODO add place time // TODO validation
// New Order Adds an order to the orderbook.
/  @param i     (Instrument) The instrument for which this order is placed
/  @param o     (Order) The order that is being placed.
/  @param a    (Account) The account to which this order belongs.
/  @param time (datetime) The time at which this order was placed.
/  @return (Inventory) The new updated inventory
.order.NewOrder            :{[i;a;o] 
    // TODO validation?
    (o`instrumentId`accountId):(
        `.instrument.Instrument!o[`instrumentId];
        `.account.Account!o[`accountId]);
    k:o[`otype];
    res:$[k=0;[ // MARKET ORDER
            .order.ProcessTrade[i;a;o`side;o`size;o`reduce;o`time];
          ]; 
          (k in (1,4,5));[ // LIMIT ORDER // TODO allow for hidden orders to be dispersed
                // IF the order is present, amend order, if amended to 0 remove
                // Assumes best bid and ask price are constantly updated.
                // TODO left over order, limit order placed as taker in other side book.
                // If the order crosses the bid/ask spread
                // sell order <= best bid or buy order >= best ask 
                // process the order as a trade. 
                $[(all[(o[`side]<0),(i[`bestBidPrice]>=o[`price]),i[`hasLiquidityBuy]] or 
                    all[(o[`side]>0),(i[`bestAskPrice]<=o[`price]),i[`hasLiquiditySell]]); // check postonly
                    [
                        .order.ProcessTrade[i;a;o`side;o`size;o`reduce;o`time];
                    ];
                    [
                        // Becuase the order is placed at the back of the queue
                        // no change in the offsets of the other orders occurs at 
                        // the level.
                        o[`orderId]:(.order.orderCount+:1);
                        o[`leaves]:o[`size];
                        o[`displayqty]:o[`leaves]^o[`displayqty];
                        // get the orderbook price level
                        ob:?[`.order.OrderBook;enlist(=;`price;o`price);();()];
                        o[`offset]:sum[ob`vqty`hqty`iqty];
                        // Fill orderbook where neccessary
                        (ob`price`side)^:(o`price;o`side);
                        ob:0^ob;
                        // TODO if order is hidden update ob
                        ob[`vqty]+:o[`displayqty];
                        ob[`iqty]+:0^((-/)o`leaves`displayqty); // TODO check
                        .order.Order,:o;
                        .order.OrderBook,:ob;

                        .pipe.egress.AddOrderCreatedEvent[o;o`time];
                        .pipe.egress.AddDepthEvent[();o`time]; // TODO remove for partial book updates

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

// TODO display qty cant be larger than size
// Amend Order modifies a given order.
// Takes the place of cancel logic when an order amount is amended to zero.
/  @param i     (Instrument) The instrument for which this order is placed
/  @param o     (Order) The order that is being placed.
/  @param a    (Account) The account to which this order belongs.
/  @param time (datetime) The time at which this order was placed.
/  @return (Inventory) The new updated inventory // TODO if update price to past best bid/ask ProcessTrade
.order.AmendOrder            :{[i;a;o] // TODO add time 
    // TODO validation?
    co:first 0!?[`.order.Order;enlist(=;`orderId;o`orderId);0b;()];
    // TODO fill current order with next order
    if[not null[o`size];[o[`leaves]:o[`size];o[`size]:co[`size]]];
    o:co,o;
    k:o[`otype];
    res:$[(k in (1,4,5));[ // LIMIT ORDER
                // Get the current state of the order book at the given price level. 
                cob:?[`.order.OrderBook;enlist(=;`price;co`price);();()];

                // Get all orders above the order in the order queue at the price level
                cod:0!?[`.order.Order;((=;`price;co`price);(<>;`orderId;co`orderId);(>;`offset;co`offset));0b;()];

                // IF the order is present, amend order, if amended to 0 remove
                // Get the current state of the order. // TODO simplify into change in price and side, change in size
                $[not[sum[o`leaves`size]>0];[
                        // Cancel order and update orderbook subsequently
                        cob[`iqty]-:((-/)co`leaves`displayqty); // TODO check
                        cob[`vqty]-:co[`leaves];

                        ![`.order.Order;enlist(=;`orderId;o`orderId);0;`symbol$()]; // Simpler drop

                        .order.OrderBook,:cob;
                        .pipe.egress.AddOrderCancelledEvent[o;o`time];
                        
                    ];
                    ((o[`side]<>co[`side]) or (o[`price]<>co[`price]));
                    [ // If the order should be replaced in the order queue when it is moved in orderbook.
                        nob:?[`.order.OrderBook;enlist(=;`price;o`price);();()];
                        cod[`offset]-:co[`leaves];

                        (nob`price`side)^:(o`price;o`side);
                        nob:0^nob;
                        o[`offset]:sum[nob`vqty`hqty`iqty];

                            // set the new orderbook qty to the  
                        nob[`iqty]+:((-/)o`leaves`displayqty); // TODO check    
                        nob[`vqty]+:o`displayqty;

                        cob[`vqty]-:co[`displayqty];
                        cob[`iqty]-:((-/)co`leaves`displayqty);

                        .order.Order,:(o,cod); // TODO test
                        .order.OrderBook,:(cob;nob);
                        .pipe.egress.AddOrderUpdatedEvent[o;o`time];
                    ];  
                    (o[`leaves]>co[`leaves]);
                    [ // If the order should be replaced in the order queue when it is made larger.

                        // considering the order is being replaced in the queue 
                        // amend all orders above the order to reflect the change
                        // in offset.
                        o[`displayqty]:o`leaves;
                        
                        vdlt:(o[`leaves] - co[`leaves]);
                        dlt:vdlt+(o[`displayqty]-co[`displayqty]);
                        
                        // Adjust the offsets of all orders > offset at level
                        // and update orderbook.
                        // Update the offset to represent the decrease
                        // in magnitude of the order
                        cod[`offset]-:co[`leaves];

                        // Because the price of the order has not been changed
                        // merely update the same level of the orderbook.
                        cob[`iqty]+:(((-/)o`leaves`displayqty)-((-/)co`leaves`displayqty));
                        cob[`vqty]+:vdlt;

                        // Reset the order offset to the sum of the 
                        // visible and hidden quantity at the level
                        o[`offset]:(cob[`vqty]-(o[`leaves]))+sum[cob`hqty`iqty];

                        .order.Order,:(o,cod); // TODO check
                        .order.OrderBook,:cob;
                        .pipe.egress.AddOrderUpdatedEvent[o;o`time];
                    ];
                    [   // If the order reduces in size it does not affect the placement in the queue

                        // Derive the delta in size of the order
                        vdlt:(o[`leaves] - co[`leaves]);
                        dlt:vdlt+(o[`displayqty]-co[`displayqty]);

                        o[`displayqty]:min[o`leaves`displayqty];

                        // Adjust the offsets of all orders > offset at level
                        // and update orderbook.
                        // Update the offset to represent the decrease
                        // in magnitude of the order
                        cod[`offset]+:dlt;

                        // Because the price of the order has not been changed
                        // merely update the same level of the orderbook.
                        cob[`iqty]+:(((-/)o`leaves`displayqty)-((-/)co`leaves`displayqty));
                        cob[`vqty]+:vdlt;

                        .order.Order,:(o,cod); // TODO check
                        .order.OrderBook,:cob;
                        .pipe.egress.AddOrderUpdatedEvent[o;o`time];
                    ]];
                    
                // TODO dependent on visible delta
                .pipe.egress.AddDepthEvent[cob;o`time]; // TODO
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
    .pipe.egress.AddOrderUpdateEvent[stop;time]; // TODO update status to TRIGGERED
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

