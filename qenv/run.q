
.rq.Require["./";`CODE];
// TODO listener

.pipe.Ingest[];

.agent.LearnerQueue[];
.agent.DynamicBatcher[];

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
.agent.ActorPool[]

// Beast learner pool


// Testing is done with a single agent