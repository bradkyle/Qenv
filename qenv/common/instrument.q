

.common.instrument.NewRiskTier             :{[tier]
    :flip[`mxamt`mmr`imr`maxlev!flip[tier]]
    };

.common.instrument.NewRiskProcedural       :{[baseRL;step;maintM;initM;maxLev;numTier]
    :flip[`mxamt`mmr`imr`maxlev!(baseRL+(step*til numTier);
    maintM+(maintM*til numTier);
    initM+(maintM*til numTier);
    numTier#maxLev)];
    };

.common.instrument.NewFeeTier              :{[tier]
    :flip[`vol`makerFee`takerFee`wdrawFee`dpsitFee`wdrawLimit!flip[tier]];
    };

// TODO fix
.common.instrument.NewFlatFee              :{[tier]
    :flip[`vol`makerFee`takerFee`wdrawFee`dpsitFee`wdrawLimit!flip[tier]];
    };