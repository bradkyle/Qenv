
.rq.Require["./";`CODE];
// TODO listener

.pipe.Ingest[];

/ The queue the learner threads will get their data from.
/ Setting `minimum_batch_size == maximum_batch_size`
/ makes the batch size static.
learnerQueue        :.agent.LearnerQueue[];
inferenceBatcher    :.agent.DynamicBatcher[];

// Beast environment/actor pool
// Creates a set of environments that each load a minibatch
// of events into memory and over which a set of actors will
// act i.e. each instance of the environment may have 30 agents
// which will add a sufficient degree of randomization to the
// environment allowing for effective generalization.
// In this sense multiple agents could not only effectively 
// run within the same environment instance but also on the
// same cpu.
// Because the unroll length of the agent in the environment 
// is short in comparison to the batch, the action 
 // Unroll length, learner queue, inference batcher, actor model.initial()
 // num pools, num actors per pool
ActorPool           :.agent.ActorPool[]

// Actor pool thread
// Run the actor pool in a seperate process

// optimizer (RMSProp)

// scheduler

// load checkpoints

// learner threads
/ flags, learner_queue, model, actor_model, optimizer, scheduler, stats, plogger
// learner threads run the learn python method

// inference threads
// flags, inference_batcher, actor_model

// Testing is done with a single agent

Main        :{[]

    actorIds:til[numActors];
    

    };