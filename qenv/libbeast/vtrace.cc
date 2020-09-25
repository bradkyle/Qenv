#pragma once

// TODO check
#include <torch/script.h>
#include <torch/torch.h>


struct VTraceFromLogitsReturns {
    torch::Tensor log_rhos;
    torch::Tensor behavior_action_log_probs;
    torch::Tensor target_action_log_probs;
    torch::Tensor vs;
    torch::Tensor pg_advantages;
};

struct  VTraceReturns {
    torch::Tensor vs;
    torch::Tensor pg_advantages;
};


torch::Tensor action_log_probs(
    torch::Tensor policy_logits, 
    torch::Tensor actions)  {
    return torch::nll_loss(
        torch::log_softmax(policy_logits.flatten(0,-2), -1), 
        actions.flatten(),
        // TODO reduction
    ).negative();
};


vtrace::VTraceReturns from_importance_weights(
    torch::Tensor log_rhos,
    torch::Tensor discounts,
    torch::Tensor rewards,
    torch::Tensor values,
    torch::Tensor bootstrap_value,
    int64_t clip_rho_threshold,
    int64_t clip_pg_rho_threshold){
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

    vs_minus_v_xs = torch.stack(result) // TODO

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

    return vtrace::VTraceReturns{vs, pg_advantages}
};

vtrace::VTraceFromLogitsReturns from_logits(
    torch::Tensor behavior_action_log_probs,
    torch::Tensor target_action_log_probs,
    torch::Tensor actions,
    torch::Tensor discounts,
    torch::Tensor rewards,
    torch::Tensor values,
    torch::Tensor bootstrap_value,
    int64_t clip_rho_threshhold,
    int64_t clip_pg_threshold){

    torch::Tensor target_action_log_probs = action_log_probs(target_policy_logits, actions);
    torch::Tensor behavior_action_log_probs = action_log_probs(behavior_policy_logits, actions);
    torch::Tensor log_rhos = target_action_log_probs - behavior_action_log_probs;

    vtrace::VtraceReturns vtrace_returns = from_importance_weights(
        log_rhos,
        discounts,
        rewards,
        values,
        bootstrap_value,
        clip_rho_threshold,
        clip_pg_rho_threshold);

    return vtrace::VTraceFromLogitsReturns{
        log_rhos, 
        behavior_action_log_probs, 
        target_action_log_probs,
        vtrace_returns.vs,
        vtrace_returns.pg_advantages};

    };

