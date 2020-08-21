\l state.q
system "d .stateTest";
\cd ../quantest/
\l quantest.q 
\cd ../env/

z:.z.z;

checkState  :{[]

    };


// TODO should time cases
test:.qt.Unit[
    ".state.getFeatureVectors";
    {[c]
        p:c[`params];
        setupState[];

        .state.DefaultInstrumentId:p[`eDI];
        .qt.M[`.state.getPriceAtLevel;p[`MgetPriceAtLevel];c];
        .qt.M[`.state.genNextClOrdId;p[`MgenNextClOrdId];c];
        
        a:p[`args];
        res:.adapter.createOrderAtLevel[a[0];a[1];a[2];a[3]];

        .qt.A[res;~;p[`eRes];"result";c];

    };
    {[p]:`args`MgetPriceAtLevel`MgenNextClOrdId`eDI`eRes!(p[0];p[1];p[2];p[3];p[4])};
    (
        ("Should correctly insert depth events into both current depth and depth event history";(
            (
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert depth events into both current depth and depth event history";(
            (
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
    );
    .qt.sBlk;
    "Creates the event to place a new order at a given level in the orderbook"];


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
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert trade events into trade event history";(
            (
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly mark price updates into trade event history";(
            (
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert funding events into funding event history";(
            (
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert liquidation events into liquidation event history";(
            (
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly insert ";(
            (
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
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
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly update existing orders with order updates in current orders ";(
            (
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
        ("Should correctly update current orders to filled ";(
            (
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            (
                (`.account.AccountEventHistory;([accountId:0 1;time:2#z] balance:2#0;available:2#0;frozen:2#0;maintMargin:2#0))
            )));
    );
    .qt.sBlk;
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];



.qt.RunTests[];
