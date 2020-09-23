#pragma once

// TODO check
#include <torch/script.h>
#include <torch/torch.h>

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
void infer(DynamicBatcher inference_batcher){
    torch::NoGradGuard no_grad; // TODO check functionality

    torch::Tensor batch = inference_batcher.get_batch();

    batch_inputs = batch.get_inputs();

    batched_env_outputs = batch_inputs[0]; 
    agent_state = batch_inputs[1];

    torch::Tensor frame  = batched_env_outputs[0].to(,non_blocking=true) // TODO args
    torch::Tensor reward = batched_env_outputs[1].to();
    torch::Tensor done  = batched_env_outputs[2].to();
    torch::Tensor agent_state = nest.map(); // TODO map to device

    // lock get outputs from model
    torch::Tensor outputs = model -> forward(); // TODO to tuple?
    // nest map t.cpu()
    batch.set_outputs(outputs);

};

void learn(BatchingQueue learner_queue){
    torch::Tensor tensors = nest.map(); // map the tensors to the learner dervice

    // lock.acquire()
    // only one thread learning at a time?
    torch::Tensor outputs = model -> forward((, intitial_agent_state));

    discounts = (env_outputs.negative().to(float)) + flags.discounting;

    // TODO

    torch::Tensor vtrace_returns = vtrace::from_logits(
        // TODO
    );

    torch::Tensor pg_loss = compute_policy_gradient_loss(
        // TDOO
    );

    torch::Tensor baseline_loss = (
        baseline_cost * compute_baseline_loss(
            // TODO
        ));

    torch::Tensor entropy_loss  = (
        entropy_cost * compute_entropy_loss(
            // TODO
        ));

    torch::Tensor total_loss = (
        pg_loss + baseline_loss + entropy_loss
    );

    optimizer.zero_grad();
    total_loss.backward();
    torch::nn::utils.clip_grad_norm_(model.parameters(), ); // todo flag
    optimizer.step();
    scheduler.step();

};

void train(){

    auto learner_queue = libtorchbeast::BatchingQueue(
        1, // batch_dim
        flags.batch_size, // minimum batch size
        flags.batch_size, // maximum batch size
        true, // check inputs
        flags.max_learner_queue_size
    );

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

    // TODO set to device

    ActorPool actors = libtorchbeast::ActorPool(
        flags.unroll_length,
        learner_queue,
        inference_batcher,
        env_server_addresses,
        actor_model.initial_state() // TODO check this
    );

    // Rmsprop 
    optimizer = torch::optim::Optimizer(
        model.parameters(), // Set the optiizer on the learner model params
        flags.learning_rate,
        flags.momentum,
        flags.epsilon,
        flags.alpha
    );

    // learning rate scheduler

    // load any checkpoints that may exist

    // Create Learner threads=

    // Create inference threads

    // start actor pool



};