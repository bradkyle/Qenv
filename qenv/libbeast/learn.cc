#pragma once

// TODO check
#include <torch/script.h>
#include <torch/torch.h>

torch::Tensor compute_baseline_loss(torch::Tensor advantages){
    return 0.5 * torch::sum(advantages.pow(2));
};