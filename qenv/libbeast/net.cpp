
#include <torch/torch.h>

struct NetInput {
  torch::Tensor frame;
  torch::Tensor reward;
  torch::tensor done;
}

// TODO centralize
typedef nest::Nest<torch::Tensor> TensorNest;

struct Net : torch::nn::Module {
  Net() {
    // Construct and register two Linear submodules.
    fc1 = register_module("fc1", torch::nn::Linear(784, 64));
    fc2 = register_module("fc2", torch::nn::Linear(64, 32));
    fc3 = register_module("fc3", torch::nn::Linear(32, 10));
  }

  TensorNest initial_state(int batch_size=1) {
     if (!use_lstm_){
       return TensorNest(std::vector({}));
     } else {
       TensorNest(std::vector({
          torch::zeros(core_num_layers_, batch_size, core_hidden_layers_), //TODO simplify
          torch::zeros(core_num_layers_, batch_size, core_hidden_layers_)
       });
     }
  }

  // Implement the Net's algorithm.
  TensorNest forward(TensorNest inputs, TensorNest core_state) {
    
    x = inputs.frame;
    x = x.flatten(0,1);
    x = x.to(float) / 255.0; 
    
    // Use one of many tensor manipulation functions.
    x = torch::relu(fc1->forward(x.reshape({x.size(0), 784})));
    x = torch::dropout(x, /*p=*/0.5, /*train=*/is_training());
    x = torch::relu(fc2->forward(x));

    torch::Tensor one_hot_last_action = torch::one_hot( // TODO 
      inputs.last_action.view_as(),
      num_actions
      );

    torch::Tensor clipped_reward = torch::clamp(inputs.reward, -1, 1).view_as(T*B, 1);
    torch::Tensor core_input = torch.cat([x, clipped_reward, one_hot_last_action], -1);

    torch::Tensor core_output;
    if(use_lstm_){
      core_input = core_input.view_as(T,B,-1).unbind();
      torch::Tensor not_done = inputs.done.negative().to(torch::kFloat64).unbind();
      // TDOO assert tensors same lenght
      std::vector<torch::Tensor> core_output_vector = std::vector({});
      for (int i=0;i<core_input.size();i++) {

      };
      core_output = torch::flatten(torch::createPyObject(), );
    } else {
      core_output = core_input;
    };

    torch::Tensor policy_logits = 0;
    torch::Tensor baseline = 0;

    torch::Tensor action;
    if(training_){
        action = torch::multinomial(); // TODO
    } else {
        action = torch::argmax();
    };

    return x;
  }

  // Use one of many "standard library" modules.
  torch::nn::Linear fc1{nullptr}, fc2{nullptr}, fc3{nullptr};
};