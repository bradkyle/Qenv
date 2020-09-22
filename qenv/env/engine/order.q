
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

.order.CLMap    :(
    [clId:`long$()]
    orderId:`.order.Order$(); 
    );

.order.fllCols:`instrumentId`accountId`side`price`qty`reduce`time;
.order.deriveFlls       :{
    gcls:`instrumentId`accountId`side`price`reduce;
    (0!?[x;();gcls!gcls;`fll`time!((sum;`qty);(last;`time))]) / [`instrumentId`accountId`side`price`qty`reduce`time]
    };

.order.deriveSelfFlls   :{
    0!?[x;enlist(=;`accountId;y);0b;
    `accountId`count`amount!(`accountId;(count;`qty);(sum;(abs;`qty)))]; 
    }

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


// Utilities For the application of state deltas
// -------------------------------------------------------------->

// TODO update instrument last price?
.order.applyNewTrades                   :{[side;price;qty;time]
        :1b;
    };

.order.applyOrderUpdates                :{[orderId;price;offset;leaves;displayqty;status;fillTime]
        :1b;
    };

.order.applyTakerFills                  :{[instrumentId;accountId;side;price;amt;reduce;fillTime]
        :1b;
    };

.order.applyMakerFills                  :{[instrumentId;accountId;side;price;amt;reduce;fillTime]
        :1b;
    };

.order.applyBookUpdates                 :{[price;side;qty;hqty;iqty;vqty;fillTime]
        :1b; // TODO sort by time
    };

// Deletes all levels from the orderbook where the sum of the visible qty, order hidden qty
// and the data derived hidden qty is 0, also should delete all levels a certain distance
// away from the mid price to increase speed.
.order.pruneBook                        :{
        delete from `.order.OrderBook where (vqty+iqty+hqty)<=0;
    };
   
// Deletes all limit orders from the orders table where the leaves qty is = 0
// also should delete all active limit orders that are a certain distance
// away from the mid price to increase speed.
.order.pruneOrders                      :{
        delete from `.order.Order where leaves<=0;
    };

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

/ .order.OrderBook,:raze'[flip 0^.util.PadM'[(`time xasc state)`price`side`tgt`hqty`iqty`vqty]];
/ .order.test.ob1:.order.OrderBook;

// TODO validation.

/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.order.ProcessDepth        :{[e] //TODO fix and test, hidden order
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
        state:`time xasc 0!uj[lj[`side`price xgroup nxt;`side`price xgroup ob];`side`price xgroup odrs]; // TODO grouping

        dlts:1_'(deltas'[raze'[flip[raze[enlist(state`qty`nqty)]]]]);
        .order.test.state:state;
        state[`tgt]: last'[state`nqty]; // TODO change to next? 
        .order.test.OBf:.order.OrderBook;
        .order.test.dlts:dlts;

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
                .order.test.pstate:state;

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
                mnoffset: (0,'-1_'(state`leaves))+raze[.util.PadM[state`hqty]]; // TODO this should be nshft
                .order.test.mnoffset:mnoffset;

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
                .order.test.notAgentQty:notAgentQty;
                .order.test.ob:.order.OrderBook;

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

                .order.test.offsetdlts:offsetdlts;
                .order.test.dneg:dneg;
                .order.test.state1:state;
                .order.test.shft:shft;
                .order.test.tmaxN:tmaxN;
                .order.test.mxshft:mxshft;
                .order.test.prices:state`price;
                .order.test.noffset:noffset;
                .order.test.nshft:nshft;
                .order.test.mxnshft:mxnshft;
                .order.test.nvqty:nvqty;
                .order.test.msk:msk;
                .order.test.lsttime:lsttime;
                // TODO considering visible quantity doesn't change

                // .order.applyOrderUpdates  :{[orderId;price;offset;leaves;displayqty;status;fillTime]

                // Update the order offsets
                .order.applyOrderUpdates   . .order.test.bng:(0^raze'[.util.PadM'[(
                        state`orderId;
                        raze[{x#y}'[numordlvl;state`price]]; // TODO make faster/fix
                        noffset;
                        state`leaves;
                        state`displayqty;
                        state`status;
                        raze[{x#y}'[numordlvl;lsttime]])]][;where[msk]]); // TODO make fasters

                // Update the orderbook
                .order.applyBookUpdates     . .order.test.bngd:(0^raze'[.util.PadM'[(
                        state`price;
                        state`side;
                        state`tgt;
                        state`hqty;
                        state`iqty;
                        nvqty;
                        lsttime)]]);


            ];[
                state[`vqty]:  sum'[raze'[flip[raze[enlist(state`tgt`displayqty)]]]];                
               
                .order.applyBookUpdates . flip(raze'[(
                        state`price;
                        state`mside;
                        nqty;
                        nhqty;
                        niqty;
                        nvqty)]);

            ]];

        // TODO fix here
    ];[
        
        .order.applyBookUpdates . flip(raze'[(
                state`price;
                state`mside;
                nqty;
                nhqty;
                niqty;
                nvqty)]);

    ]]; // TODO fix

   .order.pruneBook[];   
   .order.pruneOrders[];

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
.order.ProcessTrade        :{[e] // TODO validation, fix and test, change instrument to i, account to a
    side:td[0];fillQty:td[1];reduce: td[2];fillTime:td[3];
    nside:neg[side];
    isagnt:count[account]>0;
    
    ciId:instrument`instrumentId; // TODO use accountref
    caId:account`accountId;
    
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
        state:0!{$[x>0;desc[y];asc[y]]}[neg[side];ij[1!state;`price xgroup (update oprice:price, oside:side from odrs)]]; 
        msk:raze[.util.PadM[{x#1}'[count'[state`orderId]]]];
        state[`accountId`instrumentId]:7h$(state[`accountId`instrumentId]);
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
        .order.test.notAgentQty:notAgentQty;
        .order.test.tqty:tqty;
        .order.test.numLvls:numLvls;
        .order.test.acc:account;
        .order.test.isagnt:isagnt;
        .order.test.nside:nside;
        .order.test.ins:instrument;
        .order.test.hqtydlt:hqtydlt;
        .order.test.leavesdlt:leavesdlt;
        .order.test.numtds:numtds;
        .order.test.nobupd:nobupd;
        .order.test.numtdslvl:numtdslvl;

        // Derive and apply trades
        // -------------------------------------------------->

        // Add trades to the egress table
        .order.applyNewTrades . raze'[( // TODO derive the prices at each level before
                numtds#state`tside; // more accurate derivation
                raze[{x#y}'[numtdslvl;state`price]]; // more accurate derivation
                tqty;
                numtds#fillTime)];
        
        // Derive and apply order updates
        // -------------------------------------------------->
        
        // Derives the set of order updates that will occur
        // as a result of the trade and amends them 
        // accordingly
        .order.applyOrderUpdates . raze'[(
                state`orderId;
                state`oprice;
                noffset;
                nleaves;
                ndisplayqty;
                nstatus;
                state`time)][;where[msk]]; // TODO check time

        // Derive and apply Executions
        // -------------------------------------------------->

        // Apply the set of fills that would satisfy the 
        // amount of liquidity that is being removed from
        // the orderbook.
        .order.applyTakerFills . raze'[(
                numLvls#ciId;
                numLvls#caId;
                state`tside;
                state`price;
                sum'[tqty];
                count[tqty]#reduce;
                numLvls#fillTime)]; 

        // Check to see if the leaves of any maker orders
        // hase been update by deriving the delta and if there
        // exists any where the delta is not 0 pass those through
        // to the .order.applyMakerFills function.
        flldlt:(nleaves-state`leaves);
        isfll:raze[flldlt]<>0;
        if[any[isfll];[
            .order.applyMakerFills  . raze'[(
                    state`instrumentId;
                    state`accountId;
                    state`oside;
                    state`oprice;
                    abs[flldlt];
                    state`reduce;
                    state`time)][;where[msk and isfll]]; // TOOD check time
            ]];

        // Derive and apply order book updates
        // -------------------------------------------------->

        // Update the orderbook state
        .order.applyBookUpdates . raze'[(
                state`price;
                state`mside;
                nqty;
                nhqty;
                niqty;
                nvqty;
                nobupd#fillTime)]; // TODO add time

    ];if[count[state]>0;[
        // If no orders exist in the orderbook 
        // and yet the trade still executes
        // TODO test
        .order.applyBookUpdates . raze'[(
                state`price;
                state`mside;
                nqty;
                nhqty;
                niqty;
                nvqty)];
        
    ]]];
    
   .order.pruneBook[];
   .order.pruneOrders[];
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
.order.NewOrder            :{[e] 
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
.order.AmendOrder            :{[e] // TODO add time 
    // TODO validation?
    co:first 0!?[`.order.Order;enlist(=;`orderId;o`orderId);0b;()]; // TODO move to engine
    // TODO fill current order with next order
    if[not null[o`size];[o[`leaves]:o[`size];o[`size]:co[`size]]]; // TODO move to engine
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

                        .order.Order,:(o,cod); // TODO test move into make order update
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
.order.CheckStopOrders   :{[e]
    .order.ExecuteStop[instrument;time]'[?[`.order.OrderBook;.util.cond.isActiveStop[];0b;()]];
    };

