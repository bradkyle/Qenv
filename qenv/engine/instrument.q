\d .instrument
\l util.q

instrumentCount:0;
activeInstrumentId:0;

/*******************************************************
/ instrument enumerations
MAINTTYPE           :   `TIERED`FLAT;
FEETYPE             :   `TIERED`FLAT;
INSTRUMENTSTATE     :   `ONLINE;
INITMARGINTYPE      :   `TIERED`FLAT;
INSTRUMENTTYPE      :   `PERPETUAL`ADAPTIVE;
LIQUIDATIONSTRAT    :   `COMPLETE`PARTIAL; 
SETTLETYPE          :   `QUANTO`INVERSE;
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
    multiplier              : `float$();
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
    `FLAT,`FLAT,-0.00025,0.00025,0.5,1f,`PROCEDURAL,200f,100f,0f,0f,
    (`timespan$(`minute$480)),0,0,0f,1e6f,0f,0,0f,0b,1b,0b,0b,0b,1e6f,0f,1f,1e5f,0f,
    25f,`COMPLETE,`INVERSE,0f,100,0,0,0,0,0)};
allCols:cols Instrument;

// Event creation utilities
// -------------------------------------------------------------->

AddMarkPriceUpdateEvent    :{[]

    };

AddFundingEvent             :{[]

    };

// Inventory CRUD Logic
// -------------------------------------------------------------->

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

// TODO check if active instrument present etc.
// Returns the current state of the active instrument denoted by
// the activeInstrumentId
GetActiveInstrument        :{[]
    if[count[.instrument.Instrument]>0;:GetInstrument[.instrument.activeInstrumentId]];
    };

UpdateInstrument      :{[instrument;time]
    isMark:`markPrice in cols[instrument];
    instrument:Sanitize[instrument;GetInstrument[instrumentId];allCols];
    `.instrument.Instrument upsert instrument;
    if[isMark;AddMarkPriceUpdateEvent[]]; // TODO change.
    // TODO funding?, instrumentUpdate? 
    };

UpdateActiveInstrument  :{[instrument;time]
    instrument[`instrumentId]:.instrument.activeInstrumentId;
    :UpdateInstrument[instrument];
    };

