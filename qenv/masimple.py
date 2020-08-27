from gym import Env, spaces
from qpython import qconnection
import numpy as np
import json

class SimpleAgent():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


class MultiAgentEnv():
    '''
    A multi-agent environment consists of some number of Agents.
    '''
    def __init__(self, num_agents, config):
        self.n_agents=num_agents
        self.account_ids=list(range(self.n_agents))
        self.config=config

       

    def _set_action_space(self):
        self.action_space = spaces.Tuple(
            [self.agents[i].action_space for i in range(self.n_agents)]
        )

    def _set_observation_space(self):
        high = np.inf * np.ones(5)
        low = -high
        self.observation_space = spaces.Tuple(
            [spaces.Box(low,high) for i in range(self.n_agents)]
        )

    def _exec(self, qry):
        with qconnection.QConnection(
            host=self.host, 
            port=self.port, 
            pandas=False) as q:
            return q.sendSync(qry) 

    def _step(self, actions):
        res = self._exec(".state.Step[("+list(zip(actions,self.account_ids))+")]")
        return res

    def reset(self):
        res = self._exec(".state.Config["+
            json.dumps(self.config)
        +"]")
        return res