

\cd logic
\l contract/init.q
\l account.q 
\l instrument.q 
\l order.q 
\l orderbook.q 
\l order.q 
\l trade.q

.logic.loadTests   :{
    system[sv["";("l ";x;"/testutils.q")]];
    .contract.loadTests[sv["/";(x;"contract")]];
    / system[sv["";("l ";path;"/testutils.q")]];
    system[sv["";("l ";x;"/accountTest.q")]];
    system[sv["";("l ";x;"/instrumentTest.q")]];
    system[sv["";("l ";x;"/orderTest.q")]];
    system[sv["";("l ";x;"/orderbookTest.q")]];
    system[sv["";("l ";x;"/tradeTest.q")]];
    };

\cd ../
