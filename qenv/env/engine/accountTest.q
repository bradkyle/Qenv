


// Account Management
// -------------------------------------------------------------->
/*******************************************************

.qt.Unit[
    ".account.NewAccount";
    {[c]
        p:c[`params];


    };
    {};
    ();
    .util.testutils.defaultEngineHooks;
    "Global function for creating a new account"];

.qt.Unit[
    ".account.IsAccountInsolvent";
    {[c]
        p:c[`params];


    };
    {};
    ();
    .util.testutils.defaultEngineHooks;
    "Global function for checking if account is insolvent"];

.qt.Unit[
    ".account.Deposit";
    {[c]
        p:c[`params];
        mck1: .qt.M[`.pipe.egress.AddAccountEvent;{[a;b]};c];

    };
    {};
    ();
    .util.testutils.defaultEngineHooks;
    "Global function for adding account deposits"];

.qt.Unit[
    ".account.Withdraw";
    {[c]
        p:c[`params];
        mck1: .qt.M[`.pipe.egress.AddAccountEvent;{[a;b]};c];

    };
    {};
    ();
    .util.testutils.defaultEngineHooks;
    "Global function for adding account withdraws"];

.qt.Unit[
    ".account.AdjustOrderMargin";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.linear.account.AdjustOrderMargin;{[a;b;c;d;e]};c];
        mck2: .qt.M[`.inverse.account.AdjustOrderMargin;{[a;b;c;d;e]};c];
        mck3: .qt.M[`.quanto.account.AdjustOrderMargin;{[a;b;c;d;e]};c];
        mck5: .qt.M[`.pipe.egress.AddAccountEvent;{[a;b]};c];
        mck4: .qt.M[`.pipe.egress.AddInventoryEvent;{[a;b]};c];

    };
    {};
    ();
    .util.testutils.defaultEngineHooks;
    "Global function for creating a new account"];


// Inventory Management
// -------------------------------------------------------------->
/*******************************************************

.qt.Unit[
    ".account.NewInventory";
    {[c]
        p:c[`params];


    };
    {};
    ();
    .util.testutils.defaultEngineHooks;
    "Global function for creating a new account"];

.qt.Unit[
    ".account.ApplyFill";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.linear.account.ApplyFill;{[a;b;c;d;e]};c];
        mck2: .qt.M[`.inverse.account.ApplyFill;{[a;b;c;d;e]};c];
        mck3: .qt.M[`.quanto.account.ApplyFill;{[a;b;c;d;e]};c];
        mck5: .qt.M[`.pipe.egress.AddAccountEvent;{[a;b]};c];
        mck4: .qt.M[`.pipe.egress.AddInventoryEvent;{[a;b]};c];

    };
    {};
    ();
    .util.testutils.defaultEngineHooks;
    "Global function for creating a new account"];

.qt.Unit[
    ".account.ApplyFunding";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.linear.account.ApplyFunding;{[a;b;c;d;e]};c];
        mck2: .qt.M[`.inverse.account.ApplyFunding;{[a;b;c;d;e]};c];
        mck3: .qt.M[`.quanto.account.ApplyFunding;{[a;b;c;d;e]};c];
        mck5: .qt.M[`.pipe.egress.AddAccountEvent;{[a;b]};c];
        mck4: .qt.M[`.pipe.egress.AddInventoryEvent;{[a;b]};c];

    };
    {};
    (
        ("No funding occurs";(
            (); // Current Depth
            (); // Current Orders
            ((10#-1);1000+til 10;10#1000;10#z); // Depth Update
            ([price:(1000+til 10)] side:(10#-1);qty:(10#1000);vqty:(10#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("Negative funding occurs with hedged long position";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("Negative funding occurs with hedged short position";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("Positive funding occurs with hedged long position";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
        ("Positive funding occurs with hedged short position";(
            (); // Current Depth
            (); // Current Orders
            (((10#-1),(10#1));((1000+til 10),(999-til 10));20#1000;20#z); // Depth Update
            ([price:(((1000+til 10),(999-til 10)))] side:((10#-1),(10#1));qty:(20#1000);vqty:(20#1000)); // Expected Depth
            (); // Expected Orders
            (0b;0;()); // Expected AddDepthEvent Mock
            () // Expected Events
        ));
    );
    .util.testutils.defaultEngineHooks;
    "Global function for creating a new account"];

.qt.Unit[
    ".account.UpdateMarkPrice";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.linear.account.UpdateMarkPrice;{[a;b;c;d;e]};c];
        mck2: .qt.M[`.inverse.account.UpdateMarkPrice;{[a;b;c;d;e]};c];
        mck3: .qt.M[`.quanto.account.UpdateMarkPrice;{[a;b;c;d;e]};c];
        mck5: .qt.M[`.pipe.egress.AddAccountEvent;{[a;b]};c];
        mck4: .qt.M[`.pipe.egress.AddInventoryEvent;{[a;b]};c];

    };
    {};
    ();
    .util.testutils.defaultEngineHooks;
    "Global function for creating a new account"];

.qt.Unit[
    ".account.ApplySettlement";
    {[c]
        p:c[`params];

    };
    {};
    ();
    .util.testutils.defaultEngineHooks;
    "Global function for creating a new account"];
