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

            tds:`time`intime`kind`cmd`datum!(t x;t x;x#1;x#0;flip[(
                til[x];
                t x;
                sz x;
                p x;
                x?0,1
            )]);
            
            dpth:`time`intime`kind`cmd`datum!(t x;t x;x#0;x#1;flip[(
                p x;
                t x;
                x?0,1;
                sz x
            )]);

            invn:`time`intime`kind`cmd`datum!(t x;t x;x#7;x#1;flip[(
                x?til 3;
                x?til 2;
                t x;
                sz x;
                sz x;
                p x;
                sz x
            )]);

            accn:`time`intime`kind`cmd`datum!(t x;t x;x#6;x#1;flip[(
                x?til 3;
                t x;
                sz x;
                sz x;
                sz x;
                sz x
            )]);

            odrs:`time`intime`kind`cmd`datum!(t x;t x;x#8;x#1;flip[(
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

            mk:`time`intime`kind`cmd`datum!(t x;t x;x#2;x#1;flip[(
                t x;
                p x)]);
            
            fnd:`time`intime`kind`cmd`datum!(t x;t x;x#4;x#1;flip[(
                t x;
                sz x;
                t x
            )]);
            
            lq:`time`intime`kind`cmd`datum!(t x;t x;x#3;x#0;flip[(
                til[x];
                t x;
                sz x;
                p x;
                x?0,1
            )]);

            sg:`time`intime`kind`cmd`datum!(t x;t x;x#16;x#1;flip[(
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

            / .state.InsertResultantEvents[x];
            x
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
                (z;6;1;(0;0;0;0;0;0));
                (z;6;1;(0;0;0;0;0;0));

                (z;7;1;(0;1;z;0;1000;10;0));
                (z;7;1;(1;1;z;0;1000;10;0));
                (z;7;1;(0;-1;z;0;1000;10;0));
                (z;7;1;(1;-1;z;0;1000;10;0));
                (z;7;1;(0;0;z;0;1000;10;0));
                (z;7;1;(1;0;z;0;1000;10;0));

                (z;8;1;(0;z;0;1;1;1000;1000;0;0;0;0;0b;0;0));
                (z;8;1;(1;z;0;1;1;1000;1000;0;0;0;0;0b;0;0));
                (z;8;1;(2;z;0;1;1;1000;1000;0;0;0;0;0b;0;0));
                (z;8;1;(3;z;0;1;1;1000;1000;0;0;0;0;0b;0;0));

                (z;8;1;(4;z;0;-1;1;1001;1000;0;0;0;0;0b;0;0));
                (z;8;1;(5;z;0;-1;1;1001;1000;0;0;0;0;0b;0;0));
                (z;8;1;(6;z;0;-1;1;1001;1000;0;0;0;0;0b;0;0));
                (z;8;1;(7;z;0;-1;1;1001;1000;0;0;0;0;0b;0;0));

                (z;0;1;(10001;z;1;1000));
                (z;0;1;(10002;z;1;1000));
                (z;0;1;(10003;z;1;1000));
                (z;0;1;(10004;z;1;1000));
                (z;0;1;(10005;z;1;1000));
                
                (z;0;1;(10006;z;-1;1000));
                (z;0;1;(10007;z;-1;1000));
                (z;0;1;(10008;z;-1;1000));
                (z;0;1;(10009;z;-1;1000));
                (z;0;1;(10010;z;-1;1000));

                (z;1;0;(0;z;1000;1000;1));
                (z;1;0;(1;z;1000;1000;1));
                (z;1;0;(2;z;1000;1000;1));
                (z;1;0;(3;z;1000;1000;1));
                (z;1;0;(4;z;1000;1000;1));

                (z;1;0;(5;z;1000;1000;-1));
                (z;1;0;(6;z;1000;1000;-1));
                (z;1;0;(7;z;1000;1000;-1));
                (z;1;0;(8;z;1000;1000;-1));
                (z;1;0;(9;z;1000;1000;-1));

                (z;2;1;(z;1000));
                (z;2;1;(z;1000));
                (z;2;1;(z;1000));

                (z;4;1;(z;1;z));
                (z;4;1;(z;1;z));
                (z;4;1;(z;1;z));

                (z;3;1;(0;z;1000;1000;1));
                (z;3;1;(1;z;1000;1000;1));
                (z;3;1;(2;z;1000;1000;1))
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
                (z;8;`DELETE;(0;0;0;0;0;0));
                (z;8;`DELETE;(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )))
    );
    ({};defaultAfterAll;defaultBeforeEach;defaultAfterEach);
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];



.qt.RunTests[];
