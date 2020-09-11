

.qt.Unit[
    ".state.rews.GetRewards";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultStateHooks;
    "Global function for creating a new account"];