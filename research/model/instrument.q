
// Instrument
// ---------------------------------------------------------------------------->

.instrument.instrumentCount:0;

.engine.model.instrument.Instrument            :(
        [instrumentId           : `long$()];
        state                   : `long$();

        // Price limit values 
        upricelimit             : `long$();
        lpricelimit             : `long$();

        // Min/Max values
        minPrice             : `long$();  
        maxPrice             : `long$();
        minSize              : `long$();
        maxSize              : `long$();

        // Tick, lot and face size
        tickSize             : `long$();
        lotSize              : `long$();
        faceValue            : `long$();
        
        // Multipliers 
        priceMultiplier      : `long$();
        sizeMultiplier       : `long$();

        // UpdatedPublicValues 
        bestBidPrice         : `long$();
        bestAskPrice         : `long$();
        lastPrice            : `long$();
        midPrice             : `long$();
        markPrice            : `long$();
        hasLiquidityBuy      : `boolean$();
        hasLiquiditySell     : `boolean$()
        
        // Funding 
        fundingInterval      : `timespan$();
        nextFundingTime      : `timespan$();
        fundingRate          : `timespan$()

        // Settlement

        
    );

.engine.model.instrument.NewInstruments         :{[i]
    .engine.model.instrument.Instrument,:i;
    .engine.model.instrument.Instrument[i`instrumentId];
    };

.engine.model.instrument.UpdateInstruments      :{[i]
    .engine.model.instrument.Instrument,:i;
    .engine.model.instrument.Instrument[i`instrumentId]
    };

.engine.model.instrument.ValidInstrumentIds        :{[iIds]
    iId in key[.engine.model.instrument.Instrument][`instrumentId]
    };

.engine.model.instrument.GetInstrumentByIds     :{[iId]
    .engine.model.instrument.Instrument[iId]
    };

.engine.model.instrument.GetPublicInstrumentByIds :{[iId]

    };
