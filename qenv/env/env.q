
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


    };

// Derives a dictionary of info pertaining to the agents
// individually and those that are global.
Info        :{[accountIds]

    };

// Resets the state for all agents for whom 
// ids have been included into the ids parameter
Reset       :{[accountIds] // TODO make into accountConfigs 
    // Reset public singletons
    .engine.Reset[accountIds];
    :.state.Reset[accountIds];
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

    // TODO actions as a tuple of account id and action: derive account ids from actions.
    

    // The engine produces a set of new events.
    newEvents: .engine.ProcessEventBatch[events];

    // Advances the current state of the environment
    result: .state.Advance[accountIds; newEvents];

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