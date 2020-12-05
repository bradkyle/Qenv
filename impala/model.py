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
import numpy as np
import paddle.fluid as fluid
import parl
from parl import layers
from paddle.fluid.param_attr import ParamAttr


class Model(parl.Model):
    def __init__(self, act_dim, obs_dim):
        self.obs_dim = obs_dim
        self.act_dim = act_dim
        hid1_size = obs_dim * 10
        hid3_size = act_dim * 10
        hid2_size = int(np.sqrt(hid1_size * hid3_size))

        self.fc1 = layers.fc(size=hid1_size, act='tanh')
        self.fc2 = layers.fc(size=hid2_size, act='tanh')
        self.fc3 = layers.fc(size=hid3_size, act='tanh')
        self.fc4 = layers.fc(size=act_dim, act='tanh')

        self.value_fc = layers.fc(
            size=1,
            param_attr=ParamAttr(initializer=fluid.initializer.Normal()))

    def policy(self, obs):
        """
        Args:
            obs: A float32 tensor of shape [B, C, H, W]
        Returns:
            policy_logits: B * ACT_DIM
        """
        obs = obs / 255.0
        hid1 = self.fc1(obs)
        hid2 = self.fc2(hid1)
        hid3 = self.fc3(hid2)
        policy_logits = self.fc4(hid3)
        return policy_logits

    def value(self, obs):
        """
        Args:
            obs: A float32 tensor of shape [B, C, H, W]
        Returns:
            value: B
        """
        obs = obs / 255.0
        hid1 = self.fc1(obs)
        hid2 = self.fc2(hid1)
        hid3 = self.fc3(hid2)
        value = self.value_fc(hid3)
        value = layers.squeeze(value, axes=[1])
        return value
