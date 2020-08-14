
// TODO config delete cancelled orders.
ProcessTrade    :{[instrumentId]
    nside: $[side=`BUY:]; // TODO check if has agent orders on side, move into one select/update statement // TODO filtering on orders
    l:update fill:sums qty from 0!(.order.OrderBook pj select qty:sum leaves, oqty:sum leaves, leaves, size, offset, orderId, accountId, reduceOnly by price from .order.Order);
    lt:update tgt:qty-(qty^rp), rp:qty^rp from select price, qty, thresh:fill, rp:((fill-prev[fill])-(fill-q)),oqty,leaves,size,offset,orderId, accountId, reduceOnly from l where qty>(qty-((fill-prev[fill])-(fill-q)));

    offsets: PadM[lt[`offset]];
    sizes: PadM[lt[`size]]; 
    leaves: PadM[lt[`leaves]]; 
    maxN: max count'[offsets];
    numLvls:count[offsets];

    / Calculate the shifted offsets, which infers
    / the amount of space between each offset
    shft: leaves + offsets; 

    // Calculate new offsets and leaves.
    noffsets: raze[Clip[offsets-lt[`rp]]];
    nleaves: raze[Clip[shft-lt[`rp]]];
    nfilled: (raze[sizes]-nleaves)

    // Derive order updates
    partial:where[raze[`boolean$((sums'[offsets]<=lt[`rp])-(shft<=lt[`rp]))]]; // partial filled
    filled:where[raze[(offsets<=lt[`rp])and(shft<=lt[`rp])]]; // totally filled
    oids:raze[PadM[lt[`orderId]]];
    coids:count[oids];
    prices:raze[{x#y}'[maxN;lt[`price]]];

    // price, orderId, status, offset, leaves, filled 
    ords:(6,coids)#0;
    ords[0]:prices; // order prices
    ords[1]:oids;
    ords[2;partial]:count[partial]#1; // ORDERSTATUS$`PARTIALFILLED
    ords[2;filled]:count[filled]#2; // ORDERSTATUS$`FILLED
    ords[3]:noffsets;
    ords[4]:nleaves;
    ords[5]:; // TODO
    `.order.Order upsert (flip update status:`.order.ORDERSTATUS@status from `price`orderId`status`offset`leaves`filled!ords[;where[((oids in filled)or(oids in partial)) and (oids in raze[lt[`orderId]])]]);
    // todo order update events.

    // accountId, instrumentId, price, side, qty, time reduceOnly, isMaker
    fllcols:`accountId`instrumentId`price`side`qty`time`reduceOnly`isMaker;
    aids: raze[PadM[lt[`accountId]]];
    daids: distinct raze[lt[`accountId]];

    flls:(8,coids)#0; 
    flls[0]:aids; 
    flls[1]:coids#instrumentId;
    flls[2]:prices; // order prices
    flls[3]:coids#`long$(nside); // limit order sides
    flls[4]:Clip[raze[leaves]-nleaves];
    flls[5]:coids#time; // TODO doesnt work
    flls[5]:raze[PadM[lt[`reduceOnly]]];
    flls[6]:coids#1b;
    {.account.ApplyFill[]} 0!select sum qty,last time by accountId,instrumentId,side,price,reduceOnly,isMaker from f where accountId in daids;


    // Calculate trade qtys
    // calculated seperately from orders on account of non agent trades.
    dc:(maxN*2)+1;
    tdc:til dc;
    d:(numLvls,dc)#0; // empty matrix
    idx:(1+tdc) mod 2;
    aidx:-1_where[idx]; / idxs for agent sizes
    oidx:where[not[idx]]; / idxs for offsets
    d[;aidx]: leaves;
    d[;oidx]: offsets;
    d[;dc-1]: Clip(lt[`qty]-max'[shft]); / set last value equal to last (non agent qty)
    sd:d-Clip[sums'[flip raze (enlist(d[;0]-lt[`rp]);flip d[;1_tdc])]];

    // Derive trades from size/offset distribution.
    tqty:flip raze'[(sd*(sd>0) and (d>0))];
    tds:(raze'[(tqty;({dc#x}'[lt[`price]]))])[;where[raze[tqty]>0]];

    .order.AddTradeEvent[];

    if[isAgent;[
        if[accountId in flls[`accountId];.account.IncSelfFill[
            accountId;(count'[select by accountId from f where qty>0]@1);()
        ]]];

        .account.ApplyFill[
            qty;
            price;
            side;
            time;
            reduceOnly;
            0b;
            accountId];
        ]];

    };