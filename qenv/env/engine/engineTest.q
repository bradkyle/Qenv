\l 

.qt.Unit[
    ".engine.getInstrument";
    {[c]
        p:c[`params];

        res:.engine.getInstrument[p[`events]];

    };
    ();
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
        ((("1:0) ProcessDepthUpdateEvents BUY: (No hidden qty) one record");(

        ));
        ((("1:1) ProcessDepthUpdateEvents SELL: (No hidden qty) one record");(

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
        ((("1:0) ProcessNewTradeEvents BUY: single event");(

        ));
        ((("1:1) ProcessDepthUpdateEvents SELL: single event");(

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
    ();
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
    ();
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
    ();
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
    ();
    .util.testutils.defaultContractHooks;
    "Process a set of funding events"];
     

.qt.Unit[
    ".engine.ProcessOrderEvents";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.engine.getInstrument;{:.util.testutils.defaultInstrument};c];        
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];
        mck2: .qt.M[`.order.applyBookUpdates;{[a;b;c;d;e;f;g]};c];

        .engine.ProcessOrderEvents[p[`events]];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyOffsetUpdates Mock
        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyBookUpdates Mock
    };
    ();
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
    ();
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
    ();
    .util.testutils.defaultContractHooks;
    " "];


.qt.Unit[
    ".engine.ProcessSignalEvents";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.engine.getInstrument;{:.util.testutils.defaultInstrument};c];        
        mck1: .qt.M[`.order.ProcessDepth;{[a;b;c;d]};c];

        .engine.ProcessSignalEvents[p[`events]];

        .util.testutils.checkMock[mck2;m[1];c];  // Expected .order.applyBookUpdates Mock

    };
    ();
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
    (
        ((("1:0) ProcessDepthUpdateEvents BUY: (No hidden qty) one record");(

        ));
        ((("1:1) ProcessDepthUpdateEvents SELL: (No hidden qty) one record");(

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
    ();
    .util.testutils.defaultContractHooks;
    "Get the current info for the engine"];


.qt.Unit[
    ".engine.Reset";
    {[c]
        p:c[`params];

        .engine.Reset[p[`events]];

    };
    ();
    .util.testutils.defaultContractHooks;
    "Reset the engine with different config"];

// TODO Engine Integration Tests