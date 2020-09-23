#pragma once

// TODO check
#include <torch/script.h>
#include <torch/torch.h>

torch::Tensor action_log_probs()  {
    return torch::nll_loss(
        torch::log_softmax(policy_logits.flatten(0,-2), -1), 
        actions.flatten(),
        // TODO reduction
    ).negative();
};

from_importance_weights(){
    torch::NoGradGuard no_grad;
    torch::Tensor rhos = log_rhos.exp(); // TODO check

    torch::Tensor clipped_rhos;
    if (clip_rho_threshold) {
        clipped_rhos = torch::clamp(rhos; );
    } else {
        clipped_rhos = rhos; 
    };

    cs = torch::clamp(rhos; );

    // Append bootstrapped value to get  [v1, ..., v_t+1]
    torch::Tensor values_t_plus_1 = torch.cat();
    torch::Tensor deltas = clipped_rhos * (rewards + discounts * values_t_plus_1 - values);

    torch::Tensor acc = torch::zeros_like();
    // TODO impl

    // Add V(x_s) to get v_s.
    torch::Tensor vs = torch::add(vs_minus_v_xs, values);

    // Advantage for policy gradient.
    torch::Tensor vs_t_plus_q = torch.cat(,0);
}

from_logits(){

};