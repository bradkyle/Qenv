

.qt.Unit[
    ".liquidation.Liquidate";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultEngineHooks;
    "Global function for creating a new account"];
