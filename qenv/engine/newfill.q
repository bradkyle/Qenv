
.account.IncSelfFill    :{
                    ![`.account.Account;
                        enlist (=;`accountId;n[`accountId]);
                        0b;`selfFillCount`selfFillVolume!(
                            (+;`selfFillCount;1);
                            (+;`selfFillVolume;x)
                        )];}

[
    lvls: .order.OrderBook pj select qty:sum leaves by price from .order.Order;
    / l:0!(.qt.FOO pj select qty:sum leaves by price from .qt.BAM)
    / l[`fill]: sums l[`qty];
    / select price, qty, fill, tk:((fill-prev[fill])-(fill-q)) from l where (next[fill]-fill)>=(fill - q)
    / select from l where (next[fill]-fill)>=(fill - q) = FILLED
    / partial: last l
    / full:

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