import gym
import numpy as np
from qpython import qconnection



# TODO 
class MultiQenv(gym.Env):
    def __init__(self, num_actors, host, port):
        self.shape = (256,)
        self.port = port
        self.host = host
        self.num_actors = num_actors
        self.agent_ids = list(range(self.num_actors))

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
        if len(actions)==1:
            action_str = "enlist(0;"+str(actions)+")"
        elif len(actions)>1:
            action_str = "("+(";".join(["("+str(i)+";"+str(a)+")" for i,a in zip(self.agent_ids, actions)]))+")"
        else:
            raise ValueError("No action")
        data = self._req(".env.Step["+str()+"]")
        return (np.array(data[0].items()[0][1].tolist()), data[1].items()[0][0][0], data[2][0], {})

    def reset(self):
        agent_ids_str = "("+";".join([str(a) for a in self.agent_ids])+")"
        data = self._req(".env.Reset["+agent_ids_str+"]")
        return np.array(data.items()[0][1].tolist())

