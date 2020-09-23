
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
//     cross_entropy = F.nll_loss( https://pytorch.org/cppdocs/api/function_namespaceat_1a97f3172f3e4c3b9821eef29a8c321009.html
//         F.log_softmax(
            // torch.flatten(logits, 0, 1) https://pytorch.org/cppdocs/api/function_namespaceat_1ab8820c4c1715f8ee0882f8919cdf80f2.html
            // , dim=-1),
//         target=torch.flatten(actions, 0, 1), https://pytorch.org/cppdocs/api/function_namespaceat_1ab8820c4c1715f8ee0882f8919cdf80f2.htm
//         reduction="none",
//     )
//     cross_entropy = cross_entropy.view_as(advantages)
//     return torch.sum( https://pytorch.org/cppdocs/api/function_namespaceat_1ae7a6af6ff06d7dec33cbbb63787dc468.html
//          cross_entropy * advantages.detach()
//      )

// Net
// ------------------------------------------------------------------->

// class Net(nn.Module):
//     def __init__(self, num_actions, use_lstm=False):
//         super(Net, self).__init__()
//         self.num_actions = num_actions
//         self.use_lstm = use_lstm

//         self.feat_convs = []
//         self.resnet1 = []
//         self.resnet2 = []

//         self.convs = []

//         input_channels = 4
//         for num_ch in [16, 32, 32]:
//             feats_convs = []
//             feats_convs.append(
//                 nn.Conv2d(
//                     in_channels=input_channels,
//                     out_channels=num_ch,
//                     kernel_size=3,
//                     stride=1,
//                     padding=1,
//                 )
//             )
//             feats_convs.append(nn.MaxPool2d(kernel_size=3, stride=2, padding=1))
//             self.feat_convs.append(nn.Sequential(*feats_convs))

//             input_channels = num_ch

//             for i in range(2):
//                 resnet_block = []
//                 resnet_block.append(nn.ReLU())
//                 resnet_block.append(
//                     nn.Conv2d(
//                         in_channels=input_channels,
//                         out_channels=num_ch,
//                         kernel_size=3,
//                         stride=1,
//                         padding=1,
//                     )
//                 )
//                 resnet_block.append(nn.ReLU())
//                 resnet_block.append(
//                     nn.Conv2d(
//                         in_channels=input_channels,
//                         out_channels=num_ch,
//                         kernel_size=3,
//                         stride=1,
//                         padding=1,
//                     )
//                 )
//                 if i == 0:
//                     self.resnet1.append(nn.Sequential(*resnet_block))
//                 else:
//                     self.resnet2.append(nn.Sequential(*resnet_block))

//         self.feat_convs = nn.ModuleList(self.feat_convs)
//         self.resnet1 = nn.ModuleList(self.resnet1)
//         self.resnet2 = nn.ModuleList(self.resnet2)

//         self.fc = nn.Linear(3872, 256)

//         # FC output size + last reward.
//         core_output_size = self.fc.out_features + 1

//         if use_lstm:
//             self.core = nn.LSTM(core_output_size, 256, num_layers=1)
//             core_output_size = 256

//         self.policy = nn.Linear(core_output_size, self.num_actions)
//         self.baseline = nn.Linear(core_output_size, 1)

//     def initial_state(self, batch_size=1):
//         if not self.use_lstm:
//             return tuple()
//         return tuple(
//             torch.zeros(self.core.num_layers, batch_size, self.core.hidden_size)
//             for _ in range(2)
//         )

//     def forward(self, inputs, core_state):
//         x = inputs["frame"]
//         T, B, *_ = x.shape
//         x = torch.flatten(x, 0, 1)  # Merge time and batch.
//         x = x.float() / 255.0

//         res_input = None
//         for i, fconv in enumerate(self.feat_convs):
//             x = fconv(x)
//             res_input = x
//             x = self.resnet1[i](x)
//             x += res_input
//             res_input = x
//             x = self.resnet2[i](x)
//             x += res_input

//         x = F.relu(x)
//         x = x.view(T * B, -1)
//         x = F.relu(self.fc(x))

//         clipped_reward = torch.clamp(inputs["reward"], -1, 1).view(T * B, 1)
//         core_input = torch.cat([x, clipped_reward], dim=-1)

//         if self.use_lstm:
//             core_input = core_input.view(T, B, -1)
//             core_output_list = []
//             notdone = (~inputs["done"]).float()
//             for input, nd in zip(core_input.unbind(), notdone.unbind()):
//                 # Reset core state to zero whenever an episode ended.
//                 # Make `done` broadcastable with (num_layers, B, hidden_size)
//                 # states:
//                 nd = nd.view(1, -1, 1)
//                 core_state = nest.map(nd.mul, core_state)
//                 output, core_state = self.core(input.unsqueeze(0), core_state)
//                 core_output_list.append(output)
//             core_output = torch.flatten(torch.cat(core_output_list), 0, 1)
//         else:
//             core_output = core_input

//         policy_logits = self.policy(core_output)
//         baseline = self.baseline(core_output)

//         if self.training:
//             action = torch.multinomial(F.softmax(policy_logits, dim=1), num_samples=1)
//         else:
//             # Don't sample when testing.
//             action = torch.argmax(policy_logits, dim=1)

//         policy_logits = policy_logits.view(T, B, self.num_actions)
//         baseline = baseline.view(T, B)
//         action = action.view(T, B)

//         return (action, policy_logits, baseline), core_state


// Inference
// ------------------------------------------------------------------->

// def inference(flags, inference_batcher, model, lock=threading.Lock()):  # noqa: B008
//     with torch.no_grad():
//         for batch in inference_batcher:
//             batched_env_outputs, agent_state = batch.get_inputs()
//             frame, reward, done, *_ = batched_env_outputs
//             frame = frame.to(flags.actor_device, non_blocking=True)
//             reward = reward.to(flags.actor_device, non_blocking=True)
//             done = done.to(flags.actor_device, non_blocking=True) // https://pytorch.org/cppdocs/api/classat_1_1_tensor.html#class-documentation
//             agent_state = nest.map( // nest c 
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


// def learn(
//     flags,
//     learner_queue, // BatchingQueue
//     model,
//     actor_model,
//     optimizer,
//     scheduler,
//     stats,
//     plogger,
//     lock=threading.Lock(),
// ):
//     for tensors in learner_queue: // invokes dequeue many


//         tensors = nest.map(lambda t: t.to(flags.learner_device), tensors) // map each tensor to the learner device

//         batch, initial_agent_state = tensors
//         env_outputs, actor_outputs = batch
//         frame, reward, done, *_ = env_outputs

//         lock.acquire()  # Only one thread learning at a time.
//         learner_outputs, unused_state = model(
//             dict(frame=frame, reward=reward, done=done), initial_agent_state
//         )

//         # Take final value function slice for bootstrapping.
//         learner_outputs = AgentOutput._make(learner_outputs)
//         bootstrap_value = learner_outputs.baseline[-1]

//         # Move from obs[t] -> action[t] to action[t] -> obs[t].
//         batch = nest.map(lambda t: t[1:], batch)
//         learner_outputs = nest.map(lambda t: t[:-1], learner_outputs)

//         # Turn into namedtuples again.
//         env_outputs, actor_outputs = batch
//         env_outputs = EnvOutput._make(env_outputs) // remove
//         actor_outputs = AgentOutput._make(actor_outputs) // remove
//         learner_outputs = AgentOutput._make(learner_outputs) // remove

//         if flags.reward_clipping == "abs_one":
//             clipped_rewards = torch.clamp(env_outputs.rewards, -1, 1)
//         elif flags.reward_clipping == "none":
//             clipped_rewards = env_outputs.rewards

//         discounts = (~(env_outputs.done).byte()).float() * flags.discounting // apply discounts to all steps that aren't done

//         vtrace_returns = vtrace.from_logits(
//             behavior_policy_logits=actor_outputs.policy_logits,
//             target_policy_logits=learner_outputs.policy_logits,
//             actions=actor_outputs.action,
//             discounts=discounts,
//             rewards=clipped_rewards,
//             values=learner_outputs.baseline,
//             bootstrap_value=bootstrap_value,
//         )

//         pg_loss = compute_policy_gradient_loss( // references utility function above
//             learner_outputs.policy_logits, // 
//             actor_outputs.action,
//             vtrace_returns.pg_advantages,
//         )
//         baseline_loss = flags.baseline_cost * compute_baseline_loss(
//             vtrace_returns.vs - learner_outputs.baseline
//         )
//         entropy_loss = flags.entropy_cost * compute_entropy_loss(
//             learner_outputs.policy_logits
//         )

//         total_loss = pg_loss + baseline_loss + entropy_loss

//         optimizer.zero_grad()
//         total_loss.backward()
//         nn.utils.clip_grad_norm_(model.parameters(), flags.grad_norm_clipping)
//         optimizer.step()
//         scheduler.step()

//         actor_model.load_state_dict(model.state_dict())

//         episode_returns = env_outputs.episode_return[env_outputs.done]
//         stats["step"] = stats.get("step", 0) + flags.unroll_length * flags.batch_size
//         stats["episode_returns"] = tuple(episode_returns.cpu().numpy())
//         stats["mean_episode_return"] = torch.mean(episode_returns).item()
//         stats["mean_episode_step"] = torch.mean(env_outputs.episode_step.float()).item()
//         stats["total_loss"] = total_loss.item()
//         stats["pg_loss"] = pg_loss.item()
//         stats["baseline_loss"] = baseline_loss.item()
//         stats["entropy_loss"] = entropy_loss.item()

//         stats["learner_queue_size"] = learner_queue.size()

//         plogger.log(stats)

//         if not len(episode_returns):
//             # Hide the mean-of-empty-tuple NaN as it scares people.
//             stats["mean_episode_return"] = None

//         lock.release()


// Train
// ------------------------------------------------------------------->


// def train(flags):
//     if flags.xpid is None:
//         flags.xpid = "torchbeast-%s" % time.strftime("%Y%m%d-%H%M%S")
//     plogger = file_writer.FileWriter(
//         xpid=flags.xpid, xp_args=flags.__dict__, rootdir=flags.savedir
//     )
//     checkpointpath = os.path.expandvars(
//         os.path.expanduser("%s/%s/%s" % (flags.savedir, flags.xpid, "model.tar"))
//     )

//     if not flags.disable_cuda and torch.cuda.is_available():
//         logging.info("Using CUDA.")
//         flags.learner_device = torch.device("cuda:0")
//         flags.actor_device = torch.device("cuda:1")
//     else:
//         logging.info("Not using CUDA.")
//         flags.learner_device = torch.device("cpu")
//         flags.actor_device = torch.device("cpu")

//     if flags.max_learner_queue_size is None:
//         flags.max_learner_queue_size = flags.batch_size

//     # The queue the learner threads will get their data from.
//     # Setting `minimum_batch_size == maximum_batch_size`
//     # makes the batch size static.
//     learner_queue = libtorchbeast.BatchingQueue(
//         batch_dim=1,
//         minimum_batch_size=flags.batch_size,
//         maximum_batch_size=flags.batch_size,
//         check_inputs=True,
//         maximum_queue_size=flags.max_learner_queue_size,
//     )

//     # The "batcher", a queue for the inference call. Will yield
//     # "batch" objects with `get_inputs` and `set_outputs` methods.
//     # The batch size of the tensors will be dynamic.
//     inference_batcher = libtorchbeast.DynamicBatcher(
//         batch_dim=1,
//         minimum_batch_size=1,
//         maximum_batch_size=512,
//         timeout_ms=100,
//         check_outputs=True,
//     )


// 
//     addresses = []
//     connections_per_server = 1
//     pipe_id = 0
//     while len(addresses) < flags.num_actors:
//         for _ in range(connections_per_server):
//             addresses.append(f"{flags.pipes_basename}.{pipe_id}")
//             if len(addresses) == flags.num_actors:
//                 break
//         pipe_id += 1

//     model = Net(num_actions=flags.num_actions, use_lstm=flags.use_lstm)
//     model = model.to(device=flags.learner_device)

//     actor_model = Net(num_actions=flags.num_actions, use_lstm=flags.use_lstm)
//     actor_model.to(device=flags.actor_device)

//     # The ActorPool that will run `flags.num_actors` many loops.
//     actors = libtorchbeast.ActorPool(
//         unroll_length=flags.unroll_length,
//         learner_queue=learner_queue,
//         inference_batcher=inference_batcher,
//         env_server_addresses=addresses,
//         initial_agent_state=actor_model.initial_state(),
//     )

//     def run():
//         try:
//             actors.run()
//         except Exception as e:
//             logging.error("Exception in actorpool thread!")
//             traceback.print_exc()
//             print()
//             raise e

//     actorpool_thread = threading.Thread(target=run, name="actorpool-thread")

//     optimizer = torch.optim.RMSprop( //https://pytorch.org/cppdocs/api/classtorch_1_1optim_1_1_r_m_sprop.html#class-documentation
//         model.parameters(),
//         lr=flags.learning_rate,
//         momentum=flags.momentum,
//         eps=flags.epsilon,
//         alpha=flags.alpha,
//     )

//     def lr_lambda(epoch):
//         return (
//             1
//             - min(epoch * flags.unroll_length * flags.batch_size, flags.total_steps)
//             / flags.total_steps
//         )

//     scheduler = torch.optim.lr_scheduler.LambdaLR(optimizer, lr_lambda) // C++ doesn't have try find!

//     stats = {}

//     # Load state from a checkpoint, if possible.
//     if os.path.exists(checkpointpath):
//         checkpoint_states = torch.load(
//             checkpointpath, map_location=flags.learner_device
//         )
//         model.load_state_dict(checkpoint_states["model_state_dict"])
//         optimizer.load_state_dict(checkpoint_states["optimizer_state_dict"])
//         scheduler.load_state_dict(checkpoint_states["scheduler_state_dict"])
//         stats = checkpoint_states["stats"]
//         logging.info(f"Resuming preempted job, current stats:\n{stats}")

//     # Initialize actor model like learner model.
//     actor_model.load_state_dict(model.state_dict())

//     learner_threads = [
//         threading.Thread( // TODO find analog for this in c++
//             target=learn,
//             name="learner-thread-%i" % i,
//             args=(
//                 flags,
//                 learner_queue,
//                 model,
//                 actor_model,
//                 optimizer,
//                 scheduler,
//                 stats,
//                 plogger,
//             ),
//         )
//         for i in range(flags.num_learner_threads)
//     ]
    
//     inference_threads = [
//         threading.Thread( // TODO find analog fot this in c++
//             target=inference,
//             name="inference-thread-%i" % i,
//             args=(flags, inference_batcher, actor_model),
//         )
//         for i in range(flags.num_inference_threads)
//     ]

//     actorpool_thread.start()
//     for t in learner_threads + inference_threads:
//         t.start()

//     def checkpoint():
//         if flags.disable_checkpoint:
//             return
//         logging.info("Saving checkpoint to %s", checkpointpath)
//         torch.save( // https://pytorch.org/cppdocs/api/function_namespacetorch_1a99dc9f736064b2179cc58e6436f7a021.html
//             {
//                 "model_state_dict": model.state_dict(),
//                 "optimizer_state_dict": optimizer.state_dict(),
//                 "scheduler_state_dict": scheduler.state_dict(),
//                 "stats": stats,
//                 "flags": vars(flags),
//             },
//             checkpointpath,
//         )

//     def format_value(x):
//         return f"{x:1.5}" if isinstance(x, float) else str(x)

//     try:
//         last_checkpoint_time = timeit.default_timer()
//         while True:
//             start_time = timeit.default_timer()
//             start_step = stats.get("step", 0)
//             if start_step >= flags.total_steps:
//                 break
//             time.sleep(5)
//             end_step = stats.get("step", 0)

//             if timeit.default_timer() - last_checkpoint_time > 10 * 60:
//                 # Save every 10 min.
//                 checkpoint()
//                 last_checkpoint_time = timeit.default_timer()

//             logging.info(
//                 "Step %i @ %.1f SPS. Inference batcher size: %i."
//                 " Learner queue size: %i."
//                 " Other stats: (%s)",
//                 end_step,
//                 (end_step - start_step) / (timeit.default_timer() - start_time),
//                 inference_batcher.size(),
//                 learner_queue.size(),
//                 ", ".join(
//                     f"{key} = {format_value(value)}" for key, value in stats.items()
//                 ),
//             )
//     except KeyboardInterrupt: // TODO replacement
//         pass  # Close properly.
//     else:
//         logging.info("Learning finished after %i steps.", stats["step"])
//         checkpoint()

//     # Done with learning. Stop all the ongoing work.
//     inference_batcher.close()
//     learner_queue.close()

//     actorpool_thread.join()

//     for t in learner_threads + inference_threads:
//         t.join()