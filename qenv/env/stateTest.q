\l state.q
system "d .stateTest";
\cd ../quantest/
\l quantest.q 
\cd ../env/

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

setupState  :{[events]
    .state.InsertResultantEvents[events];
    };

checkState  :{[]

    };

// @x: count
// @y: time // TODO check cols correct
genRandomState      :{[x;y;z]
            t:{{x+`second$(rand 10)} each y#x}[y];

            // 
            tds:`time`intime`kind`cmd`datum!(t x;t x;x#`TRADE;x#`NEW;flip[.state.tradeCols!(
                til[x];
                x#z;
                x?`BUY`SELL;
                x#{10000+rand 100}[];
                x#{rand 1000}[]
            )]);
            
            dpth:`time`intime`kind`cmd`datum!(t x;t x;x#`DEPTH;x#`UPDATE;flip[.state.depthCols!(
                x?`BUY`SELL;
                x#z;
                x#{10000+rand 100}[];
                x#{rand 1000}[])]
            );

            odrs:`time`intime`kind`cmd`datum!(t x;t x;x#`ORDER;x#`UPDATE;flip[.state.ordCols!(
                til[x];
                x#.z.z;
                10?0 1;
                x?`BUY`SELL;
                x#`LIMIT;
                x#{10000+rand 100}[];
                x#{rand 1000}[];
                x#0;
                x#0;
                x#0;
                x#`NEW;
                x#0b;
                x#`NIL;
                x#`NIL
            )]);

            mk:`time`intime`kind`cmd`datum!(t x;t x;x#`MARK;x#`UPDATE;
                enlist'[x#{10000+rand 1000}[]]
            );
            
            fnd:`time`intime`kind`cmd`datum!(t x;t x;x#`FUNDING;x#`UPDATE;flip[.state.fundingCols!(
                x#z;
                x#{rand 1000}[];
                xz
            )]);
            
            lq:`liqId`time`intime`kind`cmd`datum!(t x;t x;x#`LIQUIDATION;x#`UPDATE;
                enlist'[x#{10000+rand 1000}[]]
            );

            :(
                flip[tds],
                flip[dpth],
                flip[odrs],
                flip[mk],
                flip[fnd],
                flip[lq]
            );
    };


// TODO should time cases
test:.qt.Unit[
    ".state.getFeatureVectors";
    {[c]
        p:c[`params];
        setupState[p[`cState]];

        a:p[`args];
        res:.state.getFeatureVectors[a];

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

                (z;`INVENTORY;`UPDATE;.state.inventoryCols!(0;`BUY;z;0;1000;10;0));
                (z;`INVENTORY;`UPDATE;.state.inventoryCols!(0;`BUY;z;0;1000;10;0));
                (z;`INVENTORY;`UPDATE;.state.inventoryCols!(0;`BUY;z;0;1000;10;0));
                (z;`INVENTORY;`UPDATE;.state.inventoryCols!(0;`BUY;z;0;1000;10;0));
                (z;`INVENTORY;`UPDATE;.state.inventoryCols!(0;`BUY;z;0;1000;10;0));
                (z;`INVENTORY;`UPDATE;.state.inventoryCols!(0;`BUY;z;0;1000;10;0));

                (z;`ORDER;`UPDATE;.state.ordCols!(0;z;0;`BUY;`LIMIT;1000;1000;0;0;0;`NEW;0b;`NIL;`NIL));
                (z;`ORDER;`UPDATE;.state.ordCols!(0;z;0;`BUY;`LIMIT;1000;1000;0;0;0;`NEW;0b;`NIL;`NIL));
                (z;`ORDER;`UPDATE;.state.ordCols!(0;z;0;`BUY;`LIMIT;1000;1000;0;0;0;`NEW;0b;`NIL;`NIL));
                (z;`ORDER;`UPDATE;.state.ordCols!(0;z;0;`BUY;`LIMIT;1000;1000;0;0;0;`NEW;0b;`NIL;`NIL));

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

                (z;`LIQUIDATION;`UPDATE;.state.liquidationCols!(0;z;`BUY;1000;1000));
                (z;`LIQUIDATION;`UPDATE;.state.liquidationCols!(1;z;`BUY;1000;1000));
                (z;`LIQUIDATION;`UPDATE;.state.liquidationCols!(2;z;`BUY;1000;1000))
            );
            til[10]
        ))
    );
    .qt.sBlk;
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
    .qt.sBlk;
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];



.qt.RunTests[];
