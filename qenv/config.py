
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
        "name":"bitmex_mm_1",
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
                    "min":0.01,
                    "max":100,
                },
                "observation":{ # TODO 
                    "window":100,
                },
                "reward":{
                    "kind":"sortino",
                    "window":300,
                },
                "done":{
                    "onLiquidation":True,
                    "balanceCnt":500,

                }
            },
            "engine":{
                # TODO
                "ingress_offsets":{

                },
                "egress_offsets":{
                    
                }
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
                    "kind":"flat",
                    "vol": 0,
                    "makerFee":-0.00025,
                    "takerFee":0.00075,
                    "wdrawFee":0,
                    "dpsitFee":0,
                    "wdrawLimit":0
                },
                "riskTiers":{
                    "kind":"procedural",
                    "baserl":200,
                    "step":100,
                    "maintM":0.0035,
                    "initM":0.01,
                    "maxLev":100,
                    "numTier":40
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