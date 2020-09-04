

.env.BatchSelectMethod:`.env.BATCHSELECTMETHOD$`CHRONOLOGICAL;
.env.BatchInterval:`minute$5;
.env.BatchSize: 50;

.env.PrimeBatchNum:0; // How many events are used to prime the engine with state.
.env.UseFeatures:0b;
.env.EventPath:`path;
BATCHSELECTMETHOD :`CHRONOLOGICAL`RANDOM`CURRICULUM; 
WINDOWKIND :  `TEMPORAL`EVENTCOUNT`THRESHCOUNT`TRADECOUNT`PRICECHANGE;   
.env.EventSource:`events;
.env.WindowKind:`.env.WINDOWKIND$`TEMPORAL;
.env.MaxEpisodes:1000;
.env.CurrentEpisde:0;
// TODO episodes

Episode :(
        [episodeId               :`long$()]
        batchIdx                 :`long$();
        batchStart               :`datetime$();
        batchEnd                 :`datetime$();                        
        rewardTotal              :`float$();
        returnQuoteTotal         :`float$();
        returnBaseTotal          :`float$());

// Insert a set of initial events indicative of the state 
// before the first step into the state buffer for "Priming"
nevents:raze flip'[value[.env.PrimeBatchNum#.env.EventBatch]]; //TODO derive from config


// Set the current Event batch to exclude the event batches
// used in the priming of the state.
.env.EventBatch:(.env.PrimeBatchNum)_(.env.EventBatch); // Shift events
.env.StepIndex:(.env.PrimeBatchNum)_(.env.StepIndex); // Shift events

.ingress.Reset  :{[]


    };

csi:count[.env.StepIndex];
nevents:flip[.env.EventBatch@idx];
idx:.env.StepIndex@step;
