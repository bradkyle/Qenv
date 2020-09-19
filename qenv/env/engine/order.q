
.order.orderCount:0;

// TODO better / faster matrix operations
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
    vqty      :`long$()); // Visible qty (including order qty)=(qty+displayqty)
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

// Order Inflow
// Orders increasing at a given depth when the price no longer exists i.e. the
// price has been overtaken by the opposing side means that there was an inflow of
// orders at that price (after realistically applicable) in this instance it is assumed
// that the inflow would be post only and thus they are disregarded.

// Hidden order logic
// Because hidden orders are derived from trades that have occurred and not through explicit
// agent actions, it is principly added to the front of the queue during an update,  and thus
// all offsets are increased at the price level accordingly. Visual quantity should however
// not increase as a result ?
// TODO what happens when order is at the back of the queue and hidden qty increases?
// TODO edge case

// TODO validation.

/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.order.ProcessDepth        :{[instrument;nxt] //TODO fix and test, hidden order
    // TODO validation
    // TODO offsets cannot be less than hidden qty

    odrs:?[.order.Order;.util.cond.isActiveLimitB[distinct nxt`price];0b;()]; // TODO batch update
    $[count[odrs]>0;[
        ob:0^(0!(?[`.order.OrderBook;();0b;()]));
        .order.test.ob:ob;
        // TODO uj new event
        .order.test.nxt:nxt;
        nxt:flip nxt;
        // ?[`.order.OrderBook;((=;`side;1);(<;1000;(+\;`vqty)));0b;`price`side`qty`vqty`svqty!(`price;`side;`qty;`vqty;(+\;`vqty))]
        state:0!uj[lj[`side`price xgroup nxt;`side`price xgroup ob];`side`price xgroup odrs]; // TODO grouping

        dlts:1_'(deltas'[raze'[flip[raze[enlist(state`qty`nqty)]]]]);
        .order.test.state:state;
        state[`tgt]: last'[state`nqty]; // TODO change to next? 
        .order.test.OBf:.order.OrderBook;

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

                maxN:max count'[state`offset];
                tmaxN:til maxN;
                numLvls:count[state`offset];

                shft:sum[state`offset`leaves]; // the sum of the order offsets and leaves
                mxshft:max'[shft];
                .order.test.shft:shft;

                // The Minimum offset should be the minimum shft
                // of the preceeding orders in the queue i.e. so
                // they don't overlap and provided there exists
                // a hidden order qty it should represent this
                // offset (hidden order qty derived from data)
                // is always put at the front of the queue.
                mnoffset: (0,'-1_'(shft))+raze[.util.PadM[state`hqty]];
                .order.test.mnoffset:mnoffset;

                // Derive the non agent qtys that
                // make up the orderbook // TODO add hqty, iqty to this.
                // HQTY is excluded from this because the hqty is derived
                // from historic data and as such the nascent cancellations
                // are functionally ignored.
                notAgentQty: flip .util.PadM[raze'[(
                        0^state[`offset][;0]; // Use the first offset as the first non agent qty
                        .util.Clip[0^state[`offset][;1_(tmaxN)] - 0^shft[;-1_(tmaxN)]]; //
                        .util.Clip[sum[state`qty`hqty]-mxshft] // TODO change?
                    )]];

                .order.test.notAgentQty:notAgentQty;
                .order.test.ob:.order.OrderBook;

                // Derive the deltas in the agent order offsets as if there
                // were a uniform distribution of cancellations throughout
                // the queue.
                offsetdlts: -1_'(floor[(notAgentQty%(sum'[notAgentQty]))*dneg]);

                .order.test.offsetdlts:offsetdlts;
                .order.test.dneg:dneg;
                .order.test.state1:state;
                .order.test.shft:shft;
                .order.test.tmaxN:tmaxN;
                .order.test.mxshft:mxshft;
                // Offset deltas are derived adn added to the current offset
                noffset: {?[x>y;x;y]}'[mnoffset;state[`offset] + offsetdlts];
                nshft:   state[`leaves]+noffset;
                
                .order.test.prices:state`price;
                .order.test.noffset:noffset;
                .order.test.nshft:nshft;
                .order.test.state2:state;
                
                // Calculate the new vis qty
                nvqty:  sum'[raze'[flip[raze[enlist(state`tgt`displayqty)]]]];
                mxnshft:max'[nshft];
                .order.test.mxnshft:mxnshft;
                .order.test.nvqty:nvqty;

                // TODO considering visible quantity doesn't change

                // Derive the new visible quantity as 
                / nvqty: ?[mxnshft>nvqty;mxnshft;nvqty]; // The new visible quantity
                .order.Order,:flip(`orderId`offset!((raze[state`orderId];raze[noffset])[;where[msk]])); 
                .order.test.O2:.order.Order;
                state[`vqty]:nvqty;
                .order.test.state3:state;
                .order.test.obk:.order.OrderBook;
                .order.OrderBook,:raze'[flip 0^.util.PadM'[state`price`side`tgt`hqty`iqty`vqty]];
                .order.test.ob1:.order.OrderBook;
            ];[
                state[`vqty]:  sum'[raze'[flip[raze[enlist(state`tgt`displayqty)]]]];                
                .order.OrderBook,:raze'[flip .util.PadM'[state`price`side`tgt`hqty`iqty`vqty]];
            ]];

        // TODO fix here
    ];[
        .order.OrderBook,:last'[nxt`price`side`nxtqty`nxthqty`nxtiqty`nxtqty];
    ]]; // TODO fix

    // Delete all out of bounds depths, depths that are empty 
    // i.e. where vqty + hqty = 0
    delete from `.order.OrderBook where (vqty+iqty+hqty)<=0;
    / ![`.order.OrderBook;.util.cond.bookPrune[];0;`symbol$()];  TODO pruning functionality
    / .order.test.OB:.order.OrderBook;
    // Return the orderbook update to the egress pipe
    / .pipe.egress.AddDepthEvent[?[`.order.OrderBook;.util.cond.bookUpdBounds[];0b;()];last[]; 
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
// order. // TODO implement for multiple orderss
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory // TODO make viable for batch insertions!
.order.ProcessTrade        :{[instrument;account;td] // TODO validation, fix and test, change instrument to i, account to a
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
    .order.test.aqty:aqty;
    .order.test.thresh:thresh;
    .order.test.thresh1:thresh1;
    // Derive the amount that will be replaced per level
    rp1:min[fillQty,first[aqty]]^rp;
    state[`rp]:rp1;
    .order.test.rp1:rp1;
    state:state[where (state`rp)>0];

    // TODO select by offset aswell
    odrs:?[.order.Order;.util.cond.isActiveLimit[nside;state`price];0b;()];
    .order.test.O:.order.Order;
    
    // Hidden order qty i.e. derived from data 
    // is always at the front of the queue.
    // Iceberg orders placed by agents have a 
    // typical offset and function like normal orders
    // except they aren't visible.

    // TODO count orders where filled >0;

    .order.test.odrs:odrs;
    $[count[odrs]>0;[
        state:0!{$[x>0;desc[y];asc[y]]}[neg[side];ij[1!state;`price xgroup odrs]]; 
        msk:raze[.util.PadM[{x#1}'[count'[state`orderId]]]];

        // Pad state into a matrix
        // for faster operations
        padcols:(`offset`size`leaves`displayqty`reduce`orderId`side, // TODO make constant?
            `accountId`instrumentId`price`status);
        (state padcols):.util.PadM'[state padcols]; // TODO make faster?
        .order.test.pstate:state;

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

        nhqty:          .util.Clip[(-/)state`hqty`rp];
        noffset:        .util.Clip[(-/)state`offset`rp]; // Subtract the replaced amount and clip<0
        nleaves:        .util.Clip[{?[x>z;(y+z)-x;y]}'[state`rp;state`leaves;state`offset]]; // TODO faster
        ndisplayqty:    .util.Clip[{?[((x<y) and (y>0));x;y]}'[state[`displayqty];nleaves]]; // TODO faster
        niqty:          sum'[nleaves-ndisplayqty];
        displaydlt:     (ndisplayqty-state[`displayqty]);
        nqty:           .util.Clip[((-/)state`vqty`rp)-sum'[displaydlt]];
        nvqty:          nqty+sum'[ndisplayqty];
        nshft:          nleaves+noffset;
        nmxshft:        {$[x>1;max[y];x=1;y;0]}'[maxN;nshft]; // the max shft for each price
        nfilled:        state[`size] - nleaves; // New amount that is filled
        accdlts:        state[`leaves] - nleaves; // The new Account deltas

        // Derived the boolean representation of partially and 
        // fully filled orders within the matrix of orders referenced
        // above. They should not overlap.f
        // get fully filled and then set all others that dont conform to 
        // partially filled, by simple exclusion conditional.
        nstatus:1*((state[`offset]<=state[`rp])and(nshft<=state[`rp])); // todo mask
        nstatus+:2*((sums[state[`offset]]<=state[`rp])and not nstatus); // todo mask

        state[`hqty`offset`leaves`displayqty`iqty`qty`vqty`shft`mxshft`filled`flls`status]:(
            nhqty;noffset;nleaves;ndisplayqty;niqty;nqty;nvqty;nshft;nmxshft;nfilled;accdlts;nstatus
        );
        .order.test.stateu:state;

        .order.test.ndisplayqty:ndisplayqty;
        .order.test.displaydlt:displaydlt;
        .order.test.niqty:niqty;
        .order.test.nleaves:nleaves;
        .order.test.noffset:noffset;
        .order.test.nvqty:nvqty;
        .order.test.nqty:nqty;
        .order.test.msk:msk;
        .order.test.state1:state;
        .order.test.nstatus:nstatus; 
        .order.test.nshft:nshft;

        // Derive order amends from given trades
        oupdCols:`orderId`offset`leaves`displayqty`status;
        oupd:flip(oupdCols!((raze'[state[oupdCols]])[;where[msk]])); // TODO make faster
        .order.Order,:oupd; // update where partial

        // Add order update events.
        .pipe.egress.AddOrderUpdatedEvent[oupd;fillTime]; // Emit events for all 
        
        // Make order updates
        mfllsCols:`accountId`price`qty`reduce;
        mflls:flip(mfllsCols!((raze'[state[mfllsCols]])[;where[msk]]));
        
        .order.test.mflls:mflls;
        .order.test.zec:(account[`accountId] in mflls[`accountId]);
        .order.test.isagnt:isagnt;

        if[count[mflls]>0;[
            if[(isagnt and (account[`accountId] in mflls[`accountId]));
                .account.IncSelfFill[accountId;count[mflls];sum[sflls`filled]]];
                .account.ApplyFill[account;instrument;side] mflls; // TODO change to take order accountIds, and time!
                ]];

        // Add trade events back into the event pipeline
        .pipe.egress.AddTradeEvent[[];fillTime]; // TODO derive trades

        if[isagnt;.account.ApplyFill[[]]]; // TODO

        state[`bside]:first'[distinct'[state[`side]]]; // TODO changes

        obupd:raze'[flip .util.PadM'[state`price`bside`qty`hqty`iqty`vqty]];
        .order.OrderBook,:obupd;

        // TODO make simpler and move down
        delete from `.order.OrderBook where (vqty+hqty+iqty)<=0;

    ];if[count[state]>0;[
        // TODO testing
        .order.OrderBook,:flip .util.PadM[state`price`side`qty`hqty`iqty`vqty];
        
    ]]]; // TODO fix
    
    
    // Delete all out of bounds depths, depths that are empty 
    // i.e. where vqty + hqty = 0
    / ![`.order.OrderBook;.util.cond.bookPrune[];0;`symbol$()];  TODO pruning functionality
    / .order.test.OB:.order.OrderBook;
    // Return the orderbook update to the egress pipe
    .pipe.egress.AddDepthEvent[?[`.order.OrderBook;.util.cond.bookUpdBounds[];0b;()];fillTime]; // TODO remove for partial book updates

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

