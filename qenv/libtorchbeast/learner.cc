
// import torch
// import libtorchbeast
// from torch import nn
// from torch.nn import functional as F
// from torchbeast.core import file_writer
// from torchbeast.core import vtrace


// Utilities
// ------------------------------------------------------------------->

// def compute_baseline_loss(advantages):
    // return 0.5 * torch.sum(advantages ** 2)

// def compute_entropy_loss(logits):
//     """Return the entropy loss, i.e., the negative entropy of the policy."""
//     policy = F.softmax(logits, dim=-1)
//     log_policy = F.log_softmax(logits, dim=-1)
//     return torch.sum(policy * log_policy)

// def compute_policy_gradient_loss(logits, actions, advantages):
//     cross_entropy = F.nll_loss(
//         F.log_softmax(torch.flatten(logits, 0, 1), dim=-1),
//         target=torch.flatten(actions, 0, 1),
//         reduction="none",
//     )
//     cross_entropy = cross_entropy.view_as(advantages)
//     return torch.sum(cross_entropy * advantages.detach())

// Net
// ------------------------------------------------------------------->


// Inference
// ------------------------------------------------------------------->

// def inference(flags, inference_batcher, model, lock=threading.Lock()):  # noqa: B008
//     with torch.no_grad():
//         for batch in inference_batcher:
//             batched_env_outputs, agent_state = batch.get_inputs()
//             frame, reward, done, *_ = batched_env_outputs
//             frame = frame.to(flags.actor_device, non_blocking=True)
//             reward = reward.to(flags.actor_device, non_blocking=True)
//             done = done.to(flags.actor_device, non_blocking=True)
//             agent_state = nest.map(
//                 lambda t: t.to(flags.actor_device, non_blocking=True), agent_state
//             )
//             with lock:
//                 outputs = model(
//                     dict(frame=frame, reward=reward, done=done), agent_state
//                 )
//             outputs = nest.map(lambda t: t.cpu(), outputs)
//             batch.set_outputs(outputs)



// Learn
// ------------------------------------------------------------------->