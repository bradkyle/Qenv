
\cd ../../quantest/
\l quantest.q 
\cd ../env/engine/

\cd contract/inverse
\l account.q
/ \cd ../linear
/ \l account.q
/ \cd ../quanto
/ \l account.q
\cd ../../

\l instrument.q
\l account.q
\l order.q

\cd ../util
\l table.q
\l testutils.q 
\l cond.q
\cd ../engine/

\cd ../pipe
\l common.q
\l event.q 
\l egress.q
\l ingress.q 
\l pipe.q 
\cd ../engine


\l engine.q

.qt.Unit[
    ".engine.getInstrument";
    {[c]
        p:c[`params];

        res:.engine.getInstrument[p[`events]];

    };
    {[p]
    
    };
    (
        (("1:0) ProcessNewTradeEvents BUY: single event");(

        ));
        (("1:1) ProcessDepthUpdateEvents SELL: single event");(

        ))
    );
    .util.testutils.defaultContractHooks;
    "Get the main engine instrument"];


.qt.Unit[
    ".engine.ProcessDepthUpdateEvents";
    {[c]
        p:c[`params];

        m:p`mocks;

        mck1: .qt.M[`.engine.getInstrument;{:.util.testutils.defaultInstrument};c];        
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];

        .engine.ProcessDepthUpdateEvents[p[`events]];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyOffsetUpdates Mock
    };
    {[p]
    
    };
    (
        (("1:0) ProcessDepthUpdateEvents BUY: (No hidden qty) one record");(

        ));
        (("1:1) ProcessDepthUpdateEvents SELL: (No hidden qty) one record");(

        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a set of depth update events"];


.qt.Unit[
    ".engine.ProcessNewTradeEvents";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.engine.getInstrument;{:.util.testutils.defaultInstrument};c];        
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];

        .engine.ProcessNewTradeEvents[p[`events]];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyOffsetUpdates Mock
    };
    {[p]
    
    };
    (
        (("1:0) ProcessNewTradeEvents BUY: single event");(

        ));
        (("1:1) ProcessDepthUpdateEvents SELL: single event");(

        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a set of new trade eventss"];


.qt.Unit[
    ".engine.ProcessMarkUpdateEvents";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.engine.getInstrument;{:.util.testutils.defaultInstrument};c];        
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck2: .qt.M[`.order.applyBookUpdates;{[a;b;c;d;e;f;g]};c];

        .engine.ProcessMarkUpdateEvents[p[`events]];
        
        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyOffsetUpdates Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyBookUpdates Mock
    };
    {[p]
    
    };
    (
        (("1:0) ProcessNewTradeEvents BUY: single event");(

        ));
        (("1:1) ProcessDepthUpdateEvents SELL: single event");(

        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a set of mark price update events"];


.qt.Unit[
    ".engine.ProcessSettlementEvents";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.engine.getInstrument;{:.util.testutils.defaultInstrument};c];        
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck2: .qt.M[`.order.applyBookUpdates;{[a;b;c;d;e;f;g]};c];

        .engine.ProcessSettlementEvents[p[`events]];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyOffsetUpdates Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyBookUpdates Mock
    };
    {[p]
    
    };
    (
        (("1:0) ProcessNewTradeEvents BUY: single event");(

        ));
        (("1:1) ProcessDepthUpdateEvents SELL: single event");(

        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a set of settlement events"];


.qt.Unit[
    ".engine.ProcessFundingEvents";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.engine.getInstrument;{:.util.testutils.defaultInstrument};c];        
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck2: .qt.M[`.order.applyBookUpdates;{[a;b;c;d;e;f;g]};c];

        .engine.ProcessFundingEvents[p[`events]];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyOffsetUpdates Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyBookUpdates Mock

    };
    {[p]
    
    };
    (
        (("1:0) ProcessNewTradeEvents BUY: single event");(

        ));
        (("1:1) ProcessDepthUpdateEvents SELL: single event");(

        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a set of funding events"];


.qt.Unit[
    ".engine.ProcessNewPriceLimitEvents";
    {[c]
        p:c[`params];
        
        mck1: .qt.M[`.engine.getInstrument;{:.util.testutils.defaultInstrument};c];        
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck2: .qt.M[`.order.applyBookUpdates;{[a;b;c;d;e;f;g]};c];

        .engine.ProcessFundingEvents[p[`events]];
        
        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyOffsetUpdates Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyBookUpdates Mock

    };
    {[p]
    
    };
    (
        (("1:0) ProcessNewTradeEvents BUY: single event");(

        ));
        (("1:1) ProcessDepthUpdateEvents SELL: single event");(

        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a set of funding events"];
     

.qt.Unit[
    ".engine.ProcessNewOrderEvents";
    {[c]
        p:c[`params];

        m:p`mocks;
        mck1: .qt.M[`.engine.getInstrument;{:.util.testutils.defaultInstrument};c];        
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck2: .qt.M[`.order.applyBookUpdates;{[a;b;c;d;e;f;g]};c];

        .engine.ProcessNewOrderEvents[p[`events]];
        .engine.test.m:m;
        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyOffsetUpdates Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyBookUpdates Mock
    };
    {[p]`events`mocks!(p[0];(1_3#p))};
    (
        (("7:0) ProcessNewOrderEvents BUY: 2 single new order events");(
            (   // `eid`time`cmd`kind`datum
                enlist(z;2#8;2#0;((0;0;0;0;0;0);(0;0;0;0;0;0)))
            );
            (1b;1;());
            (1b;1;())
        ));
        (("7:1) ProcessNewOrderEvents SELL: 2 single new order events");(
            (
                enlist(z;2#8;2#0;((0;0;0;0;0;0);(0;0;0;0;0;0)))
            );
            (1b;1;());
            (1b;1;())
        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a set of order events"];

.qt.Unit[
    ".engine.ProcessAmendOrderEvents";
    {[c]
        p:c[`params];

        m:p`mocks;
        mck1: .qt.M[`.engine.getInstrument;{:.util.testutils.defaultInstrument};c];        
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck2: .qt.M[`.order.applyBookUpdates;{[a;b;c;d;e;f;g]};c];

        .engine.ProcessAmendOrderEvents[p[`events]];
        .engine.test.m:m;
        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyOffsetUpdates Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyBookUpdates Mock
    };
    {[p]`events`mocks!(p[0];(1_3#p))};
    (
        (("7:0) ProcessAmendOrderEvents BUY: 2 single new order events");(
            (   // `eid`time`cmd`kind`datum
                enlist(z;2#8;2#0;((0;0;0;0;0;0);(0;0;0;0;0;0)))
            );
            (1b;1;());
            (1b;1;())
        ));
        (("7:1) ProcessAmendOrderEvents SELL: 2 single new order events");(
            (
                enlist(z;2#8;2#0;((0;0;0;0;0;0);(0;0;0;0;0;0)))
            );
            (1b;1;());
            (1b;1;())
        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a set of order events"];

.qt.Unit[
    ".engine.ProcessWithdrawEvents";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.engine.getInstrument;{:.util.testutils.defaultInstrument};c];        
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck2: .qt.M[`.order.applyBookUpdates;{[a;b;c;d;e;f;g]};c];

        .engine.ProcessWithdrawEvents[p[`events]];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyOffsetUpdates Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyBookUpdates Mock
    };
    {[p]
    
    };
    (
        (("1:0) ProcessNewTradeEvents BUY: single event");(

        ));
        (("1:1) ProcessDepthUpdateEvents SELL: single event");(

        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a set of withdraw events"];


.qt.Unit[
    ".engine.ProcessDepositEvents";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.engine.getInstrument;{:.util.testutils.defaultInstrument};c];        
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck2: .qt.M[`.order.applyBookUpdates;{[a;b;c;d;e;f;g]};c];

        .engine.ProcessDepositEvents[p[`events]];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyOffsetUpdates Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyBookUpdates Mock

    };
    {[p]
    
    };
    (
        (("1:0) ProcessNewTradeEvents BUY: single event");(

        ));
        (("1:1) ProcessDepthUpdateEvents SELL: single event");(

        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a batch of deposit events"];


.qt.Unit[
    ".engine.ProcessSignalEvents";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.engine.getInstrument;{:.util.testutils.defaultInstrument};c];        
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];

        .engine.ProcessSignalEvents[p[`events]];

        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyBookUpdates Mock

    };
    {[p]
    
    };
    (
        (("1:0) ProcessNewTradeEvents BUY: single event");(

        ));
        (("1:1) ProcessDepthUpdateEvents SELL: single event");(

        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a batch of signal events"];


.qt.Unit[
    ".engine.ProcessEvents";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];

        .engine.ProcessEvents[p[`events]];

        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyBookUpdates Mock

    };
    {[p]
    
    };
    (
        (("1:0) ProcessNewTradeEvents BUY: single event");(

        ));
        (("1:1) ProcessDepthUpdateEvents SELL: single event");(

        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a batch of events"];


.qt.Unit[
    ".engine.Info";
    {[c]
        p:c[`params];

        .engine.Info[p[`events]];

    };
    {[p]
    
    };
    (
        (("1:0) ProcessNewTradeEvents BUY: single event");(

        ));
        (("1:1) ProcessDepthUpdateEvents SELL: single event");(

        ))
    );
    .util.testutils.defaultContractHooks;
    "Get the current info for the engine"];


.qt.Unit[
    ".engine.Reset";
    {[c]
        p:c[`params];

        .engine.Reset[p[`events]];

    };
    {[p]
    
    };
    (
        (("1:0) ProcessNewTradeEvents BUY: single event");(

        ));
        (("1:1) ProcessDepthUpdateEvents SELL: single event");(

        ))
    );
    .util.testutils.defaultContractHooks;
    "Reset the engine with different config"];

// TODO Engine Integration Tests
.qt.SkpBesTest[7];
.qt.RunTests[];