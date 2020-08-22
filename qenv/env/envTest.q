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


dSecEvents: {[x;y]
            t:{{x+`second$(rand 10)} each y#x}[y];

            tds:`time`intime`kind`cmd`datum!(t x;t x;x#`TRADE;x#`NEW;flip[(x?`BUY`SELL;x#{10000+rand 100}[];x#{rand 1000}[])]);
            dpth:`time`intime`kind`cmd`datum!(t x;t x;x#`DEPTH;x#`UPDATE;flip[(x?`BUY`SELL;x#{10000+rand 100}[];x#{rand 1000}[])]);
            mk:`time`intime`kind`cmd`datum!(t x;t x;x#`MARK;x#`UPDATE;enlist'[x#{10000+rand 1000}[]]);

            :(flip[dpth],flip[mk],flip[tds]);
    };

// TODO test with differing intime?
test:.qt.Unit[
    ".env.Step";
    {[c]
        p:c[`params];

        p1:p[`eAdapt];  
        p2:p[`eProcessEvents];  
        p3:p[`eInsertResultantEvents];  
        p4:p[`eGetFeatures];  
        p5:p[`eGetRewards];  
        p6:p[`eInfo];  

        mck1: .qt.M[`.adapter.Adapt;{[at;t;a]};c];
        mck2: .qt.M[`.engine.ProcessEvents;{[e]};c];
        mck3: .qt.M[`.state.InsertResultantEvents;{[e]};c];
        mck4: .qt.M[`.state.GetFeatures;{[e]};c];
        mck5: .qt.M[`.state.GetRewards;{[e]};c];
        mck6: .qt.M[`.env.Info;{[e]};c];

        if[count[p[`eStepIndex]];.env.StepIndex:p[`eStepIndex]];
        if[count[p[`eCurrentStep]];.env.CurrentStep:p[`eCurrentStep]];
        if[count[p[`eEventBatch]];.env.EventBatch:p[`eEventBatch]];

        res:.env.Step[p[`actions]];
        .qt.A[res;~;p[`eRes];"response";c];
        / show p1;

        .qt.MA[mck1;p1[`called];p1[`numCalls];p1[`calledWith];c];
        / .qt.MA[mck2;p2[`called];p2[`numCalls];p2[`calledWith];c];
        / .qt.MA[mck3;p3[`called];p3[`numCalls];p3[`calledWith];c];
        / .qt.MA[mck4;p4[`called];p4[`numCalls];p4[`calledWith];c];
        / .qt.MA[mck5;p5[`called];p5[`numCalls];p5[`calledWith];c];
        / .qt.MA[mck6;p6[`called];p6[`numCalls];p6[`calledWith];c];

        // Assertions
    };
    {[p]
        / e:({`time`kind`cmd`datum!x} each p[0]);
        / show p[0];
        events:.envTest.dSecEvents[10;z];
        m:{
            mCols:`called`numCalls`calledWith`fn;
            (count[x]#mCols)!x};  

        :(`actions`eCurrentStep`eStepIndex`eEventBatch`eRes`eAdapt`eProcessEvents,
        `eInsertResultantEvents`eGetFeatures`eGetRewards`eInfo)!(
            p[0];
            p[1];
            p[2];
            p[3];
            p[4];
            m p[5];
            m p[6];
            m p[7];
            m p[8];
            m p[9];
            m p[10]
            )
    };
    (
        enlist("step=1 single action account pair ordered by 1 second per step, 5 steps";(
            ((1;0));
            0;
            (sz 5*til[5]);
            (
                (sz 1;());
                (sz 2;());
                (sz 3;());
                (sz 4;());
                (sz 5;())
            );
            (til 5);
            (1b;1;(`MARKETMAKER;z;(1;0));{[x;t;a]});
            (1b;1;());
            (1b;1;());
            (1b;1;());
            (1b;1;());
            (0b;0;())
        ))
    );
    .qt.sBlk;
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];


// TODO profile event step!!!
.qt.RunTests[];