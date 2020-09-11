

.util.Require[(
    ("account.q";".account"); 
    ("order.q";".order")
    )]; 

.qt.Unit[
    ".account.NewAccount";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".account.Deposit";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultEngineHooks
    "Global function for adding account deposits"];



.qt.Unit[
    ".account.Withdraw";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultEngineHooks
    "Global function for adding account withdraws"];


.qt.Unit[
    ".account.NewInventory";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".account.AdjustOrderMargin";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".account.ApplyFill";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".account.ApplyFunding";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".account.UpdateMarkPrice";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];


.qt.Unit[
    ".account.ApplySettlement";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultEngineHooks
    "Global function for creating a new account"];
