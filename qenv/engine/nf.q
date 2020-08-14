

ProcessTrade    :{[]
    nside: .order.NegSide[side]; // TODO check if has agent orders on side, move into one select/update statement
    l:update fill:sums qty from 0!(.order.OrderBook pj select qty:sum leaves, oqty:sum leaves, leaves, offset, orderId by price from .order.Order);
    lt:update tgt:qty-(qty^rp), rp:qty^rp from select price, qty, thresh:fill, rp:((fill-prev[fill])-(fill-q)),oqty,leaves,offset,orderId from l where qty>(qty-((fill-prev[fill])-(fill-q)));

    offsets: PadM[lt[`offset]];
    sizes: PadM[lt[`leaves]]; 
    maxN: max count'[offsets];
    numLvls:count[offsets];

    / Calculate the shifted offsets, which infers
    / the amount of space between each offset
    shft: sizes + offsets; 

    // Calculate new offsets and sizes.
    noffsets: Clip[offsets-lt[`rp]];
    nsizes: Clip[shft-lt[`rp]];

    // Derive partial fills TODO test
    partial:`boolean$((sums'[offsets]<=lt[`rp])-(shft<=lt[`rp]));

    // Calculate trade qtys
    dc:(maxN*2)+1;
    tdc:til dc;
    d:(numLvls,dc)#0; // empty matrix
    idx:(1+tdc) mod 2;
    aidx:-1_where[idx]; / idxs for agent sizes
    oidx:where[not[idx]]; / idxs for offsets
    d[;aidx]: sizes;
    d[;oidx]: offsets;
    d[;dc-1]: Clip(lt[`qty]-max'[shft]); / set last value equal to last (non agent qty)
    sd:d-Clip[sums'[flip raze (enlist(d[;0]-lt[`rp]);flip d[;1_tdc])]];

    // Derive trades from size/offset distribution.
    tqty:flip raze'[(sd*(sd>0) and (d>0))];
    tds:(raze'[(tqty;({9#x}'[lt[`price]]))])[;where[raze[tqty]>0]];

    if[isAgent;.account.ApplyFill[
            qty;
            price;
            side;
            time;
            reduceOnly;
            0b;
            accountId]];

    };