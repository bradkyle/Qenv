

BINANCE_MM_1 = {
        "name":"bitmex_mm_combined",
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
                "contractType":"LINEAR",
                "quoteAsset":"BTC",
                "settleAsset":"USDT",
                "faceValue":1,
                "maxLeverage":125,
                "minLeverage":0,
                "tickSize":0.01,
                "priceMultiplier":100,
                "cntMultiplier":1000,
                "marginMultiplier":1,
                "maxPrice":1000000,
                "maxOrderQty":10000000,
                "minPrice":0,
                "lotSize":1,  # TODO
                "junkOrderSize":25, # TODO
                "liquidationStrat":[
                    "CANCELORDERS",  # TODO
                    "TAKEOVER"
                ],
                "insuranceFee":"",  # TODO
                "maxOpenOrders":0, 
                "feeTiers":{
                    "kind":"tier",
                    "tiers":(
                        (50,      0.0006,    0.0006,    600),
                        (500,     0.00054,   0.0006,    600),
                        (1500,    0.00048,   0.0006,    600),
                        (4500,    0.00042,   0.0006,    600),
                        (10000,   0.00042,   0.00054,   600),
                        (20000,   0.00036,   0.00048,   600),
                        (40000,   0.00024,   0.00036,   600),
                        (80000,   0.00018,   0.000300,  600),
                        (150000,  0.00012,   0.00024,   600)                    
                    )
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