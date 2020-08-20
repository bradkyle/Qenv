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

        p1:p[`eAdapt];  
        p2:p[`eProcessEvents];  
        p3:p[`eInsertResultantEvents];  
        p4:p[`eloadEvents];  

        mck1: .qt.M[`.adapter.Adapt;{[at;t;a]};c];
        mck2: .qt.M[`.engine.ProcessEvents;{[e]};c];
        mck3: .qt.M[`.state.InsertResultantEvents;{[e]};c];
        mck4: .qt.M[`.env.loadEvents;{[e]};c];

        a:p[`args];
        res:.env.Advance[a[`step];a[`actions]];

        .qt.MA[mck1;p1[`called];p1[`numCalls];p1[`calledWith];c];
        .qt.MA[mck2;p2[`called];p2[`numCalls];p2[`calledWith];c];
        .qt.MA[mck3;p3[`called];p3[`numCalls];p3[`calledWith];c];
        .qt.MA[mck4;p4[`called];p4[`numCalls];p4[`calledWith];c];

        // Assertions
        {.qt.A[get[y];~;z;string[y];x]}[c] each p[`eState]; 
    };
    {[p]
        / e:({`time`kind`cmd`datum!x} each p[0]);
        :`args`eAdapt`eProcessEvents``eInsertResultantEvents`eloadEvents!(
            e;
            p[1];
            p[2];
            p[3];
            p[4]
        )};
    (
        ("First";(
            1;2;3;4;5
        ));
        ("Second";(
            1;2;3;4;5
        ))
    );
    .qt.sBlk;
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];


// TODO profile event step!!!
.qt.RunTests[];