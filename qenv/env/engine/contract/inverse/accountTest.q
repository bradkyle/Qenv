
\l account.q

.qt.Unit[
    ".inverse.account.ExecCost";
    {[c]
        p:c[`params];

        res:.inverse.account.ExecCost[];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.AvgPrice";
    {[c]
        p:c[`params];

        res:.inverse.account.AvgPrice[];
    };
    {[p]
    
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.UnrealizedPnl";
    {[c]
        p:c[`params];


        res:.inverse.account.UnrealizedPnl[];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.RealizedPnl";
    {[c]
        p:c[`params];

        res:.inverse.account.RealizedPnl[];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.MaintMarginReq";
    {[c]
        p:c[`params];

        res:.inverse.account.MaintMarginReq[];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.InitMarginReq";
    {[c]
        p:c[`params];

        res:.inverse.account.InitMarginReq[];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.MaintMargin";
    {[c]
        p:c[`params];

        res:.inverse.account.MaintMargin[];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.InitMargin";
    {[c]
        p:c[`params];

        res:.inverse.account.InitMargin[];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.LiquidationPrice";
    {[c]
        p:c[`params];

        res:.inverse.account.LiquidationPrice[];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.BankruptcyPrice";
    {[c]
        p:c[`params];

        res:.inverse.account.BankruptcyPrice[];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];

// TODO simplify rectify state


.qt.Unit[
    ".inverse.account.AdjustOrderMargin";
    {[c]
        p:c[`params];

        res:.inverse.account.AdjustOrderMargin[];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.incFill";
    {[c]
        p:c[`params];

        res:.inverse.account.incFill[];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.redFill";
    {[c]
        p:c[`params];

        res:.inverse.account.redFill[];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.crsFill";
    {[c]
        p:c[`params];

        res:.inverse.account.crsFill[];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.ApplyFill";
    {[c]
        p:c[`params];

        res:.inverse.account.ApplyFill[];

    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];

.qt.Unit[
    ".inverse.account.UpdateMarkPrice";
    {[c]
        p:c[`params];

        res:.inverse.account.UpdateMarkPrice[];

    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];

.qt.Unit[
    ".inverse.account.Deposit";
    {[c]
        p:c[`params];

        res:.inverse.account.Deposit[];
        
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".inverse.account.Withdraw";
    {[c]
        p:c[`params];

        res:.inverse.account.Withdraw[];
        
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];