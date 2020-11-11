
\cd test

loadTests   :{
    system[sv["";("l ";x;"/benchmarks.q")]];
    system[sv["";("l ";x;"/integration.q")]];
    };

if[TESTING;loadTests[system["pwd"][0]]];
\cd ../