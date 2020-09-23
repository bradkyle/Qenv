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

    inference_batcher.get_batch();
};

void learn(BatchingQueue learner_queue){
    torch::Tensor tensors = 0;

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
    learner_queue = libtorchbeast::BatchingQueue(

    );

    inference_batcher = libtorchbeast::DynamicBatcher(

    );

    // TOOD setup addresses

    auto model = std::make_shared<Net>(); 
    // TODO set to device

    auto actor_model = std::make_shared<Net>(); 
    // TODO set to device

    actors = libtorchbeast::ActorPool(

    );

    // Rmsprop 

    // learning rate scheduler

    // load any checkpoints that may exist

    // Create Learner threads=

    // Create inference threads

    // start actor pool



};