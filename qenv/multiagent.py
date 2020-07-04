from gym import Env, spaces
from qpython import qconnection

class MultiAgentEnv():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


    def _exec(self, qry):
        with qconnection.QConnection(
            host=self.host, 
            port=self.port, 
            pandas=False) as q:
            return q.sendSync(qry) 

    def _set_action_space(self):
        pass

    def _set_observation_space(self):
        pass

    def step(self):
        pass

    def reset(self):
        pass