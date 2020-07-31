
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
    .state.CurrentStep:0; // TODO include buffer i.e. set current step to 10
    .state.StepTime: exec from .state.PrimaryStepInfo where step=0; // returns the current step info i.e. time, loadshedding prob etc.
    
    // Derive the primary set of events derived from exchange
    events: nextEvents[.state.CurrentStep]; // TODO derive actual events from datums
    // TODO reset accounts inventory orders instrument

    :advance[events;accountIds];
    };

// Carries out a step in the exchange environment
// It generates a set of events for each action
// given its time and sets a given offset for 
// each event therin before sending the action to
// the engine.
// It will thereafter advance the state and return
// the next observations, rewards, done and info
// for each agent
Step    :{[actions]
    // TODO format actions

    // TODO actions as a tuple of account id and action: derive account ids from actions.
    .adapter.Adapt[time] each ej[`agentId;actions;.env.Agent]; 

    // The engine produces a set of new events.
    newEvents: .engine.ProcessEventBatch[events];

    InsertResultantEvents[events]; // TODO try catch etc.
    featureVectors: getFeatureVector[accountIds]; // TODO parrellelize

    // Generates a set of resultant rewards based on the config
    // of each agent, the rewards are returned as a table indexed
    // by the respective accountIds
    rewards: getResultantReward[accountIds]; // TODO parrellelize

    // Derive the current info for the
    // entire engine and for each subsequent
    // account referenced in accountIds
    // Returns a table of Info indexed by accountId
    info: Info[accountIds];
    
    // TODO log info to analytics

    :(uj)over(obs;rewards;info);
    };