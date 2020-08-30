

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
deriveOrderUpdates  :{

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

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
derivePublicTrades :{
    splt:{$[count[x];1_(raze raze'[0,(0^x);y]);y]}'[pleaves;nagentQty];
    qty:{s:sums[y];Clip[?[(x-s)>=0;y;x-(s-y)]]}'[rp;splt];
    };


// Process Depth update
// -------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
ProcessDepth        :{[]
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

    nagentQty: flip PadM[raze'[(poffset[;0]; Clip[poffset[;1_(til first maxN)] - shft[;-1_(til first maxN)]];Clip[qty-max'[shft]])]]; // TODO what qty is this referring to
    mnoffset: (0,'-1_'(shft));

    offsetdlts: -1_'(floor[(nagentQty%(sum'[nagentQty]))*dneg]);

    noffset: {?[x>y;x;y]}'[mnoffset;poffset + offsetdlts];
    nshft: pleaves+noffset;
    nvqty: sum'[raze'[flip[raze[enlist(tgt;pleaves)]]]]
    vqty: {?[x>y;x;y]}'[mxshft;nvqty] // todo take into account mxnshift

    oupd:.order.deriveOrderUpdates[];
    odbk:.order.deriveNewOrderBook[];

    if[count[oupd]>0;[
        .order.amendOrderWrapper[oupd];
        ]];

    .order.updDepth[odbk]; 1
    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
ProcessDepthEvent   :{

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
ProcessTrade        :{
    nside: .order.NegSide[side];

    poffset:PadM[offset];
    psize:PadM[size];
    pleaves:PadM[leaves];
    preduceOnly:PadM[reduceOnly];
    porderId:PadM[orderId];
    paccountId:PadM[accountId];
    pinstrumentId:PadM[instrumentId];
    pprice:PadM[oprice];
    pstatus:PadM[status];
    maxN:max count'[offset];
    numLvls:count[offset];
    nshft:pleaves+poffset;

    mxshft:{$[x>1;max[y];x=1;y;0]}'[maxN;nshft];
    noffset: Clip[poffset-rp];
    nleaves: {?[x>z;(y+z)-x;y]}'[rp;pleaves;poffset];

    nvqty: sum'[raze'[flip[raze[enlist(tgt;pleaves)]]]]; // TODO make simpler
    nagentQty: flip PadM[raze'[(0^poffset[;0];Clip[0^poffset[;1_(til first maxN)] - 0^nshft[;-1_(til first maxN)]];Clip[qty-mxshft])]];
    nfilled: psize - nleaves;
    accdlts: pleaves - nleaves;
    vqty: {?[x>y;x;y]}'[mxshft;nvqty];
    
    flls:.order.deriveAccountFills[];
    oupd:.order.deriveOrderUpdates[];
    trds:.order.derivePublicTrades[];
    odbk:.order.deriveNewOrderBook[];

    if[count[flls]>0;[
        .order.applyFillWrapper[flls];
        .order.incSelfFillWrapper[flls];
        ]];

    if[count[oupd]>0;[
        .order.amendOrderWrapper[oupd];
        ]];
    
    if[count[trds[0]]>0;[
        .order.applyFillWrapper[trds[0]];
        ]];

    if[count[trds[1]]>0;[
        .order.addTradeWrapper[trds[1]];
        ]];

    .order.updDepth[odbk];

    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
ProcessTradeEvent   :{

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
ProcessOrderEvent   :{

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

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
ProcessCancelEvent   :{

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
EnactStop            :{[]

    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
UpdateMarkPrice     :{[]

    };