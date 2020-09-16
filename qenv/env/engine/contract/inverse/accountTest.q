
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

// TODO simplify rectify state


.qt.Unit[
    ".inverse.account.AdjustOrderMargin";
    {[c]
        p:c[`params];

        res:.inverse.account.AdjustOrderMargin[];
    };
    {[p]
    
    };
    (
        ();
        ();
        ()
    );
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
    (
        ("hedged:long_to_longer");
        ("hedged:short_to_shorter");
        ("combined:long_to_longer");
        ("combined:short_to_shorter");
        ()
    );
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
    (
        ("hedged:long_to_longer";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("hedged:longer_to_long";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("hedged:long_to_flat";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("hedged:longer_to_flat";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("hedged:short_to_shorter";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("hedged:shorter_to_short";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("hedged:shorter_to_flat";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:long_to_longer";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:longer_to_long";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:long_to_flat";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:longer_to_short";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:long_to_shorter";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:short_to_shorter";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:shorter_to_short";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:short_to_long";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:short_to_longer";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:short_to_flat_rpl_-50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("hedged:long_to_flat_rpl_50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("hedged:short_to_flat_rpl_50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("hedged:long_to_flat_rpl_-50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:long_to_flat_rpl_50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:long_to_flat_rpl_-50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:long_to_short_rpl_-50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:long_to_short_rpl_50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:short_to_flat_rpl_50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:short_to_long_rpl_50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:short_to_long_rpl_-50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:short_to_flat_rpl_-50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:long_to_flat_rpl_50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:long_to_flat_rpl_-50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:short_to_flat_rpl_50";(
            (); // Instrument
            (); // Account
            (); // Inventory
            (); // Fill
            (); // Expected Account
            (); // Expected Inventory
            (();(0b;0;())); // redFill Mock
            (();(0b;0;())); // incFill Mock
            (();(0b;0;())); // crsFill Mock
            (0;(1b;1;())); // UnrealizedPnl Mock
        ));
        ("combined:short_to_flat_rpl_-50")
    );
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