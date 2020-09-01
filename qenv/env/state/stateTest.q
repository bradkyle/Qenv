\l state.q
system "d .stateTest";
\cd ../../quantest/
\l quantest.q 
\cd ../env/state/

z:.z.z;


defaultAfterEach: {
     
     .qt.RestoreMocks[];
    };

defaultBeforeEach: {
     delete from `.state.AccountEventHistory;
     delete from `.state.InventoryEventHistory;
     delete from `.state.OrderEventHistory;
     delete from `.state.CurrentDepth;
     delete from `.state.DepthEventHistory;
     delete from `.state.TradeEventHistory;
     delete from `.state.MarkEventHistory;
     delete from `.state.FundingEventHistory;
     delete from `.state.LiquidationEventHistory;
    };

defaultAfterAll     :{
    /  delete from `.state.AccountEventHistory;
    /  delete from `.state.InventoryEventHistory;
    /  delete from `.state.OrderEventHistory;
    /  delete from `.state.CurrentDepth;
    /  delete from `.state.DepthEventHistory;
    /  delete from `.state.TradeEventHistory;
    /  delete from `.state.MarkEventHistory;
    /  delete from `.state.FundingEventHistory;
    /  delete from `.state.LiquidationEventHistory;
    };

setupState  :{[events]
    .state.InsertResultantEvents[events];
    };

checkState  :{[]

    };

// @x: count
// @y: time // TODO check cols correct
// TODO deterministic ordering
// .stateTest.genRandomState[100000;.z.z;250]; generates a million events between .z.z and 100 minutes
// TODO gen based on data
genRandomState      :{[x;y;z] // TODO add max time
            / t:{{y+(`minute$(rand x))}[x] z#y}[z;y];
            t:{{x+(`minute$(rand 250))} each y#x}[y];
            p:{{10000+rand 100} each til[x]};
            sz:{{x+rand 100} each til[x]};

            .state.tS:(
                til[x];
                t x;
                sz x;
                p x;
                x?0,1
            );

            .state.dS:(
                p x;
                t x;
                x?0,1;
                sz x
            );

            // 
            tds:`time`intime`kind`cmd`datum!(t x;t x;x#`TRADE;x#`NEW;flip[.state.tradeCols!(
                til[x];
                t x;
                sz x;
                p x;
                x?0,1
            )]);
            
            dpth:`time`intime`kind`cmd`datum!(t x;t x;x#`DEPTH;x#`UPDATE;flip[.state.depthCols!(
                p x;
                t x;
                x?0,1;
                sz x
            )]);

            invn:`time`intime`kind`cmd`datum!(t x;t x;x#`INVENTORY;x#`UPDATE;flip[.state.inventoryCols!(
                x?til 3;
                x?0,1;
                t x;
                sz x;
                sz x;
                p x;
                sz x
            )]);

            accn:`time`intime`kind`cmd`datum!(t x;t x;x#`ACCOUNT;x#`UPDATE;flip[.state.accountCols!(
                x?til 3;
                t x;
                sz x;
                sz x;
                sz x;
                sz x
            )]);

            odrs:`time`intime`kind`cmd`datum!(t x;t x;x#`ORDER;x#`UPDATE;flip[.state.ordCols!(
                til[x];
                t x;
                x?0 1;
                x?0,1;
                x#1;
                sz x;
                p x;
                x#0;
                x#0;
                x#0;
                x#0;
                x#0b;
                x#0;
                x#0
            )]);

            mk:`time`intime`kind`cmd`datum!(t x;t x;x#`MARK;x#`UPDATE;flip[.state.markCols!(
                t x;
                p x)]);
            
            fnd:`time`intime`kind`cmd`datum!(t x;t x;x#`FUNDING;x#`UPDATE;flip[.state.fundingCols!(
                t x;
                sz x;
                t x
            )]);
            
            lq:`time`intime`kind`cmd`datum!(t x;t x;x#`LIQUIDATION;x#`NEW;flip[.state.liquidationCols!(
                til[x];
                t x;
                sz x;
                p x;
                x?0,1
            )]);

            sg:`time`intime`kind`cmd`datum!(t x;t x;x#`SIGNAL;x#`UPDATE;flip[cols[.state.SignalEventHistory]!(
                rand'[x#30];
                t x;
                rand'[(`float$(sz x))]
            )]);

            x:(
                flip[tds],
                flip[dpth],
                flip[odrs],
                flip[accn],
                flip[invn],
                flip[mk],
                flip[fnd],
                flip[lq],
                flip[sg]
            );

            .state.InsertResultantEvents[x];
    };


// TODO should time cases
// TODO change to simple update better for processing speed
test:.qt.Unit[
    ".state.GetObservations";
    {[c]
        p:c[`params];
        setupState[p[`cState]];

        a:p[`args];
        res:.state.GetObservations[a];

        .qt.A[res;~;p[`eRes];"result";c];

    };
    {[p]
        e:({`time`kind`cmd`datum!x} each p[1]);
        :`args`cState`eResp!(p[0];e;p[1]);
    };
    (
        enlist("Should correctly insert depth events into both current depth and depth event history";(
            0 1;
            (
                (z;`ACCOUNT;`UPDATE;.state.accountCols!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;.state.accountCols!(0;0;0;0;0;0));

                (z;`INVENTORY;`UPDATE;.state.inventoryCols!(0;`LONG;z;0;1000;10;0));
                (z;`INVENTORY;`UPDATE;.state.inventoryCols!(1;`LONG;z;0;1000;10;0));
                (z;`INVENTORY;`UPDATE;.state.inventoryCols!(0;`SHORT;z;0;1000;10;0));
                (z;`INVENTORY;`UPDATE;.state.inventoryCols!(1;`SHORT;z;0;1000;10;0));
                (z;`INVENTORY;`UPDATE;.state.inventoryCols!(0;`BOTH;z;0;1000;10;0));
                (z;`INVENTORY;`UPDATE;.state.inventoryCols!(1;`BOTH;z;0;1000;10;0));

                (z;`ORDER;`UPDATE;.state.ordCols!(0;z;0;`BUY;`LIMIT;1000;1000;0;0;0;`NEW;0b;`NIL;`NIL));
                (z;`ORDER;`UPDATE;.state.ordCols!(1;z;0;`BUY;`LIMIT;1000;1000;0;0;0;`NEW;0b;`NIL;`NIL));
                (z;`ORDER;`UPDATE;.state.ordCols!(2;z;0;`BUY;`LIMIT;1000;1000;0;0;0;`NEW;0b;`NIL;`NIL));
                (z;`ORDER;`UPDATE;.state.ordCols!(3;z;0;`BUY;`LIMIT;1000;1000;0;0;0;`NEW;0b;`NIL;`NIL));

                (z;`ORDER;`UPDATE;.state.ordCols!(4;z;0;`SELL;`LIMIT;1001;1000;0;0;0;`NEW;0b;`NIL;`NIL));
                (z;`ORDER;`UPDATE;.state.ordCols!(5;z;0;`SELL;`LIMIT;1001;1000;0;0;0;`NEW;0b;`NIL;`NIL));
                (z;`ORDER;`UPDATE;.state.ordCols!(6;z;0;`SELL;`LIMIT;1001;1000;0;0;0;`NEW;0b;`NIL;`NIL));
                (z;`ORDER;`UPDATE;.state.ordCols!(7;z;0;`SELL;`LIMIT;1001;1000;0;0;0;`NEW;0b;`NIL;`NIL));

                (z;`DEPTH;`UPDATE;.state.depthCols!(10001;z;`BUY;1000));
                (z;`DEPTH;`UPDATE;.state.depthCols!(10002;z;`BUY;1000));
                (z;`DEPTH;`UPDATE;.state.depthCols!(10003;z;`BUY;1000));
                (z;`DEPTH;`UPDATE;.state.depthCols!(10004;z;`BUY;1000));
                (z;`DEPTH;`UPDATE;.state.depthCols!(10005;z;`BUY;1000));
                
                (z;`DEPTH;`UPDATE;.state.depthCols!(10006;z;`SELL;1000));
                (z;`DEPTH;`UPDATE;.state.depthCols!(10007;z;`SELL;1000));
                (z;`DEPTH;`UPDATE;.state.depthCols!(10008;z;`SELL;1000));
                (z;`DEPTH;`UPDATE;.state.depthCols!(10009;z;`SELL;1000));
                (z;`DEPTH;`UPDATE;.state.depthCols!(10010;z;`SELL;1000));

                (z;`TRADE;`NEW;.state.tradeCols!(0;z;1000;1000;`BUY));
                (z;`TRADE;`NEW;.state.tradeCols!(1;z;1000;1000;`BUY));
                (z;`TRADE;`NEW;.state.tradeCols!(2;z;1000;1000;`BUY));
                (z;`TRADE;`NEW;.state.tradeCols!(3;z;1000;1000;`BUY));
                (z;`TRADE;`NEW;.state.tradeCols!(4;z;1000;1000;`BUY));

                (z;`TRADE;`NEW;.state.tradeCols!(5;z;1000;1000;`SELL));
                (z;`TRADE;`NEW;.state.tradeCols!(6;z;1000;1000;`SELL));
                (z;`TRADE;`NEW;.state.tradeCols!(7;z;1000;1000;`SELL));
                (z;`TRADE;`NEW;.state.tradeCols!(8;z;1000;1000;`SELL));
                (z;`TRADE;`NEW;.state.tradeCols!(9;z;1000;1000;`SELL));

                (z;`MARK;`UPDATE;.state.markCols!(z;1000));
                (z;`MARK;`UPDATE;.state.markCols!(z;1000));
                (z;`MARK;`UPDATE;.state.markCols!(z;1000));

                (z;`FUNDING;`UPDATE;.state.fundingCols!(z;1;z));
                (z;`FUNDING;`UPDATE;.state.fundingCols!(z;1;z));
                (z;`FUNDING;`UPDATE;.state.fundingCols!(z;1;z));

                (z;`LIQUIDATION;`UPDATE;.state.liquidationCols!(0;z;1000;1000;`BUY));
                (z;`LIQUIDATION;`UPDATE;.state.liquidationCols!(1;z;1000;1000;`BUY));
                (z;`LIQUIDATION;`UPDATE;.state.liquidationCols!(2;z;1000;1000;`BUY))
            );
            til[10]
        ))
    );
    ({};defaultAfterAll;defaultBeforeEach;defaultAfterEach);
    "Creates the event to place a new order at a given level in the orderbook"];

.qt.SkpBes[0];

test:.qt.Unit[
    ".state.InsertResultantEvents";
    {[c]
        p:c[`params];

        .state.InsertResultantEvents[p[`events]];
        
        // Assertions
        {.qt.A[get[y];~;z;string[y];x]}[c] each p[`eState]; 
    };
    {[p]
        e:({`time`kind`cmd`datum!x} each p[0]);
        :`events`eState!(e;p[1]);};
    (
        ("Should correctly insert depth events into both current depth and depth event history";(
            (
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.DepthEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0));
                (`.account.CurrentDepth;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert trade events into trade event history";(
            (
                (z;`TRADE;`NEW;.state.tradeCols!(0;z;1000;1000;`SELL));
                (z;`TRADE;`NEW;.state.tradeCols!(0;z;1000;1000;`SELL))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly mark price updates into trade event history";(
            (
                (z;`MARK;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`MARK;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.MarkEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert funding events into funding event history";(
            (
                (z;`FUNDING;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`FUNDING;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert liquidation events into liquidation event history";(
            (
                (z;`LIQUIDATION;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`LIQUIDATION;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            ))); 
        ("Should correctly insert account events from different accounts, different times";(
            (
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert inventory events";(
            (
                (z;`INVENTORY;`UPDATE;`accountId`side`realizedPnl`avgPrice`unrealizedPnl!(0;`LONG;0;0;0));
                (z;`INVENTORY;`UPDATE;`accountId`side`realizedPnl`avgPrice`unrealizedPnl!(1;`LONG;0;0;0))
            );
            (
                (`.account.InventoryEventHistory;([accountId:0 1;side:2#`LONG;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert new orders into current orders and order event history";(
            (
                (z;`ORDER;`NEW;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ORDER;`NEW;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly update existing orders with order updates in current orders ";(
            (
                (z;`ORDER;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ORDER;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly update current orders to filled ";(
            (
                (z;`ORDER;`DELETE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ORDER;`DELETE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )))
    );
    ({};defaultAfterAll;defaultBeforeEach;defaultAfterEach);
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];



.qt.RunTests[];
