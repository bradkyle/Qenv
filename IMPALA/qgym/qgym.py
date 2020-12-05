# PongNoFrameskip-v4
# pip install pybox2d
# 'LunarLander-v2'
# env = gym.make('PongNoFrameskip-v4')
import gym

class Server(gym.Env):
    def __init__(self, env_name='PongNoFrameskip-v4'):
        self.env = gym.make(env_name)
        self.episode_step = 0;
        self.episode_reward = 0;
        self.reset()

    @property
    def observation_space(self):
        return self.env.observation_space

    @property
    def action_space(self):
        return self.env.action_space

    def reset(self):
        obs = self.env.reset()
        episode_step = self.episode_step
        episode_rewards = self.episode_reward
        self.episode_step=0
        self.episode_reward=0
        return (
            obs.tolist(),
            0,
            False,
            {}
        )

    def step(self, action):
        obs, rew, dne, ifo = self.env.step(action)
        self.episode_reward += rew
        self.episode_step += 1 
        if dne:
            return self.reset()
        else:
            return (
                obs.tolist(),
                rew,
                dne,
                {}
            )

    def close():
        pass


server = Server()

def reset():
    return server.reset()

def step(action):
    return server.step(action)
