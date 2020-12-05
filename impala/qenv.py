import gym
import numpy as np
from qpython import qconnection



# TODO 
class MultiQenv(gym.Env):
    def __init__(self, pool_size, host, port):
        self.port = port
        self.host = host
        self.pool_size = pool_size
        self.agent_ids = list(range(self.pool_size))

    def _req(self, qry):
        with qconnection.QConnection(host=self.host, port=self.port) as q:
            return q.sendSync(qry)

    @property
    def observation_space(self):
        return gym.spaces.Box(0, 1, shape=(136,))

    @property
    def action_space(self):
        return gym.spaces.Discrete(22)

    # TODO sorted
    def step(self, actions):
        if len(actions)==1:
            action_str = "enlist(0;"+str(actions)+")"
        elif len(actions)>1:
            action_str = "("+(";".join(["("+str(i)+";"+str(a)+")" for i,a in zip(self.agent_ids, actions)]))+")"
        else:
            raise ValueError("No action")
        data = self._req(".env.Step["+action_str+"]")
        return (
              np.reshape(np.array([d[1].tolist() for d in data[0].items()]),(self.pool_size, 136)),
              np.array([d[1][0] for d in data[1].items()]),
              np.array(data[2])
        )

    # TODO sorted
    def reset(self):
        agent_ids_str = "("+";".join([str(a) for a in self.agent_ids])+")"
        data = self._req(".env.Reset["+agent_ids_str+"]")
        return np.reshape(np.array([d[1].tolist() for d in data.items()]),(self.pool_size, 136))
