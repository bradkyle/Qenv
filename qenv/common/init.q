
\cd common
\l event.q
if[TESTING;[
    path:system["pwd"][0];
    system[sv["";("l ";path;"/testutils.q")]];
    ]];
\cd ../
