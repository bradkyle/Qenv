import os
from env.TrainingEnv import TrainingEnv
from env.state import TypicalMMState
from stable_baselines.common.policies import MlpLnLstmPolicy, CnnPolicy, MlpPolicy, MlpLstmPolicy,CnnLnLstmPolicy, CnnLstmPolicy
from stable_baselines.common.vec_env import SubprocVecEnv, DummyVecEnv
from stable_baselines import A2C, ACKTR, PPO2, DDPG, ACER
import uuid
import wandb
from tscv import GapKFold
from fastparquet import ParquetFile
from tscv import GapKFold
import tensorflow as tf

RID = uuid.uuid1()
def rid(num):
    return str(RID)+"_"+str(num)

env_cls = TrainingEnv(
    TypicalMMState,
    training=True,
    load=False,
    **CONFIG
)

#TODO num envs remains constant
env = SubprocVecEnv([lambda:env_cls for i in range(len(train_dfs))])

model = PPO2( #TODO mlp policy supports testing
    MlpPolicy, 
    env, 
    verbose=1,
    tensorboard_log="./tensorboard",
    nminibatches=1,
    learning_rate=CONFIG["learning_rate"],
)

# Prepare Subproc vec env
train_envs = SubprocVecEnv([lambda: env_cls.prepare(df=train_dfs[idx]) for idx in range(len(train_dfs))])
test_env = DummyVecEnv([lambda: env_cls.prepare(df=test_df, logging=True, max_steps=20000)])

for i in range(epochs):
    wandb.init(
        id=rid(i),
        project=PROJECT,
        config=CONFIG,
        reinit=True,
        group="rid"
    )
    model.set_env(train_envs)
    model.env.reset()
    model.learn(train_steps)
    model.save(os.path.join(wandb.run.dir, "model.h5"))
    model.set_env(test_env)
    obs, done = model.env.reset(), False
    while not done:
        action, _ = model.predict(obs)
        obs, reward, done, info = model.env.step(action)
