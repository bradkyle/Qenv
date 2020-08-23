\l adapter.q 
// TODO CHANGE EVENTS TO LISTS INSTEAD OF DICTIONARIES

// Agent ________________________ engine ____
// Pipe ______ exchange events __/          \__ state _____ feature buffer ___ Agent 
//      \_____ other features _____________________________/
// TODO hooks system

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
        numAgentSteps       : `long$());

WINDOWKIND :  `TEMPORAL`EVENTCOUNT`THRESHCOUNT;   

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

// Main Callable functions
// --------------------------------------------------->

// config recieves a json representation of the given config
// that pertains to the initial environment state, agent state 
// aswell as the strategy for which steps will take place.
// utilizes the .j (json) namespace to process a json representation
// sent to it.
Config      :{[config]

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
    // TODO config engine

    };

// Derives a dictionary of info pertaining to the agents
// individually and those that are global.
Info        :{[aIds;step]
        :(
            .engine.Info[];
            .state.Info[];
            .env.CurrentStep
        );
    };


/ GenNextEventBatch
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
PChoice {[n;k;p]k?raze ("j"$p*10 xexp max count each("."vs'string p)[;1])#'til n};

// Batches are synonymous with episode // TODO train test split
GenNextEpisode    :{
    // If the batch idxs which correspond with the length of an episode are
    // not set create the set of batch idxs.
    // set the batch window intervals above.

    // TODO check day is divisible by batch size? 
    // TODO missing events at start of events
    if[count[.env.BatchIndex]<1;[ 
        bidx:select start:(date+(.env.BatchSize xbar `minute$time)) from .env.EventSource;
        bidx:update end:next start from bidx;
        bidx:update end:first[(select last time from events)`time]^end from bidx;
        .env.BatchIndex:bidx;
    ]];

    nextBatch:$[
       (.env.BatchSelectMethod=`.env.BATCHSELECTMETHOD$`RANDOM);
        [.env.BatchIndex@rand count[bidx]];
       (.env.BatchSelectMethod=`.env.BATCHSELECTMETHOD$`CHRONOLOGICAL);
        [.env.BatchIndex@(.env.CurrentEpisde mod count[.env.BatchIndex])];
       (.env.BatchSelectMethod=`.env.BATCHSELECTMETHOD$`CURRICULUM); // TODO
        ['NOTIMPLEMENTED];
        ['INVALID_BATCH_SELECTION_METHOD]
    ];

     $[(.env.WindowKind=`.env.WINDOWKIND$`TEMPORAL);
            [.env.EventBatch:select time, intime, kind, cmd, datum by grp:5 xbar `second$time from .env.events where time within value[nextBatch]];
       (.env.WindowKind=`.env.WINDOWKIND$`EVENTCOUNT);
            [.env.EventBatch:select time, intime, kind, cmd, datum by grp:5 xbar i from .env.events where time within value[nextBatch]];
       (.env.WindowKind=`.env.WINDOWKIND$`THRESHCOUNT);
            ['NOTIMPLEMENTED];
       ['INVALID_WINDOWING_METHOD]
     ];

      // TODO insert feature batch.
      // TODO upsert new episode with event count etc.

     .state.StepIndex: key .env.EventBatch;
    };

/ Reset Logic
// =====================================================================================>

// TODO reset step count, load first batch etc.
// Resets the state for all agents for whom 
// ids have been included into the ids parameter
/ ResetAgents       :{[aIds] // TODO make into accountConfigs, TODO load initial events for given buffer time
/     // Reset public singletons
/     .engine.ResetAgents[aIds];
/     .state.ResetAgents[aIds];
/     };

// TODO validation
Reset    :{
    .engine.Reset[];
    .state.Reset[];

    // Loads the next set of events from 
    // HDB into memory
    .env.GenNextEpisode[]; // TODO check that length is greater than config

    nvents:.env.PrimeBatchNum#.env.EventBatch;
    aevents:.env.SetupEvents[];
    xevents:.engine.ProcessEvents[(nevents,aevents)];
    .state.InsertResultantEvents[xevents];

    aids:actions[;1];
    obs:.state.PrimeFeatures[aids; 100; 0];
    .env.EventBatch:.env.PrimeBatchNum_.env.EventBatch;
    .env.StepIndex:.env.PrimeBatchNum_.env.StepIndex;

    .env.CurrentStep+:1;
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
Step    :{[actions]
    // TODO format actions
    step:.env.CurrentStep;
    // Advances the current state of the environment
    $[((step+1)<count[.env.StepIndex]);
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

            :(obs;rwd;ifo);
        ];
        [
            
        ]
    ];
 
    .env.CurrentStep+:1;
    

    };