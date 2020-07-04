system "d .orderbookTest";
\l order.q

e:{[x] :enlist[x]};

/*******************************************************
/ QTYS

testGetQtys :{

    };

testUpdateQtys :{

    };

testGetBestQty :{

    };

testGetQtyAtPrice :{

    }

testDecrementQty  :{

    }

testUpdateQty   :{

    }

testGetAvailableQty :{

    }


/*******************************************************
/ Offsets

testGetOffsets  :{

    };

testAddNewOffset    :{

    };

testGenNewOffset    :{

    };

testUpdateOffsets   :{

    }

testDecrementOffsetsAtPrice :{

    }

/*******************************************************
/ Sizes

testGetSizes    :{

    };

testAddNewSize  :{

    };

testUpdateSizes :{

    };

testNewLvl  :{

    };
    
/*******************************************************
/ Combined Representation

testGetCombinedQtys :{[]

    };

testGetSideCombinedQtys :{[]

    };

testGetAllCombinedQtys  :{

    };

testGetSpread   :{

    };

// Depth Update Logic
// -------------------------------------------------------------->


// TODO more cases i.e. with agent orders etc.
testProcessSideUpdate   :{ 
        runCase: {[dscr; case]
            $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
            / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
            $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
            $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

            res:.order.processSideUpdate[case[`side];case[`updates]];
            / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
            .qunit.assertEquals[.order.getQtys[case[`side]]; case[`eqtys]; "qtys expected"];
            .qunit.assertEquals[.order.getOffsets[case[`side]]; case[`eoffsets]; "offsets expected"];
            .qunit.assertEquals[.order.getSizes[case[`side]]; case[`esizes]; "sizes expected"];
        };
        caseCols:`side`updates`qtys`orders`offsets`sizes`eqtys`eorders`eoffsets`esizes`eresnum;
        
        runCase["case1";caseCols!(`BUY;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
        runCase["case2";caseCols!(`SELL;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
    };


// Limit Order Manipulation CRUD Logic
// -------------------------------------------------------------->

testAddLimitOrder   :{
    runCase:{[dscr;case]
        $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
        / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
        $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
        $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

        res:.order.NewOrder[case[`orders];.z.z];
        / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
        .qunit.assertEquals[.order.getQtys[case[`side]]; case[`eqtys]; "qtys expected"];
        .qunit.assertEquals[.order.getOffsets[case[`side]]; case[`eoffsets]; "offsets expected"];
        .qunit.assertEquals[.order.getSizes[case[`side]]; case[`esizes]; "sizes expected"];
    };
    oCols:`orderId`accountId`side`price`size`isClose`execInst;
    caseCols:`side`qtys`offsets`sizes`orders`eqtys`eoffsets`esizes`eorders;
    / ((100 100.5!100 100))
    runCase["case1";caseCols!(`SELL;();();();oCols!(1;1;`SELL;100f;200f;0b;());(e[100f]!e[200]);(e[1]!e[0]);(e[100f]!e[200]);())];

    };

testUpdateLimitOrder    :{
    runCase:{[dscr;case]
        $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
        / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
        $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
        $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

        res:.order.UpdateOrder[case[`orders];.z.z];
        / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
        .qunit.assertEquals[.order.getQtys[case[`side]]; case[`eqtys]; "qtys expected"];
        .qunit.assertEquals[.order.getOffsets[case[`side]]; case[`eoffsets]; "offsets expected"];
        .qunit.assertEquals[.order.getSizes[case[`side]]; case[`esizes]; "sizes expected"];
    };
    oCols:`orderId`accountId`side`price`size`isClose`execInst;
    caseCols:`side`qtys`offsets`sizes`orders`eqtys`eoffsets`esizes`eorders;
    / ((100 100.5!100 100))
    runCase["case1";caseCols!(`SELL;();();();oCols!(1;1;`SELL;100f;200f;0b;());(e[100f]!e[200]);(e[1]!e[0]);(e[100f]!e[200]);())];

    };

testRemoveLimitOrder    :{

    };


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