/ Important note: Perpetual contracts on Binance Futures are not an inverse contract, 
/ they have clear pricing rules and are settled in USDT. 
/
    underlying: btc/usd
    multiplier: 1usd/point
    tick size:  point
    min change: 0.1 point // price
    face value: 100
    adj factor: 
    funding interval: 8hours
    settlement: 8hours 4,12,20 (GMT+8)
\

// max amt of contracts, mmr, imr, max leverage // TODO mmr
TieredRisk:.instrument.NewRiskTier[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f;
        1000000     0.01     0.02     50f;
        5000000     0.025    0.05     20f;
        20000000    0.05     0.1      10f;
        50000000    0.1      0.20     5f;
        100000000   0.125    0.25     4f;
        200000000   0.15     0.333    3f;
        500000000   0.25     0.50     2f;
        500000000   0.25     1.0      1f
    )];

// 30day trading volume(USD), makerFee, takerFee, withdrawal limit
// - Maker fees are paid when you add liquidity to our order book, 
//      by placing a limit order under the last trade price for buy 
//      and above the last trade price for sell.
// - Taker fees are paid when you remove liquidity from our 
//      order book, by placing any order that is executed against 
//      an order of the orderbook. (Please note when your limit 
//      order is executed against other user's limit order and 
//      his/her order placed earlier than your order, you will pay taker fees.)
TieredFee:.instrument.NewFeeTier[(
        25e6  0.0002   0.0005   600f;
        5e7   0.00015  0.0005   600f;
        1e8   0.0001   0.0005   600f;
        15e7  0.00005  0.00045  600f;
        3e8   0.0      0.00045  600f;
        4e8   0.0      0.0004   600f;
        5e8   -0.0005  0.00037  600f;
        1e9   -0.0001  0.00037  600f
    )];


// Default Hedged position
Instrument:.instrument.NewInstrument[

    ];

// derive initial margin
deriveInitialMargin         :{[]

    };

// derive maintenence margin
deriveMaintenenceMargin     :{[]

    };


// derive unrealized pnl
deriveUnrealizedPnl         :{[]

    };

// derive realized pnl
deriveRealizedPnl           :{[]

    };

// derive liquidation price
deriveLiquididationPrice     :{[]

    };

// derive bankruptcy price
deriveBankruptPrice          :{[]

    };

// exec fill
execFill    :{[account;inventory;fillQty;price;fee]
    
    };

// liquidation
liquidation     :{[]

    };