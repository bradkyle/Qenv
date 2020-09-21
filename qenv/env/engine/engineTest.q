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

        .engine.ProcessDepthUpdateEvents[p[`events]];

    };
    ();
    .util.testutils.defaultContractHooks;
    "Process a set of depth update events"];


.qt.Unit[
    ".engine.ProcessNewTradeEvents";
    {[c]
        p:c[`params];

        .engine.ProcessNewTradeEvents[p[`events]];

    };
    ();
    .util.testutils.defaultContractHooks;
    "Process a set of new trade eventss"];


.qt.Unit[
    ".engine.ProcessMarkUpdateEvents";
    {[c]
        p:c[`params];

        .engine.ProcessMarkUpdateEvents[p[`events]];

    };
    ();
    .util.testutils.defaultContractHooks;
    "Process a set of mark price update events"];


.qt.Unit[
    ".engine.ProcessSettlementEvents";
    {[c]
        p:c[`params];

        .engine.ProcessSettlementEvents[p[`events]];

    };
    ();
    .util.testutils.defaultContractHooks;
    "Process a set of settlement events"];


.qt.Unit[
    ".engine.ProcessFundingEvents";
    {[c]
        p:c[`params];

        .engine.ProcessFundingEvents[p[`events]];

    };
    ();
    .util.testutils.defaultContractHooks;
    "Process a set of funding events"];


.qt.Unit[
    ".engine.ProcessLiquidationEvents";
    {[c]
        p:c[`params];

        .engine.ProcessLiquidationEvents[p[`events]];

    };
    ();
    .util.testutils.defaultContractHooks;
    "Process a set of liquidation events"];


.qt.Unit[
    ".engine.ProcessNewPriceLimitEvents";
    {[c]
        p:c[`params];

        .engine.ProcessNewPriceLimitEvents[p[`events]];

    };
    ();
    .util.testutils.defaultContractHooks;
    "Process a set of new price limit events"];


.qt.Unit[
    ".engine.ProcessOrderEvents";
    {[c]
        p:c[`params];

        .engine.ProcessOrderEvents[p[`events]];

    };
    ();
    .util.testutils.defaultContractHooks;
    "Process a set of order events"];


.qt.Unit[
    ".engine.ProcessWithdrawEvents";
    {[c]
        p:c[`params];

        .engine.ProcessWithdrawEvents[p[`events]];

    };
    ();
    .util.testutils.defaultContractHooks;
    "Process a set of withdraw events"];


.qt.Unit[
    ".engine.ProcessDepositEvents";
    {[c]
        p:c[`params];

        .engine.ProcessDepositEvents[p[`events]];

    };
    ();
    .util.testutils.defaultContractHooks;
    " "];


.qt.Unit[
    ".engine.ProcessSignalEvents";
    {[c]
        p:c[`params];

        .engine.ProcessSignalEvents[p[`events]];

    };
    ();
    .util.testutils.defaultContractHooks;
    "Process a batch of signal events"];


.qt.Unit[
    ".engine.ProcessEvents";
    {[c]
        p:c[`params];

        .engine.ProcessEvents[p[`events]];

    };
    ();
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