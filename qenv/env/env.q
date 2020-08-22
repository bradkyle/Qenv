\l adapter.q 
// TODO CHANGE EVENTS TO LISTS INSTEAD OF DICTIONARIES

// Agent ________________________ engine ____
// Pipe ______ exchange events __/          \__ state _____ feature buffer ___ Agent 
//      \_____ other features _____________________________/
\d .env

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
        numAgentSteps       : `long$()
    );

/ Agent :(
/     [agentId        :`long$()]
/     accountId       :`long$();
/     rewardKind          : `.reward.REWARDKIND$();
/     lookBackSize        : `long$();
/     encouragement       : `float$()
/     );

.env.CurrentStep:0;
.env.PrimeBatchNum:0;
.env.ADPT:`.adapter.ADAPTERTYPE$`MARKETMAKER;
.env.BatchInterval:`minute$5;
.env.BatchSize: 50;
.env.StepIndex:();
.env.EventBatch:();
.env.FeatureBatch:();

// Main Callable functions
// --------------------------------------------------->

// config recieves a json representation of the given config
// that pertains to the initial environment state, agent state 
// aswell as the strategy for which steps will take place.
// utilizes the .j (json) namespace to process a json representation
// sent to it.
Config      :{[config]

    // Env Config

    // Agent Config
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

    };

// Derives a dictionary of info pertaining to the agents
// individually and those that are global.
Info        :{[aIds;step]
        .engine.Info[];
    };


/ GenNextEventBatch
// =====================================================================================>

GenNextBatch    :{

    };

/ Reset Logic
// =====================================================================================>

// TODO reset step count, load first batch etc.
// Resets the state for all agents for whom 
// ids have been included into the ids parameter
ResetAgents       :{[aIds] // TODO make into accountConfigs, TODO load initial events for given buffer time
    // Reset public singletons
    .engine.ResetAgents[aIds];
    .state.ResetAgents[aIds];
    };

ResetAll    :{
    .engine.Reset[];
    .state.Reset[];

    // Loads the next set of events from 
    // HDB into memory
    .env.GenNextBatch[]; // TODO check that length is greater than config

    nvents:.env.PrimeBatchNum#.env.EventBatch;
    aevents:.env.SetupEvents[];
    xevents:.engine.ProcessEvents[(nevents,aevents)];
    .state.InsertResultantEvents[xevents];


    };



/ Advancing System
// =====================================================================================>

firstDay:{`datetime$((select first date from events)[`date])};


/ date       time                    intime                  kind  cmd datum
/ ---------------------------------------------------------------------------------------
/ 2020.07.26 2020.07.26T23:54:24.490 2020.07.26T23:54:24.547 TRADE NEW `SELL 993500i 1i
/ 2020.07.26 2020.07.26T23:54:44.650 2020.07.26T23:54:44.708 TRADE NEW `BUY  993550i 92i
/ 2020.07.26 2020.07.26T23:54:44.650 2020.07.26T23:54:44.708 TRADE NEW `BUY  993550i 110i
/ 2020.07.26 2020.07.26T23:54:44.650 2020.07.26T23:54:44.708 TRADE NEW `BUY  993550i 200i
/ 2020.07.26 2020.07.26T23:54:44.650 2020.07.26T23:54:44.708 TRADE NEW `BUY  993550i 4i

loadEvents  :{
    // .Q.ind[]
    :select time, intime, kind, cmd, datum by grp:5 xbar `second$time from .env.events where time within ();
    };

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
Step    :{[actions]
    // TODO format actions
    step:.env.CurrentStep;
    // Advances the current state of the environment
    $[(step<count[.env.StepIndex]);
        [
            idx:.env.StepIndex@step;
            nevents:flip[.env.EventBatch@idx];
            
            / feature:FeatureBatch@thresh;
            // should add a common offset to actions before inserting them into
            // the events.
            aevents:.adapter.Adapt[.env.ADPT;idx;actions]; 
            xevents:.engine.ProcessEvents[(nevents,aevents)];

            .state.InsertResultantEvents[xevents];

            aids:actions[;1];
            obs:.state.GetFeatures[aids; 100; step];
            rwd:.state.GetRewards[aids; 100; step];
            ifo:.env.Info[aids;step];

            // TODO analytics
            / if[.env.ActiveEnv[`doAnalytics]; // CHANGE to config
                / .analytics.LogStep[step;actions;obs;rwd;ifo;nevents;aevents;xevents]];

            

            :(obs;rwd;ifo);
        ];
        [
            
        ]
    ];
 
    .env.CurrentStep+:1;
    

    };