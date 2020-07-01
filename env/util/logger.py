
class Logger():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def log_config(self, config):
        raise NotImplementedError

    def log_state(self, state):
        raise NotImplementedError

class ParquetLogger():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def log_config(self, config):
        pass

    def log_state(self, state):
        pass

class WandbLogger():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def log_config(self, config):
        pass

    def log_state(self, state):
        pass

class VisualLogger():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

class KDBLogger():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)