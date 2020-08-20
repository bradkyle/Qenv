



checkState  :{[]

    };

test:.qt.Unit[
    ".state.InsertResultantEvents";
    {[c]
        p:c[`params];
        setupState[p];

        res:.state.InsertResultantEvents[p[`aids]];
        
        // Assertions
        checkState[];
    };
    {[p]:`aids`cEvents`eFea`eRes!(p[0];p[1];p[2];p[3])};
    (
        ("Should return normalized feature buffer for 1 account";(
            (til 3);
            ();
            ()));
        ("Should fill in resultant nulls with 0 and upsert where neccessary";(
            (til 4);
            ();
            ();
            ()))
    );
    .qt.sBlk;
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];
