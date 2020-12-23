\cd engine
\l testutils.q
\l model/init.q
\l logic/init.q
\l valid/init.q
\l engine.q

loadTests   :{
    / .qt.SkpBesTest[(27 28 29 30)]; // instrument
    / .qt.SkpBesTest[(31 32 33 34)]; // order
    / .qt.SkpBesTest[(38 39 40 41)]; // valid order
    .qt.SkpBesTest[(42 43 44 45)]; // valid account 
    .logic.loadTests[sv["/";(x;"logic")]];
    .valid.loadTests[sv["/";(x;"valid")]];
    system[sv["";("l ";x;"/engineTest.q")]];
    };

if[TESTING;loadTests[system["pwd"][0]]];
\cd ../

// TODO load tests
