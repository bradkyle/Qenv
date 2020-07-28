
\d .okex

/
    contract:BTCUSDSWAP
    underlying:btc/usdt
    face value:0.01BTC
    tick size:0.1
    leverage:0.01 - 100;
\

// max amt of contracts, mmr, minimum initial margin ratio, max leverage
TieredRisk:NewRiskTier[(
        50000     0.005    0.01    100f;
        300000    0.01     0.015   66.66f;
        550000    0.015    0.02    50f;
        800000    0.02     0.025   40f;
        1050000   0.025    0.03    33.3f;
        1300000   0.03     0.035   28.57f;
        1550000   0.035    0.04    25f;
        1800000   0.04     0.045   22.22f;
        2050000   0.045    0.05    20f;
        2300000   0.05     0.055   18.18f;
        2550000   0.055    0.06    16.66f;
        2800000   0.060    0.065   15.38f;
        3050000   0.065    0.070   14.28f;
        3300000   0.070    0.075   13.33f;
        3550000   0.075    0.080   12.50f;
        3800000   0.08     0.085   11.76f;
        4050000   0.085    0.09    11.11f;
        4300000   0.09     0.095   10.52
    )];

/ The 30-day trading volume of Perpetual Swap trading is calculated in BTC USD price. 
/ Trading volume is converted into BTC and settled at 00:00 (UTC+8) every day, 
/ calculated based on the accumulated trading volume in the last 30 days of 
/ all Perpetual Swap trading assets.
/ For example, a user traded BTC, ETH and ETC coin margined Perpetual Swap 
/ in the last 30 days, the system will calculate the BTC, ETH and ETC trading 
/ volume (contract face value*number of contracts) by converting the BTC USD 
/ price into BTC and settle the accumulated trading volume of the last 30 
/ days at 00:00 (UTC+8) every day.
// 30day trading volume(BTC), makerFee, takerFee, withdrawal limit
TieredFee:NewFeeTier[(
        5000    0.00015     0.0003    600f;
        10000   0.00005     0.0003    800f;
        20000   0           0.0003    1000f;
        60000   -0.00005    0.0003    1200f;
        100000  -0.00008    0.0003    1500f;
        150000  -0.00010    0.0003    1800f;
        200000  -0.00015    0.03      2000f
    )];

// Default Hedged position
Instrument:NewInstrument[

    ];

// derive maintenence margin
deriveMaintenenceMargin :{[]

    };

// derive unrealized pnl
/ Long position：
//（latest mark price-settlement reference price）x number of contracts  xface value
// Short Position：
// (settlement reference price - latest mark price price）x number of contracts x face value
deriveUnrealizedPnl     :{[]

    };

// derive realized pnl
deriveRealizedPnl       :{[]

    };

// derive liquidation price
deriveLiquidationPrice  :{[]

    };

// derive bankruptcy price


// derive breakeven price


// deriveAverageEntryPrice


// exec fill


// update order margin


// liquidation
/ For positions at Tier 3 or above (Number of contracts>=550,001, e.g. 600,000), 
/ Partial Liquidation occurs when the Margin Ratio is lower than the required 
/ Maintenance Margin Ratio (2%). The relevant position will be liquidated 
/ until it is at Tier 1. In the above example, the Number of contracts to 
/ be closed = Number of contracts held – max Number of contracts acceptable 
/ for Tier 1 = 600,000-50,000=550,000contracts.
/ liquidation orders will be sent in a price slightly better than market price, force-closing the required number of contracts. During the time, the position will be frozen and cannot be controlled by the user.
/ About a minute later, if the orders are filled and the Margin Ratio of the remaining position reach the Maintenance Margin Ratio + Liquidation Fee Rate required by the relevant tier, then the remaining liquidation orders will be canceled, and the user’s control over the position is restored.
/ If the liquidation orders are unfilled or the Margin Ratio of the remaining position does not reach the required Maintenance Margin Ratio + Liquidation Fee Rate, then the unfilled liquidation orders will be canceled. The liquidation procedure will start over again. This process will be repeated until the latest Margin Ratio meets MMR requirement.

/ In Cross Margin Mode, if there are both long and short positions, the pairs of 
/ long/short positions will be closed immediately. If Margin Ratio reaches the 
/ required Maintenance Margin Ratio, liquidation will stop; 
/ if it is not reached, the liquidation will continue.
/ When a user's maintenance margin ratio tier is 2 or below 
/ and his maintenance margin ratio falls below the tier's 
/ required level, or when a user's maintenance margin ratio tier is 3 or 
/ above and his maintenance margin ratio is less than the requirement 
/ of tier 1, the position will be closed at its bankruptcy price 
/ (at which all margins are lost) and taken over by the 
/ liquidation engine.