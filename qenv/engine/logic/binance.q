
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
\

// max amt of contracts, mmr, imr, max leverage // TODO mmr
TieredRisk:NewRiskTier[
    (
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
    );
    ];

// 30day trading volume(BTC), makerFee, takerFee, withdrawal limit
TieredFee:NewFeeTier[ // todo withdraw limit
    (
        50      0.00075   0.00075   600f;
        500     0.00075   0.00075   600f;
        1500    0.0006    0.00075   600f;
        4500    0.000525  0.000675  600f;
        10000   0.000450  0.0006    600f;
        20000   0.000375  0.000525  600f;
        40000   0.0003    0.000450  600f;
        80000   0.000225  0.000375  600f;
        150000  0.000150  0.0003    600f
        
    )
    ];

// 30day trading volume(BTC), makerFee, takerFee, withdrawal limit
// fees for referral
TieredFeeRf:NewFeeTier[(
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
Instrument:NewInstrument[

    ];

// derive maintenence margin


// derive unrealized pnl


// derive realized pnl


// derive liquidation price


// derive bankruptcy price


// derive breakeven price


// exec fill


// update order margin


// liquidation


// Funding
/ Funding Amount=Nominal Value of Positions* ×Funding Rate
/ *Nominal Value of Positions = Mark Price x Size of a Contract