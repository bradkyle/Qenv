\l state.q
system "d .envTest";
\cd ../engine/
\l engine.q 
\cd ../quantest/
\l quantest.q 
\cd ../env/
\l env.q

z:.z.z;
sc:{x+(`second$y)};
sz:sc[z];

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

// TODO test with differing intime?
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
    };
    {[p]
        / e:({`time`kind`cmd`datum!x} each p[0]);
        / show p[0];


        makeEvents      :{

            };

        





        :`args`eStepIndex`eEventBatch`eAdapt`eProcessEvents`eInsertResultantEvents`eloadEvents!(
            `step`actions!p[0];
            p[1];
            p[2];
            p[3];
            p[4];
            p[5];
            p[6]
        )};
    (
        ("step=1 single action account pair ordered by 1 second per step, 5 steps";(
            (1;((1;0)));
            (sz 5*til[5]);
            (
                (sz 1;(0 0 0 1 1 1 2 2 2));
                (sz 2;(0 0 0 1 1 1 2 2 2));
                (sz 3;(0 0 0 1 1 1 2 2 2));
                (sz 4;(0 0 0 1 1 1 2 2 2));
                (sz 5;(0 0 0 1 1 1 2 2 2))
            );
            enlist(1b;1;(`MARKETMAKER;z;(1;0));{[x;t;a]}); // Adapt
            enlist(1b;1;()); // ProcessEvents
            enlist(1b;1;()); // InsertResultantEvents
            enlist(0b;0;()) // loadEvents
        ));
        ("step=1 single action account pair ordered by 1 second per step, 5 steps";(
            (1;((1;0)));
            (sz 5*til[5]);
            (
                (sz 1;());
                (sz 2;());
                (sz 3;());
                (sz 4;());
                (sz 5;())
            );
            enlist(1b;1;(`MARKETMAKER;z;(1;0));{[x;t;a]});
            enlist(1b;1;());
            enlist(1b;1;());
            enlist(0b;0;())
        ))
    );
    .qt.sBlk;
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];


// TODO profile event step!!!
.qt.RunTests[];