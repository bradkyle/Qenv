


OKEX_MM_1 = {
        "name":"okex_mm_combined",
        "config":{
            "env":{
                "adapter":{
                    "kind":"MARKETMAKER",
                    "mapping":{

                    },
                    "limitSize":0,
                    "marketSize":0,
                    "actionSpace":{
                        
                    }
                },
                "step":{
                    "kind":"TEMPORAL",
                    "interval":5 #Seconds
                },
                "minibatch":{
                    "kind":"CHRONOLOGICAL",
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
                    "kind":"SORTINO",
                    "window":300,
                },
                "done":{
                    "onLiquidation":True,
                    "balanceCnt":500,
                }
            },
            "engine":{
                # TODO
                "loadShedding":{

                },
                "ingress_offsets":{

                },
                "egress_offsets":{

                }
            },
            "orderBook":{
                "maxUpdateDrift":30,
            },
            "instrument":{
                "contractType":"INVERSE",
                "quoteAsset":"USD",
                "settleAsset":"XBT",
                "faceValue":1,
                "maxLeverage":100,
                "minLeverage":0,
                "tickSize":0.5,
                "priceMultiplier":10,
                "cntMultiplier":0,
                "marginMultiplier":1e8,
                "maxPrice":1000000,
                "maxOrderQty":10000000,
                "minPrice":0,
                "lotSize":1,
                "junkOrderSize":25,
                "liquidationStrat":[
                    "CANCELORDERS",
                    "TAKEOVER"
                ],
                "insuranceFee":"",
                "maxOpenOrders":100,
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
            "accounts":[ # TODO add more i.e. 10
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