\l state.q
system "d .stateTest";
\cd ../quantest/
\l quantest.q 
\cd ../env/

z:.z.z;


test:.qt.Unit[
    ".env.Config";
    {[c]
        p:c[`params];

        .env.Config[p[`config]];
        
        // Assertions
        {.qt.A[get[y];~;z;string[y];x]}[c] each p[`eState]; 
    };
    {[p]
        e:({`time`kind`cmd`datum!x} each p[0]);
        :`events`eState!(e;p[1]);};
    (
        ("Should correctly insert account events from different accounts, different times";());
        ("Should correctly insert inventory events";())
    );
    .qt.sBlk;
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];

 
test:.qt.Unit[
    ".env.Advance";
    {[c]
        p:c[`params];

        mck1: .qt.M[`.adapter.Adapt;{[at;t;a]};c];
        mck1: .qt.M[`.engine.ProcessEvents;{[e]};c];
        mck1: .qt.M[`.state.InsertResultantEvents;{[e]};c];
        mck1: .qt.M[`.env.loadEvents;{[e]};c];

        .env.InsertResultantEvents[p[`events]];
        
        // Assertions
        {.qt.A[get[y];~;z;string[y];x]}[c] each p[`eState]; 
    };
    {[p]
        e:({`time`kind`cmd`datum!x} each p[0]);
        :`events`eState!(e;p[1]);};
    (
        ("Should work with event count window StepIndex";( ));
        ("Should work with time window StepIndex";( ))
    );
    .qt.sBlk;
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];


// TODO profile event step!!!
.qt.RunTests[];