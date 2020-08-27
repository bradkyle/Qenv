


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
                    "tiers":( #TODO
                        50000     0.005    0.01    100;
                        300000    0.01     0.015   66.66;
                        550000    0.015    0.02    50;
                        800000    0.02     0.025   40;
                        1050000   0.025    0.03    33.3;
                        1300000   0.03     0.035   28.57;
                        1550000   0.035    0.04    25;
                        1800000   0.04     0.045   22.22;
                        2050000   0.045    0.05    20;
                        2300000   0.05     0.055   18.18;
                        2550000   0.055    0.06    16.66;
                        2800000   0.060    0.065   15.38;
                        3050000   0.065    0.070   14.28;
                        3300000   0.070    0.075   13.33;
                        3550000   0.075    0.080   12.50;
                        3800000   0.08     0.085   11.76;
                        4050000   0.085    0.09    11.11;
                        4300000   0.09     0.095   10.52
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