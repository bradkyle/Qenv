



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
    {[p]:`events`eState!(p[0];p[1])};
    (
        ("Should correctly insert account events";(
            (til 3);
            ()));
        ("Should correctly insert inventory events";(
            (til 4);
            ());
        ("Should correctly insert order events";(
            (til 4);
            ()); 
        ("Should correctly insert depth events";(
            (til 4);
            ());
        ("Should correctly insert trade events";(
            (til 4);
            ());
        ("Should correctly insert markprice events";(
            (til 4);
            ());
        ("Should correctly insert funding events";(
            (til 4);
            ());
        ("Should correctly insert liquidation events";(
            (til 4);
            ());
        )
    );
    .qt.sBlk;
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];
