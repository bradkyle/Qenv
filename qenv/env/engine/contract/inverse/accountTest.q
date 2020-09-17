
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
    (
        ();
        ();
        ()
    );
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
        ("hedged:long_to_longer");
        ("hedged:short_to_shorter");
        ("combined:long_to_longer");
        ("combined:short_to_shorter");
        ("hedged:long_to_longer");
        ("hedged:short_to_shorter");
        ("combined:long_to_longer");
        ("combined:short_to_shorter")
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
    (
        ("hedged:longer_to_long";());
        ("hedged:shorter_to_short";());
        ("hedged:longer_to_long rpl + 0.25";());
        ("hedged:shorter_to_short rpl + 0.25";());
        ("hedged:longer_to_long rpl - 0.25";());
        ("hedged:shorter_to_short rpl - 0.25";());
        ("combined:longer_to_long";());
        ("combined:shorter_to_short";());
        ("combined:longer_to_long rpl + 0.25";());
        ("combined:shorter_to_short rpl + 0.25";());
        ("combined:longer_to_long rpl - 0.25";());
        ("combined:shorter_to_short rpl - 0.25";())
    );
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
    (
        ("combined:longer_to_short";());
        ("combined:shorter_to_long";());
        ("combined:shorter_to_longer";());
        ("combined:longer_to_shorter";());
        ("combined:longer_to_short rpl + 0.25";());
        ("combined:shorter_to_long rpl + 0.25";());
        ("combined:longer_to_short rpl - 0.25";());
        ("combined:shorter_to_long rpl - 0.25";());
        ("combined:longer_to_shorter rpl + 0.25";());
        ("combined:shorter_to_longer rpl + 0.25";());
        ("combined:longer_to_shorter rpl - 0.25";());
        ("combined:shorter_to_longer rpl - 0.25";())
    );
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
    (
        ();
        ();
        ();
        ();
        ();
        ();
        ()
    );
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];

.qt.Unit[
    ".inverse.account.ApplyFunding";
    {[c]
        p:c[`params];

        res:.inverse.account.ApplyFunding[];
        
    };
    {[p]
    
    };
    (
        ("No inventory, no funding occurs hedged";());
        ("No inventory, no funding occurs combined";());
        ("Positive Funding occurs hedged long position";());
        ("Negative Funding occurs hedged long position";());
        ("Positive Funding occurs hedged short position";());
        ("Negative Funding occurs hedged short position";());
        ("Negative Funding occurs with split hedged short(0.50)/long(0.50) position";());
        ("Positive Funding occurs with split hedged long(0.50)/short(0.50) position";());
        ("Negative Funding occurs with split hedged short(0.75)/long(0.25) position";());
        ("Negative Funding occurs with split hedged long(0.25)/short(0.75) position";());
        ("Positive Funding occurs with split hedged short(0.75)/long(0.25) position";());
        ("Positive Funding occurs with split hedged long(0.25)/short(0.75) position";());
        ("Negative Funding occurs combined short position";());
        ("Positive Funding occurs combined short position";());
        ("Negative Funding occurs combined long position";());
        ("Positive Funding occurs combined long position";())
    );
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
    (
        ("deposit valid amt without positions";());
        ("deposit valid amt with combined short position";());
        ("deposit valid amt with combined long position";());
        ("deposit valid amt with hedged short position";());
        ("deposit valid amt with hedged long position";());
        ("deposit valid amt with split hedged short(0.50)/long(0.50) position";());
        ("deposit valid amt with split hedged long(0.50)/short(0.50) position";());
        ("deposit valid amt with split hedged short(0.75)/long(0.25) position";());
        ("deposit valid amt with split hedged long(0.25)/short(0.75) position";());
        ("deposit valid amt with split hedged short(0.75)/long(0.25) position";());
        ("deposit valid amt with split hedged long(0.25)/short(0.75) position";());
        ("deposit invalid amt without positions";());
        ("deposit invalid amt with combined short position";());
        ("deposit invalid amt with combined long position";());
        ("deposit invalid amt with hedged short position";());
        ("deposit invalid amt with hedged long position";());
        ("deposit invalid amt with split hedged short(0.50)/long(0.50) position";());
        ("deposit invalid amt with split hedged long(0.50)/short(0.50) position";());
        ("deposit invalid amt with split hedged short(0.75)/long(0.25) position";());
        ("deposit invalid amt with split hedged long(0.25)/short(0.75) position";());
        ("deposit invalid amt with split hedged short(0.75)/long(0.25) position";());
        ("deposit invalid amt with split hedged long(0.25)/short(0.75) position";())
    );
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
    (
        ("withdraw sufficient balance without positions";());
        ("withdraw sufficient balance with combined short position";());
        ("withdraw sufficient balance with combined long position";());
        ("withdraw sufficient balance with hedged short position";());
        ("withdraw sufficient balance with hedged long position";());
        ("withdraw sufficient balance with split hedged short(0.50)/long(0.50) position";());
        ("withdraw sufficient balance with split hedged long(0.50)/short(0.50) position";());
        ("withdraw sufficient balance with split hedged short(0.75)/long(0.25) position";());
        ("withdraw sufficient balance with split hedged long(0.25)/short(0.75) position";());
        ("withdraw sufficient balance with split hedged short(0.75)/long(0.25) position";());
        ("withdraw sufficient balance with split hedged long(0.25)/short(0.75) position";());
        ("withdraw insufficient balance without positions";());
        ("withdraw insufficient balance with combined short position";());
        ("withdraw insufficient balance with combined long position";());
        ("withdraw insufficient balance with hedged short position";());
        ("withdraw insufficient balance with hedged long position";());
        ("withdraw insufficient balance with split hedged short(0.50)/long(0.50) position";());
        ("withdraw insufficient balance with split hedged long(0.50)/short(0.50) position";());
        ("withdraw insufficient balance with split hedged short(0.75)/long(0.25) position";());
        ("withdraw insufficient balance with split hedged long(0.25)/short(0.75) position";());
        ("withdraw insufficient balance with split hedged short(0.75)/long(0.25) position";());
        ("withdraw insufficient balance with split hedged long(0.25)/short(0.75) position";())
    );
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];