\l adapter.q 
// TODO CHANGE EVENTS TO LISTS INSTEAD OF DICTIONARIES

// Agent ________________________ engine ____
// Pipe ______ exchange events __/          \__ state _____ feature buffer ___ Agent 
//      \_____ other features _____________________________/              \___ Logging

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


// Derives a dictionary of info pertaining to the agents
// individually and those that are global.
Info        :{[aIds;step]
        :(
            .engine.Info[];
            .state.Info[];
            .env.CurrentStep
        );
    };

/ Reset Logic
// =====================================================================================>

// TODO reset step count, load first batch etc.
// Resets the state for all agents for whom 
// ids have been included into the ids parameter
// TODO validation
Reset    :{[config]
    
    res:.engine.Reset[config];
    res:.state.Reset[config];

    // Loads the next set of events from 
    // HDB into memory
    .env.GenNextEpisode[]; // TODO check that length is greater than config
    
    aevents:.env.SetupEvents[config];
    nevents:raze flip'[value[.env.PrimeBatchNum#.env.EventBatch]]; //TODO derive from config
    xevents:.engine.ProcessEvents[(nevents,aevents)];
    .state.InsertResultantEvents[xevents];

    aids:(.env.Env@0)`accountIds;
    obs:.state.GetObservations[aids; 100; 0];
    .env.EventBatch:(.env.PrimeBatchNum)_(.env.EventBatch); // Shift events
    .env.StepIndex:(.env.PrimeBatchNum)_(.env.StepIndex); // Shift events

    .env.CurrentStep:0;

    // TODO analytics log reset

    :.obs.GetObs[
        .env.CurrentStep;
        .env.CONF`lookback;
        .env.CONF`accountIds];
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

        aIds:actions[;1];
        naids:count[ads];
        obs:.obs.GetObs[step; .env.CONF`lookback; aIds];
        rwd:.state.GetRewards[aIds; 100; step];
        dns:$[((step+1)<count[.env.StepIndex]); 
                .state.GetDones[aIds; 0];
                flip[(aIds;naIds#1b)]];
        ifo:.env.Info[aIds;step];

        .env.CurrentStep+:1;
        :(obs;rwd;dns;ifo);
    ];'INVALID_STEP];
    };