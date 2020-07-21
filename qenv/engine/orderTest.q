system "d .orderTest";
\l order.q
\l util.q

// Depth Update Logic
// -------------------------------------------------------------->


// TODO more cases i.e. with agent orders etc.
testProcessSideUpdate   :{ 
        runCase: {[dscr; side; orderbook; orders; upd; eorderbook; eorders] 
            if[count[orderbook]>0;.order.OrderBook:orderbook];
            if[count[orders]>0;.order.Order:orders];

            .order.processSideUpdate[side;upd];

            ob: .order.OrderBook;
            ors: .order.Order;

            .qunit.assertEquals[ob~eorderbook; 1b; dscr,": orderbook"]; // TODO use caseid etc
            / .qunit.assertEquals[.order.getQtys[case[`side]]; case[`eqtys]; "qtys expected"];
            / .qunit.assertEquals[.order.getOffsets[case[`side]]; case[`eoffsets]; "offsets expected"];
            / .qunit.assertEquals[.order.getSizes[case[`side]]; case[`esizes]; "sizes expected"];
        };
        b:`.order.ORDERSIDE$`BUY;

        runCase["simple update no agent orders or previous depth";`BUY;
            ();
            (); // flat maker fee
            (E[100.5]!E[100]);
            1!([]price:E[100.5];side:E[b];qty:E[100f]);
            ()];

        runCase["simple update no agent orders with previous depth";`BUY;
            1!([]price:E[100.5];side:E[b];qty:E[1000f]);
            (); // flat maker fee
            (E[100.5]!E[100]);
            1!([]price:E[100.5];side:E[b];qty:E[100f]);
            ()];

        runCase["simple update no agent orders with previous multi level depth one side";`BUY;
            1!([]price:100.5 101;side:2#b;qty:1000 1000f);
            (); // flat maker fee
            (E[100.5]!E[100]);
            1!([]price:100.5 101;side:2#b;qty:100 1000f);
            ()];

        runCase["multiple level updates simultaneously";`BUY;
            1!([]price:100.5 101;side:2#b;qty:1000 1000f);
            (); // flat maker fee
            (E[100.5]!E[100]);
            1!([]price:100.5 101;side:2#b;qty:100 1000f);
            ()];
 
    };


// Limit Order Manipulation CRUD Logic
// -------------------------------------------------------------->

/ testAddLimitOrder   :{
/     runCase:{[dscr;case]
/         $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
/         / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
/         $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
/         $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

/         res:.order.NewOrder[case[`orders];.z.z];
/         / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
/         .qunit.assertEquals[.order.getQtys[case[`side]]; case[`eqtys]; "qtys expected"];
/         .qunit.assertEquals[.order.getOffsets[case[`side]]; case[`eoffsets]; "offsets expected"];
/         .qunit.assertEquals[.order.getSizes[case[`side]]; case[`esizes]; "sizes expected"];
/     };
/     oCols:`orderId`accountId`side`price`size`isClose`execInst;
/     caseCols:`side`qtys`offsets`sizes`orders`eqtys`eoffsets`esizes`eorders;
/     / ((100 100.5!100 100))
/     runCase["case1";caseCols!(`SELL;();();();oCols!(1;1;`SELL;100f;200f;0b;());(e[100f]!e[200]);(e[1]!e[0]);(e[100f]!e[200]);())];

/     };

/ testUpdateLimitOrder    :{
/     runCase:{[dscr;case]
/         $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
/         / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
/         $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
/         $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

/         res:.order.UpdateOrder[case[`orders];.z.z];
/         / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
/         .qunit.assertEquals[.order.getQtys[case[`side]]; case[`eqtys]; "qtys expected"];
/         .qunit.assertEquals[.order.getOffsets[case[`side]]; case[`eoffsets]; "offsets expected"];
/         .qunit.assertEquals[.order.getSizes[case[`side]]; case[`esizes]; "sizes expected"];
/     };
/     oCols:`orderId`accountId`side`price`size`isClose`execInst;
/     caseCols:`side`qtys`offsets`sizes`orders`eqtys`eoffsets`esizes`eorders;
/     / ((100 100.5!100 100))
/     runCase["case1";caseCols!(`SELL;();();();oCols!(1;1;`SELL;100f;200f;0b;());(e[100f]!e[200]);(e[1]!e[0]);(e[100f]!e[200]);())];

/     };

/ testRemoveLimitOrder    :{

/     };


// Market Order and Trade Logic
// -------------------------------------------------------------->

/ testFillTrade:{
/     time: .z.z
/     side:`SELL;
/     qtys:100 100.5!100 100;

/     res:.order.fillTrade[side;qty;time;0b;0N];
/     / .qunit.assertEquals[res; 1b; "Should return true"];
/     / .qunit.assertEquals[.order.getQtys[side]; qtys; "The orderbook should process"];
/     };