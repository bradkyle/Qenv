import gym
import numpy as np
from qpython import qconnection

class Qenv(gym.Env):
    def __init__(self, host, port):
        self.shape = (256,)
        self.port = port
        self.host = host

    @property
    def observation_space(self):
        return gym.spaces.Box(0, 255, self.shape)

    @property
    def action_space(self):
        return gym.spaces.Discrete(17)

    def step(self, actions):
        with qconnection.QConnection(host=self.host, port=self.port) as q:
            data = q.sendSync(".env.Step["+str(actions)+"]")
        return (np.array(data[0]), data[1], data[2], {})

    def reset(self):
        with qconnection.QConnection(host=self.host, port=self.port) as q:
            data = q.sendSync(".env.Reset[]")
        return np.array(data)

