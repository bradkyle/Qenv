

.util.Require["/env/state/";
    enlist("state.q";".state")
    ]; 

// Inventory
// ----------------------------------------------------------------------------------------------------------------->

.qt.Unit[
    ".state.openInventory";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultStateHooks;
    "Returns a given accounts open inventory"];


.qt.Unit[
    ".state.amtBySide";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultStateHooks;
    "Derives the amount of open inventory by side for an account"];


// Orders
// ----------------------------------------------------------------------------------------------------------------->

.qt.Unit[
    ".state.ordQtyByPrice";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultStateHooks;
    "Derives the amount of open inventory by side for an account"];


.qt.Unit[
    ".state.lvlQtyByPrice";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultStateHooks;
    "Derives the amount of open inventory by side for an account"];


.qt.Unit[
    ".state.deriveBucketedQty";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultStateHooks;
    "Derives the amount of open inventory by side for an account"];


.qt.Unit[
    ".state.outBoundsOrders";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultStateHooks;
    "Derives the amount of open inventory by side for an account"];


.qt.Unit[
    ".state.genNextClOrdId";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultStateHooks;
    "Derives the amount of open inventory by side for an account"];


// Depth
// ----------------------------------------------------------------------------------------------------------------->

.qt.Unit[
    ".state.deriveLvlPrices";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultStateHooks;
    "Derives the amount of open inventory by side for an account"];


.qt.Unit[
    ".state.derivePriceAtLvl";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultStateHooks;
    "Derives the amount of open inventory by side for an account"];


.qt.Unit[
    ".state.deriveBucketedPrices";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultStateHooks;
    "Derives the amount of open inventory by side for an account"];


.qt.Unit[
    ".state.derivePriceAtBucket";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultStateHooks;
    "Derives the amount of open inventory by side for an account"];

// Insert Events
// ----------------------------------------------------------------------------------------------------------------->

.qt.Unit[
    ".state.InsertResultantEvents";
    {[c]
        p:c[`params];

        .state.InsertResultantEvents[p[`events]];

    };
    {[p]
        e:({`time`kind`cmd`datum!x} each p[0]);
        :`events`eState!(e;p[1]);};
    (
        ("Should correctly insert depth events into both current depth and depth event history";(
            (
                (z;6;1;(0;0;0;0;0;0));
                (z;6;1;(1;0;0;0;0;0))
            );
            (
                (`.account.DepthEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0));
                (`.account.CurrentDepth;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert trade events into trade event history";(
            (
                (z;1;0;(0;z;1000;1000;-1));
                (z;1;0;(0;z;1000;1000;-1))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly mark price updates into trade event history";(
            (
                (z;2;1;(0;0;0;0;0;0));
                (z;2;1;(1;0;0;0;0;0))
            );
            (
                (`.account.MarkEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert funding events into funding event history";(
            (
                (z;4;1;(0;0;0;0;0;0));
                (z;4;1;(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert liquidation events into liquidation event history";(
            (
                (z;3;1;(0;0;0;0;0;0));
                (z;3;1;(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            ))); 
        ("Should correctly insert account events from different accounts, different times";(
            (
                (z;6;1;(0;0;0;0;0;0));
                (z;6;1;(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert inventory events";(
            (
                (z;7;1;6Id(0;1;0;0;0));
                (z;7;1;6Id(1;1;0;0;0))
            );
            (
                (`.account.InventoryEventHistory;([accountId:0 1;side:2#1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert new orders into current orders and order event history";(
            (
                (z;8;0;(0;0;0;0;0;0));
                (z;8;0;(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly update existing orders with order updates in current orders ";(
            (
                (z;8;1;(0;0;0;0;0;0));
                (z;8;1;(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly update current orders to filled ";(
            (
                (z;8;2;(0;0;0;0;0;0));
                (z;8;2;(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )))
    );.util.testutils.defaultStateHooks;
    "Global function for creating a new account"];