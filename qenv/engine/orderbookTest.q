system "d .orderbookTest";
\l orderbook.q


// TODO more cases i.e. with agent orders etc.
testProcessSideUpdate:{ 
        runCase: {[case]
            $[count[case[`qtys]]>0;.orderbook.updateQtys[case[`side];case[`qtys]];0N];
            / $[count[case[`orders]]>0;.orderbook.updateOrders[case[`side];case[`orders]];0N];
            $[count[case[`offsets]]>0;.orderbook.updateOffsets[case[`side];case[`offsets]];0N];
            $[count[case[`sizes]]>0;.orderbook.updateSizes[case[`sizes];case[`sizes]];0N];

            res:.orderbook.processSideUpdate[case[`side];case[`updates]];
            / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
            .qunit.assertEquals[.orderbook.getQtys[case[`side]]; case[`eqtys]; "qtys not expected"];
            .qunit.assertEquals[.orderbook.getOffsets[case[`side]]; case[`eoffsets]; "offsets not expected"];
            .qunit.assertEquals[.orderbook.getSizes[case[`side]]; case[`esizes]; "sizes not expected"];
        };
        caseCols:`caseId`side`updates`qtys`orders`offsets`sizes`eqtys`eorders`eoffsets`esizes`eresnum;
        //simple ask update no agent orders or previous depth
        runCase[caseCols!(1;`BUY;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
        runCase[caseCols!(2;`SELL;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
    };

testFillTrade:{
    time: .z.z
    side:`SELL;
    qtys:100 100.5!100 100;

    res:.orderbook.fillTrade[side;qty;time;0b;0N];
    / .qunit.assertEquals[res; 1b; "Should return true"];
    / .qunit.assertEquals[.orderbook.getQtys[side]; qtys; "The orderbook should process"];
    };