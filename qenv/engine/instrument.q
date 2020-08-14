\d .instrument
\l util.q

instrumentCount:0;

// https://blog.bitmex.com/xbt-vs-xbu-chain/
/*******************************************************
/ instrument enumerations
MAINTTYPE           :   `TIERED`FLAT;
FEETYPE             :   `TIERED`FLAT;
INITMARGINTYPE      :   `TIERED`FLAT;
INSTRUMENTTYPE      :   `PERPETUAL`ADAPTIVE;
LIQUIDATIONSTRAT    :   `COMPLETE`PARTIAL; 
SETTLETYPE          :   `VANILLA`QUANTO`INVERSE;
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
    maintType               : `.instrument.MAINTTYPE$();
    feeType                 : `.instrument.FEETYPE$();
    flatMakerFee            : `float$();
    flatTakerFee            : `float$();
    tickSize                : `float$();
    priceMultiplier         : `long$();
    sizeMultiplier          : `long$();
    riskTierType            : `.instrument.RISKTIERTYPE$();
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
    settleType              : `.instrument.SETTLETYPE$();
    insuranceFee            :  `float$();
    maxOpenOrders           : `int$(); // The default maximum number of orders that an agent can have open.
    numLiquidations         : `long$();
    numAccountLiquidations  : `long$();
    numPositionLiquidations : `long$();
    numBankruptcies         : `long$();
    numForcedCancellations  : `long$());

mandCols:();
// Defaults approximate the values seen with bitmex XBTUSD
defaults:{:(
    (instrumentCount+:1),`ONLINE,`QUOTE,`BASE,`UNDERLYING,1,100,0,
    `FLAT,`FLAT,-0.00025,0.00025,0.5,10,1,`PROCEDURAL,200f,100f,0f,0f,
    (`timespan$(`minute$480)),0,0,0f,1e6f,0f,0,0f,0b,1b,0b,0b,0b,1e6f,0f,1f,1e5f,0f,
    25f,`COMPLETE,`INVERSE,0f,100,0,0,0,0,0)};
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
NewInstrument            :{[instrument; isActive; time]
    if[any null instrument[mandCols]; :0b];      
    instrument:Sanitize[instrument;defaults[];allCols];
    `.instrument.Instrument upsert instrument;
    if[isActive; .instrument.activeInstrumentId:instrument[`instrumentId]];
    };

// Returns the current state of the instrument denoted by the provided
// instrument Id,
GetInstrument             :{[instrumentId]
    if[instrumentId in key .instrument.Instrument;:.instrument.Instrument[instrumentId];]
    };
 
UpdateInstrument      :{[instrument;time]
    instrument:Sanitize[instrument;GetInstrument[instrumentId];allCols];
    `.instrument.Instrument upsert instrument;
    };


NewRiskTier             :{[tier]
    `mxamt`mmr`imr`maxlev!flip[tier];

    };

NewRiskProcedural       :{[]
    // TODO
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