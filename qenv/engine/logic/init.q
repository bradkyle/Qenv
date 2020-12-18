

\cd logic
\l contract/init.q
\l account.q 
\l instrument.q 
\l order.q 
\l orderbook.q 
\l order.q 
\l match.q 
\l inventory.q 

.logic.loadTests   :{
    .qt.SkpBesTest[(31 34 35 36)];
    .contract.loadTests[sv["/";(x;"contract")]];
    system[sv["";("l ";x;"/testutils.q")]];
    system[sv["";("l ";x;"/accountTest.q")]];
    system[sv["";("l ";x;"/instrumentTest.q")]];
    system[sv["";("l ";x;"/orderTest.q")]];
    system[sv["";("l ";x;"/orderbookTest.q")]];
    system[sv["";("l ";x;"/matchTest.q")]];
    system[sv["";("l ";x;"/inventoryTest.q")]];
    };

\cd ../
