
\cd contract
\l inverse.q
\l linear.q
\l quanto.q

.contract.loadTests   :{
    system[sv["";("l ";path;"/testutils.q")]];
    system[sv["";("l ";x;"/inverseTest.q")]];
    system[sv["";("l ";x;"/linearTest.q")]];
    system[sv["";("l ";x;"/quantoTest.q")]];
    };

\cd ../
