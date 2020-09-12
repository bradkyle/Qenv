\d .instrument

.instrument.instrumentCount:0;

// TODO logic mappings per CONTRACTTYPE
// TODO move defaults to util.defaults

// Inventory CRUD Logic
// -------------------------------------------------------------->

.instrument.NewRiskTier             :{[tier]
    :flip[`mxamt`mmr`imr`maxlev!flip[tier]]
    };

.instrument.NewRiskProcedural       :{[baseRL;step;maintM;initM;maxLev;numTier]
    :flip[`mxamt`mmr`imr`maxlev!(baseRL+(step*til numTier);
    maintM+(maintM*til numTier);
    initM+(maintM*til numTier);
    numTier#maxLev)];
    };

.instrument.NewFeeTier              :{[tier]
    :flip[`vol`makerFee`takerFee`wdrawFee`dpsitFee`wdrawLimit!flip[tier]];
    };

// TODO fix
.instrument.NewFlatFee              :{[tier]
    :flip[`vol`makerFee`takerFee`wdrawFee`dpsitFee`wdrawLimit!flip[tier]];
    };

// TODO INVERSE vs QUANTO i.e. bitmex + okex vs binance etc.
// TODO do funding, fair price marking, 
// TODO are trades aggregated
// TODO short/long ratio
// TODO people online, bots online
// TODO long fraction, short fraction, historic data
// TODO apply premium
.instrument.Instrument: (
    [instrumentId           : `long$()];
    state                   : `long$();
    quoteAsset              : `symbol$();
    baseAsset               : `symbol$();
    underlyingAsset         : `symbol$();
    faceValue               : `long$();
    maxLeverage             : `long$();
    minLeverage             : `long$();
    priceMultiplier         : `long$();
    sizeMultiplier          : `long$();
    markPrice               : `long$();
    lastPrice               : `long$();
    fundingInterval         : `timespan$();
    totalVolume             : `long$();
    volume24h               : `long$();
    bestBidPrice            : `long$();
    bestAskPrice            : `long$();
    midPrice                : `long$();
    openInterest            : `long$();
    openValue               : `long$();
    taxed                   : `boolean$();
    deleverage              : `boolean$();
    capped                  : `boolean$();
    hasLiquidityBuy         : `boolean$();
    hasLiquiditySell        : `boolean$();
    usePriceLimits          : `boolean$();
    maxPrice                : `long$();
    minPrice                : `long$();
    upricelimit             : `long$();
    lpricelimit             : `long$();
    lotSize                 : `long$(); 
    maxOrderSize            : `long$();
    minOrderSize            : `long$();
    junkOrderSize           : `long$();
    liquidationStrat        : `long$();
    contractType            : `long$();
    maxOpenOrders           : `long$(); // The default maximum number of orders that an agent can have open.
    numLiquidations         : `long$();
    numAccountLiquidations  : `long$();
    numPositionLiquidations : `long$();
    numBankruptcies         : `long$();
    numForcedCancellations  : `long$();
    riskBuffer              : `long$();
    tickSize                : `float$();
    feeTiers                : ();
    riskTiers               : ());

.instrument.mandCols:();

.instrument.defaultRiskTier:.instrument.NewRiskTier[(
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

.instrument.defaultFeeTier: .instrument.NewFeeTier[(
        50      0.0006    0.0006    0  0 600f;
        500     0.00054   0.0006    0  0 600f;
        1500    0.00048   0.0006    0  0 600f;
        4500    0.00042   0.0006    0  0 600f;
        10000   0.00042   0.00054   0  0 600f;
        20000   0.00036   0.00048   0  0 600f;
        40000   0.00024   0.00036   0  0 600f;
        80000   0.00018   0.000300  0  0 600f;
        150000  0.00012   0.00024   0  0 600f
    )];

// Defaults approximate the values seen with bitmex XBTUSD
.instrument.defaults:{:( // TODO redo
    (instrumentCount+:1),`ONLINE,`QUOTE,`BASE,`UNDERLYING,1,100,0,0.5,10,1,0f,0f,
    (`timespan$(`minute$480)),0,0,0f,1e6f,0f,0,0f,0b,1b,0b,0b,0b,1e6f,0f,1f,1e5f,0f,
    25f,`COMPLETE,`INVERSE,0f,100,0,0,0,0,0,0,0N,0N)
    };
.instrument.allCols:cols Instrument;

// Instrument CRUD Logic
// -------------------------------------------------------------->

// TODO instrument udpate event
// TODO reference to dict
// Generates a new instrument with default 
// values and inserts it into the instrument 
// table, it also returns the reference to
// the singleton class representation therin.
// TODO deal with columns without values specified etc.
.instrument.NewInstrument            :{[instrument; time]
    if[any null instrument[mandCols]; :0b];      
    instrument:Sanitize[instrument;defaults[];allCols];
    .instrument.I:instrument;
    `.instrument.Instrument upsert instrument;
    };


// SETTLEMENT
