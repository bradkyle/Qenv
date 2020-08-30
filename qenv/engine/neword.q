

// Order Utilities
// -------------------------------------------------------------->


// Process Depth update
// -------------------------------------------------------------->

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

    `.order.OrderBook upsert (select price, side, qty:tgt, vqty from state where vqty>0);

    `.order.Order upsert (select from (select 
                price:raze[pprice], 
                orderId:raze[porderId], 
                offset:raze[noffset] from state) where orderId in raze[state[`orderId]]);
    
    dllvl:(select price,side from state where vqty<=0);
            if[count[dllvl]>0;{delete from `.order.OrderBook where price=x[`price], side=x[`side]}'[dllvl]];

    };

ProcessDepthEvent   :{

    };

// Process Trades/Market Orders
// -------------------------------------------------------------->

applyFillWrapper    :{
    .account.ApplyFill[enlist x`accountId`instrumentId`side`time`reduceOnly`isMaker`price`fillQty];
    };

deriveOrderUpdates  :{

    };

deriveAccountFills  :{

    };

deriveTrades        :{

    };

// Constructs matrix representation of trades that need to take place 
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
    
    };

ProcessTradeEvent   :{

    };


// Process Trades/Market Orders
// -------------------------------------------------------------->

NewOrder            :{

    };

AmendOrder          :{

    };

ProcessOrderEvent   :{

    };

CancelOrder         :{

    };

ProcessCancelEvent   :{

    };