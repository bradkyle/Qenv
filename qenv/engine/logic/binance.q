\d .binance
/ Important note: Perpetual contracts on Binance Futures are not an inverse contract, 
/ they have clear pricing rules and are settled in USDT. 
/
    contract:BTCUSDT
    underlying:btc/usdt
    face value:0.001BTC
    tick size:0.01
    leverage:0.01 - 100;
    base initial margin rate:0.0080
    base maint margin rate:0.0040
    liquidation fee: 0.003

    Symbol: BTCUSDT
    Type: USDT quoted and settled
    Initial Margin: 1% + Entry Taker Fee
    Maint. Margin: 0.5% + Funding Rate
    Funding Interval: every 8 hours
    Mark Price: Index Price * (1 + Funding Basis)
    Leverages: 100x, 50x, 20x, 10x, 5x, 3x, 2x, 1x
    Contract Size: 1 BTC
    Lot Size: 0.0001 Contract
    Tick Size: 0.1 USDT
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

// 30day trading volume(BTC), makerFee, takerFee, withdrawal limit
// fees for referral
TieredFee:.instrument.NewFeeTier[(
        50      0.0006    0.0006    600f;
        500     0.00054   0.0006    600f;
        1500    0.00048   0.0006    600f;
        4500    0.00042   0.0006    600f;
        10000   0.00042   0.00054   600f;
        20000   0.00036   0.00048   600f;
        40000   0.00024   0.00036   600f;
        80000   0.00018   0.000300  600f;
        150000  0.00012   0.00024   600f
    )];

// deposit fee, min withdraw, withdraw fee
// 0, 0.0000018, 0.0000036
// 0  0.001    , 0.0004 

// Default Hedged position
Instrument:.instrument.NewInstrument[

    ];


deriveOpenPremium           :{[noc;direction;markPrice;orderPrice]
    :noc * abs[min[0,direction*(markPrice-orderPrice)]]
    };

// derive initial margin
deriveInitialMargin         :{[]
    initialMargin:notionalValue%leverage
    };

// derive maintenence margin
deriveMaintenenceMargin     :{[currentQty;markPrice]
        notionalValue:currentQty*markPrice;
        mmr:.binance.TieredRisk[currentQty][0];
        :(notionalValue * mmr) 
    };

// derive unrealized pnl
/ Mark Price is a better estimate of the ‘true’ value of the contract, 
/ compared to Perpetual Futures prices which can be more volatile in the short term. 
/ We use this price to prevent unnecessary liquidations for traders and to discourage 
/ any market manipulations by poor actors.
/ Unrealized PnL is thus calculated as (all values in USDT):
/ Net Negative Position: UnrealizedPnL= (Entry Price−MarkPrice)×S
/ Net Positive Position: UnrealizedPnL=(MarkPrice−InitialBuyPrice)×Position
/ Total Collateral for Margin and Liquidation purposes: 
/       Collateral=InitialCollateral+RealizedPnL+UnrealizedPnL
/ The maximum amount of collateral can be withdrawn from the account so long 
/ as collateral > (initial margin + borrowed amount) . 
deriveUnrealizedPnl         :{[account]
        $[
            ;
        ];
    };

// derive realized pnl
deriveRealizedPnl           :{[]

    };

// derive liquidation price // todo add noise
deriveLiquididationPrice     :{[]

    };

// derive bankruptcy price
deriveBankruptPrice          :{[currentQty;avgPrice;initMargin]
    :(currentQty%((currentQty%avgPrice)-(initMargin*-1)))
    };

// derive breakeven price


// exec fill
execFill    :{[account;inventory;fillQty;price;fee]
    
    };

// liquidation
liquidation     :{[]

    };

// Funding
/ Funding Amount=Nominal Value of Positions* ×Funding Rate
/ *Nominal Value of Positions = Mark Price x Size of a Contract