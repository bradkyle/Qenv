#pragma once

// TODO check
#include <torch/script.h>
#include <torch/torch.h>

bool path_exists(const std::string &s)
{
  struct stat buffer;
  return (stat (s.c_str(), &buffer) == 0);
}

torch::Tensor   compute_baseline_loss(torch::Tensor advantages){
    return 0.5 * torch::sum(advantages.pow(2));
};

torch::Tensor   compute_entropy_loss(torch::Tensor logits){
    torch::Tensor policy = torch::softmax(logits, -1);
    torch::Tensor log_policy = torch::log_softmax(logits, -1);
    return torch::sum(policy*log_policy);
};

torch::Tensor   compute_policy_gradient_loss(
        torch::Tensor logits, 
        torch::Tensor actions, 
        torch::Tensor advantages):{
            torch::Tensor cross_entropy = torch::nll_loss( // TODO check
                torch::log_softmax(),
                actions.flatten(),
                "None" // TODO check
            );

            return torch::sum(
                cross_entropy.view_as(advantages) * 
                advantages.detach()
            );
};

// TODO is run in its own thread
void infer(
    DynamicBatcher inference_batcher
    ){
    torch::NoGradGuard no_grad; // TODO check functionality

    torch::Tensor batch = inference_batcher.get_batch();

    batch.for_each([this, ](const torch::Tensor& tensor){
        batch_inputs = batch.get_inputs();
        batched_env_outputs = batch_inputs[0]; 
        agent_state = batch_inputs[1];

        torch::Tensor frame  = batched_env_outputs[0].to(,non_blocking=true) // TODO args
        torch::Tensor reward = batched_env_outputs[1].to();
        torch::Tensor done  = batched_env_outputs[2].to();
        torch::Tensor agent_state = nest.map();
    });



     // TODO map to device

    // TODO lock get outputs from model
    torch::Tensor outputs = model -> forward(dict(frame=frame, reward=reward, done=done), agent_state); // TODO to tuple?
    // nest map t.cpu()
    batch.set_outputs(outputs);

};

// TORCH_MODULE(Net);

// TODO named tuple analog
void learn( // TODO flags
    BatchingQueue learner_queue,
    Model model,
    Model actor_model,
    // TODO
    ){
    torch::Tensor tensors = nest.map(); // map the tensors to the learner dervice

    // lock.acquire()
    // only one thread learning at a time?
    torch::Tensor outputs = model -> forward(((), intitial_agent_state)); // TODO change type

    if(flags.reward_clipping == "abs_one"){
        clipped_rewards = torch::clamp(env_outputs.rewards, -1, 1); // TODO check
    } else {
        clipped_rewards = env_outputs.rewards;
    };

     // apply discounts to all steps where done = 0b
    discounts = (env_outputs.negative().to(float)) + flags.discounting;

    // TODO
    
    // Derive the vtrace returns from the batches
    torch::Tensor vtrace_returns = vtrace::from_logits(
        actor_outputs.policy_logits,
        learner_outputs.policy_logits,
        actor_outputs.action,
        discounts,
        clipped_rewards,
        learner_outputs.baseline,
        bootstrap_value
    );

    torch::Tensor pg_loss = compute_policy_gradient_loss(
        learner_outputs.policy_logits,
        actor_outputs.action,
        vtrace_returns.pg_advantages
    );

    torch::Tensor baseline_loss = (
        flags.baseline_cost * compute_baseline_loss(
            vtrace_returns.vs - learner_outputs.baseline
        ));

    torch::Tensor entropy_loss  = (
        flags.entropy_cost * compute_entropy_loss(
            learner_outputs.policy_logits
        ));

    torch::Tensor total_loss = (
        pg_loss + baseline_loss + entropy_loss
    );

    // In PyTorch, we need to set the gradients to zero before 
    // starting to do backpropragation because PyTorch accumulates 
    // the gradients on subsequent backward passes.
    optimizer.zero_grad();

    // Run backward pass with autograd
    total_loss.backward(); 

    // 
    torch::nn::utils.clip_grad_norm_(
        model.parameters(), 
        flags.grad_norm_clipping
    ); // todo flag
    
    // Step the optimizer and
    // scheduler respectively
    optimizer.step();
    scheduler.step();

    actor_model.load_state_dict();

};

void train(){
    

    // The queue the learner threads will get their data from.
    // Setting `minimum_batch_size == maximum_batch_size`
    // makes the batch size static.
    auto learner_queue = libtorchbeast::BatchingQueue(
        1, // batch_dim
        flags.batch_size, // minimum batch size
        flags.batch_size, // maximum batch size
        true, // check inputs
        flags.max_learner_queue_size
    );

    // The "batcher" , a queue for the inference call.
    // Will yield "batch" objects with `get_inputs` and
    // `set_outputs` methods.
    // The batch size of the tensors will be dynamic
    auto inference_batcher = libtorchbeast::DynamicBatcher(
        1, // batch_dim
        1, // minimum batch size
        512, // maximum batch size
        100, // timeout ms
        true // check outputs
    );

    // TOOD setup addresses

    // Instantiate the learner device
    auto model = (std::make_shared<Net>(
        flags.num_actions,
        flags.use_lstm
    )).to(flags.learner_device);

    // Instantiate the actor device
    auto actor_model = (std::make_shared<Net>(
        flags.num_actions,
        flags.use_lstm
    )).to(flags.actor_device);

    // The ActorPool that will run `flags.num_actors` many loops.
    ActorPool actors = libtorchbeast::ActorPool(
        flags.unroll_length,
        learner_queue,
        inference_batcher,
        env_server_addresses,
        actor_model.initial_state() // TODO check this
    );

    // Rmsprop 
    optimizer = torch::optim::Optimizer( // TODO change to R
        model.parameters(), // Set the optiizer on the learner model params
        flags.learning_rate,
        flags.momentum,
        flags.epsilon,
        flags.alpha
    );

    // learning rate scheduler // TODO implement

    // load any checkpoints that may exist
    if (path_exists(checkpointpath)){

    };

    // Create Learner threads


    // Create inference threads

    // start actor pool



};