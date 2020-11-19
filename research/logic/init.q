
\cd logic
\l contract/init.q
\l fill.q
\l liquidation.q

.logic.loadTests   :{
    .contract.loadTests[sv["/";(x;"contract")]];
    / system[sv["";("l ";path;"/testutils.q")]];
    system[sv["";("l ";x;"/fillTest.q")]];
    system[sv["";("l ";x;"/liquidationTest.q")]];
    };

\cd ../
