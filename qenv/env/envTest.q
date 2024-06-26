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
dts:{(`date$x)+(`second$x)};
dtz:{dts[sc[x;y]]}[z]
doz:`date$z;
dozc:{x+y}[doz];

dSecEvents: {[x;y]
            t:{{x+`second$(rand 10)} each y#x}[y];

            tds:`time`intime`kind`cmd`datum!(t x;t x;x#`TRADE;x#`NEW;flip[(x?`BUY`SELL;x#{10000+rand 100}[];x#{rand 1000}[])]);
            dpth:`time`intime`kind`cmd`datum!(t x;t x;x#`DEPTH;x#`UPDATE;flip[(x?`BUY`SELL;x#{10000+rand 100}[];x#{rand 1000}[])]);
            mk:`time`intime`kind`cmd`datum!(t x;t x;x#`MARK;x#`UPDATE;enlist'[x#{10000+rand 1000}[]]);

            :(flip[dpth],flip[mk],flip[tds]);
    };

defaultEnvEach: {
     .env.CurrentStep:0;
     .env.CurrentEpisde:0;
     .env.PrimeBatchNum:0;
     .env.StepIndex:();
     .env.BatchIndex:();
     .env.EventBatch:();
     .env.FeatureBatch:();
    };

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
    ({};{};defaultEnvEach;defaultEnvEach);
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];



// TODO test with differing intime?
test:.qt.Unit[
    ".env.GenNextEpisode";
    {[c]
        p:c[`params];

        if[count[p[`cStepIndex]]>0;.env.StepIndex:p[`cStepIndex]];
        if[count[p[`cBatchIndex]]>0;.env.BatchIndex:p[`cBatchIndex]];
        if[count[p[`cCurrentStep]]>0;.env.CurrentStep:p[`cCurrentStep]];
        if[count[p[`cCurrentEpisode]]>0;.env.CurrentEpisode:p[`cCurrentEpisode]];
        if[count[p[`cEventSource]]>0;.env.EventSource:p[`cEventSource]];
        if[(count[p[`cEvents]]>0) and (count[p[`cEventSource]]>0);
            p[`cEventSource] set p[`cEvents];
        ];



        $[all(null[p[`eThrows]]);[
            .env.GenNextEpisode[];
        ];[
            .qt.AT[.env.GenNextEpisode;();p[`eThrows];"GenNextEpisode";c];
        ]];
 
        / if[count[p[`cStepIndex]]>1;.qt.A[.env.StepIndex;=;p[`cStepIndex][1];".env.StepIndex"; c]];
        / if[count[p[`cBatchIndex]]>1;.qt.A[.env.BatchIndex;=;p[`cBatchIndex][1];".env.BatchIndex"; c]];
        / if[count[p[`cCurrentStep]]>1;.qt.A[.env.CurrentStep;=;p[`cCurrentStep][1];".env.CurrentStep"; c]];
        / if[count[p[`cCurrentEpisode]]>1;.qt.A[.env.CurrentEpisde;=;p[`cCurrentEpisode][1];".env.CurrentEpisde"; c]];
        / if[count[p[`cEventSource]]>1;.qt.A[.env.EventSource;=;p[`cEventSource][1];".env.EventSource"; c]];
        .qt.A[.env.EventBatch;=;p[`eEventBatch];".env.EventBatch"; c];

    };
    {[p]
        / e:({`time`kind`cmd`datum!x} each p[0]);
        / show p[0];
        / m:{
            / mCols:`called`numCalls`calledWith`fn;
            / (count[x]#mCols)!x};  

        v:`grp xasc (`grp xgroup  raze flip ({m:{`time`intime`kind`cmd`datum!x}'[x[1]]; m[`grp]:x[0];m}'[p[5]]));

        :(`cCurrentStep`cBatchIndex`cCurrentEpisode`cEventSource`cEvents`eEventBatch`eStepIndex`eThrows)!(
            p[0];
            p[1];
            p[2];
            p[3];
            {`time`intime`kind`cmd`datum!x}'[p[4]];
            v;
            p[6];
            p[7]);
    };
    (
        ("step=0 single action account pair ordered by 1 second per step, 5 steps";(
            0; // current Step
            (); // BatchIndex
            0; // Current Episode
            `.env.events; // events splayed table
            (
                  (sz 1;sz 1;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 2;sz 2;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 3;sz 3;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 4;sz 4;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 5;sz 5;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 6;sz 6;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 7;sz 7;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 8;sz 8;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 9;sz 9;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 10;sz 10;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 11;sz 11;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 12;sz 12;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
            );
            (
                (0; (
                  (sz 1;sz 1;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 2;sz 2;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 3;sz 3;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 4;sz 4;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 5;sz 5;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 6;sz 6;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ));
                (7;(
                  (sz 7;sz 7;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 8;sz 8;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 9;sz 9;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 10;sz 10;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 11;sz 11;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 12;sz 12;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ))
            );
            (dtz 0;dtz 1); // step index
            0N
        ));
        ("step=0 single action account pair ordered by 1 second per step, 5 steps";(
            0; // current Step
            (); // BatchIndex
            0; // Current Episode
            `.env.events; // events splayed table
            (
                  (sz 1;sz 1;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 2;sz 2;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 3;sz 3;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 4;sz 4;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 5;sz 5;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 6;sz 6;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 7;sz 7;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 8;sz 8;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 9;sz 9;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 10;sz 10;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 11;sz 11;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 12;sz 12;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
            );
            (
                (0; (
                  (sz 1;sz 1;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 2;sz 2;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 3;sz 3;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 4;sz 4;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 5;sz 5;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 6;sz 6;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ));
                (7;(
                  (sz 7;sz 7;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 8;sz 8;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 9;sz 9;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 10;sz 10;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 11;sz 11;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 12;sz 12;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ))
            );
            (dtz 0;dtz 1); // step index
            0N
        ))
    );
    ({};{};defaultEnvEach;defaultEnvEach);
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];



// TODO test with differing intime?
// TODO test prime batch num type, env batch type etc.
// TODO no action events created
// TODO register Env as config
test:.qt.Unit[
    ".env.Reset";
    {[c]
        p:c[`params];

        p1:p[`eSetupEvents];  
        p2:p[`eProcessEvents];  
        p3:p[`eInsertResultantEvents];  
        p4:p[`eGetFeatures];  

        .qt.M[`.engine.Reset;{};c];
        .qt.M[`.state.Reset;{};c];
        .qt.M[`.env.GenNextEpisode;{};c];

        mck1: .qt.M[`.env.SetupEvents;{};c];
        mck2: .qt.M[`.engine.ProcessEvents;{[e]};c];
        mck3: .qt.M[`.state.InsertResultantEvents;{[e]};c];
        mck4: .qt.M[`.state.GetObservations;{[a;w;s]};c];

        if[count[p[`cStepIndex]];.env.StepIndex:p[`cStepIndex]];
        if[count[p[`cCurrentStep]];.env.CurrentStep:p[`cCurrentStep]];
        if[count[p[`cEventBatch]];.env.EventBatch:p[`cEventBatch]];
        if[count[p[`cPrimeBatchNum]];.env.PrimeBatchNum:p[`cPrimeBatchNum]];

        $[all(null[p[`eThrows]]);[
            res:.env.Reset[p];
            .qt.A[res;~;p[`eRes];"response";c];
        ];[
            .qt.AT[.env.Reset;();p[`eThrows];"Reset";c];
        ]];
        / show p1;

        .qt.MA[mck1;p1[`called];p1[`numCalls];p1[`calledWith];c];
        .qt.MA[mck2;p2[`called];p2[`numCalls];p2[`calledWith];c];
        .qt.MA[mck3;p3[`called];p3[`numCalls];p3[`calledWith];c];
        .qt.MA[mck4;p4[`called];p4[`numCalls];p4[`calledWith];c];
    };
    {[p]
        / e:({`time`kind`cmd`datum!x} each p[0]);
        / show p[0];
        m:{
            mCols:`called`numCalls`calledWith`fn;
            (count[x]#mCols)!x};  

        e:{`time`kind`cmd`datum!x};

        v:`grp xasc (`grp xgroup  raze flip ({m:{`time`intime`kind`cmd`datum!x}'[x[1]]; m[`grp]:x[0];m}'[p[3]]));


        :(`cPrimeBatchNum`cCurrentStep`cStepIndex`cEventBatch`eRes`eSetupEvents`eProcessEvents,
        `eInsertResultantEvents`eGetFeatures`eThrows)!(
            p[0];
            p[1];
            p[2];
            v;
            p[4];
            m p[5];
            m p[6];
            m p[7];
            m p[8];
            p[9]
            )
    };
    (
        ("prime batch num=0 ordered by 1 second per step, 5 steps";(
            0; // actions
            0; // prime batch num
            (dtz 0;dtz 1); // step index
            (
                (0; (
                  (sz 1;sz 1;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 2;sz 2;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 3;sz 3;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 4;sz 4;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 5;sz 5;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 6;sz 6;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ));
                (7;(
                  (sz 7;sz 7;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 8;sz 8;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 9;sz 9;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 10;sz 10;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 11;sz 11;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 12;sz 12;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ))
            );
            (til 5); // expected response
            (1b;1;enlist(`.adapter.ADAPTERTYPE$`MARKETMAKER;dtz 0;((1;0);(1;1)));{[x;t;a]}); // eAdapt
            (1b;1;()); // eProcessEvents
            (1b;1;()); // eInsertResultantEvents
            (1b;1;()); // eGetFeatures
            0N
        ));
        ("prime batch num=1 ordered by 1 second per step, 5 steps";(
            1; // actions
            0; // current step
            (dtz 0;dtz 1); // step index
            (
                (0; (
                  (sz 1;sz 1;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 2;sz 2;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 3;sz 3;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 4;sz 4;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 5;sz 5;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 6;sz 6;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ));
                (7; (
                  (sz 1;sz 1;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 2;sz 2;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 3;sz 3;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 4;sz 4;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 5;sz 5;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 6;sz 6;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ));
                (14;(
                  (sz 7;sz 7;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 8;sz 8;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 9;sz 9;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 10;sz 10;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 11;sz 11;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 12;sz 12;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ))
            );
            (til 5); // expected response
            (1b;1;enlist(`.adapter.ADAPTERTYPE$`MARKETMAKER;dtz 0;((1;0);(1;1)));{[x;t;a]}); // eAdapt
            (1b;1;()); // eProcessEvents
            (1b;1;()); // eInsertResultantEvents
            (1b;1;()); // eGetFeatures
            0N
        ));
        ("prime batch num=1 ordered by 1 second per step, 5 steps";(
            2; // actions
            0; // current step
            (dtz 0;dtz 1); // step index
            (
                (0; (
                  (sz 1;sz 1;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 2;sz 2;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 3;sz 3;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 4;sz 4;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 5;sz 5;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 6;sz 6;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ));
                (7; (
                  (sz 1;sz 1;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 2;sz 2;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 3;sz 3;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 4;sz 4;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 5;sz 5;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 6;sz 6;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ));
                (14;(
                  (sz 7;sz 7;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 8;sz 8;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 9;sz 9;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 10;sz 10;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 11;sz 11;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 12;sz 12;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ))
            );
            (til 5); // expected response
            (1b;1;enlist(`.adapter.ADAPTERTYPE$`MARKETMAKER;dtz 0;((1;0);(1;1)));{[x;t;a]}); // eAdapt
            (1b;1;()); // eProcessEvents
            (1b;1;()); // eInsertResultantEvents
            (1b;1;()); // eGetFeatures
            0N
        ))
    );
    ({};{};defaultEnvEach;defaultEnvEach);
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];


// TODO test with differing intime?
// TODO differing event count 
// TODO test with null split
// TODO features
// TODO check offset is added.
// TODO test no acounts exist etc.
// TODO no action/nevents created
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
        mck4: .qt.M[`.state.GetObservations;{[a;w;s]};c];
        mck5: .qt.M[`.state.GetRewards;{[e;w;s]};c];
        mck6: .qt.M[`.env.Info;{[a;s]};c];

        if[count[p[`cStepIndex]];.env.StepIndex:p[`cStepIndex]];
        if[count[p[`cCurrentStep]];.env.CurrentStep:p[`cCurrentStep]];
        if[count[p[`cEventBatch]];.env.EventBatch:p[`cEventBatch]];

        $[all(null[p[`eThrows]]);[
            res:.env.Step[p[`actions]];
            .qt.A[res;~;p[`eRes];"response";c];
        ];[
            .qt.AT[.env.Step;p[`actions];p[`eThrows];"Step";c];
        ]];
        / show p1;

        .qt.MA[mck1;p1[`called];p1[`numCalls];p1[`calledWith];c];
        .qt.MA[mck2;p2[`called];p2[`numCalls];p2[`calledWith];c];
        .qt.MA[mck3;p3[`called];p3[`numCalls];p3[`calledWith];c];
        .qt.MA[mck4;p4[`called];p4[`numCalls];p4[`calledWith];c];
        .qt.MA[mck5;p5[`called];p5[`numCalls];p5[`calledWith];c];
        .qt.MA[mck6;p6[`called];p6[`numCalls];p6[`calledWith];c];

    };
    {[p]
        / e:({`time`kind`cmd`datum!x} each p[0]);
        / show p[0];
        m:{
            mCols:`called`numCalls`calledWith`fn;
            (count[x]#mCols)!x};  

        e:{`time`kind`cmd`datum!x};

        v:`grp xasc (`grp xgroup  raze flip ({m:{`time`intime`kind`cmd`datum!x}'[x[1]]; m[`grp]:x[0];m}'[p[3]]));


        :(`actions`cCurrentStep`cStepIndex`cEventBatch`eRes`eAdapt`eProcessEvents,
        `eInsertResultantEvents`eGetFeatures`eGetRewards`eInfo`eThrows)!(
            p[0];
            p[1];
            p[2];
            v;
            p[4];
            m p[5];
            m p[6];
            m p[7];
            m p[8];
            m p[9];
            m p[10];
            p[11]
            )
    };
    (
        ("step=0 ordered by 1 second per step, 5 steps";(
            ((1;0);(1;1)); // actions
            0; // current step
            (dtz 0;dtz 1); // step index
            (
                (dtz 0; (
                  (sz 0;sz 0;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 2;sz 2;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 3;sz 3;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 4;sz 4;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 5;sz 5;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 6;sz 6;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ));
                (dtz 1;(
                  (sz 7;sz 7;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 8;sz 8;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 9;sz 9;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 10;sz 10;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 11;sz 11;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 12;sz 12;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ))
            );
            (til 5); // expected response
            (1b;1;enlist(`.adapter.ADAPTERTYPE$`MARKETMAKER;dtz 0;((1;0);(1;1)));{[x;t;a]}); // eAdapt
            (1b;1;()); // eProcessEvents
            (1b;1;()); // eInsertResultantEvents
            (1b;1;()); // eGetFeatures
            (1b;1;()); // eGetRewards
            (0b;0;()); // eInfo
            0N
        ));
        ("step=1 ordered by 1 second per step, 5 steps, differing from idx";(
            ((1;0);(1;1)); // actions
            1; // current step
            (dtz 0;dtz 7); // step index
            (
                (dtz 0; (
                  (sz 1;sz 1;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 2;sz 2;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 3;sz 3;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 4;sz 4;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 5;sz 5;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 6;sz 6;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ));
                (dtz 7;(
                  (sz 7;sz 7;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 8;sz 8;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 9;sz 9;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 10;sz 10;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 11;sz 11;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 12;sz 12;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ))
            );
            (til 5); // expected response
            (1b;1;enlist(`.adapter.ADAPTERTYPE$`MARKETMAKER;dtz 0;((1;0);(1;1)));{[x;t;a]}); // eAdapt
            (1b;1;()); // eProcessEvents
            (1b;1;()); // eInsertResultantEvents
            (1b;1;()); // eGetFeatures
            (1b;1;()); // eGetRewards
            (0b;0;()); // eInfo
            0N
        ));
        ("step=1 ordered by index/event count grouping";(
            ((1;0);(1;1)); // actions
            1; // current step
            (0;6); // step index
            (
                (0; (
                  (sz 1;sz 1;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 2;sz 2;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 3;sz 3;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 4;sz 4;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 5;sz 5;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 6;sz 6;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ));
                (6;(
                  (sz 7;sz 7;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 8;sz 8;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 9;sz 9;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 10;sz 10;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 11;sz 11;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 12;sz 12;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ))
            );
            (til 5); // expected response
            (1b;1;enlist(`.adapter.ADAPTERTYPE$`MARKETMAKER;dtz 0;((1;0);(1;1)));{[x;t;a]}); // eAdapt
            (1b;1;()); // eProcessEvents
            (1b;1;()); // eInsertResultantEvents
            (1b;1;()); // eGetFeatures
            (1b;1;()); // eGetRewards
            (0b;0;()); // eInfo
            0N
        ));
        ("step=2 should error, functionality not called";(
            ((1;0);(1;1)); // actions
            2; // current step
            (0;6); // step index
            (
                (0; (
                  (sz 1;sz 1;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 2;sz 2;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 3;sz 3;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 4;sz 4;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 5;sz 5;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 6;sz 6;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ));
                (6;(
                  (sz 7;sz 7;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 8;sz 8;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 9;sz 9;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 10;sz 10;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 11;sz 11;`DEPTH;`UPDATE;enlist(10001;`BUY;1000));
                  (sz 12;sz 12;`DEPTH;`UPDATE;enlist(10001;`BUY;1000))
                ))
            );
            (til 5); // expected response
            (0b;0;();{[x;t;a]}); // eAdapt
            (0b;0;()); // eProcessEvents
            (0b;0;()); // eInsertResultantEvents
            (0b;0;()); // eGetFeatures
            (0b;0;()); // eGetRewards
            (0b;0;()); // eInfo
            "INVALID_STEP"
        ))
    );
    ({};{};defaultEnvEach;defaultEnvEach);
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];

/ .qt.SkpBes[5];

// TODO profile event step!!!
.qt.RunTests[];