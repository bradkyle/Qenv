// # This file taken from
// #     https://github.com/deepmind/scalable_agent/blob/
// #         cd66d00914d56c8ba2f0615d9cdeefcb169a8d70/vtrace.py
// # and modified.

// # Copyright 2018 Google LLC
// #
// # Licensed under the Apache License, Version 2.0 (the "License");
// # you may not use this file except in compliance with the License.
// # You may obtain a copy of the License at
// #
// #     https://www.apache.org/licenses/LICENSE-2.0
// #
// # Unless required by applicable law or agreed to in writing, software
// # distributed under the License is distributed on an "AS IS" BASIS,
// # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// # See the License for the specific language governing permissions and
// # limitations under the License.
// """Functions to compute V-trace off-policy actor critic targets.

// For details and theory see:

// "IMPALA: Scalable Distributed Deep-RL with
// Importance Weighted Actor-Learner Architectures"
// by Espeholt, Soyer, Munos et al.

// See https://arxiv.org/abs/1802.01561 for the full paper.
// """

// import collections

// import torch
// import torch.nn.functional as F


// VTraceFromLogitsReturns = collections.namedtuple(
//     "VTraceFromLogitsReturns",
//     [
//         "vs",
//         "pg_advantages",
//         "log_rhos",
//         "behavior_action_log_probs",
//         "target_action_log_probs",
//     ],
// )

// VTraceReturns = collections.namedtuple("VTraceReturns", "vs pg_advantages")


// def action_log_probs(policy_logits, actions):
//     return -F.nll_loss( // https://pytorch.org/cppdocs/api/function_namespaceat_1a97f3172f3e4c3b9821eef29a8c321009.html#function-documentation
//         F.log_softmax(torch.flatten(policy_logits, 0, -2), dim=-1),
//         torch.flatten(actions),
//         reduction="none",
//     ).view_as(actions)


// def from_logits(
//     behavior_policy_logits,
//     target_policy_logits,
//     actions,
//     discounts,
//     rewards,
//     values,
//     bootstrap_value,
//     clip_rho_threshold=1.0,
//     clip_pg_rho_threshold=1.0,
// ):
//     """V-trace for softmax policies."""

//     target_action_log_probs = action_log_probs(target_policy_logits, actions)
//     behavior_action_log_probs = action_log_probs(behavior_policy_logits, actions)
//     log_rhos = target_action_log_probs - behavior_action_log_probs
//     vtrace_returns = from_importance_weights(
//         log_rhos=log_rhos,
//         discounts=discounts,
//         rewards=rewards,
//         values=values,
//         bootstrap_value=bootstrap_value,
//         clip_rho_threshold=clip_rho_threshold,
//         clip_pg_rho_threshold=clip_pg_rho_threshold,
//     )
//     return VTraceFromLogitsReturns(
//         log_rhos=log_rhos,
//         behavior_action_log_probs=behavior_action_log_probs,
//         target_action_log_probs=target_action_log_probs,
//         **vtrace_returns._asdict(),
//     )


// @torch.no_grad()
// def from_importance_weights(
//     log_rhos,
//     discounts,
//     rewards,
//     values,
//     bootstrap_value,
//     clip_rho_threshold=1.0,
//     clip_pg_rho_threshold=1.0,
// ):
//     """V-trace from log importance weights."""
//     {
//          torch::NoGradGuard no_grad;
//     }
//     with torch.no_grad():
//         rhos = torch.exp(log_rhos)
//         if clip_rho_threshold is not None:
//              // https://pytorch.org/cppdocs/api/function_namespaceat_1a841f17d40902723ce69e6a9ed8ff2c10.html
//             clipped_rhos = torch.clamp(rhos, max=clip_rho_threshold) 
//         else:
//             clipped_rhos = rhos

//         cs = torch.clamp(rhos, max=1.0) // https://pytorch.org/cppdocs/api/function_namespaceat_1a841f17d40902723ce69e6a9ed8ff2c10.html
//         # Append bootstrapped value to get [v1, ..., v_t+1]
//         values_t_plus_1 = torch.cat( https://pytorch.org/cppdocs/api/function_namespaceat_1a224cc240a8cc8b9ba137d0c92c21a14c.html
//             [values[1:], torch.unsqueeze(bootstrap_value, 0)], dim=0 https://pytorch.org/cppdocs/api/function_namespaceat_1abb85aec9e29fb6176db0004d6d9bcba7.html
//         )
//         deltas = clipped_rhos * (rewards + discounts * values_t_plus_1 - values)

//         acc = torch.zeros_like(bootstrap_value) https://pytorch.org/cppdocs/api/function_namespaceat_1ad7f6f191c9c29c5200b787ad82698818.html
//         result = []
//         for t in range(discounts.shape[0] - 1, -1, -1):
//             acc = deltas[t] + discounts[t] * cs[t] * acc
//             result.append(acc)
//         result.reverse()
//         vs_minus_v_xs = torch.stack(result) https://pytorch.org/cppdocs/api/function_namespaceat_1aa015fb8bf3f3b43644929c5a7b617b47.html?

//         # Add V(x_s) to get v_s.
//         vs = torch.add(vs_minus_v_xs, values) https://pytorch.org/cppdocs/api/function_namespaceat_1a0b94036087f206a574a0d7842dc93f7c.html#exhale-function-namespaceat-1a0b94036087f206a574a0d7842dc93f7c

//         # Advantage for policy gradient.
//         broadcasted_bootstrap_values = torch.ones_like(vs[0]) * bootstrap_value https://pytorch.org/cppdocs/api/function_namespaceat_1aa012efb3f45a87f5c1949796072d61d8.html#exhale-function-namespaceat-1aa012efb3f45a87f5c1949796072d61d8
//         vs_t_plus_1 = torch.cat( https://pytorch.org/cppdocs/api/function_namespaceat_1a224cc240a8cc8b9ba137d0c92c21a14c.html
//             [vs[1:], broadcasted_bootstrap_values.unsqueeze(0)], dim=0
//         )
//         if clip_pg_rho_threshold is not None:
//             clipped_pg_rhos = torch.clamp(rhos, max=clip_pg_rho_threshold) // https://pytorch.org/cppdocs/api/function_namespaceat_1a841f17d40902723ce69e6a9ed8ff2c10.html
//         else:
//             clipped_pg_rhos = rhos
//         pg_advantages = clipped_pg_rhos * (rewards + discounts * vs_t_plus_1 - values)

//         # Make sure no gradients backpropagated through the returned values.
//         return VTraceReturns(vs=vs, pg_advantages=pg_advantages)
