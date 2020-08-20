
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

Agent :(
    [agentId        :`long$()]
    accountId       :`long$();
    rewardKind          : `.reward.REWARDKIND$();
    lookBackSize        : `long$();
    encouragement       : `float$();
    );


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
    // 

    };

// Derives a dictionary of info pertaining to the agents
// individually and those that are global.
Info        :{[aIds]

    };

// Resets the state for all agents for whom 
// ids have been included into the ids parameter
Reset       :{[aIds] // TODO make into accountConfigs 
    // Reset public singletons
    .engine.Reset[aIds];
    :.state.Reset[aIds];
    };




/ Advancing System
// =====================================================================================>

Adapter:`.adapter.ADAPTERTYPE$`MARKETMAKER;
BatchSize:0;
StepIndex:();
EventBatch:();
FeatureBatch:();

// step rate i.e. by number of events, by interval, by number of events within interval, by number of events outside interval. 

// batching/episodes and episode randomization/replay buffer.

// get daily 


SetBatch: {[]
    EventBatch:0; 
    };

firstDay:{`datetime$((select first date from events)[`date])}

// SIMPLE DERIVE STEP RATE
Advance :{[step;actions]
    $[
        (step=0);
        [
            idx:.env.StepIndex@step;
        ];
        (step<(count[.env.StepIndex]-1));
        [
            idx:.env.StepIndex@step;
            nevents:flip[.env.EventBatch@idx];
            
            / feature:FeatureBatch@thresh;
            // should add a common offset to actions before inserting them into
            // the events.
            // TODO offset
            // TODO 
            aevents:.adapter.Adapt[.env.Adapter][time] each actions; 
            newEvents: .engine.ProcessEvents[(nevents,aevents)];

            .env.InsertResultantEvents[newEvents];
        ];
        [
            .env.EventBatch:select time, intime, kind, cmd, datum by grp:5 xbar `second$time from .env.events where time within ();
            .env.StepIndex:key .env.EventBatch;
            / .env.FeatureBatch:select time, intime, kind, cmd, datum by grp:5 xbar `second$time from events;
        ]
    ];
    };


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

    // Advances the current state of the environment
    results: .env.Advance[accountIds; newEvents];

    // Derive the current info for the
    // entire engine and for each subsequent
    // account referenced in accountIds
    // Returns a table of Info indexed by accountId
    info: Info[accountIds];

    if[.env.ActiveEnv[`doAnalytics]; 
        .analytics.LogStep[actions;result[0];result[1];info;newEvents]];

    // Returns a set of observations, rewards and info
    // to the agents (uj by agent)
    :(uj)over(result[0];result[1];info);
    };