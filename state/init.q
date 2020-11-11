\cd state
\l state.q
\l adapter.q
\l dns.q
\l obs.q
\l rew.q
if[TESTING;[
    path:system["pwd"][0];
    system[sv["";("l ";path;"/testutils.q")]];
    system[sv["";("l ";path;"/stateTest.q")]];
    system[sv["";("l ";path;"/adapterTest.q")]];
    system[sv["";("l ";path;"/dnsTest.q")]];
    system[sv["";("l ";path;"/obsTest.q")]];
    system[sv["";("l ";path;"/rewTest.q")]];
    ]];
\cd ../