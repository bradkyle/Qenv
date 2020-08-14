
// TODO config delete cancelled orders.
ProcessTrade    :{[]
    nside: .order.NegSide[side]; // TODO check if has agent orders on side, move into one select/update statement // TODO filtering on orders
    l:update fill:sums qty from 0!(.order.OrderBook pj select qty:sum leaves, oqty:sum leaves, leaves, size, offset, orderId by price from .order.Order);
    lt:update tgt:qty-(qty^rp), rp:qty^rp from select price, qty, thresh:fill, rp:((fill-prev[fill])-(fill-q)),oqty,leaves,size,offset,orderId from l where qty>(qty-((fill-prev[fill])-(fill-q)));

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

    // price, orderId, status, offset, leaves, filled 
    ords:(6,count[oids])#0;
    ords[0]:raze[{x#y}'[count'[lt[`orderId]];lt[`price]]];
    ords[1]:oids;
    ords[2;partial]:count[partial]#1; // ORDERSTATUS$`PARTIALFILLED
    ords[2;filled]:count[filled]#2; // ORDERSTATUS$`FILLED
    ords[3]:noffsets;
    ords[4]:nleaves;
    ords[5]:;
    `.order.Order upsert (flip update status:`.order.ORDERSTATUS@status from `price`orderId`status`offset`leaves`filled!ords[;where[((oids in filled)or(oids in partial)) and (oids in raze[lt[`orderId]])]]);

    // derive account updates


    // Calculate trade qtys
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

    if[isAgent;.account.ApplyFill[
            qty;
            price;
            side;
            time;
            reduceOnly;
            0b;
            accountId]];

    };