system "d .orderbookTest";
\l orderbook.q

/
{
    "Depth update with a single agent ask decreasing (delta less than offset)":{
        "config": {
            "tick_size": 0.5,
            "current_sell_qtys":{},

        },
        "execute":[

        ],
        "expected": {

        }
    }
}
\

// TODO more cases i.e. with agent orders etc.
testProcessSideUpdate:{
    side:`SELL;
    qtys:100 100.5!100 100;

    res:.orderbook.processSideUpdate[side;qtys];
    / .qunit.assertEquals[res; 1b; "Should return true"];
    .qunit.assertEquals[.orderbook.getQtys[side]; qtys; "The orderbook should process"];
    .qunit.assertEquals[.orderbook.getOffsets[side]; (); "There should be no offsets"];
    };

testFillTrade:{
    side:`SELL;
    qtys:100 100.5!100 100;

    res:.orderbook.fillTrade[side;qty;time;0b;0N];
    / .qunit.assertEquals[res; 1b; "Should return true"];
    / .qunit.assertEquals[.orderbook.getQtys[side]; qtys; "The orderbook should process"];
    };