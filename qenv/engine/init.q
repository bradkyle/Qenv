\cd engine
\l testutils.q
\l model/init.q
\l logic/init.q
\l valid/init.q
\l engine.q

loadTests   :{
    / .qt.SkpBesTest[(11 12 13 14)]; // inverse contract 
    / .qt.SkpBesTest[(23 24 25 26)]; // account 
    / .qt.SkpBesTest[(27 28 29 30)]; // instrument
    .qt.SkpBesTest[(31 32 33 34)]; // order
    / .qt.SkpBesTest[(38 39 40 41)]; // valid order
    / .qt.SkpBesTest[(20 + til 25)]; // valid account 
    .logic.loadTests[sv["/";(x;"logic")]];
    .valid.loadTests[sv["/";(x;"valid")]];
    system[sv["";("l ";x;"/engineTest.q")]];
    };

if[TESTING;loadTests[system["pwd"][0]]];
\cd ../

// TODO load tests
