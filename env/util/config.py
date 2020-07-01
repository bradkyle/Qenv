

class Config():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def to_dict(self):
        pass

    def log_config(self, logger):
        pass