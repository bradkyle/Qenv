

[
    lvls: .order.OrderBook pj select qty:sum leaves, oqty:sum leaves, leaves, offset, orderId by price from .order.Order;
    / l:update fill:sums qty from 0!(.qt.FOO pj select qty:sum leaves, oqty:sum leaves, leaves, offset, orderId by price from .qt.BAM)
    / lt:select price, qty, fill, tk:((fill-prev[fill])-(fill-q)),oqty,leaves,offset,orderId from l where (next[fill]-fill)>=(fill - q)
    / select from l where (next[fill]-fill)>=(fill - q) = FILLED
    / q:1450
    / lt:update tgt:qty-(qty^rp), rp:qty^rp from select price, qty, thresh:fill, rp:((fill-prev[fill])-(fill-q)),oqty,leaves,offset,orderId from l where qty>(qty-((fill-prev[fill])-(fill-q)))
    / partial: select from lt where tk>0;
    / full: exec price from lt where tk<=0;
    / update tgt:qty-filled from select price, qty, fill, filled:((fill-prev[fill])-(fill-q)),oqty,leaves,offset,orderId from l where qty>(qty-((fill-prev[fill])-(fill-q)))
    / select price, qty, fill, tgt:qty-((fill-prev[fill])-(fill-q)),oqty,leaves,offset,orderId from l where qty>(qty-((fill-prev[fill])-(fill-q)))
    / 1_sums raze(neg[q],lt[`leaves])
    / get non agent qtys
    / lt:update filled:qty,tgt:0 from lt where null[filled]
    / shft<=lt[`filled]
    / {.order.NewOrder[x[0];x[1]]} each .orderTest.makeOrders[(til[8];8#1;8#1;8#`BUY;8#`LIMIT;100 400 600 100 400 600 800 100;8#100;raze(3#1000; 4#999; 1#998);8#.z.z)]
    / odrs:0!(`price xgroup odrs);
    / odrs:0!(`price xgroup odrs);
    / offsets: PadM[lt[`offset]];
    / sizes: PadM[lt[`leaves]]; 
    / maxN: max count'[offsets];
    / numLvls:count[offsets]; // TODO check

    / / Calculate the shifted offsets, which infers
    / / the amount of space between each offset
    / shft: sizes + offsets; 

    / qtys:exec qty from l where price in odrs[`price]
    / filled:(offsets<=lt[`rp])and(shft<=lt[`rp])
    / partial:`boolean$((sums'[offsets]<=lt[`rp])-(shft<=lt[`rp])) // TODO test
    / (raze[PadM[ids]]) where[raze filled]
    / raze[shft][where[raze `boolean$((offsets<=ln[`filled])-(shft<=ln[`filled]))]]
    / raze shft-filled
    / non agent order fills
    / (raze[nes];raze[PadM[ids]];raze[noffsets])[;where[raze partial]]
    / agent order partial fills: raze[PadM[ln[`orderId]]] where[raze partial]
    / raze[shft-ln[`filled]] where[raze partial]
    / raze[shft-ln[`filled]] where[raze partial]
    / -1_'n
    / nes:shft-lt[`rp]
    / 
    / dst:flip[(maxN*2) numLvls#raze[flip[n,sizes]]] // for finding distribution of qty to be filled for trades?
    / shft[;0]:shft[;0]-lt[`rp]
    / sums'[shft] - lt[]

    / new offsets:Clip[offsets-delta] 
    / new trades
    / new qty (orderbook)
    / new filled, new partial

    effected:select from .order.Order where offset<=qty, price=price;

    // derive non agent qtys from effected

    ![`.order.OrderBook;enlist (=;`price;price);0b;(enlist `qty)!enlist (-;`qty;nonAgentSum)];      

    // Update orders set offset to min between offset-qty and 0                 
    ![`.order.Order;.order.isActiveLimit[n[`price]];0b;(enlist `offset)!enlist (-;`offset;n[`offset])];


    {[qty;t;o]
        amt:$[];
        namt:$[];

        ![`.order.Order;
            enlist (=;`orderId;n[`orderId]);
            0b;`offset`size`status!(
                0;0;`.order.ORDERSTATUS$`FILLED
            )];

        .account.ApplyFill[
            qty;
            price;
            nside;
            time;
            o[`reduceOnly];
            1b; // isMaker
            o[`accountId]];

        if[isAgent;
            // If the order was made by an agent the first level of
            // the orderbook should represent the change otherwise not
            // captured.
            / decrementQty[side;price;smallestOffset]; 
            if[o[`accountId]=accountId;.account.IncSelfFill[o[`size]]]];

            .account.ApplyFill[
                n[`size];
                price;
                side;
                time;
                reduceOnly;
                0b;
                accountId];
        ];
        .order.AddTradeEvent[(side;n[`size];price);time];
        .order.AddOrderUpdateEvent[];
    }

]