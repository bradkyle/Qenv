\cd engine
\l model/init.q
\l logic/init.q
\l services/init.q
\l egress.q
\l ingress.q
\l engine.q

loadTests   :{
    system[sv["";("l ";x;"/testutils.q")]];
    system[sv["";("l ";x;"/engineTest.q")]];
    system[sv["";("l ";x;"/ingressTest.q")]];
    system[sv["";("l ";x;"/egressTest.q")]];
    .model.loadTests[sv["/";(x;"model")]];
    .logic.loadTests[sv["/";(x;"logic")]];
    .services.loadTests[sv["/";(x;"services")]];
    };

if[TESTING;loadTests[system["pwd"][0]]];
\cd ../

// TODO load tests
