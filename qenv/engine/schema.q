
\d .schema

// Utilities
// --------------------------------------------------->

// Todo move to schema/event
MakeEvent   : {[time;cmd;kind;datum;isAgent;agentId]
        if[not (type time)=-15h; :`]; //TODO fix
        if[not (cmd in EVENTCMD); ];
        if[not (kind in EVENTKIND); ];
        if[not] //validate datum 
        :`time`cmd`kind`datum!(time;cmd;kind;datum);
};

MakeFailure    :{[]

}

// State
// --------------------------------------------------->
// represents the offset in milliseconds
// check if flip is right
Engine:flip (
    loadSheddingProbability     : `float$();
    placeOrderOffsetMu          : `float$(); 
    placeOrderOffsetSigma       : `float$();
    placeBatchOffsetMu          : `float$();
    placeBatchOffsetSigma       : `float$();
    cancelOrderOffsetMu         : `float$(); 
    cancelOrderOffsetSigma      : `float$(); 
    cancelOrderBatchOffsetMu    : `float$(); 
    cancelOrderBatchOffsetSigma : `float$(); 
    cancelAllOrdersOffsetMu     : `long$(); 
    cancelAllOrdersOffsetSigma  : `long$(); 
    amendOrderOffsetMu          : `long$(); 
    amendBatchOffsetSigma       : `long$();
    commonOffset                : `long$(); 
)

UpdateEngineProbs   :{[]

}

DeriveEngineProbs   :{[]

}

Instrument: (
    [id                     : `symbol$()];
    state                   : `INSTRUMENTSTATE$();
    quoteAsset              : `symbol$();
    baseAsset               : `symbol$();
    underlyingAsset         : `symbol$();
    faceValue               : `long$();
    maxLeverage             : `long$();
    minLeverage             : `long$();
    maintType               : `MAINTTYPE$();
    feeType                 : `FEETYPE$();
    flatMakerFee            : `float$();
    flatTakerFee            : `float$();
    tickSize                : `float$();
    multiplier              : `float$();
    riskTierType            : `RISKTIERTYPE$();
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
    liquidationStrat        : `LIQUIDATIONSTRAT$();
    settleType              : `SETTLETYPE$();
    insuranceFee            :  `float$();
    maxOpenOrders           : `int$(); // The default maximum number of orders that an agent can have open.
    numLiquidations         : `long$();
    numAccountLiquidations  : `long$();
    numPositionLiquidations : `long$();
    numBankruptcies         : `long$();
    numForcedCancellations  : `long$();
)

MakeMarkPriceUpdateEvent    :{[]

}

MakeFundingEvent             :{[]

}

// Account state in this instance serves as a proxy
// for a single agent and contains config therin
// pertaining to what the agent setting is.
Account: (
    [id                 : `long$()]
    balance             : `long$();
    frozen              : `long$();
    maintMargin         : `long$();
    available           : `long$();
    openBuyOrderQty     : `long$();
    openSellOrderQty    : `long$();
    marginType          : `MARGINTYPE$();
    positionType        : `POSITIONTYPE$();
    depositAmount       : `long$();
    depositCount        : `long$();
    withdrawAmount      : `long$();
    withdrawCount       : `long$();
    tradeVolume         : `long$();
    tradeCount          : `long$();
    netLongPosition     : `long$();
    netShortPosition    : `long$();
    shortFundingCost    : `float$();
    longFundingCost     : `float$();
    totalFundingCost    : `float$();
    totalFundingCostMrg : `float$();
);

NewAccount              :{[accountId]

};

MakeAccountUpdateEvent  :{[]

}

MakeAllAccountsUpdatedEvent :{[]

}

Inventory: (
    [inventoryId        :  `long$()]
    accountId           :  `long$();
    amount              :  `long$();
    faceValue           :  `int$();
    side                :  `POSITIONSIDE$();
    avgPrice            :  `float$();
    realizedPnl         :  `long$();
    unrealizedPnl       :  `long$();
    totalCost           :  `long$();
    totalEntry          :  `long$();
    execCost            :  `long$();
    grossProfit         :  `long$();
    totalCloseAmt       :  `long$();
    totalCrossAmt       :  `long$();
    totalOpenAmt        :  `long$();
    markPrice           :  `float$();
    lastPrice           :  `float$();
    liquidationPrice    :  `float$();
    bankruptPrice       :  `float$();
    breakEvenPrice      :  `float$();
    lastPrice           :  `float$();
    lastValue           :  `float$();
    markPrice           :  `float$();
    markValue           :  `float$();
    initMarginReq       :  `float$();
    maintMarginReq      :  `float$();
    activeTakerFee      :  `float$();
    activeMakerFee      :  `float$();
);

NewInventory               :{[]

}

MakeInventoryUpdateEvent   :{[]

}

MakeAllPositionsUpdatedEvent :{[]

}

orderMandatoryFields    :`accountId`side`otype`osize;
Order: (
    [orderId        : `long$()]
    accountId       : `long$();
    side            : `ORDERSIDE$();
    otype           : `ORDERTYPE$();
    timeinforce     : `TIMEINFORCE$();
    osize           : `long$(); / multiply by 100
    leaves          : `long$();
    filled          : `long$();
    limitprice      : `long$(); / multiply by 100
    stopprice       : `long$(); / multiply by 100
    effdate         : `long$(); / as YYYYMMDD
    status          : `ORDERSTATUS$();
    time            : `datetime$();
    trigger         : `STOPTRIGGER$();
    execInst        : `EXECINST$();
);

ValidateOrder   : {[order]

}

MakeNewOrderEvent   :{[]

}

MakeOrderUpdateEvent :{[]

}

MakeBatchOrderEvent   :{[]

}

MakeCancelAllOrdersEvent :{[]

}


Bids: `qtys`agentOffsets`agentSizes!()
Asks: `qtys`agentOffsets`agentSizes!()
OrderBook:`BUY`SELL!Bids Asks;

MakeDepthUpdateEvent :{[]
    
}

// Stateless Events
// --------------------------------------------------->



// Lookback Buffers (Simulates what the agen will see)
// --------------------------------------------------->

AccountEventHistory: (

);

InventoryEventHistory: (

);

OrderEventHistory: (

);

DepthEventHistory: (

);

TradeEventHistory: (

);

FeatureBuffer: (

);

/ ********************************
/ Utility function for inserting resultant events
/ into the lookback buffers shown above.

// Source Buffers (hold all of the events that are to be processed)
// --------------------------------------------------->
// TODO add randomization to history repr



// U
// --------------------------------------------------->