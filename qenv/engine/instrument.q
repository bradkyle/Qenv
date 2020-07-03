\d .instrument

/*******************************************************
/ instrument enumerations
MAINTTYPE           :   `TIERED`FLAT;
FEETYPE             :   `TIERED`FLAT;
INSTRUMENTSTATE     :   `ONLINE;
INITMARGINTYPE      :   `TIERED`FLAT;
INSTRUMENTTYPE      :   `PERPETUAL`ADAPTIVE;
LIQUIDATIONSTRAT    :   `COMPLETE`PARTIAL; 
SETTLETYPE          :   `QUANTO`INVERSE;
LIQUIDATEFEETYPE    :  `TOTAL`COMMISSION;

Instrument: (
    [id                     : `symbol$()];
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
    fundingInterval         : `datetime$();
    totalVolume             : `long$();
    volume                  : `long$();
    volume24h               : `long$();
    bestBidPrice            : `float$();
    bestAskPrice            : `float$();
    midPrice                : `float$();
    openInterest            : `long$();
    openValue               : `float$();
    taxed                   : `boolean$();
    deleverage              : `boolean$();
    capped                  : `boolean$();
    maxPrice                : `float$();
    minPrice                : `float$();
    lotSize                 : `float$();
    maxOrderSize            : `float$();
    junkOrderSize           : `float$();
    liquidationStrat        : `.instrument.LIQUIDATIONSTRAT$();
    settleType              : `.instrument.SETTLETYPE$();
    insuranceFee            :  `float$();
    maxOpenOrders           : `int$(); // The default maximum number of orders that an agent can have open.
    numLiquidations         : `long$();
    numAccountLiquidations  : `long$();
    numPositionLiquidations : `long$();
    numBankruptcies         : `long$();
    numForcedCancellations  : `long$();
)

// TODO reference to dict
// Generates a new instrument with default 
// values and inserts it into the instrument 
// table, it also returns the reference to
// the singleton class representation therin.
NewInstrument            :{[]

};

MakeMarkPriceUpdateEvent    :{[]

}

MakeFundingEvent             :{[]

}


reserveOrderMargin  : {[side;price;size;orderId;time]
    // 
    events:();
    markPrice: 0;
    faceValue: 0;
    leverage:0;
    $[side=`BUY & price>markPrice; 
      premium:floor[(price-markPrice)*faceValue];
      side=`SELL & price<markPrice;
      premium:floor[(markPrice-price)*faceValue];
      premium:0;
    ];

    $[side=`SELL & longOpenQty>sellOpenQty;
     charged:max[size-(longOpenQty-sellOrderQty),0];
     side=`BUY & shortOpenQty>buyOrderQty;
     charged:max[size-(shortOpenQty-buyOrderQty),0];
     charged:0;
    ];
    
    reserved: floor[((charged+(initialMarginCoefficient*charged*faceValue)+changed*premium)%price)%leverage];
    $[(reserved<availableBalance) | (reserved=0);
        [
            orderMargin:reserved;
            :1b;
        ];
        [:0b]
    ];
    :events;
    };