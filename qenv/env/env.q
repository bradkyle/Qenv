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

.env.CurrentStep:0; // The current step of the environment.
.env.CONF:();

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
    
    // Reset the Engine and 
    // the current state and 
    // return obs
    .engine.Reset[config];
    .state.Reset[config];

    
    // Derive the initial state from the
    // engine and derive deposit events etc.
    aevents:.env.SetupEvents[config];
    nevents:.ingress.Start[config];
    xevents:.engine.ProcessEvents[(nevents,aevents)];
    .state.InsertResultantEvents[xevents];
    .env.CurrentStep:0;

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
        rwd:.rew.GetRewards[step; 100; aIds];
        dns:$[((step+1)<count[.env.StepIndex]); 
                .state.GetDones[aIds; 0];
                flip[(aIds;naIds#1b)]];
        ifo:.env.Info[aIds;step];

        .env.CurrentStep+:1;
        :(obs;rwd;dns;ifo);
    ];'INVALID_STEP];
    };