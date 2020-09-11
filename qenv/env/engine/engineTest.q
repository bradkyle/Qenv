

.util.Require[(
    ("engine.q";".engine"); 
    ("instrument.q";".instrument"); 
    ("account.q";".account"); 
    ("order.q";".order"); 
    ("liquidation.q";".engine")
    )]; 

.qt.Unit[
    ".engine.getInstrument";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.ProcessDepthUpdateEvents";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.ProcessNewTradeEvents";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.ProcessMarkUpdateEvents";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.ProcessSettlementEvents";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.ProcessFundingEvents";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.ProcessLiquidationEvents";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.ProcessNewPriceLimitEvents";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.ProcessOrderEvents";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.ProcessWithdrawEvents";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.ProcessDepositEvents";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.ProcessSignalEvents";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.ProcessEvents";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.Info";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.Reset";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];