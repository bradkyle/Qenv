
class ConfigDatum():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

class Account():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

class Inventory():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

class Instrument():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

class Engine():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

class Env():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


[
    {
        "name":"",
        "config":{
            "env":{
                "rewardkind":"sortino",
                "adapterKind":"marketmaker",
                "windowing":{
                    "kind":"temporal",
                    "interval":5 #Seconds
                },
                "minibatch":{
                    "kind":"chronological",
                    "size":86400 #Seconds
                }
            },
            "engine":{
                # TODO
            },
            "instrument":{
                "quoteAsset":"",
                "baseAsset":"",
                "underlyingAsset": "",
                "faceValue":"",
                "maxLeverage":"",
                "minLeverage":"",
                ""
            },
            "accounts":[
                {
                    "account":{},
                    "shortInventory":{},
                    "longInventory":{},
                    "bothInventory":{}
                },
                {
                    "account":{},
                    "shortInventory":{},
                    "longInventory":{},
                    "bothInventory":{}
                },
                {
                    "account":{},
                    "shortInventory":{},
                    "longInventory":{},
                    "bothInventory":{}
                },
                {
                    "account":{},
                    "shortInventory":{},
                    "longInventory":{},
                    "bothInventory":{}
                }
            ]
        }
    }
]