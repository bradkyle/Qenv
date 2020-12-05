import gym
import numpy as np
from qpython import qconnection

# TODO 
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
        return gym.spaces.Box(0, 1, shape=(136,))

    @property
    def action_space(self):
        return gym.spaces.Discrete(22)

    def step(self, actions):
        data = self._req(".env.Step[enlist(0;"+str(actions)+")]")
        return (np.array(data[0].items()[0][1].tolist()), data[1].items()[0][0][0], data[2][0], {})

    def reset(self):
        data = self._req(".env.Reset[]")
        return np.array(data.items()[0][1].tolist())

class QMultiEnv(gym.Env):
    def __init__(self, host, port):
        pass
