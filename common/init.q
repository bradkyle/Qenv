
\cd common
\l account.q
\l error.q
\l event.q
\l instrument.q
\l order.q
if[TESTING;[
    path:system["pwd"][0];
    system[sv["";("l ";path;"/testutils.q")]];
    ]];
\cd ../