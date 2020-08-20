\l state.q
system "d .stateTest";
\cd ../quantest/
\l quantest.q 
\cd ../env/

z:.z.z;

checkState  :{[]

    };

test:.qt.Unit[
    ".state.InsertResultantEvents";
    {[c]
        p:c[`params];

        .state.InsertResultantEvents[p[`events]];
        
        // Assertions
        checkState[];
    };
    {[p]
        e:({`time`kind`cmd`datum!x} each p[0]);

        


        :`events`eState!(e;p[1]);};
    (
        ("Should correctly insert account events";(
            (
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(0;0;0;0;0;0));
                (z;`ACCOUNT;`UPDATE;`accountId`balance`frozen`available`realizedPnl`maintMargin!(1;0;0;0;0;0))
            );
            ()));
        ("Should correctly insert inventory events";(
            (
                (z;`INVENTORY;`UPDATE;`accountId`side`realizedPnl`avgPrice`unrealizedPnl!(0;0;0;0;0));
                (z;`INVENTORY;`UPDATE;`accountId`side`realizedPnl`avgPrice`unrealizedPnl!(1;0;0;0;0))
            );
            ()))
    );
    .qt.sBlk;
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];
