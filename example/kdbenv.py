import collections
from sklearn import preprocessing
import pyarrow.parquet as pq 
import pyarrow as pa
import numpy as np
from empyrical import sortino_ratio
import wandb
import gym
from fastparquet import ParquetFile
import json

#TODO seperate process for logging to wandb
#TODO implement fracdiff
class Env(gym.Env): 
    def __init__(self, state, load=True, *args, **kwargs):
        self.training = kwargs.get('training', False)
        self.logging = kwargs.get('logging', not self.training)
        self.reward_func = kwargs.get('reward_func', None)
        self.state_buffer_size = int(kwargs.get('state_buffer_size', 500))
        self.win_size = int(kwargs.get('win_size', 1))
        self.data_file = kwargs.get('data_file', '../data/test.parquet')
        self.config_file = kwargs.get('config_file', '../config/test.json')
        self.initial_balance = kwargs.get('initial_balance', 10)
        self.annualization = kwargs.get('annualization', 6311385)
        self.scaler_high = int(kwargs.get('scaler_high', 255))
        self.max_steps = int(kwargs.get('max_steps', 1500000))
        self.fracdiff = kwargs.get('fracdiff', False)
        self.min_balance_fraction = kwargs.get('min_balance_fraction', 0.1)
        self.state_type = kwargs.get('state_type', False)
        self.load = load
        self.state = state

        # State buffers
        self.state_buffer = collections.deque(maxlen=self.state_buffer_size)
        self.net_worths = collections.deque(maxlen=self.state_buffer_size)

        # Scaler
        self.scaler = preprocessing.MinMaxScaler(feature_range=(0,self.scaler_high))
        self.kwargs = kwargs
        self.state_cls = state

        if self.load:
            self.df, self.config = self._load()
        else:
            self.config = self._load_config()
        self.state = self.state_cls(**self.kwargs)

    def prepare(self, df, logging=False, max_steps=None):
        self.logging=logging
        if max_steps is not None: self.max_steps = max_steps
        self.df = df 
        self.state = self.state_cls(**self.kwargs)
        return self
        
    @property
    def action_space(self):
        return self.state.action_space()

    @property
    def num_cols(self):
        if self.config is not None and "obs_fields" in self.config:
            return len(self.config["obs_fields"])
        else:
            return len(self.df.columns)

    @property
    def observation_space(self):
        return self.state.observation_space(
            num_cols=self.num_cols, 
            high=self.scaler_high, 
            low=0, 
            win_size=self.win_size
        )

    @property
    def min_balance(self):
        return self.initial_balance*self.min_balance_fraction

    def _load_config(self):
        with open(self.config_file, 'r') as f:
            co = json.load(f)
        return co

    def _load(self):
        df = ParquetFile(self.data_file).to_pandas()
        co = self._load_config()
        return df, co

    @staticmethod
    def from_df(df, state, **kwargs):
        state = state(**kwargs)
        env = Env(state=state, load=False, **kwargs)
        env.df = df
        return env

    def _reward(self):
        """
        Calculates rewards 
        """
        returns = np.diff(self.net_worths)

        if np.count_nonzero(returns) < 1: return 0
        if self.reward_func == 'sortino':
            reward = sortino_ratio(returns, annualization=self.annualization)
        else:
            reward = returns[-1]

        return reward if np.isfinite(reward) else 0 

    def _step_profit(self):
        returns = np.diff(self.net_worths)[-1]
        return returns if np.isfinite(returns) else 0 

    #TODO add fracdiff and other features
    def _next_observation(self):
        obs =  np.nan_to_num(self.state_buffer)
        obs = np.array(self.scaler.fit_transform(obs)[-self.win_size:]).flatten()
        obs = np.nan_to_num(obs)
        return obs 

    def reset(self):
        self.state_buffer.clear()
        self.net_worths.clear()
        self.current_step = 0
        self.state = self.state_cls(**self.kwargs)
        [self._update_state() for _ in range(self.state_buffer_size)]
        return self._next_observation()
