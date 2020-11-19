show system("pwd");
\cd services
\l account.q
\l depth.q
\l funding.q
\l mark.q
\l order.q
\l pricelimit.q
\l settlement.q
\l trade.q

.services.loadTests   :{
    / system[sv["";("l ";path;"/testutils.q")]];
    system[sv["";("l ";x;"/accountTest.q")]];
    system[sv["";("l ";x;"/depthTest.q")]];
    system[sv["";("l ";x;"/fundingTest.q")]];
    system[sv["";("l ";x;"/markTest.q")]];
    system[sv["";("l ";x;"/orderTest.q")]];
    system[sv["";("l ";x;"/pricelimitTest.q")]];
    system[sv["";("l ";x;"/settlementTest.q")]];
    system[sv["";("l ";x;"/tradeTest.q")]];
    };

\cd ../
