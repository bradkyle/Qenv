
#include <torch/torch.h>

struct Net : torch::nn::Module {
  Net() {
    // Construct and register two Linear submodules.
    fc1 = register_module("fc1", torch::nn::Linear(784, 64));
    fc2 = register_module("fc2", torch::nn::Linear(64, 32));
    fc3 = register_module("fc3", torch::nn::Linear(32, 10));
  }

  // Implement the Net's algorithm.
  torch::Tensor forward(NetInput inputs, torch::Tensor core_state) {
    
    x = inputs.frame;
    x = x.flatten(0,1);
    x = x.to(float) / 255.0; 
    
    // Use one of many tensor manipulation functions.
    x = torch::relu(fc1->forward(x.reshape({x.size(0), 784})));
    x = torch::dropout(x, /*p=*/0.5, /*train=*/is_training());
    x = torch::relu(fc2->forward(x));

    one_hot_last_action = torch::one_hot( // TODO 
      inputs.last_action.view_as(),
      num_actions
      );

    clipped_reward = torch::clamp(inputs.reward, -1, 1).view_as(T*B, 1);
    core_input = torch.cat([x, clipped_reward, one_hot_last_action], -1);

    torch::Tensor core_output;
    if(use_lstm){
      core_input = core_input.view_as(T,B,-1); 
    } else {
      core_output = core_input;
    };

    torch::Tensor policy_logits = 0;
    torch::Tensor baseline = 0;

    return x;
  }

  // Use one of many "standard library" modules.
  torch::nn::Linear fc1{nullptr}, fc2{nullptr}, fc3{nullptr};
};