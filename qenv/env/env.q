\l adapter.q 
// TODO CHANGE EVENTS TO LISTS INSTEAD OF DICTIONARIES

// Agent ________________________ engine ____
// Pipe ______ exchange events __/          \__ state _____ feature buffer ___ Agent 
//      \_____ other features _____________________________/
// TODO hooks system

\d .env


// TODO config order size, balance randomization prob, 
Env  :(
        [envId               :`long$()]
        initialBalance      : `float$();
        rebalanceHigh       : `float$();
        rebalanceLow        : `float$();
        rebalancefreq       : `long$();
        maxBalanceRebalance : `long$();
        withrawFreq         : `long$();
        minBalanceWithdraw  : `long$();
        doneBalance         : `float$();
        maxNumSteps         : `long$();
        totalSteps          : `long$();
        outageFreq          : `long$();
        outageMaxLength     : `long$();
        outageMinLength     : `long$();
        outageMU            : `float$();
        outageSigma         : `float$();
        doBatchedReplay     : `boolean$();
        batchSize           : `long$();
        currentStep         : `long$();
        stepTime            : `datetime$();
        numFailures         : `long$();
        numAgentSteps       : `long$();
        accountIds          : ());

WINDOWKIND :  `TEMPORAL`EVENTCOUNT`THRESHCOUNT`TRADECOUNT`PRICECHANGE;   

BATCHSELECTMETHOD :`CHRONOLOGICAL`RANDOM`CURRICULUM; 

// TODO episodes
Episode :(
        [episodeId               :`long$()]
        batchIdx                 :`long$();
        batchStart               :`datetime$();
        batchEnd                 :`datetime$();                        
        rewardTotal              :`float$();
        returnQuoteTotal         :`float$();
        returnBaseTotal          :`float$()
    );

.env.EventPath:`path;
.env.EventSource:`events;
.env.UseFeatures:0b;
.env.MaxEpisodes:1000;
.env.RewardKind:0;

.env.CurrentEpisde:0;
.env.CurrentStep:0; // The current step of the environment.
.env.PrimeBatchNum:0; // How many events are used to prime the engine with state.

.env.ADPT:`.adapter.ADAPTERTYPE$`MARKETMAKER;
.env.WindowKind:`.env.WINDOWKIND$`TEMPORAL;
.env.BatchSelectMethod:`.env.BATCHSELECTMETHOD$`CHRONOLOGICAL;
.env.BatchInterval:`minute$5;
.env.BatchSize: 50;

.env.BatchIndex:();
.env.StepIndex:();
.env.EventBatch:();
.env.FeatureBatch:();


// Derives a dictionary of info pertaining to the agents
// individually and those that are global.
Info        :{[aIds;step]
        :(
            .engine.Info[];
            .state.Info[];
            .env.CurrentStep
        );
    };


/ Env Utils
// =====================================================================================>

firstDay:{`datetime$((select first date from events)[`date])};


/ date       time                    intime                  kind  cmd datum
/ ---------------------------------------------------------------------------------------
/ 2020.07.26 2020.07.26T23:54:24.490 2020.07.26T23:54:24.547 TRADE NEW `SELL 993500i 1i
/ 2020.07.26 2020.07.26T23:54:44.650 2020.07.26T23:54:44.708 TRADE NEW `BUY  993550i 92i
/ 2020.07.26 2020.07.26T23:54:44.650 2020.07.26T23:54:44.708 TRADE NEW `BUY  993550i 110i
/ 2020.07.26 2020.07.26T23:54:44.650 2020.07.26T23:54:44.708 TRADE NEW `BUY  993550i 200i
/ 2020.07.26 2020.07.26T23:54:44.650 2020.07.26T23:54:44.708 TRADE NEW `BUY  993550i 4i

// Probabalistic choice
// @n: number of choices
// @k: count of choices
// @p: probability spread
PChoice :{[n;k;p]k?raze ("j"$p*10 xexp max count each("."vs'string p)[;1])#'til n};

// Returns the next batch from the

// Batches are synonymous with episode // TODO train test split
// TODO test next
// TODO batch by price movement
GenNextEpisode    :{
    // If the batch idxs which correspond with the length of an episode are
    // not set create the set of batch idxs.
    // set the batch window intervals above.

    // TODO check day is divisible by batch size? 
    // TODO missing events at start of events
    if[count[.env.BatchIndex]<1;[ 
        bidx:select start:((`date$time)+(.env.BatchSize xbar `minute$time)) from .env.EventSource;
        bidx:update end:next start from bidx;
        bidx:update end:first[(select last time from .env.EventSource)`time]^end from bidx;
        .env.BatchIndex:bidx;
    ]];

    nextBatch:$[
       (.env.BatchSelectMethod=`.env.BATCHSELECTMETHOD$`RANDOM);
        [.env.BatchIndex@rand count[bidx]];
       (.env.BatchSelectMethod=`.env.BATCHSELECTMETHOD$`CHRONOLOGICAL);
        [.env.BatchIndex@(.env.CurrentEpisde mod count[.env.BatchIndex])];
       (.env.BatchSelectMethod=`.env.BATCHSELECTMETHOD$`CURRICULUM); // TODO
        ['NOTIMPLEMENTED];
        ['INVALID_BATCH_SELECTION_METHOD]];

    $[(.env.WindowKind=`.env.WINDOWKIND$`TEMPORAL);
        [
            .env.EventBatch:select time, intime, kind, cmd, datum by grp:(`date$time)+5 xbar `second$time from .env.EventSource where time within value[nextBatch];
            if[.env.UseFeatures;.env.FeatureBatch:0N];
        ];
    (.env.WindowKind=`.env.WINDOWKIND$`EVENTCOUNT);
        [
            .env.EventBatch:select time, intime, kind, cmd, datum by grp:5 xbar i from .env.EventSource where time within value[nextBatch];
            if[.env.UseFeatures;.env.FeatureBatch:0N];
        ];
    (.env.WindowKind=`.env.WINDOWKIND$`THRESHCOUNT);
        ['NOTIMPLEMENTED];
    ['INVALID_WINDOWING_METHOD]];

      // TODO insert feature batch.
      // TODO upsert new episode with event count etc.

     .state.StepIndex: key .env.EventBatch;
    };


/ Reset Logic
// =====================================================================================>

// TODO reset step count, load first batch etc.
// Resets the state for all agents for whom 
// ids have been included into the ids parameter
// TODO validation
Reset    :{[config]
    // Env Config
        // Create accounts
        // Create inventory
        // Create Instrument
        // Set engine instrument
    / .engine.Config[];

    // Agent Config
    / env:.env.Env@0;

    // - reward kind, 
    // feature kind, 
    // adapter kind, 
    // encouragement, 
    // lookback size
    // source of events
    // order size
    // min inventory
    // max inventory
    // training episodes (roughly 8X training sample size)
    // training sample size
    // testing sample size
    // memory size
    // 
    // TODO log config to analytics 

    .state.Reset[config];
    // TODO randomization of environment config

    .engine.Reset[config]; 

    // Loads the next set of events from 
    // HDB into memory
    .env.GenNextEpisode[]; // TODO check that length is greater than config
    
    aevents:.env.SetupEvents[config];
    nevents:raze flip'[value[.env.PrimeBatchNum#.env.EventBatch]]; //TODO derive from config
    xevents:.engine.ProcessEvents[(nevents,aevents)];
    .state.InsertResultantEvents[xevents];

    // TODO randomize
        // order size
        // offset time
        // balance 
        // withdraws 
        // 

    aids:(.env.Env@0)`accountIds;
    obs:.state.GetObservations[aids; 100; 0];
    .env.EventBatch:(.env.PrimeBatchNum)_(.env.EventBatch); // Shift events
    .env.StepIndex:(.env.PrimeBatchNum)_(.env.StepIndex); // Shift events

    .env.CurrentStep:0;

    // TODO analytics log reset

    :(obs);
    };



/ Advancing System
// =====================================================================================>

// step rate i.e. by number of events, by interval, by number of events within interval, by number of events outside interval. 

// batching/episodes and episode randomization/replay buffer.
// Loads events into memory such that they can be more rapidly stepped over
// moving this to a seperate process will increase the speed even further. 
// Carries out a step in the exchange environment
// It generates a set of events for each action
// given its time and sets a given offset for 
// each event therin before sending the action to
// the engine.
// It will thereafter advance the state and return
// the next observations, rewards, done and info
// for each agent
// TODO is done, buffering/historic replay etc.
// TODO add noise events to input i.e. trades etc.
Step    :{[actions]
    // TODO format actions
    step:.env.CurrentStep;
    csi:count[.env.StepIndex];
    // Advances the current state of the environment
    $[.env.CurrentStep<csi;[    
        idx:.env.StepIndex@step;
        nevents:flip[.env.EventBatch@idx];
        / feature:FeatureBatch@thresh; // TODO feature batch with noisy offsets
        // should add a common offset to actions before inserting them into
        // the events.
        tme:$[type idx~15h;idx;exec first time from nevents];
        // TODO should add offset to action events!!!.
        // TODO should add random withraws, deposits outages etc.
        aevents:.adapter.Adapt[.env.ADPT;idx;actions];
        xevents:.engine.ProcessEvents[(nevents,aevents)];
        // TODO should add offset to resultant events!!!
        .state.InsertResultantEvents[xevents];

        aids:actions[;1];
        naids:count[aids];
        obs:.state.GetObservations[aids; 100; step];
        rwd:.state.GetRewards[aids; 100; step];
        dns:$[((step+1)<count[.env.StepIndex]); 
                .state.GetDones[aids; 0];
                flip[(aids;naids#1b)]];
        ifo:.env.Info[aids;step];

        .env.CurrentStep+:1;
        :(obs;rwd;dns;ifo);
    ];'INVALID_STEP];
    };