

// select dst:qtyDist[last maxN;last numLvls;pleaves;poffset;shft;qty;rp] from lt
deriveTrades  :{[maxN;numLvls;leaves;offset;shft;qty;rp]
            dc:(maxN*2)+1; 
            tdc:til[dc];
            d:(numLvls,dc)#0; // empty matrix
            idx:(1+tdc) mod 2;
            aidx:-1_where[idx]; / idxs for agent sizes
            oidx:where[not[idx]]; / idxs for offsets
            d[;aidx]: leaves;
            d[;oidx]: offset;
            d[;dc-1]: Clip(qty-max'[shft]);
            sd:(d-Clip[sums'[flip raze (enlist(d[;0]-rp);flip d[;1_tdc])]])
            tqty:flip raze'[(sd*(sd>0) and (d>0))];

            tds:(raze'[(tqty;({dc#x}'[lt[`price]]);((dc*2)#0);((dc*2)#time))])[;where[raze[tqty]>0]];
            t:flip `size`price`side`time!tds;
        };

deriveFills :{

        flls:0!select 
            side:nside,
            fillQty:sum nfilled,
            time:.z.z, // TODO update time.
            isMaker:1b 
            by paccountId,pinstrumentId,pprice,preduceOnly 
            from (select 
                raze[porderId],
                raze[paccountId],
                raze[pinstrumentId],
                raze[pprice],
                raze[nfilled],
                raze[preduceOnly] from lt) 
            where porderId in raze lt[`orderId]

    };

deriveOrderUpdates :{
    oupd:(select price,orderId,offset,leaves,status from 
    (update
        status:`.order.ORDERSTATUS$`FILLED
    from (update 
        status:`.order.ORDERSTATUS$`PARTIALFILLED
        from (select 
        price:raze[pprice], 
        orderId:raze[porderId], 
        offset:raze[noffset], 
        leaves:raze[nleaves], 
        partial:`boolean$(raze[(sums'[poffset]<=rp)-(shft<=rp)]), 
        filled:`boolean$(raze[(poffset<=rp)and(shft<=rp)]),
        status:raze[pstatus] from lt) where partial)where filled) where partial or filled and orderId in raze[lt[`orderId]]);
    };

// Derives transitionary state from 
deriveNextStateFromTrade :{
    lt: update
                    nfilled: psize - nleaves,
                    accdlts: pleaves - nleaves
                from update
                    noffset: Clip[poffset-rp],
                    nleaves: Clip[shft-rp]
                from update
                    shft:pleaves+poffset
                from update 
                    poffset:PadM[offset],
                    psize:PadM[size],
                    pleaves:PadM[leaves],
                    preduceOnly:PadM[reduceOnly],
                    porderId:PadM[orderId],
                    paccountId:PadM[accountId],
                    pinstrumentId:PadM[instrumentId],
                    pprice:PadM[oprice],
                    pstatus:PadM[status],
                    maxN:max count'[offset],
                    numLvls:count[offset] 
                from (select from (
                        update 
                            rp:qty^rp,
                            tgt:qty-rp // the amount that is left over after fill
                                from update 
                                    rp: (thresh-prev[thresh])-(thresh-fillQty) // The amount that is filled at the given level
                                    from update
                                        thresh:sums qty
                                        from update 
                                            qty: qty+(0^oqty)
                                            from 0!((select from .order.OrderBook where side=nside) uj (select 
                                                oqty:sum leaves, 
                                                oprice: price,
                                                leaves, 
                                                size, 
                                                offset, 
                                                orderId, 
                                                accountId, 
                                                instrumentId,
                                                status,
                                                reduceOnly 
                                                by price from .order.Order where otype=`LIMIT, side=nside, status in `PARTIALFILLED`NEW, size>0)) // TODO add instrument id
                    ) where qty>tgt);

    }


nonAgentQtys:{[maxN;poffset;shft;qtys]
    maxNl:til maxN;
    numLvls:count[poffset]; 
    n:(numLvls,(maxN+1))#0;
    n[;0]: poffset[;0];
    n[;-1_(1+maxNl)]: Clip(poffset[;1_maxNl] - shft[;-1_maxNl]);
    n[;maxN]: Clip(qtys-max'[shft]);
    :n;
    };

deriveNextStateFromDepthUpdate  :{


    };