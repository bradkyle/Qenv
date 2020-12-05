#   Copyright (c) 2018 PaddlePaddle Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import gym
import numpy as np
import parl
import six
import parl
from model import Model
from collections import defaultdict
from agent import Agent
from parl.env.atari_wrappers import wrap_deepmind, MonitorEnv, get_wrapper_by_cls
from parl.env.vector_env import VectorEnv
import random
import qenv
# import qggym

@parl.remote_class
class Actor(object):
    def __init__(self, config, host_conf):
        self.config = config
        self.host = host_conf['host']
        self.port = host_conf['port']

        self.env = qenv.MultiQenv(
              pool_size=self.config['pool_size'],
              host=self.host,
              port=self.port
        )

        self.obs_batch = self.env.reset()

        obs_shape = self.env.observation_space.shape
        act_dim = self.env.action_space.n

        model = Model(act_dim, obs_shape[0])
        algorithm = parl.algorithms.IMPALA(
            model,
            sample_batch_steps=self.config['sample_batch_steps'],
            gamma=self.config['gamma'],
            vf_loss_coeff=self.config['vf_loss_coeff'],
            clip_rho_threshold=self.config['clip_rho_threshold'],
            clip_pg_rho_threshold=self.config['clip_pg_rho_threshold'])
        self.agent = Agent(algorithm, obs_shape, act_dim)

    def sample(self):
        env_sample_data = {}
        for actor_id in range(self.config['pool_size']):
            env_sample_data[actor_id] = defaultdict(list)

        for i in range(self.config['sample_batch_steps']):
            actions, behaviour_logits = self.agent.sample(
                np.stack(self.obs_batch))
            next_obs_batch, reward_batch, done_batch = \
                    self.env.step(actions)

            for actor_id in range(self.config['pool_size']):
                env_sample_data[actor_id]['obs'].append(self.obs_batch[actor_id])
                env_sample_data[actor_id]['actions'].append(actions[actor_id])
                env_sample_data[actor_id]['behaviour_logits'].append(behaviour_logits[actor_id])
                env_sample_data[actor_id]['rewards'].append(reward_batch[actor_id])
                env_sample_data[actor_id]['dones'].append(done_batch[actor_id])

            self.obs_batch = next_obs_batch

        # Merge data of envs
        sample_data = defaultdict(list)
        for actor_id in range(self.config['pool_size']):
            for data_name in [
                    'obs', 'actions', 'behaviour_logits', 'rewards', 'dones'
            ]:
                sample_data[data_name].extend(
                    env_sample_data[actor_id][data_name])

        # size of sample_data: env_num * sample_batch_steps
        for key in sample_data:
            sample_data[key] = np.stack(sample_data[key])

        return sample_data

    def get_metrics(self):
        metrics = defaultdict(list)
        for env in self.envs:
            monitor = get_wrapper_by_cls(env, MonitorEnv)
            if monitor is not None:
                for episode_rewards, episode_steps in monitor.next_episode_results(
                ):
                    metrics['episode_rewards'].append(episode_rewards)
                    metrics['episode_steps'].append(episode_steps)
        return metrics

    def set_weights(self, weights):
        self.agent.set_weights(weights)
