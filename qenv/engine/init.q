\cd engine
\l testutils.q
\l model/init.q
\l logic/init.q
\l valid/init.q
\l engine.q

loadTests   :{
    / .qt.SkpBesTest[(38 39)]; // trade 
    / .qt.SkpBesTest[(40)]; // fill 
    / .qt.SkpBesTest[(11 12 13 14)]; // inverse contract 
    / .qt.SkpBesTest[(25 26 27)]; // account 
    / .qt.SkpBesTest[(28 29 30 31)]; // instrument
    / .qt.SkpBesTest[(31 32 33 34)]; // order
    / .qt.SkpBesTest[(38 39 40 41)]; // valid order
    / .qt.SkpBesTest[(38 39 40 41)]; // valid order
    .qt.SkpBesTest[(47 48 49 50 51 52 53)]; // valid account 
    .logic.loadTests[sv["/";(x;"logic")]];
    .valid.loadTests[sv["/";(x;"valid")]];
    system[sv["";("l ";x;"/engineTest.q")]];
    };

if[TESTING;loadTests[system["pwd"][0]]];
\cd ../

// TODO load tests
