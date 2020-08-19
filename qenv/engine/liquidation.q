
// derive maintenence margin
/ This is the minimum amount of margin you must maintain to avoid liquidation on your position.
/ The amount of commission applicable to close out all your positions will also be added onto 
/ your maintenance margin requirement. // TODO make strategy dependent
deriveMaintainenceMargin    :{[currentQty;takerFee;markPrice;faceValue]
    :(maintMarginCoeff[coeff;takerFee;markPrice]*currentQty)*
        pricePerContract[faceValue;markPrice];
    };



liquidationPrice    :{[account;inventoryL;inventoryS;inventoryB;instrument]
        bal:account[`balance];
        
        cumB:maintMargin[];
        cumL:maintMargin[];
        cumS:maintMargin[];

        epB:avgPrice[];
        epL:avgPrice[];
        epS:avgPrice[];

        amtB:inventoryB[`amt];
        amtL:inventoryL[`amt];
        amtS:inventoryS[`amt];

        mmB:50;
        mmL:50;
        mmS:50;

        sB:1;
        tmm:0;

        :(((bal+tmm+cumB+cumL+cumS)-(sB*amtB*epB)-(amtL*epL)+(amtS*epS))
            %(amtB*mmb)+(amtL*mmL)+(amtS*mmS)-(sB*amtB)-(amtL+amtS));
    };

bankruptcyPrice     :{[]

    };