
\cd contract
\l inverse.q
\l linear.q
\l quanto.q
\l contract.q 

.contract.loadTests   :{
    system[sv["";("l ";path;"/testutils.q")]];
    system[sv["";("l ";x;"/inverseTest.q")]];
    system[sv["";("l ";x;"/linearTest.q")]];
    system[sv["";("l ";x;"/quantoTest.q")]];
    system[sv["";("l ";x;"/contractTest.q")]];
    };

\cd ../
