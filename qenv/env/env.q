\l adapter.q 
// TODO CHANGE EVENTS TO LISTS INSTEAD OF DICTIONARIES

// Agents ________________________ engine ____
// Pipe ______ exchange events __/          \__ state _____ feature buffer ___ Agent 
//      \_____ other features _____________________________/              \___ Logging

// TODO hooks system

// TODO random funding events per batch
// TODO random settlement events per batch
// TODO random markPrice events per batch
// TODO random priceLimit events per batch
// TODO random (large market buy events)

// TODO heartbeats

// TODO config order size, balance randomization prob, 
.env.Env  :(
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

// Episode is a table that is used to track 
// the performance of all agents for a given
// batch.
.env.Episode :(
        [episodeId               :`long$()]
        batchIdx                 :`long$();
        batchStart               :`datetime$();
        batchEnd                 :`datetime$();                        
        rewardTotal              :`float$();
        returnQuoteTotal         :`float$();
        returnBaseTotal          :`float$());

.env.CurrentStep:0; // The current step of the environment.
.env.CONF:();

// Derives a dictionary of info pertaining to the agents
// individually and those that are global.
.env.Info        :{[aIds;step]
        :(
            .engine.Info[];
            .state.Info[];
            .pipe.Info[];
            .env.CurrentStep
        );
    };

/ Reset Logic
// =====================================================================================>

// TODO reset step count, load first batch etc.
// Resets the state for all agents for whom 
// ids have been included into the ids parameter
// TODO validation
/  @param config     (JSON) A json string containing the env config 
/  @return          (List/Vector) The first observation for each agent
.env.Reset    :{[config]
    .env.CONF:.config.ParseConfig[config];
    // Reset the Engine and 
    // the current state and 
    // return obs
    .engine.Reset[.env.CONF];
    .state.Reset[.env.CONF];

    // Reset the current step
    step:0;
    .env.CurrentStep:step;

    // Based upon initial configuration set in .env.Reset
    // this function derives the set of events at the given
    // step that should be executed by the engine.
    // This also allows for longer temporal steps and larger
    // batch sizes for faster overall processing speed.
    nevents:.pipe.GetIngressEvents[step];
    
    // Process the first set of events produced
    // by the ingress logic to form the initial
    // reset obs seen by the agent.
    .engine.ProcessEvents[nevents];

    // Based upon initial configuration set in .env.Reset
    // this function derives the set of events at the given
    // step that should be inserted into the local state.
    // This also allows for longer temporal steps and larger
    // batch sizes for faster overall processing speed.
    xevents:.pipe.GetEgressEvents[step];

    // Insert the first set of events into the state 
    // such that the initialz observations therin can
    // be derived.
    .state.InsertResultantEvents[xevents];
    
    :.state.obs.GetObs[
        .env.CurrentStep;
        .env.CONF`lookback; // TODO make better
        .env.CONF`accountIds]; // TODO make better
    };



/ Advancing System
// =====================================================================================>

// step rate i.e. by number of events, by interval, by number of events within interval, by number of events outside interval. 

// TODO is done, buffering/historic replay etc.
// TODO add noise events to input i.e. trades etc.
// TODO if any done or no more from loader reset all?
// TODO add environment episode details/invocations.
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
/  @param actions     (Tuple[Action;AgentId]) A List of tuples containing 
/                     agent id and their respective actions (Long)
/  @return          (Tuple[Observation;Reward;Dones]) Returns a tuple of 
/                    agentId, observation, reward, dones for each agent.
.env.Step    :{[actions]
    // TODO format actions
    step:.env.CurrentStep;
    // TODO get current time

    // The adapter takes a given action set and creates
    // the set of events that need to transpire to anneal
    // to this target. The events are then inserted into
    // the pipeline in such a manner that preserves the 
    // temporal coherence of macro actions and the delay
    // in time between the agent and the exchange.
    .adapter.Adapt[.env.CONF`adapterType;idx;actions]; // TODO make better

    // Based upon initial configuration set in .env.Reset
    // this function derives the set of events at the given
    // step that should be executed by the engine.
    // This also allows for longer temporal steps and larger
    // batch sizes for faster overall processing speed.
    nevents:.pipe.GetIngressEvents[step];

    // The engine processes the set of events
    // provided by the pipeline and inserts a set
    // of resultant events into the egress events 
    // table in pipe thereafter. 
    .engine.ProcessEvents[nevents];
    
    // Based upon initial configuration set in .env.Reset
    // this function derives the set of events at the given
    // step that should be inserted into the local state.
    // This also allows for longer temporal steps and larger
    // batch sizes for faster overall processing speed.
    xevents:.pipe.GetEgressEvents[step];
    
    // Events are inserted back into the state such that
    // a set of features can be derived therin
    .state.InsertResultantEvents[xevents];

    // Final aggregated state derivation is performed
    // inorder to derive the observations, dones and 
    // rewards that are to be sent back to the agent.
    aIds:actions[;1]; // Get the account ID's
    obs:.state.obs.GetObs[step; .env.CONF`lookback; aIds]; // TODO make better
    rwd:.state.rew.GetRewards[step; 100; aIds];
    dns:.state.dns.GetDones[]; // TODO move to env and create better!

    // TODO log interval?

    .env.CurrentStep+:1;
    :(obs;rwd;dns);
    };