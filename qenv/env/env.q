
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
        rewardKind          : `.reward.REWARDKIND$();
        lookBackSize        : `long$();
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
        encouragement       : `float$();
    );

activeEnvId:0;

// Exposed State Logic
// =====================================================================================>

/
The state module utilizes historic lookback buffers to
represent the state thate an agent would recieve when 
subscribed to an exchange.
TODO move adapters into here
\


getFeatureVector    :{[]

    };

// Returns the resultant rewards for a set of agent
// ids based upon the configuration set i.e.
// sortino ratio etc.
getResultantRewards  :{[accountIds] // TODO apply given reward function by agent specified reward function.
    stepReturns: select deltas last amount by accountId, (`date$time) + 1 xbar `minute$time from account where time >= `minute$rewardLookbackMinutes // TODO make reward lookback minutes configurable
    };


// Secondary state functions
// --------------------------------------------------->

// Uses a preset query to derive a set of events
// that represent the progression of state on
// an exchange, thereafter the events are parsed
// into the forms defined by the models after which
// they are returned.
nextEvents   :{[step] // TODO changes in depth due to trades still persist only when agent order do change?
        :(
            select from .schema.SourceDepth where step=step; // returns the set of depth updates (including trades) that happen.
            select from .schema.SourceTrades where step=step; // returns the set of trades (not made by the agent) in period
            select from .schema.SourceMarks where step=step; // returns the set of mark price updates that occur in the period
            select from .schema.SourceFundings where step=step; // returns the set of funding events that occur in the period
        );
    };

// Derives a set of events that would constitute
// the transition of state of the exchange BEFORE
// THE ACTIONS TOOK PLACE.
// Appending the actions to the events to be processed.
derive  :{[actions;time]
    events: ();
    events:events, nextEvents[.state.CurrentStep]; // Utilizes a global variable to denote the current step.
    // sample a probability space of request time
    events:events, .adapter.Adapt [] [accountId;action;time;meanWait;stdWait]; // TODO make work
    :events; //TODO implement penalty
    };

// Inserts the step wise events recieved (back)
// from the engine and adds them to their 
// respective table before deriving a feature
// vector and resultant reward for each agent
// participating in the environment.
advance :{[events;accountIds]
    InsertResultantEvents[events]; // TODO try catch etc.
    featureVectors: getFeatureVector[accountIds]; // TODO parrellelize
    .state.CurrentStep+:1;
    :featureVectors;
    };

// Main Callable functions
// --------------------------------------------------->

// config recieves a json representation of the given config
// that pertains to the initial environment state, agent state 
// aswell as the strategy for which steps will take place.
// utilizes the .j (json) namespace to process a json representation
// sent to it.
Config      :{[config]

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
    events:derive[actions];

    // The engine produces a set of new events.
    newEvents: .engine.ProcessEventBatch[events];

    obs:  advance[newEvents;accountIds];

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