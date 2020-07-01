import collections
from sklearn import preprocessing
import pyarrow.parquet as pq 
import pyarrow as pa
import numpy as np
import empyrical
import wandb
import gym
import json
import time
import logging
from env.state.state import State
from env.engine.engine import Engine
from env.kdb.kdb_client import KDBClient
from env.state.adapters import *
from env.util.config import *
from env.util.logger import *
from gym import spaces

import numpy as np
np.seterr(divide='ignore', invalid='ignore')

# TODO max loss per day
# TODO event hooks
# TODO heartbeat/dead man switch

class Env(gym.Env):
    def __init__(self, *args, **kwargs):
        self.obs_low = kwargs.get('obs_low', 0)
        self.obs_high = kwargs.get('obs_high', 255)
        self.config = Config() 
        self.state = State(
            store=KDBClient(), 
            adapter=DiscreteAdapter,
            engine=Engine(
                config={"allowed_event_types": DEFAULT_ALLOWED_EVENT_TYPES}
            )
        )
        
        # Setup logging
        self.logger = ParquetLogger()
        self.logger.log_config(
            config=self.config
        )

        self._feature_count = len(self.state.reset()) 

    @property
    def action_space(self):
        return self.state.adapter.action_space

    @property
    def observation_space(self):
        return spaces.Box(shape=(self._feature_count, ), low=self.obs_low, high=self.obs_high)

    def reset(self):
        return self.state.reset()

    def step(self, action):
        
        next_obs, reward, done, info = self.state.step(
            action=action
        )
        # logging.error(action)

        if np.isnan(next_obs).any():
            logging.error(next_obs)
            logging.error(self.state.current_step)

        if np.isnan(reward).any():
            logging.error(reward)
            logging.error(self.state.current_step)

        # Log current step state and results
        self.logger.log_state({
            "action":action,
            "next_obs":next_obs,
            "reward":reward,
            "done":done,
            "info":info
        })

        # Return 
        return next_obs, reward, done, info
