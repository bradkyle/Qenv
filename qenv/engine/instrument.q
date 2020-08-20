\d .instrument
\l util.q

instrumentCount:0;

// https://blog.bitmex.com/xbt-vs-xbu-chain/
/*******************************************************
/ instrument enumerations
INSTRUMENTTYPE      :   `PERPETUAL`ADAPTIVE;
LIQUIDATIONSTRAT    :   `COMPLETE`PARTIAL; 
CONTRACTTYPE        :   `VANILLA`QUANTO`INVERSE;
LIQUIDATEFEETYPE    :   `TOTAL`COMMISSION;
RISKTIERTYPE        :   `PROCEDURAL`FLAT;
INSTRUMENTSTATE     :   `ONLINE`DOWN`MAINTENENCE;

// TODO INVERSE vs QUANTO i.e. bitmex + okex vs binance etc.
// TODO do funding, fair price marking, 
// TODO are trades aggregated
Instrument: (
    [instrumentId           : `long$()];
    state                   : `.instrument.INSTRUMENTSTATE$();
    quoteAsset              : `symbol$();
    baseAsset               : `symbol$();
    underlyingAsset         : `symbol$();
    faceValue               : `long$();
    maxLeverage             : `long$();
    minLeverage             : `long$();
    flatMakerFee            : `float$();
    flatTakerFee            : `float$();
    tickSize                : `float$();
    priceMultiplier         : `long$();
    sizeMultiplier          : `long$();
    flatRiskLimit           : `float$();
    flatRiskStep            : `float$();
    markPrice               : `float$();
    lastPrice               : `float$();
    fundingInterval         : `timespan$();
    totalVolume             : `long$();
    volume24h               : `long$();
    bestBidPrice            : `float$();
    bestAskPrice            : `float$();
    midPrice                : `float$();
    openInterest            : `long$();
    openValue               : `float$();
    taxed                   : `boolean$();
    deleverage              : `boolean$();
    capped                  : `boolean$();
    hasLiquidityBuy         : `boolean$();
    hasLiquiditySell        : `boolean$();
    maxPrice                : `float$();
    minPrice                : `float$();
    lotSize                 : `float$(); 
    maxOrderSize            : `float$();
    minOrderSize            : `float$();
    junkOrderSize           : `float$();
    liquidationStrat        : `.instrument.LIQUIDATIONSTRAT$();
    contractType            : `.instrument.CONTRACTTYPE$();
    insuranceFee            :  `float$();
    maxOpenOrders           : `int$(); // The default maximum number of orders that an agent can have open.
    numLiquidations         : `long$();
    numAccountLiquidations  : `long$();
    numPositionLiquidations : `long$();
    numBankruptcies         : `long$();
    numForcedCancellations  : `long$();
    feeTiers                : ();
    riskTiers               : ());

mandCols:();
// Defaults approximate the values seen with bitmex XBTUSD
defaults:{:(
    (instrumentCount+:1),`ONLINE,`QUOTE,`BASE,`UNDERLYING,1,100,-0.00025,
    0.00025,0.5,10,1,200f,100f,0f,0f,
    (`timespan$(`minute$480)),0,0,0f,1e6f,0f,0,0f,0b,1b,0b,0b,0b,1e6f,0f,1f,1e5f,0f,
    25f,`COMPLETE,`INVERSE,0f,100,0,0,0,0,0,
    .instrument.NewRiskProcedural[],
    .instrument.NewFeeTier[]
    };
allCols:cols Instrument;

// Inventory CRUD Logic
// -------------------------------------------------------------->

// TODO instrument udpate event
// TODO reference to dict
// Generates a new instrument with default 
// values and inserts it into the instrument 
// table, it also returns the reference to
// the singleton class representation therin.
// TODO deal with columns without values specified etc.
NewInstrument            :{[instrument; time]
    if[any null instrument[mandCols]; :0b];      
    instrument:Sanitize[instrument;defaults[];allCols];
    .instrument.I:instrument;
    `.instrument.Instrument upsert instrument;
    };

NewRiskTier             :{[tier]:flip[`mxamt`mmr`imr`maxlev!flip[tier]]};

NewRiskProcedural       :{[baseRL;step;maintM;initM;maxLev;numTier]
    :flip[`mxamt`mmr`imr`maxlev!(baseRL+(step*til numTier);
    maintM+(maintM*til numTier);
    initM+(maintM*til numTier);
    numTier#maxLev)];
    };

NewFeeTier              :{[]
    `vol`makerFee`takerFee`wdrawFee`dpsitFee`wdrawLimit!flip[tier];

    };


NewFlatFee              :{[]
    // TODO
    };

UpdateMarkPrice : {[markPrice;instrumentId;time]
    update markPrice:markPrice from `.instrument.Instrument where instrumentId=instrumentId;
    };

DerivePremium   :{[]

    };