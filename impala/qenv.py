import gym
import numpy as np
from qpython import qconnection

class Qenv(gym.Env):
    def __init__(self, host, port):
        self.shape = (256,)
        self.port = port
        self.host = host
        # self.obs_space = self._observation_space()
        # self.act_space = self._action_space()

    def _req(self, qry):
        with qconnection.QConnection(host=self.host, port=self.port) as q:
            return q.sendSync(qry)

    @property
    def observation_space(self):
        self.obs_space

    @property
    def action_space(self):
        self.act_space

    def _observation_space(self):
        data = self._req(".env.FeatureSpace")
        return gym.spaces.Box(0, 1, shape=(data,))

    def _action_space(self):
        data = self._req(".env.ActionSpace")
        return gym.spaces.Discrete(data)

    def step(self, actions):
        data = self._req(".env.Step["+str(actions)+"]")
        return (np.array(data[0]), data[1], data[2], {})

    def reset(self):
        data = self._req(".env.Reset[]")
        return np.array(data)

