
// Base Event Creation Utilities
// ---------------------------------------------------------------------------------------->

.qt.Unit[
    ".state.adapter.createMarketOrder";
    {[c]
        p:c[`params];

        res:.state.adapter.createMarketOrder . p`args;
        / .qt.A[sum[res];~;p[`args][0];"res";c];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`args`eRes!p};
    ();
    .util.testutils.defaultStateHooks;
    "linearly increasing distribution"];

.qt.Unit[
    ".state.adapter.createOrderBatchAmend";
    {[c]
        p:c[`params];

        res:.state.adapter.createMarketOrder . p`args;
        / .qt.A[sum[res];~;p[`args][0];"res";c];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`args`eRes!p};
    ();
    .util.testutils.defaultStateHooks;
    "linearly increasing distribution"];

.qt.Unit[
    ".state.adapter.createOrderBatchCancel";
    {[c]
        p:c[`params];

        res:.state.adapter.createMarketOrder . p`args;
        / .qt.A[sum[res];~;p[`args][0];"res";c];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`args`eRes!p};
    ();
    .util.testutils.defaultStateHooks;
    "linearly increasing distribution"];

.qt.Unit[
    ".state.adapter.createOrderBatchNew";
    {[c]
        p:c[`params];

        res:.state.adapter.createMarketOrder . p`args;
        / .qt.A[sum[res];~;p[`args][0];"res";c];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`args`eRes!p};
    ();
    .util.testutils.defaultStateHooks;
    "linearly increasing distribution"];

.qt.Unit[
    ".state.adapter.createDeposit";
    {[c]
        p:c[`params];

        res:.state.adapter.createMarketOrder . p`args;
        / .qt.A[sum[res];~;p[`args][0];"res";c];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`args`eRes!p};
    ();
    .util.testutils.defaultStateHooks;
    "linearly increasing distribution"];


.qt.Unit[
    ".state.adapter.createWithdraw";
    {[c]
        p:c[`params];

        res:.state.adapter.createMarketOrder . p`args;
        / .qt.A[sum[res];~;p[`args][0];"res";c];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`args`eRes!p};
    ();
    .util.testutils.defaultStateHooks;
    "linearly increasing distribution"];

// Amount distribution logic
// ---------------------------------------------------------------------------------------->

// TODO check that bids and asks ascend /descend accordingly
.qt.Unit[
    ".state.adapter.increasingLinearDistribution";
    {[c]
        p:c[`params];

        res:.state.adapter.increasingLinearDistribution . p`args;
        / .qt.A[sum[res];~;p[`args][0];"res";c];
        .qt.A[res;~;p[`eRes];"res";c];
    };
    {[p] :`args`eRes!p};
    (
        ("10 distributed across 5 with a lot size of 0.1";(
            (10f;5;0.1f);(1 1.5 2 2.5 3)
        ));
        ("10 distributed across 5 with a lot size of 1";(
            (10f;5;1f);(1 1 2 2 3f)
        ));
        ("10 distributed across 10 with a lot size of 1";(
            (10f;10;1f);(0 0 0 0 0 1 1 1 1 1f)
        ));
        ("10 distributed across 10 with a lot size of 0.1";(
            (10f;10;0.1f);(0.3 0.4 0.6 0.7 0.9 1 1.2 1.3 1.5 1.6f)
        ));
        ("10 distributed across 3 with a lot size of 1";(
            (10f;3;1f);(2 3 4f)
        ));
        ("10 distributed across 3 with a lot size of 0.1";(
            (10f;3;0.1f);(2.2 3.3 4.4f)
        ))
    );
    .util.testutils.defaultStateHooks;
    "linearly increasing distribution"];

.qt.Unit[
    ".state.adapter.decreasingLinearDistribution";
    {[c]
        p:c[`params];

        res:.state.adapter.decreasingLinearDistribution . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("10 distributed across 5 with a lot size of 0.1";(
            (10f;5;0.1f);reverse(1 1.5 2 2.5 3)
        ));
        ("10 distributed across 5 with a lot size of 1";(
            (10f;5;1f);reverse(1 1 2 2 3f)
        ));
        ("10 distributed across 10 with a lot size of 1";(
            (10f;10;1f);reverse(0 0 0 0 0 1 1 1 1 1f)
        ));
        ("10 distributed across 10 with a lot size of 0.1";(
            (10f;10;0.1f);reverse(0.3 0.4 0.6 0.7 0.9 1 1.2 1.3 1.5 1.6f)
        ));
        ("10 distributed across 3 with a lot size of 1";(
            (10f;3;1f);reverse(2 3 4f)
        ));
        ("10 distributed across 3 with a lot size of 0.1";(
            (10f;3;0.1f);reverse(2.2 3.3 4.4f)
        ))
    );
    .util.testutils.defaultStateHooks;
    "linearly decreasing distribution"];

.qt.Unit[
    ".state.adapter.increasingSuperLinearDistribution";
    {[c]
        p:c[`params];

        res:.state.adapter.increasingSuperLinearDistribution . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("10 distributed across 5 with a lot size of 1";(
            (10;5;1);(0 0 1 2 4f)
        ));
        ("10 distributed across 5 with a lot size of 0.1";(
            (10;5;0.1);(0.3 0.8 1.6 2.8 4.3)
        ));
        ("10 distributed across 10 with a lot size of 1";(
            (10;10;1);(0 0 0 0 0 0 1 1 2 2f)
        ));
        ("10 distributed across 10 with a lot size of 0.1";(
            (10;10;0.1);(0 0.1 0.2 0.4 0.6 0.9 1.2 1.6 2 2.5)
        ));
        ("10 distributed across 3 with a lot size of 1";(
            (10;3;1);(1 2 5f)
        ));
        ("10 distributed across 3 with a lot size of 0.1";(
            (10;3;0.1);(1.1 2.9 5.8)
        ))
    );
    .util.testutils.defaultStateHooks;
    "superlinearly increasing distribution"];


.qt.Unit[
    ".state.adapter.decreasingSuperLinearDistribution";
    {[c]
        p:c[`params];

        res:.state.adapter.decreasingSuperLinearDistribution . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("10 distributed across 5 with a lot size of 1";(
            (10;5;1);reverse(0 0 1 2 4f)
        ));
        ("10 distributed across 5 with a lot size of 0.1";(
            (10;5;0.1);reverse(0.3 0.8 1.6 2.8 4.3)
        ));
        ("10 distributed across 10 with a lot size of 1";(
            (10;10;1);reverse(0 0 0 0 0 0 1 1 2 2f)
        ));
        ("10 distributed across 10 with a lot size of 0.1";(
            (10;10;0.1);reverse(0 0.1 0.2 0.4 0.6 0.9 1.2 1.6 2 2.5)
        ));
        ("10 distributed across 3 with a lot size of 1";(
            (10;3;1);reverse(1 2 5f)
        ));
        ("10 distributed across 3 with a lot size of 0.1";(
            (10;3;0.1);reverse(1.1 2.9 5.8)
        ))
    );
    .util.testutils.defaultStateHooks;
    "superlinearly dencreasing distribution"];

.qt.Unit[
    ".state.adapter.increasingExponentialDistribution";
    {[c]
        p:c[`params];

        res:.state.adapter.increasingExponentialDistribution . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("10 distributed across 5 with a lot size of 1";(
            (10;5;1);(0 0 0 2 6f)
        ));
        ("10 distributed across 5 with a lot size of 0.1";(
            (10;5;0.1);(0.1 0.3 0.8 2.3 6.2)
        ));
        ("10 distributed across 10 with a lot size of 1";(
            (10;10;1);(0 0 0 0 0 0 0 0 2 6f)
        ));
        ("10 distributed across 10 with a lot size of 0.1";(
            (10;10;0.1);(0 0 0 0 0 0.1 0.3 0.8 2.3 6.3)
        ));
        ("10 distributed across 3 with a lot size of 1";(
            (10;3;1);(1 2 6f)
        ));
        ("10 distributed across 3 with a lot size of 0.1";(
            (10;3;0.1);(1.1 2.5 6.3)
        ))
    );
    .util.testutils.defaultStateHooks;
    "exponentially increasing distribution"];

.qt.Unit[
    ".state.adapter.decreasingExponentialDistribution";
    {[c]
        p:c[`params];

        res:.state.adapter.decreasingExponentialDistribution . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("10 distributed across 5 with a lot size of 1";(
            (10;5;1);reverse(0 0 0 2 6f)
        ));
        ("10 distributed across 5 with a lot size of 0.1";(
            (10;5;0.1);reverse(0.1 0.3 0.8 2.3 6.2)
        ));
        ("10 distributed across 10 with a lot size of 1";(
            (10;10;1);reverse(0 0 0 0 0 0 0 0 2 6f)
        ));
        ("10 distributed across 10 with a lot size of 0.1";(
            (10;10;0.1);reverse(0 0 0 0 0 0.1 0.3 0.8 2.3 6.3)
        ));
        ("10 distributed across 3 with a lot size of 1";(
            (10;3;1);reverse(1 2 6f)
        ));
        ("10 distributed across 3 with a lot size of 0.1";(
            (10;3;0.1);reverse(1.1 2.5 6.3)
        ))
    );
    .util.testutils.defaultStateHooks;
    "exponentially decreasing distribution"];

.qt.Unit[
    ".state.adapter.increasingLogarithmicDistribution";
    {[c]
        p:c[`params];

        res:.state.adapter.increasingLogarithmicDistribution . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("10 distributed across 5 with a lot size of 1";(
            (10;5;1);(1 1 2 2 2f)
        ));
        ("10 distributed across 5 with a lot size of 0.1";(
            (10;5;0.1);(1.4 1.8 2 2.2 2.4)
        ));
        ("10 distributed across 10 with a lot size of 1";(
            (10;10;1);(0 0 0 0 1 1 1 1 1 1f)
        ));
        ("10 distributed across 10 with a lot size of 0.1";(
            (10;10;0.1);(0.6 0.7 0.8 0.9 1 1 1.1 1.1 1.2 1.2)
        ));
        ("10 distributed across 3 with a lot size of 1";(
            (10;3;1);(2 3 3f)
        ));
        ("10 distributed across 3 with a lot size of 0.1";(
            (10;3;0.1);(2.7 3.3 3.8)
        ))
    );
    .util.testutils.defaultStateHooks;
    "logarithmically decreasing distribution"];


.qt.Unit[
    ".state.adapter.decreasingLogarithmicDistribution";
    {[c]
        p:c[`params];

        res:.state.adapter.decreasingLogarithmicDistribution . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("10 distributed across 5 with a lot size of 1";(
            (10;5;1);reverse(1 1 2 2 2f)
        ));
        ("10 distributed across 5 with a lot size of 0.1";(
            (10;5;0.1);reverse(1.4 1.8 2 2.2 2.4)
        ));
        ("10 distributed across 10 with a lot size of 1";(
            (10;10;1);reverse(0 0 0 0 1 1 1 1 1 1f)
        ));
        ("10 distributed across 10 with a lot size of 0.1";(
            (10;10;0.1);reverse(0.6 0.7 0.8 0.9 1 1 1.1 1.1 1.2 1.2)
        ));
        ("10 distributed across 3 with a lot size of 1";(
            (10;3;1);reverse(2 3 3f)
        ));
        ("10 distributed across 3 with a lot size of 0.1";(
            (10;3;0.1);reverse(2.7 3.3 3.8)
        ))
    );
    .util.testutils.defaultStateHooks;
    "linearly decreasing distribution"];

.qt.Unit[
    ".state.adapter.normalDistribution";
    {[c]
        p:c[`params];

        res:.state.adapter.normalDistribution . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("10 distributed across 5 with a lot size of 1";(
            (10;5;1);(1 2 3 2 1f)
        ));
        ("10 distributed across 5 with a lot size of 0.1";(
            (10;5;0.1);(1.1 2.2 3.3 2.2 1.1)
        ));
        ("10 distributed across 10 with a lot size of 1";(
            (10;10;1);(0 0 0 1 1 1 1 1 0 0f)
        ));
        ("10 distributed across 10 with a lot size of 0.1";(
            (10;10;0.1);(0.2 0.5 0.8 1.1 1.4 1.7 1.4 1.1 0.8 0.5)
        ));
        ("10 distributed across 3 with a lot size of 1";(
            (10;3;1);(2 5 2f)
        ));
        ("10 distributed across 3 with a lot size of 0.1";(
            (10;3;0.1);(2.5 5 2.5)
        ))
    );
    .util.testutils.defaultStateHooks;
    "linearly decreasing distribution"];


.qt.Unit[
    ".state.adapter.flatDistribution";
    {[c]
        p:c[`params];

        res:.state.adapter.flatDistribution . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("10 distributed across 5 with a lot size of 1";(
            (10;5;1);(2 2 2 2 2f)
        ));
        ("10 distributed across 5 with a lot size of 0.1";(
            (10;5;0.1);(2 2 2 2 2f)
        ));
        ("10 distributed across 10 with a lot size of 1";(
            (10;10;1);(1 1 1 1 1 1 1 1 1 1f)
        ));
        ("10 distributed across 10 with a lot size of 0.1";(
            (10;10;0.1);(1 1 1 1 1 1 1 1 1 1f)
        ));
        ("10 distributed across 3 with a lot size of 1";(
            (10;3;1);(3 3 3f)
        ));
        ("10 distributed across 3 with a lot size of 0.1";(
            (10;3;0.1);(3.3 3.3 3.3)
        ))
    );
    .util.testutils.defaultStateHooks;
    "linearly decreasing distribution"];

// Price Distribution Utilities
// ---------------------------------------------------------------------------------------->

.qt.Unit[
    ".state.adapter.uniformalPriceDistribution";
    {[c]
        p:c[`params];

        res:.state.adapter.uniformalPriceDistribution . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (1000;2;0.1;10;-1);
            (
                1000 999.8 999.6 999.4 999.2 999 998.8 998.6 998.4 998.2;
                999.8 999.6 999.4 999.2 999 998.8 998.6 998.4 998.2 998
            )
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (1000;2;0.1;10;1);
            (
                1000.0 1000.2 1000.4 1000.6 1000.8 1001.0 1001.2 1001.4 1001.6 1001.8;
                1000.2 1000.4 1000.6 1000.8 1001.0 1001.2 1001.4 1001.6 1001.8 1002.0
            )
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (1000;2;0.5;10;-1);
            (
                1000 999 998 997 996 995 994 993 992 991f;
                999 998 997 996 995 994 993 992 991 990f
            )
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (1000;2;0.5;10;1);
            (
                1000 1001 1002 1003 1004 1005 1006 1007 1008 1009f;
                1001 1002 1003 1004 1005 1006 1007 1008 1009 1010f
            )
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (1000;3;0.5;10;-1);
            (
                1000 998.5 997 995.5 994 992.5 991 989.5 988 986.5;
                998.5 997 995.5 994 992.5 991 989.5 988 986.5 985
            )
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (1000;3;0.5;10;1);
            (
                1000   1001.5 1003   1004.5 1006   1007.5 1009   1010.5 1012   1013.5;
                1001.5 1003   1004.5 1006   1007.5 1009   1010.5 1012   1013.5 1015
            )
        ))
    );
    .util.testutils.defaultStateHooks;
    "Returns a given accounts open inventory"];

.qt.Unit[
    ".state.adapter.exponentialPriceDistribution";
    {[c]
        p:c[`params];

        res: .state.adapter.exponentialPriceDistribution . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (1000;2;0.1;10;-1);
            (
                999.9 999.6 999.1 998.4 997.5 996.4 995.1 993.6 991.9 990;
                999.6 999.1 998.4 997.5 996.4 995.1 993.6 991.9 990 987.9
            )
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (1000;2;0.1;10;1);
            (
                1000.1 1000.4 1000.9 1001.6 1002.5 1003.6 1004.9 1006.4 1008.1 1010;
                1000.4 1000.9 1001.6 1002.5 1003.6 1004.9 1006.4 1008.1 1010 1012.1
            )
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (1000;2;0.5;10;-1);
            (
                999.5 998.0 995.5 992 987.5 982 975.5 968 959.5 950;
                998.0 995.5 992 987.5 982 975.5 968 959.5 950 939.5
            )
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (1000;2;0.5;10;1);
            (
                1000.5 1002.0 1004.5 1008 1012.5 1018 1024.5 1032 1040.5 1050;
                1002.0 1004.5 1008 1012.5 1018 1024.5 1032 1040.5 1050 1060.5
            )
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (1000;3;0.5;10;-1);
            (
                999.5 996 986.5 968 937.5 892 828.5 744 635.5 500;
                996 986.5 968 937.5 892 828.5 744 635.5 500 334.5
            )
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (1000;3;0.5;10;1);
            (
                1000.5 1004 1013.5 1032 1062.5 1108 1171.5 1256 1364.5 1500;
                1004 1013.5 1032 1062.5 1108 1171.5 1256 1364.5 1500 1665.5
            )
        ))
    );
    .util.testutils.defaultStateHooks;
    "Returns a given accounts open inventory"];


// TODO fix this
.qt.Unit[
    ".state.adapter.logarithmicPriceDistribution";
    {[c]
        p:c[`params];

        res:.state.adapter.logarithmicPriceDistribution . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (1000;2;0.1;10;-1);
            (
                1000.1 1000.4 1000.9 1001.6 1002.5 1003.6 1004.9 1006.4 1008.1 1010;
                1000.4 1000.9 1001.6 1002.5 1003.6 1004.9 1006.4 1008.1 1010 1012.1
            )
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (1000;2;0.1;10;1);
            (
                1000.1 1000.4 1000.9 1001.6 1002.5 1003.6 1004.9 1006.4 1008.1 1010;
                1000.4 1000.9 1001.6 1002.5 1003.6 1004.9 1006.4 1008.1 1010 1012.1
            )
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (1000;2;0.5;10;-1);
            (
                1000.5 1002.0 1004.5 1008 1012.5 1018 1024.5 1032 1040.5 1050;
                1002.0 1004.5 1008 1012.5 1018 1024.5 1032 1040.5 1050 1060.5
            )
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (1000;2;0.5;10;1);
            (
                1000.5 1002.0 1004.5 1008 1012.5 1018 1024.5 1032 1040.5 1050;
                1002.0 1004.5 1008 1012.5 1018 1024.5 1032 1040.5 1050 1060.5
            )
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (1000;3;0.5;10;-1);
            (
                1000.5 1004 1013.5 1032 1062.5 1108 1171.5 1256 1364.5 1500;
                1004 1013.5 1032 1062.5 1108 1171.5 1256 1364.5 1500 1665.5
            )
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (1000;3;0.5;10;1);
            (
                1000.5 1004 1013.5 1032 1062.5 1108 1171.5 1256 1364.5 1500;
                1004 1013.5 1032 1062.5 1108 1171.5 1256 1364.5 1500 1665.5
            )
        ))
    );
    .util.testutils.defaultStateHooks;
    "Returns a given accounts open inventory"];

// Flattening Utils
// ---------------------------------------------------------------------------------------->

.qt.Unit[
    ".state.adapter.createFlattenSideOrdersLimit";
    {[c]
        p:c[`params];

    };
    {[p] :`args`eRes!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ))
    );
    "Global function for creating a new account"];


.qt.Unit[
    ".state.adapter.createFlattenAllOrdersLimit";
    {[c]
        p:c[`params];

    };
    {[p] :`args`eRes!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ))
    );
    "Global function for creating a new account"];


.qt.Unit[
    ".state.adapter.createFlattenSideOrdersMarket";
    {[c]
        p:c[`params];

    };
    {[p] :`args`eRes!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ))
    );
    "Global function for creating a new account"];


.qt.Unit[
    ".state.adapter.createFlattenAllOrdersMarket";
    {[c]
        p:c[`params];


    };
    {[p] :`args`eRes!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ))
    );
    "Global function for creating a new account"];


// General Order Placement Utilities
// ---------------------------------------------------------------------------------------->

.qt.Unit[
    ".state.adapter.createBatches";
    {[c]
        p:c[`params];
    };
    {[p] :`args`eRes!p};
    (
        ("should allow for batches smaller than batch size";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("should allowr for batches larger than batch size";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("should allow for batches equal to batch size";(
            (10;5;0.1;1);(1 1 1)
        ))
    );
    "Returns a given accounts open inventory"];
 
.qt.Unit[
    ".state.adapter.createDeltaEvents";
    {[c]
        p:c[`params];
        mck1: .qt.M[`.state.getLvlPrices;{[a;b;c]};c];
        mck2: .qt.M[`.state.getLvlsQty;{[a;b;c]};c];

        res:.state.adapter.createBucketLimitOrdersDeltaProvided . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected .order.applyOffsetUpdates Mock

    };
    {[p] :`args`eRes!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ))
    );
    "Creates the set of orders that will serve to transition the state"];

.qt.Unit[
    ".state.adapter.createBucketLimitOrdersDeltaDistribution";
    {[c]
        p:c[`params];

        res:.state.adapter.createBucketLimitOrdersDeltaDistribution . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ))
    );
    "Creates the set of distributions that will serve to amelierate the bucket qty"];

.qt.Unit[
    ".state.adapter.constructMacroMarketFn";
    {[c]
        p:c[`params];

        res:.state.adapter.constructMacroMarketFn . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ))
    );
    "Creates the set of distributions that will serve to amelierate the bucket qty"];


.qt.Unit[
    ".state.adapter.deriveTradingMargin";
    {[c]
        p:c[`params];

        res:.state.adapter.deriveTradingMargin . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1)
        ))
    );
    "Creates the set of distributions that will serve to amelierate the bucket qty"];

// Hedged Path Finder Tests 
// ---------------------------------------------------------------------------------------->


.qt.Unit[
    ".state.adapter.HedgedPathFinder";
    {[c]
        p:c[`params];

        res:.state.adapter.deriveTradingMargin . p`args;
        .qt.A[res;~;p[`eRes];"res";c];

    };
    {[p] :`args`eRes`mocks!p};
    (
        ("min price 1000 (asks) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (bids) price distribution 0.01 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (asks) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ));
        ("min price 1000 (bids) price distribution 0.5 tick size: 10 levels";(
            (10;5;0.1;1);(1 1 1);()
        ))
    );
    "Path finder action set (made for binance exchange)"];



