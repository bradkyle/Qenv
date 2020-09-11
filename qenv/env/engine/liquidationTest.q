

.util.Require["/env/engine/";(
    ("liquidation.q";".liquidation"); 
    ("instrument.q";".instrument"); 
    ("account.q";".account"); 
    ("order.q";".order") 
    )]; 

.qt.Unit[
    ".liquidation.Liquidate";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultEngineHooks;
    "Global function for creating a new account"];
