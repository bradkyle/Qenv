system "d .engineTest";
\l qunit.q
\l engine.q

// TODO more cases i.e. with agent orders etc.
/ testProcessSideUpdate   :{ 
/         runCase: {[dscr; case]
/             $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
/             / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
/             $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
/             $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

/             res:.order.processSideUpdate[case[`side];case[`updates]];
/             / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
/             .qunit.assertEquals[.order.getQtys[case[`side]]; case[`eqtys]; "qtys expected"];
/             .qunit.assertEquals[.order.getOffsets[case[`side]]; case[`eoffsets]; "offsets expected"];
/             .qunit.assertEquals[.order.getSizes[case[`side]]; case[`esizes]; "sizes expected"];
/         };
/         caseCols:`side`updates`qtys`orders`offsets`sizes`eqtys`eorders`eoffsets`esizes`eresnum;
        
/         runCase["case1";caseCols!(`BUY;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
/         runCase["case2";caseCols!(`SELL;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
/     };

testSetupEngine :{

    };