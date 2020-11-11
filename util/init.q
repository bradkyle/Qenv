\cd util
\l util.q
\l indicators.q
\l table.q
\l batch.q
\l numpy.q

loadTests   :{
    system[sv["";("l ";x;"/batchTest.q")]];
    system[sv["";("l ";x;"/numpyTest.q")]];
    };

if[TESTING;loadTests[system["pwd"][0]]];
\cd ../
