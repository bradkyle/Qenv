

ProcessTrade    :{[]
    update fill:sums qty from 0!(.qt.FOO pj select qty:sum leaves, oqty:sum leaves, leaves, offset, orderId by price from .qt.BAM);
    lt:update tgt:qty-(qty^rp), rp:qty^rp from select price, qty, thresh:fill, rp:((fill-prev[fill])-(fill-q)),oqty,leaves,offset,orderId from l where qty>(qty-((fill-prev[fill])-(fill-q)));

    };