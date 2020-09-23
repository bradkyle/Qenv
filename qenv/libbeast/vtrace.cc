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
    torch::Tensor broadcasted_bootstrap_values = torch::ones_like(vs[0]) * bootstrap_value;
    torch::Tensor vs_t_plus_q = torch.cat([vs[1:], broadcasted_bootstrap_values.unsqueeze(0)],0);

    torch::Tensor clipped_rhos;
    if (clip_pg_rho_threshold) {
        clipped_pg_rhos = torch.clamp(rhos, max=clip_pg_rho_threshold); 
    } else {
        clipped_pg_rhos = rhos;
    };
    torch::Tensor pg_advantages = clipped_pg_rhos * (rewards + discounts * vs_t_plus_1 - values);

    // return VTraceReturns(vs=vs, pg_advantages=pg_advantages)
}

from_logits(){
    torch::Tensor target_action_log_probs = action_log_probs(target_policy_logits, actions);
    torch::Tensor behavior_action_log_probs = action_log_probs(behavior_policy_logits, actions);
    torch::Tensor log_rhos = target_action_log_probs - behavior_action_log_probs;

    VtraceReturns vtrace_returns = from_importance_weights(
        log_rhos,
        discounts,
        rewards,
        values,
        bootstrap_value,
        clip_rho_threshold,
        clip_pg_rho_threshold
    );
    //     return VTraceFromLogitsReturns(
//         log_rhos=log_rhos,
//         behavior_action_log_probs=behavior_action_log_probs,
//         target_action_log_probs=target_action_log_probs,
//         **vtrace_returns._asdict(),
//     )
};