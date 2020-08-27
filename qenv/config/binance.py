

BITMEX_MM_1 = {
        "name":"bitmex_mm_combined",
        "config":{
            "env":{
                "adapter":{
                    "kind":"marketmaker",
                    "mapping":{

                    },
                    "limitSize":0,
                    "marketSize":0,
                    "actionSpace":{
                        
                    }
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
                    "kind":"tier",
                    "tiers":(
                        (50000,       0.004,    0.008,    125),
                        (250000,      0.005,    0.01,     100),
                        (1000000,     0.01,     0.02,     50),
                        (5000000,     0.025,    0.05,     20),
                        (20000000,    0.05,     0.1,      10),
                        (50000000,    0.1,      0.20,     5),
                        (100000000,   0.125,    0.25,     4),
                        (200000000,   0.15,     0.333,    3),
                        (500000000,   0.25,     0.50,     2),
                        (500000000,   0.25,     1.0,      1)
                    )
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