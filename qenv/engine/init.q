\cd engine
\l testutils.q
\l model/init.q
\l logic/init.q
\l engine.q

loadTests   :{
    // system[sv["";("l ";x;"/testutils.q")]];
    system[sv["";("l ";x;"/engineTest.q")]];
    .logic.loadTests[sv["/";(x;"logic")]];
    };

if[TESTING;loadTests[system["pwd"][0]]];
\cd ../

// TODO load tests
