
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
        "name":"bitmex_1",
        "config":{
            "env":{
                "adapter":{
                    "kind":"marketmaker"
                },
                "step":{
                    "kind":"temporal",
                    "interval":5 #Seconds
                },
                "minibatch":{
                    "kind":"chronological",
                    "size":86400 #Seconds
                },
                "balance":{
                    "min":0,
                    "max":100,
                },
                "observation":{
                    "window":100,
                },
                "reward":{
                    "window":300,
                }
            },
            "engine":{
                # TODO
            },
            "instrument":{
                "contractType":"",
                "quoteAsset":"",
                "baseAsset":"",
                "underlyingAsset": "",
                "faceValue":"",
                "maxLeverage":"",
                "minLeverage":"",
                "tickSize":"",
                "priceMultiplier":"",
                "sizeMultiplier":"",
                "maxPrice":"",
                "minPrice":"",
                "lotSize":"",
                "junkOrderSize":"",
                "liquidationStrat":{},
                "insuranceFee":"",
                "maxOpenOrders":0,
                "feeTiers":{

                },
                "riskTiers":{

                }
            },
            "accounts":[
                {
                    "account":{"balance":0,"marginType":"cross","positionType":"combined","leverage":100},
                    "shortInventory":{"amt":0,"leverage":0},
                    "longInventory":{"amt":0,"leverage":0},
                    "bothInventory":{"amt":0,"leverage":0},
                },
                {
                    "account":{"balance":0,"marginType":"cross","positionType":"combined","leverage":100},
                    "shortInventory":{"amt":0,"leverage":0},
                    "longInventory":{"amt":0,"leverage":0},
                    "bothInventory":{"amt":0,"leverage":0},
                },
                {
                    "account":{"balance":0,"marginType":"cross","positionType":"combined","leverage":100},
                    "shortInventory":{"amt":0,"leverage":0},
                    "longInventory":{"amt":0,"leverage":0},
                    "bothInventory":{"amt":0,"leverage":0},
                },
                {
                    "account":{"balance":0,"marginType":"cross","positionType":"combined","leverage":100},
                    "shortInventory":{"amt":0,"leverage":0},
                    "longInventory":{"amt":0,"leverage":0},
                    "bothInventory":{"amt":0,"leverage":0},
                }
            ]
        }
    }
]