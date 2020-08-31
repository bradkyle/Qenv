

// Order Utilities
// -------------------------------------------------------------->


// Extern Functionality Wrappers
// -------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
applyFillWrapper    :{
    .account.ApplyFill[enlist x`accountId`instrumentId`side`time`reduceOnly`isMaker`price`fillQty];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
addTradeWrapper    :{
    .account.ApplyFill[enlist x`accountId`instrumentId`side`time`reduceOnly`isMaker`price`fillQty];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
addOrderUpdWrapper    :{
    .account.ApplyFill[enlist x`accountId`instrumentId`side`time`reduceOnly`isMaker`price`fillQty];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
addOrderNewWrapper    :{
    .account.ApplyFill[enlist x`accountId`instrumentId`side`time`reduceOnly`isMaker`price`fillQty];
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
addOrderDelWrapper    :{
    .account.ApplyFill[enlist x`accountId`instrumentId`side`time`reduceOnly`isMaker`price`fillQty];
    };


// Common Conditionals
// -------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
isActiveLimit:{:((>;`size;0);
               (in;`status;enlist[`NEW`PARTIALFILLED]);
               (in;`price;x); // TODO CONDITIONAL
               (in;`side;y); // TODO CONDITIONAL
               (=;`otype;`.order.ORDERTYPE$`LIMIT))};

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
isActiveStop:{:((>;`size;0);
               (in;`status;enlist[`NEW`PARTIALFILLED]);
               (in;`price;x); // TODO CONDITIONAL
               (in;`side;y); // TODO CONDITIONAL
               (in;`otype;enlist[`STOP_MARKET`STOP_LIMIT]))};


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
    state:uj[?[`.order.OrderBook;(=;`side;nside);0b;()]; // TODO grouping
       ?[`.order.Order;.order.isActiveLimit[();nside];0b;()];`price;()]; // TODO grouping

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

// Constructs matrix representation of trades that need to take place 
// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
ProcessTrade        :{[instrument;account;side;fillQty;reduce;fillTime]
    nside: .order.NegSide[side];

    // Join the opposing side of the orderbook with the current agent orders
    // at that level, creating the trade effected state
    state:uj[?[`.order.OrderBook;(=;`side;nside);0b;()];
       ?[`.order.Order;.order.isActiveLimit[();nside];0b;()];`price;()]; // todo update oqty, oprice, check perf on smaller sel

    // TODO move into state
    pqty: qty+(0^oqty);
    thresh:sums qty;
    rp:?[pqty<fillQty;pqty;fillQty]^((thresh-prev[thresh])-(thresh-fillQty));
    tgt:qty-rp;

    // Order differently based on price
    state:$[x=`BUY;`price xasc y;`price xdesc y]; // TODO move into above

    // Pad state into a matrix
    // for faster operations
    poffset:PadM[state`offset]; // TODO move into one invocation
    psize:PadM[state`size];
    pleaves:PadM[state`leaves];
    preduceOnly:PadM[state`reduceOnly];
    porderId:PadM[state`orderId];
    paccountId:PadM[state`accountId];
    pinstrumentId:PadM[state`instrumentId];
    pprice:PadM[state`oprice];
    pstatus:PadM[state`status];

    // Useful counts 
    maxN:max count'[poffset];
    numLvls:count[poffset];

    // Calculate new shifts and max shifts
    nshft:pleaves+poffset;
    mxshft:{$[x>1;max[y];x=1;y;0]}'[maxN;nshft];
    noffset: Clip[poffset-rp];
    nleaves: {?[x>z;(y+z)-x;y]}'[rp;pleaves;poffset];

    // Calculate the new vis qty
    nvqty: sum'[raze'[flip[raze[enlist(tgt;pleaves)]]]]; // TODO make simpler
    nagentQty: flip PadM[
        raze'[(
            0^poffset[;0]; // Use the first offset as the first non agent qty
            Clip[0^poffset[;1_(til first maxN)] - 0^nshft[;-1_(til first maxN)]]; //
            Clip[qty-mxshft]
        )]];
    nfilled: psize - nleaves; // New amount that is filled
    accdlts: pleaves - nleaves; // The new Account deltas
    vqty: {?[x>y;x;y]}'[mxshft;nvqty]; // The new visible quantity

    // Derived the boolean representation of partially and 
    // fully filled orders within the matrix of orders referenced
    // above. They should not overlap.
    partfilled:`boolean$(raze[(sums'[poffset]<=rp)-(nshft<=rp)]);
    fullfilled: `boolean$(raze[(poffset<=rp)and(nshft<=rp)]);
    
    .order.applyAccountFills[
        porderId;
        paccountId;
        pprice;
        nfilled;
        preduceOnly;
        state`accountId];
    
    .order.applyOrderUpdates[
        pprice;
        porderId;
        noffset;
        nleaves;
        pstatus;
        partfilled;
        fullfilled];

    .order.applyPublicTrades[
        accountId;
        instrumentId;
        pleaves;
        preduceOnly;
        nagentQty;
        rp;
        side;
        pprice];

    .order.applyNewOrderBook[
        state`price;
        state`side;
        tgt;
        vqty];

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
NewOrder            :{

    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
AmendOrder          :{

    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
CancelOrder         :{

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
    ExecuteStop[instrument;time]'[?[`.order.OrderBook;.order.isActiveStop[];0b;()]];
    };