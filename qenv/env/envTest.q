
 
test:.qt.Unit[
    ".env.Advance";
    {[c]
        p:c[`params];

        .env.InsertResultantEvents[p[`events]];
        
        // Assertions
        {.qt.A[get[y];~;z;string[y];x]}[c] each p[`eState]; 
    };
    {[p]
        e:({`time`kind`cmd`datum!x} each p[0]);
        :`events`eState!(e;p[1]);};
    (
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
            )))
    );
    .qt.sBlk;
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];
