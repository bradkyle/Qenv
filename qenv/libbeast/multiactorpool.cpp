/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <atomic>
#include <chrono>
#include <deque>
#include <future>
#include <memory>
#include <mutex>
#include <optional>
#include <stdexcept>
#include <thread>

#include <grpc++/grpc++.h>

// Enable including numpy via numpy_stub.h.
#define USE_NUMPY 1

#include <ATen/core/ivalue.h>
#include <torch/csrc/autograd/profiler.h>
#include <torch/csrc/utils/numpy_stub.h>
#include <torch/extension.h>
#include <torch/script.h>

#include "nest_serialize.h"
#include "kdbmultienv.grpc.pb.h"
#include "kdbmultienv.pb.h"

#include "../nest/nest/nest.h"
#include "../nest/nest/nest_pybind.h"

namespace py = pybind11;

typedef nest::Nest<torch::Tensor> TensorNest;

TensorNest batch(const std::vector<TensorNest>& tensors, int64_t batch_dim) {
  // TODO(heiner): Consider using accessors and writing slices ourselves.
  nest::Nest<std::vector<torch::Tensor>> zipped = TensorNest::zip(tensors);
  return zipped.map([batch_dim](const std::vector<torch::Tensor>& v) {
    return torch::cat(v, batch_dim);
  });
}

TensorNest batch_all(const std::vector<TensorNest>& tensors, int64_t batch_dim) {
  // TODO(heiner): Consider using accessors and writing slices ourselves.
  nest::Nest<std::vector<torch::Tensor>> zipped = TensorNest::zip(tensors);
  return zipped.map([batch_dim](const std::vector<torch::Tensor>& v) {
    return torch::cat(v, batch_dim);
  });
}

struct ClosedBatchingQueue : public std::runtime_error {
 public:
  using std::runtime_error::runtime_error;
};

// Enable a few standard Python exceptions.
namespace pybind11 {
PYBIND11_RUNTIME_EXCEPTION(runtime_error, PyExc_RuntimeError)
PYBIND11_RUNTIME_EXCEPTION(timeout_error, PyExc_TimeoutError)
PYBIND11_RUNTIME_EXCEPTION(connection_error, PyExc_ConnectionError)
}  // namespace pybind11

struct Empty {};

// Batching Queue
// --------------------------------------------------------------------------->

template <typename T = Empty>
class BatchingQueue {
 public:
  struct QueueItem {
    TensorNest tensors;
    T payload;
  };
  BatchingQueue(int64_t batch_dim, int64_t minimum_batch_size,
                int64_t maximum_batch_size,
                std::optional<int> timeout_ms = std::nullopt,
                bool check_inputs = true,
                std::optional<uint64_t> maximum_queue_size = std::nullopt)
      : batch_dim_(batch_dim),
        minimum_batch_size_(
            minimum_batch_size > 0
                ? minimum_batch_size
                : throw py::value_error("Min batch size must be >= 1")),
        maximum_batch_size_(
            maximum_batch_size >= minimum_batch_size
                ? maximum_batch_size
                : throw py::value_error(
                      "Max batch size must be >= min batch size")),
        timeout_(timeout_ms),
        maximum_queue_size_(maximum_queue_size),
        check_inputs_(check_inputs) {
    if (maximum_queue_size_ != std::nullopt &&
        *maximum_queue_size_ < maximum_batch_size_) {
      throw py::value_error("Max queue size must be >= max batch size");
    }
  }

  int64_t size() const {
    std::unique_lock<std::mutex> lock(mu_);
    return deque_.size();
  }

  void enqueue(QueueItem item) {

    // If the configuration stipulates that
    // the inputs should be checked
    if (check_inputs_) {
      bool is_empty = true;

      item.tensors.for_each([this, &is_empty](const torch::Tensor& tensor) {
        is_empty = false;

        if (tensor.dim() <= batch_dim_) {
          throw py::value_error(
              "Enqueued tensors must have more than batch_dim == " +
              std::to_string(batch_dim_) + " dimensions, but got " +
              std::to_string(tensor.dim()));
        }
      });

      if (is_empty) {
        throw py::value_error("Cannot enqueue empty vector of tensors");
      }
    }

    bool should_notify = false;
    {
      std::unique_lock<std::mutex> lock(mu_);
      // Block when maximum_queue_size is reached.
      while (maximum_queue_size_ != std::nullopt && !is_closed_ &&
             deque_.size() >= *maximum_queue_size_) {
        can_enqueue_.wait(lock);
      }
      if (is_closed_) {
        throw ClosedBatchingQueue("Enqueue to closed queue");
      }
      deque_.push_back(std::move(item));
      should_notify = deque_.size() >= minimum_batch_size_;
    }

    if (should_notify) {
      enough_inputs_.notify_one();
    }
  }

  // enqueue the rollout into the learner queue which 
  // will subsequently update state. In the multiactor
  // scenario whereby in essence multiple perceptual
  // streams have been acquired in the same rollout
  // we would enqueue each instance of rollout into
  // the learner queue
  void enqueue_all(std::vector<QueueItem> items) { // TODO make effective
    for(int i =0;i<items.size(); i++) {
        // If the configuration stipulates that
        // the inputs should be checked
        if (check_inputs_) {
          bool is_empty = true;

          items[i].tensors.for_each([this, &is_empty](const torch::Tensor& tensor) {
            is_empty = false;

            if (tensor.dim() <= batch_dim_) {
              throw py::value_error(
                  "Enqueued tensors must have more than batch_dim == " +
                  std::to_string(batch_dim_) + " dimensions, but got " +
                  std::to_string(tensor.dim()));
            }
          });

          if (is_empty) {
            throw py::value_error("Cannot enqueue empty vector of tensors");
          }
        }

        bool should_notify = false;
        {
          std::unique_lock<std::mutex> lock(mu_);
          // Block when maximum_queue_size is reached.
          while (maximum_queue_size_ != std::nullopt && !is_closed_ &&
                deque_.size() >= *maximum_queue_size_) {
            can_enqueue_.wait(lock);
          }
          if (is_closed_) {
            throw ClosedBatchingQueue("Enqueue to closed queue");
          }
          deque_.push_back(std::move(items[i])); // TODO check if this is correct
          should_notify = deque_.size() >= minimum_batch_size_;
        }

        if (should_notify) {
          enough_inputs_.notify_one();
        }
    }
  }

  // Decueue many gets a set of 
  std::pair<TensorNest, std::vector<T>> dequeue_many() {
    std::vector<TensorNest> tensors;
    std::vector<T> payloads;
    {
      std::unique_lock<std::mutex> lock(mu_);

      bool timed_out = false;
      while (!is_closed_ &&
             (deque_.empty() ||
              (!timed_out && deque_.size() < minimum_batch_size_))) {
        if (timeout_ == std::nullopt) {
          // If timeout_ isn't set, stop waiting when:
          // - queue is closed, or
          // - we have enough inputs inside the queue.
          enough_inputs_.wait(lock);
        } else {
          // If timeout_ is set, stop waiting when:
          // - queue is closed, or
          // - we timed out and have at least one input, or
          // - we have enough inputs in the queue.
          timed_out = (enough_inputs_.wait_for(lock, *timeout_) ==
                       std::cv_status::timeout);
        }
      }

      if (is_closed_) {
        throw py::stop_iteration("Queue is closed");
      }
      const int64_t batch_size =
          std::min<int64_t>(deque_.size(), maximum_batch_size_);
      for (auto it = deque_.begin(), end = deque_.begin() + batch_size;
           it != end; ++it) {
        tensors.push_back(std::move(it->tensors));
        payloads.push_back(std::move(it->payload));
      }
      deque_.erase(deque_.begin(), deque_.begin() + batch_size);
    }
    can_enqueue_.notify_all();
    return std::make_pair(batch(tensors, batch_dim_), std::move(payloads));
  }

  bool is_closed() const {
    std::unique_lock<std::mutex> lock(mu_);
    return is_closed_;
  }

  void close() {
    {
      std::unique_lock<std::mutex> lock(mu_);
      if (is_closed_) {
        throw py::runtime_error("Queue was closed already");
      }
      is_closed_ = true;
      deque_.clear();
    }
    enough_inputs_.notify_all();  // Wake up dequeues.
    can_enqueue_.notify_all();
  }

 private:
  mutable std::mutex mu_;

  const int64_t batch_dim_;
  const uint64_t minimum_batch_size_;
  const uint64_t maximum_batch_size_;
  const std::optional<std::chrono::milliseconds> timeout_;
  const std::optional<uint64_t> maximum_queue_size_;

  std::condition_variable enough_inputs_;
  std::condition_variable can_enqueue_;

  bool is_closed_ = false /* GUARDED_BY(mu_) */;
  std::deque<QueueItem> deque_ /* GUARDED_BY(mu_) */;

  const bool check_inputs_;
};


// Dynamic Batcher
// --------------------------------------------------------------------------->
// Used to batch perceptual streams to the inference worker

class DynamicBatcher {
 public:
  typedef std::promise<std::pair<std::shared_ptr<TensorNest>, int64_t>>
      BatchPromise;

  class Batch {
   public:
    Batch(int64_t batch_dim, TensorNest&& tensors,
          std::vector<BatchPromise>&& promises, bool check_outputs)
        : batch_dim_(batch_dim),
          inputs_(std::move(tensors)),
          promises_(std::move(promises)),
          check_outputs_(check_outputs) {}

    const TensorNest& get_inputs() { return inputs_; }

    void set_outputs(TensorNest outputs) {
      if (promises_.empty()) {
        // Batch has been set before.
        throw py::runtime_error("set_outputs called twice");
      }

      if (check_outputs_) {
        const int64_t expected_batch_size = promises_.size();

        outputs.for_each([this,
                          expected_batch_size](const torch::Tensor& tensor) {
          if (tensor.dim() <= batch_dim_) {
            std::stringstream ss;
            ss << "With batch dimension " << batch_dim_
               << ", output shape must have at least " << batch_dim_ + 1
               << " dimensions, but got " << tensor.sizes();
            throw py::value_error(ss.str());
          }
          if (tensor.sizes()[batch_dim_] != expected_batch_size) {
            throw py::value_error(
                "Output shape must have the same batch "
                "dimension as the input batch size. Expected: " +
                std::to_string(expected_batch_size) +
                ". Observed: " + std::to_string(tensor.sizes()[batch_dim_]));
          }
        });
      }

      auto shared_outputs = std::make_shared<TensorNest>(std::move(outputs));

      int64_t b = 0;
      for (auto& promise : promises_) {
        promise.set_value(std::make_pair(shared_outputs, b));
        ++b;
      }
      promises_.clear();
    }

   private:
    const int64_t batch_dim_;
    const TensorNest inputs_;
    std::vector<BatchPromise> promises_;

    const bool check_outputs_;
  };

  DynamicBatcher(int64_t batch_dim, int64_t minimum_batch_size,
                 int64_t maximum_batch_size,
                 std::optional<int> timeout_ms = std::nullopt,
                 bool check_outputs = true)
      : batching_queue_(batch_dim, minimum_batch_size, maximum_batch_size,
                        timeout_ms),
        batch_dim_(batch_dim),
        check_outputs_(check_outputs) {}

  TensorNest compute(TensorNest tensors) {
    BatchPromise promise;
    auto future = promise.get_future();

    // 
    batching_queue_.enqueue({std::move(tensors), std::move(promise)});

    std::future_status status = future.wait_for(std::chrono::seconds(10 * 60));
    if (status != std::future_status::ready) {
      throw py::timeout_error("Compute timeout reached.");
    }

    const std::pair<std::shared_ptr<TensorNest>, int64_t> pair = [&] {
      try {
        return future.get();
      } catch (const std::future_error& e) {
        if (batching_queue_.is_closed() &&
            e.code() == std::future_errc::broken_promise) {
          throw ClosedBatchingQueue("Batching queue closed during compute");
        }
        throw;
      }
    }();

    // Define a map function that serves to TODO
    return pair.first->map([batch_dim = batch_dim_, batch_entry = pair.second](const torch::Tensor& t) {
        return t.slice(batch_dim, batch_entry, batch_entry + 1);
    });
  }

  // TODO check this
  TensorNest compute_all(TensorNest tensors) {
    BatchPromise promise;
    auto future = promise.get_future();

    // 
    batching_queue_.enqueue_all({std::move(tensors), std::move(promise)});

    std::future_status status = future.wait_for(std::chrono::seconds(10 * 60));
    if (status != std::future_status::ready) {
      throw py::timeout_error("Compute timeout reached.");
    }

    const std::pair<std::shared_ptr<TensorNest>, int64_t> pair = [&] {
      try {
        return future.get();
      } catch (const std::future_error& e) {
        if (batching_queue_.is_closed() &&
            e.code() == std::future_errc::broken_promise) {
          throw ClosedBatchingQueue("Batching queue closed during compute");
        }
        throw;
      }
    }();

    // Define a map function that serves to TODO
    return pair.first->map([batch_dim = batch_dim_, batch_entry = pair.second](const torch::Tensor& t) {
        return t.slice(batch_dim, batch_entry, batch_entry + 1);
    });
  }

  std::shared_ptr<Batch> get_batch() {
    auto pair = batching_queue_.dequeue_many();
    return std::make_shared<Batch>( // Return a torch 
        batch_dim_, 
        std::move(pair.first),
        std::move(pair.second), 
        check_outputs_
    );
  }

  int64_t size() const { return batching_queue_.size(); }

  void close() { batching_queue_.close(); }
  bool is_closed() { return batching_queue_.is_closed(); }

 private:
  BatchingQueue<std::promise<std::pair<std::shared_ptr<TensorNest>, int64_t>>>
      batching_queue_;
  int64_t batch_dim_;

  bool check_outputs_;
};


// Actor Pool
// --------------------------------------------------------------------------->

// MultiActorPool instantiates a set of actors for each instance of env_server_addresses.
// The utilization of multiple actors in this manner is for the effective randomization
// of the market microstructure.



class MultiActorPool {
 public:
  MultiActorPool(int unroll_length, int num_actors, std::shared_ptr<BatchingQueue<>> learner_queue,
            std::shared_ptr<DynamicBatcher> inference_batcher,
            std::vector<kdbmultienv::Address> env_server_addresses,
            TensorNest initial_agent_state)
      : unroll_length_(unroll_length),
        num_actors_(num_actors),
        learner_queue_(std::move(learner_queue)),
        inference_batcher_(std::move(inference_batcher)),
        env_server_addresses_(std::move(env_server_addresses)),
        initial_agent_state_(std::move(initial_agent_state)) {}



  // MAIN LOOP FUNCTION
  // ------------------------------------------------------------->

  void loop(
    int64_t loop_index, 
    const kdbmultienv::Address& address, 
    kdbmultienv::EnvConfig& env_config) {

    // TODO
    std::shared<kdbmultienv::MultiEnv> client = kdbmultienv::MultiEnv(
      address,
      env_config);

    // Retrieve the first step (reset) from the environment
    kdbmultienv::MultiStep multi_step; // TODO change to kdb
    if (!client->Reset(&multi_step)) {
      throw py::connection_error("Initial read failed.");
    }

    // Duplicate the initial agent state (which is passed in as a param)
    // num_actors times, such that multiple perceptual streams can be
    // derived simultaneously.
    TensorNest initial_multi_agent_states = MultiActorPool::replicate_agent_state(
      initial_agent_state_,
      num_actors_);

    // Convert the MultiStep protocol buffers into nest tensors
    // Returns a set of TensorNest where each item maps to a given 
    // agent.
    TensorNest multi_env_outputs = &multi_step.to_nest(); // TODO change to kdb

    // TODO map the compute function to each step pb ?
    // Assert env outputs and initial agent states have same length

    // create a batch vector of env outputs, in a multienv scenario this would
    // entail a set of multiple agent_step pairs i.e. the MultiStep pb
    // TODO make sure outputs size = initial agent states!

    TensorNest compute_inputs(std::vector({
        multi_env_outputs, 
        initial_multi_agent_states
      })); // TODO instantiate for each num_actors/ create zip fn

    // Calls the compute method of the DynamicBatcher defined above 
    // The . (dot) operator and the -> (arrow) operator are used
    // to reference individual members of classes, structures, 
    // and unions. which serves to create the first tensor
    // in a multi agent scenario it would loop over the columns
    // (compute_inputs) of the first row.
    TensorNest all_multi_agent_outputs =
        inference_batcher_->compute_all(compute_inputs);  // Copy.

    // Check this once per thread.
    if (!all_multi_agent_outputs.is_vector()) {
      throw py::value_error("Expected agent output to be tuple");
    }

    // TODO update this for multi agent scenario
    if (all_multi_agent_outputs.get_vector().size() != num_actors_) {
      throw py::value_error(
          "Expected num outputs to be equal to num_actors:" +
          std::to_string(num_actors_) +
          " but got sequence of "
          "length " +
          std::to_string(all_multi_agent_outputs.get_vector().size()));
    }

    // TODO update this for multi agent scenario
    if (all_multi_agent_outputs.get_vector().size() != 2) {
      throw py::value_error(
          "Expected mulit agent output to be (((action, ...), new_state),((action, ...), new_state)) but got "
          "sequence of "
          "length " +
          std::to_string(all_multi_agent_outputs.get_vector().size()));
    }

    // Instantiates a set of num_actors X agent states that
    // are used 
    TensorNest multi_agent_states = all_multi_agent_outputs.get_vector()[1];
    
    // Instantiates a set of num_actors X agent states that
    // are used
    TensorNest multi_agent_outputs = all_multi_agent_outputs.get_vector()[0];

    // TODO update for multiagent env
    if (!multi_agent_outputs.is_vector()) {
      throw py::value_error(
          "Expected first entry of agent output to be a (action, ...) tuple");
    };

    TensorNest last(std::vector({multi_env_outputs, multi_agent_outputs})); // TODO check

    kdbmultienv::MultiAction multi_action;
    std::vector<std::vector<TensorNest>> rollouts; // TODO change to xtensor matrix
    try {
      while (true) {

        // Adds either the first instance of last which
        // is derived above as a vector of the env outputs 
        // and agent outputs 
        // or as the last instance of env outputs and agent
        // outputs derived after the loop.
        rollouts.push_back(std::move(last));

        // Run a loop for a given set unroll length
        // This function in the case of a multi agent environment
        // should invoke a series of agent states inorder to compute
        // a set of resultant actions.
        for (int t = 1; t <= unroll_length_; ++t) {

          // Would have to be an each?
          // for each mapping
          all_multi_agent_outputs = inference_batcher_->compute_all(compute_inputs);
          // Todo check that all agent outputs/values are present.
          
          // Returns a set of num_actors X agent states that are
          // used  
          multi_agent_states = all_multi_agent_outputs.get_vector()[1];
          
          // Returns a set of num_actors  X agent outputs
          multi_agent_outputs = all_multi_agent_outputs.get_vector()[0];

          // multi_agent_outputs must be a tuple/list.
          TensorNest multi_action = multi_agent_outputs.get_vector().front(); // TODO

          // Write the set of actions to the grpc stream
          // That will in turn be ingested by an instance
          // of the environment
          client->Step(multi_action; &multi_step); 

          // Derives a vector of environment outputs for each
          // actor from the protocol buffers referenced // TODO change to q/KDB
          multi_env_outputs = &multi_step.to_nest(); // TODO change to q/kdb+

          // reset the compute inputs for the next iteration
          compute_inputs = TensorNest(std::vector({multi_env_outputs, agent_state}));

          // Reset the last tensor which both serves as the last instance
          // of all rollout steps and the first instance of the next rollout.
          last = TensorNest(std::vector({multi_env_outputs, multi_agent_outputs}));

          // should append to each agents respective column
          rollouts.push_back(std::move(last));
        }

        // Implement this for multiple actors
        last = rollouts.end1();

        learner_queue_->enqueue_all({TensorNest( // TODO
                  std::vector(
                    {
                      batch_all(rollouts, 0),
                      std::move(initial_multi_agent_states)
                    }
                  )
                ),
            });
 
        // Clear the rollout matrix
        rollouts.clear();

        // Set the initial agent states to the current latent
        // state, which will in turn be used for inference in
        // the subsequent step.
        initial_multi_agent_states = multi_agent_states;  // Copy

        // 
        count_ += unroll_length_;
        count_all_ += (unroll_length_*num_actors_);
      }
    } catch (const ClosedBatchingQueue& e) {
      // Thrown when inference_batcher_ and learner_queue_ are closed. Stop.
      kdb::Status status = client->Close();  // TODO change to q/kdb+
      if (!status.ok()) {
        std::cerr << "kdb env failed on finish." << std::endl;
      }
    }
  }

  void run() {
    // std::async instead of plain threads as we want to raise any exceptions
    // here and not in the created threads.
    std::vector<std::future<void>> futures;
    for (int64_t i = 0, size = env_server_addresses_.size(); i != size; ++i) {
      futures.push_back(std::async(
        std::launch::async, 
        &MultiActorPool::loop, 
        this,
        i, 
        env_server_addresses_[i]
      ));
    }
    for (auto& future : futures) {
      // This will only catch errors in the first thread. std::when_any would be
      // good here but it's not available yet. We could also write the
      // condition_variable code ourselves, but let's not do this.
      future.get();
    }
  }

  uint64_t count() const { return count_; }

  static TensorNest replicate_agent_state(TensorNest agent_state, int num_actors){
    // TODO?
  };

  std::vector<TensorNest> derive_multistep_from_result(kdb::Result& result){ // TODO errors?
        K kres  = result.get_res();
        std::vector<TensorNest> tensors;
        for (int i=0; i< kres->n; i++) {
            K step = kK(kres)[0]; // TODO
            tensors.push_back(TensorNest(std::vector({ // omits agentId
                std::move(TensorNest(torch::tensor(kF(kK(step)[1]), {torch::kFloat64}))), // observation // TODO
                std::move(TensorNest(torch::tensor(kK(step)[2]->f, {torch::kFloat64}))), // reward // TODO change to long
                std::move(TensorNest(torch::tensor(kK(step)[3]->g, {torch::kBool}))), // done
                std::move(TensorNest(torch::tensor(kK(step)[4]->f, {torch::kFloat64}))), // episode_step TODO change // TODO change to long
                std::move(TensorNest(torch::tensor(kK(step)[5]->f, {torch::kFloat64})))  // episode_return 
                })));
        };
        return tensors;
  };
  
 private:
  std::atomic_uint64_t count_;
  std::atomic_uint64_t count_all_;

  const int unroll_length_;
  std::shared_ptr<BatchingQueue<>> learner_queue_;
  std::shared_ptr<DynamicBatcher> inference_batcher_;
  const std::vector<kdbmultienv::Address> env_server_addresses_;
  TensorNest initial_agent_state_;
};
