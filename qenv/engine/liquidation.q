
// derive maintenence margin
/ This is the minimum amount of margin you must maintain to avoid liquidation on your position.
/ The amount of commission applicable to close out all your positions will also be added onto 
/ your maintenance margin requirement. // TODO make strategy dependent
deriveMaintainenceMargin    :{[currentQty;takerFee;markPrice;faceValue]
    :(maintMarginCoeff[coeff;takerFee;markPrice]*currentQty)*
        pricePerContract[faceValue;markPrice];
    };

