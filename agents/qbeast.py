

class QNet(nn.Module):
    def __init__(self, observation_shape, num_actions, use_lstm=False):
        super(QNet, self).__init__()
        self.observation_shape = observation_shape
        self.num_actions = num_actions


def create_env(flags):
    return qenv_wrappers.wrap_pytorch(
        qenv_wrappers.wrap_deepmind(
            qenv_wrappers.make_qenv(flags.env),
            clip_rewards=False,
            frame_stack=True,
            scale=False,
        )
    )