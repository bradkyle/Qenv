system "d .orderbookTest";
\l orderbook.q

// TODO more cases i.e. with agent orders etc.
testProcessSideUpdate:{
    side:`SELL;
    qtys:100 100.5!100 100;

    res:.orderbook.processSideUpdate[side;qtys];
    / .qunit.assertEquals[res; 1b; "Should return true"];
    .qunit.assertEquals[.orderbook.getQtys[side]; qtys; "The orderbook should process"];
    };

testFillTrade:{
    side:`SELL;
    qtys:100 100.5!100 100;

    res:.orderbook.fillTrade[side;qty;time;0b;0N];
    / .qunit.assertEquals[res; 1b; "Should return true"];
    / .qunit.assertEquals[.orderbook.getQtys[side]; qtys; "The orderbook should process"];
    };