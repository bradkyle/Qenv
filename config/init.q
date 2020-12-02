
\cd config
\l config.q
loadTests   :{
    // system[sv["";("l ";x;"/testutils.q")]];
    system[sv["";("l ";x;"/configTest.q")]];
    };
if[TESTING;loadTests[system["pwd"][0]]];
\cd ../
