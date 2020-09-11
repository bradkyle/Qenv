
// Integration

.qt.Integration[
    ".engine.ProcessEvents";
    {[c]
        p:c[`params];
        .engine.ProcessEvents[];
        .util.testutils.checkDepth[];
        .util.testutils.checkOrders[];
        .util.testutils.checkInstrument[];
        .util.testutils.checkAccount[];
        .util.testutils.checkInventory[];
        .util.testutils.checkLiquidation[];
        .util.testutils.checkIngressEvents[];
        .util.testutils.checkEngressEvents[];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Derives the amount of open inventory by side for an account"];


.qt.Integration[
    ".adapter.Adapt";
    {[c]
        p:c[`params];
        .state.adapter.Adapt[];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Derives the amount of open inventory by side for an account"];


.qt.Integration[
    ".env.Step";
    {[c]
        p:c[`params];
        .env.Step[];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Derives the amount of open inventory by side for an account"];