
.account.IncSelfFill    :{
                    ![`.account.Account;
                        enlist (=;`accountId;n[`accountId]);
                        0b;`selfFillCount`selfFillVolume!(
                            (+;`selfFillCount;1);
                            (+;`selfFillVolume;x)
                        )];}

[
    effected:select from .order.Order where offset<=qty, price=price;

    // derive non agent qtys from effected

    ![`.order.OrderBook;enlist (=;`price;price);0b;(enlist `qty)!enlist (-;`qty;nonAgentSum)];      

    // Update orders set                           
    ![`.order.Order;.order.isActiveLimit[n[`price]];0b;(enlist `offset)!enlist (-;`offset;n[`offset])];


    {[qty;isAgent;o]
        amt:$[];
        namt:$[];


        ![`.order.Order;
            enlist (=;`orderId;n[`orderId]);
            0b;`size`status!(
                0;`.order.ORDERSTATUS$`FILLED
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