\d .utilTests
\l qunit.q
\l util.q

testMakeEvent:{
    aid:1;
    time:.z.z;
    event:MakeEvent[time;`NEW;`TRADE;((`side`size`price)!(`LONG;9;99f))];
    show event
    };




testMakeEvent[]
\d .