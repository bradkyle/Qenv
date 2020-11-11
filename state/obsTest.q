 

// 

.qt.Unit[
    ".state.obs.derive";
    {[c]
        p:c[`params];

        .state.obs.derive . p[`args];

    };();();.util.testutils.defaultStateHooks;
    "Global function for creating a new account"];

.qt.Unit[
    ".state.obs.GetObs";
    {[c]
        p:c[`params];
        .state.InsertEvents[p[`cState]];

        res:.obs.GetObs . p`args;

        .qt.A[res;~;p[`eRes];"res";c];

    };{[p]
        e:({`time`kind`cmd`datum!x} each p[1]);
        :`args`cState`eRes!(p[0];e;p[1]);
    };(
        ("Given full state should create the correct features (One Account)";(
            (0;100;enlist[1]);
            (
                (z;6;1;(0;z;0;0;0;0)); // Current Account
                (z;6;1;(0;z;0;0;0;0)); // Current Account

                (z;7;1;(0;1;z;0;1000;10;0)); // Inventory
                (z;7;1;(1;1;z;0;1000;10;0)); // Inventory
                (z;7;1;(0;-1;z;0;1000;10;0)); // Inventory
                (z;7;1;(1;-1;z;0;1000;10;0)); // Inventory
                (z;7;1;(0;0;z;0;1000;10;0)); // Inventory
                (z;7;1;(1;0;z;0;1000;10;0)); // Inventory

                (z;8;1;(0;z;0;1;1;1000;1000;0;0;0;0b;0;0)); // CurrentOrders
                (z;8;1;(1;z;0;1;1;1000;1000;0;0;0;0b;0;0)); // CurrentOrders
                (z;8;1;(2;z;0;1;1;1000;1000;0;0;0;0b;0;0)); // CurrentOrders
                (z;8;1;(3;z;0;1;1;1000;1000;0;0;0;0b;0;0)); // CurrentOrders

                (z;8;1;(4;z;0;-1;1;1001;1000;0;0;0;0b;0;0)); // CurrentOrders
                (z;8;1;(5;z;0;-1;1;1001;1000;0;0;0;0b;0;0)); // CurrentOrders
                (z;8;1;(6;z;0;-1;1;1001;1000;0;0;0;0b;0;0)); // CurrentOrders
                (z;8;1;(7;z;0;-1;1;1001;1000;0;0;0;0b;0;0)); // CurrentOrders

                (z;0;1;(10001;z;1;1000)); // CurrentDepth
                (z;0;1;(10002;z;1;1000)); // CurrentDepth
                (z;0;1;(10003;z;1;1000)); // CurrentDepth
                (z;0;1;(10004;z;1;1000)); // CurrentDepth
                (z;0;1;(10005;z;1;1000)); // CurrentDepth
                
                (z;0;1;(10006;z;-1;1000)); // CurrentDepth
                (z;0;1;(10007;z;-1;1000)); // CurrentDepth
                (z;0;1;(10008;z;-1;1000)); // CurrentDepth
                (z;0;1;(10009;z;-1;1000)); // CurrentDepth
                (z;0;1;(10010;z;-1;1000)); // CurrentDepth

                (z;1;0;(0;z;1000;1000;1)); // TradeEventHistory
                (z;1;0;(1;z;1000;1000;1)); // TradeEventHistory
                (z;1;0;(2;z;1000;1000;1)); // TradeEventHistory
                (z;1;0;(3;z;1000;1000;1)); // TradeEventHistory
                (z;1;0;(4;z;1000;1000;1)); // TradeEventHistory

                (z;1;0;(5;z;1000;1000;-1)); // TradeEventHistory
                (z;1;0;(6;z;1000;1000;-1)); // TradeEventHistory
                (z;1;0;(7;z;1000;1000;-1)); // TradeEventHistory
                (z;1;0;(8;z;1000;1000;-1)); // TradeEventHistory
                (z;1;0;(9;z;1000;1000;-1)); // TradeEventHistory

                (z;2;1;(z;1000));   // MarkEventHistory
                (z;2;1;(z;1000));   // MarkEventHistory
                (z;2;1;(z;1000));   // MarkEventHistory

                (z;4;1;(z;0.1;z)); // FundingEventHistory
                (z;4;1;(z;0.1;z)); // FundingEventHistory
                (z;4;1;(z;0.1;z)); // FundingEventHistory

                (z;3;1;(0;z;1000;1000;1));  // LiquidationEventHistory
                (z;3;1;(1;z;1000;1000;1));  // LiquidationEventHistory
                (z;3;1;(2;z;1000;1000;1))   // LiquidationEventHistory
            );
            til[10]
        ));
        ("Given incomplete state should create the correct features";(
            (0;100;enlist[1]);
            (
                (z;6;1;(0;z;0;0;0;0)); // Current Account
                (z;6;1;(0;z;0;0;0;0)); // Current Account

                (z;7;1;(0;1;z;0;1000;10;0)); // Inventory
                (z;7;1;(1;1;z;0;1000;10;0)); // Inventory
                (z;7;1;(0;-1;z;0;1000;10;0)); // Inventory
                (z;7;1;(1;-1;z;0;1000;10;0)); // Inventory
                (z;7;1;(0;0;z;0;1000;10;0)); // Inventory
                (z;7;1;(1;0;z;0;1000;10;0)); // Inventory

                (z;8;1;(0;z;0;1;1;1000;1000;0;0;0;0b;0;0)); // CurrentOrders
                (z;8;1;(1;z;0;1;1;1000;1000;0;0;0;0b;0;0)); // CurrentOrders
                (z;8;1;(2;z;0;1;1;1000;1000;0;0;0;0b;0;0)); // CurrentOrders
                (z;8;1;(3;z;0;1;1;1000;1000;0;0;0;0b;0;0)); // CurrentOrders

                (z;8;1;(4;z;0;-1;1;1001;1000;0;0;0;0b;0;0)); // CurrentOrders
                (z;8;1;(5;z;0;-1;1;1001;1000;0;0;0;0b;0;0)); // CurrentOrders
                (z;8;1;(6;z;0;-1;1;1001;1000;0;0;0;0b;0;0)); // CurrentOrders
                (z;8;1;(7;z;0;-1;1;1001;1000;0;0;0;0b;0;0)); // CurrentOrders

                (z;0;1;(10001;z;1;1000)); // CurrentDepth
                (z;0;1;(10002;z;1;1000)); // CurrentDepth
                (z;0;1;(10003;z;1;1000)); // CurrentDepth
                (z;0;1;(10004;z;1;1000)); // CurrentDepth
                (z;0;1;(10005;z;1;1000)); // CurrentDepth
                
                (z;0;1;(10006;z;-1;1000)); // CurrentDepth
                (z;0;1;(10007;z;-1;1000)); // CurrentDepth
                (z;0;1;(10008;z;-1;1000)); // CurrentDepth
                (z;0;1;(10009;z;-1;1000)); // CurrentDepth
                (z;0;1;(10010;z;-1;1000)); // CurrentDepth

                (z;1;0;(0;z;1000;1000;1)); // TradeEventHistory
                (z;1;0;(1;z;1000;1000;1)); // TradeEventHistory
                (z;1;0;(2;z;1000;1000;1)); // TradeEventHistory
                (z;1;0;(3;z;1000;1000;1)); // TradeEventHistory
                (z;1;0;(4;z;1000;1000;1)); // TradeEventHistory

                (z;1;0;(5;z;1000;1000;-1)); // TradeEventHistory
                (z;1;0;(6;z;1000;1000;-1)); // TradeEventHistory
                (z;1;0;(7;z;1000;1000;-1)); // TradeEventHistory
                (z;1;0;(8;z;1000;1000;-1)); // TradeEventHistory
                (z;1;0;(9;z;1000;1000;-1)); // TradeEventHistory

                (z;2;1;(z;1000));   // MarkEventHistory
                (z;2;1;(z;1000));   // MarkEventHistory
                (z;2;1;(z;1000));   // MarkEventHistory

                (z;4;1;(z;0.1;z)); // FundingEventHistory
                (z;4;1;(z;0.1;z)); // FundingEventHistory
                (z;4;1;(z;0.1;z)); // FundingEventHistory

                (z;3;1;(0;z;1000;1000;1));  // LiquidationEventHistory
                (z;3;1;(1;z;1000;1000;1));  // LiquidationEventHistory
                (z;3;1;(2;z;1000;1000;1))   // LiquidationEventHistory
            );
            til[10]
        ))
    );.util.testutils.defaultStateHooks;
    "Generates a vector representation of the current state"];

