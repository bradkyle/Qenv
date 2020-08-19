
// derive maintenence margin
/ This is the minimum amount of margin you must maintain to avoid liquidation on your position.
/ The amount of commission applicable to close out all your positions will also be added onto 
/ your maintenance margin requirement. // TODO make strategy dependent
deriveMaintainenceMargin    :{[currentQty;takerFee;markPrice;faceValue]
    :(maintMarginCoeff[coeff;takerFee;markPrice]*currentQty)*
        pricePerContract[faceValue;markPrice];
    };

avgPrice        :{[isignum;execCost;totalEntry]
    :0^$[isignum>0;1e8%floor[execCost%totalEntry];1e8%ceiling[execCost%totalEntry]];
    };

// TODO inverse vs quanto vs vanilla

liquidationPrice    :{[account;inventoryL;inventoryS;inventoryB;instrument]
        bal:account[`balance];
        tmm:0; 

        // Derive risk limits
        lmB:first ?[instrument[`riskTier];enlist(>;`mxamt;inventoryB[`amt]); 0b; ()];
        lmL:first ?[instrument[`riskTier];enlist(>;`mxamt;inventoryL[`amt]); 0b; ()];
        lmS:first ?[instrument[`riskTier];enlist(>;`mxamt;inventoryS[`amt]); 0b; ()];
        
        // Current Position
        amtB:inventoryB[`amt];
        amtL:inventoryL[`amt];
        amtS:inventoryS[`amt];

        // Maintenence margin rate
        mmB:lmB[`mmr];
        mmL:lmL[`mmr];
        mmS:lmS[`mmr];

        // Maintenece Amount
        cumB: amtB*(mmB+instrument[`riskBuffer]);
        cumL: amtL*(mmL+instrument[`riskBuffer]);
        cumS: amtS*(mmS+instrument[`riskBuffer]);

        // Derive Average price
        sB:inventoryB[`isignum];
        epB:avgPrice[sB;inventoryB[`execCost];inventoryB[`totalEntry]];
        epL:avgPrice[1;inventoryL[`execCost];inventoryL[`totalEntry]];
        epS:avgPrice[-1;inventoryS[`execCost];inventoryS[`totalEntry]];

        :(((bal+tmm+cumB+cumL+cumS)-(sB*amtB*epB)-(amtL*epL)+(amtS*epS))
            %((amtB*mmB)+(amtL*mmL)+(amtS*mmS)-(sB*amtB)-(amtL+amtS)));
    };

bankruptcyPrice     :{[account;inventoryL;inventoryS;inventoryB;instrument]
        bal:account[`balance];
        tmm:0; 

        // Derive risk limits
        lmB:first ?[instrument[`riskTier];enlist(>;`mxamt;inventoryB[`amt]); 0b; ()];
        lmL:first ?[instrument[`riskTier];enlist(>;`mxamt;inventoryL[`amt]); 0b; ()];
        lmS:first ?[instrument[`riskTier];enlist(>;`mxamt;inventoryS[`amt]); 0b; ()];
        
        // Current Position
        amtB:inventoryB[`amt];
        amtL:inventoryL[`amt];
        amtS:inventoryS[`amt];

        // Maintenence margin rate
        imrB:lmB[`imr];
        imrL:lmL[`imr];
        imrS:lmS[`imr];

        // Maintenece Amount
        cumB: amtB*imrB;
        cumL: amtL*imrL;
        cumS: amtS*imrS;

        // Derive Average price
        sB:inventoryB[`isignum];
        epB:avgPrice[sB;inventoryB[`execCost];inventoryB[`totalEntry]];
        epL:avgPrice[1;inventoryL[`execCost];inventoryL[`totalEntry]];
        epS:avgPrice[-1;inventoryS[`execCost];inventoryS[`totalEntry]];

        :(((bal+tmm+cumB+cumL+cumS)-(sB*amtB*epB)-(amtL*epL)+(amtS*epS))
            %((amtB*imrB)+(amtL*imrL)+(amtS*imrS)-(sB*amtB)-(amtL+amtS)));

    };