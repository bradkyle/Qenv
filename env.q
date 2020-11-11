// Agents ________________________ engine ____
// Pipe ______ exchange events __/          \__ state _____ feature buffer ___ Agent 
//      \_____ other features _____________________________/              \___ Logging

// TODO hooks system

// TODO random funding events per batch
// TODO random settlement events per batch
// TODO random markPrice events per batch
// TODO random priceLimit events per batch
// TODO random (large market buy events)


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
        returnBaseTotal          :`float$()); // TODO more data

.env.CurrentStep:0; // The current step of the environment.
.env.HasReset:0b;

// Derives a dictionary of info pertaining to the agents
// individually and those that are global.
.env.Info        :{[aIds;step]
        :(
            .engine.Info[];
            .state.Info[];
            .env.CurrentStep
        );
    };

/ Env Initialization 
// =====================================================================================>

.env.Init : {[]
    // Initialization of available (levels)/(batches)        

      
    }

// Get Next Events 
// =====================================================================================>

// TODO move to trainer
.env.Populate :{[start;end]
    h:neg hopen master;    
    h(("getEpisodes";start;end);"")
    };

.env.Advance :{[master;ep;kinds;start;end]
    h:neg hopen master;    
    h(("getNextBatch";kinds;ep;start;end);"")
    };

/ Reset Logic
// =====================================================================================>

// TODO reset step count, load first batch etc.
// Resets the state for all agents for whom 
// ids have been included into the ids parameter
// TODO validation
/  @param config     (JSON) A json string containing the env config 
/  @return          (List/Vector) The first observation for each agent
.env.Reset    :{
    // Reset the current step
    step:0;
    .env.CurrentStep:step;
    .env.HasReset:1b;

    // Reset the Engine and 
    // the current state and 
    // return obs
    .state.Reset[];
    nevents: .engine.Reset[];

    // Insert the first set of events into the state 
    // such that the initialz observations therin can
    // be derived.
    .state.InsertEvents[nevents];

    // Return the result to the agent/'s which is a tuple
    // of (agentId; observation; observation_shape; 
    // reward; done; episode_step; episode_return)
    // Final aggregated state derivation is performed
    // inorder to derive the observations, dones and 
    // rewards that are to be sent back to the agent.
    aIds:.conf.c[`env;`accountIds]; // Get the account ID's
    obs:.state.obs.GetObs[step; .conf.c[`env;`obsWindowSize]; aIds]; // TODO make better
    rwd:count[aIds]#0f;
    dns:count[aIds]#0b; // TODO move to env and create better!

    :(obs;rwd;dns);
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

    // Get the next set of 
    // environment events from 
    // the ingest cluster
    ingest:.env.Advance[
        .conf.c[`ingest;`master];
        .env.CurrentEpisode;
        .conf.c[`ingest;`kinds];
        .env.Watermark;
        .env.Watermark+.conf.c[`ingest;`pullWindow];
        actions]; // TODO update to actions above ^ 

    isDone:ingest[0];
    xevents:ingest[1];

    // The adapter takes a given action set and creates
    // the set of events that need to transpire to anneal
    // to this target. The events are then inserted into
    // the pipeline in such a manner that preserves the 
    // temporal coherence of macro actions and the delay
    // in time between the agent and the exchange.
    xevents,:.state.adapter.Adapt[
        .conf.c[`env;`adapterType];
        .conf.c[`env;`encouragement];
        actions]; // TODO update to actions above ^ 

    // Get the events generated by the adapter and send
    // them to the engine for further processing.
    nevents:.engine.Advance[xevents];
    
    // Events are inserted back into the state such that
    // a set of features can be derived therin
    .state.InsertEvents[nevents];

    // Return the result to the agent/'s which is a tuple
    // of (agentId; observation; observation_shape; 
    // reward; done; episode_step; episode_return)
    // Final aggregated state derivation is performed
    // inorder to derive the observations, dones and 
    // rewards that are to be sent back to the agent.
    aIds:actions[;0]; // Get the account ID's
    obs:.state.obs.GetObs[step;.conf.c[`env;`obsWindowSize];aIds]; // TODO make better
    rwd:.state.rew.GetRewards[step;.conf.c[`env;`rewWindowSize];aIds];
    dns:.state.dns.GetDones[step;.conf.c[`env;`dneWindowSize];aIds]; // TODO move to env and create better!

    .env.CurrentStep+:1;
    :(obs;rwd;dns);
    };











