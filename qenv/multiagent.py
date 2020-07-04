from gym import Env, spaces
from qpython import qconnection

class MultiAgentEnv():
    '''
    A multi-agent environment consists of some number of Agents.
    '''
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


    def _set_action_space(self):
        pass

    def _set_observation_space(self):
        pass

    def _exec(self, qry):
        with qconnection.QConnection(
            host=self.host, 
            port=self.port, 
            pandas=False) as q:
            return q.sendSync(qry) 

    def step(self):
        res = self._exec(".state.Step[("+";".join(["("+str(x)+";"+str(x*2)+")" for x in range(10)])+")]")

    def reset(self):
        res =  self._exec(".state.Reset[("+";".join(self.account_ids)+")]")