
\cd model
\l instrument.q
\l orderbook.q
\l inventory.q
\l account.q
\l order.q

.model.loadTests   :{
    / system[sv["";("l ";path;"/testutils.q")]];
    system[sv["";("l ";x;"/instrumentTest.q")]];
    system[sv["";("l ";x;"/inventoryTest.q")]];
    system[sv["";("l ";x;"/orderbookTest.q")]];
    system[sv["";("l ";x;"/accountTest.q")]];
    system[sv["";("l ";x;"/orderTest.q")]];
    };

\cd ../
