

.qt.Unit[
    ".engine.services.pricelimit.ParsePriceLimitEvents";
    {[c]
        p:c[`params];


    };();();({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.services.pricelimit.ProcessNewPriceLimitEvents";
    {[c]
        p:c[`params]; 

        m:.util.testutils.MakeMocks[p`mocks;c];

        res:.util.testutils.checkErr[
            .engine.services.pricelimit.ProcessMarkUpdateEvents;
            p`args;
            p`err;
            c];

        .util.testutils.checkMocks[m;c];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p]`args`eRes`mocks`err!p}; 
    (
        (("1:0) ProcessNewTradeEvents BUY: single event");(
            `eid`time`cmd`kind`datum!flip((0;z;0;0;(100,0));(0;z;0;0;(100,0)));
            ();
            (
                (1b;1;());
                (1b;1;())
            );
            ()
        ));
        (("1:1) ProcessDepthUpdateEvents SELL: single event");(
            `eid`time`cmd`kind`datum!flip((0;z;0;0;(100,0));(0;z;0;0;(100,0)));
            ();
            (
                (1b;1;());
                (1b;1;())
            );
            ()
        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a set of funding events"];

