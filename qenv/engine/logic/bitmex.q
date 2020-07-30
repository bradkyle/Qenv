
\d .bitmex

/ Symbol	Base Risk Limit	   Step	      Base Maintenance Margin	 Base Initial Margin
/ XBTUSD	200 XBT	          100 XBT	  0.35%	                    1.00%
TieredRisk :NewRiskTier[(

    )];

FlatFee    :NewFlatFee[(

    )];

Instrument:NewInstrument[

    ];

pricePerContract  :{[faceValue;price]$[price>0;faceValue%price;0]};

derivePremium   :{[]

    };
    
/ reserveOrderMargin  : {[side;price;size;orderId;time]
/     // 
/     events:();
/     markPrice: 0;
/     faceValue: 0;
/     leverage:0;
/     $[side=`BUY & price>markPrice; 
/       premium:floor[(price-markPrice)*faceValue];
/       side=`SELL & price<markPrice;
/       premium:floor[(markPrice-price)*faceValue];
/       premium:0;
/     ];

/     $[side=`SELL & longOpenQty>sellOpenQty;
/      charged:max[size-(longOpenQty-sellOrderQty),0];
/      side=`BUY & shortOpenQty>buyOrderQty;
/      charged:max[size-(shortOpenQty-buyOrderQty),0];
/      charged:0;
/     ];
    
/     reserved: floor[((charged+(initialMarginCoefficient*charged*faceValue)+changed*premium)%price)%leverage];
/     $[(reserved<availableBalance) | (reserved=0);
/         [
/             orderMargin:reserved;
/             :1b;
/         ];
/         [:0b]
/     ];
/     :events;
/     };
/ Symbol	Base Risk Limit	Step	Base Maintenance Margin	Base Initial Margin
/ XRPU20	50 XBT	50 XBT	2.50%	5.00%
/ If a contract uses Fair Price Marking initial margin will be calculated differently. 
/ If a buy order is placed above the mark price, or if a sell order is placed below 
/ the mark price then the trader must fully fund the difference between the order 
/ price and the mark price. For example, if the mark price is $100 and the trader 
/ submits a bid order for 10 contracts at $110, then the 
/ initial margin required = (IM * 10 contracts * $110 * Multiplier) + 
/ (100% * 10 contracts * ($110 - $100) * Multiplier).
deriveInitialMargin         :{[]

    };

/ / This is the minimum amount of margin you must maintain to avoid liquidation on your position.
/ / The amount of commission applicable to close out all your positions will also be added onto 
/ / your maintenance margin requirement.
/ deriveMainteneceMargin  : {[]

/     };

maintMarginCoeff  :{[coeff;takerFee;fundingRate] coeff + (takerFee*2) + fundingRate}

// derive maintenence margin
/ This is the minimum amount of margin you must maintain to avoid liquidation on your position.
/ The amount of commission applicable to close out all your positions will also be added onto 
/ your maintenance margin requirement. // TODO make strategy dependent
deriveMaintainenceMargin    :{[currentQty;takerFee;markPrice;faceValue]
    :(maintMarginCoeff[coeff;takerFee;markPrice]*currentQty)*
        pricePerContract[faceValue;markPrice];
    };


// Returns the unrealized profit for the current position considering the current
// mark price and the average entry price (uses mark price to prevent liquidation).
deriveUnrealizedPnl :{[avgPrice;markPrice;faceValue;currentQty]; // TODO is currentQty sign agnostic?
    :(pricePerContract[faceValue;avgPrice] - pricePerContract[faceValue;markPrice])*currentQty;
    };

// Calculates the realized profit and losses for a given position, size is a positive
// or negative number that represents the portion of the current position that has been
// closed and thus should be of the same side as the position i.e. negative for short and 
// positive for long.
deriveRealisedPnl :{[avgPrice;fillPrice;faceValue;fillQty]; // TODO is fillQty sign agnostic?
    :(pricePerContract[faceValue;avgPrice] - pricePerContract[faceValue;fillPrice])*fillQty;
    };


/ Calculate the position liquidation price
/ To do this, we use the PNL equation from the series guide to determine 
/ the price at which only the maintenance margin remains on the position 
/ (ie, the rest of the initial margin has been deducted due 
/ to unrealised losses.)
/ (Size * (1/Entry Price - 1/Liquidation Price)) = (Initial Margin - MM) * -1
/ (200000 * (1/10000 - 1/Liquidation Price)) = (1 - 0.1178517) * -1
/ Liquidation Price = $9577.56
deriveLiquidationPrice      :{[currentQty;avgPrice;initMargin;maintMargin]
    :(currentQty%((currentQty%avgPrice)-((initMargin-maintMargin)*-1)))
    };


/ Calculate the position bankruptcy price
/ To do this, we use the PNL equation from the series guide to 
/ determine the price at which the initial margin of the position 
/ has been lost.
/ Size * (1/Entry Price - 1/Bankruptcy Price) = Initial Margin * -1
/ 200000 * (1/10000 - 1/Bankruptcy Price) = 1 * -1
/ Bankruptcy Price = 9523
deriveBankruptPrice          :{[currentQty;avgPrice;initMargin]
    :(currentQty%((currentQty%avgPrice)-(initMargin*-1)))
    };


// derive breakeven price


// exec fill
// Binance hedged Cross
// If the amount of the reduce-only order is larger than the 
// position you have, the order will be rejected and expired.
// TODO if position does exist and close only only exec = position side
execFill    :{[account;inventory;fillQty;price;fee]
    $[abs[fillQty]>0;0N;:0b];
    $[price>0 & (type price)=-9h;0N;:0b];
    $[(type account)=99h;0N;:0b];
    $[(type inventory)=99h;0N;:0b];
    // TODO errors
    cost: fee * (abs[fillQty]%price);
    nxtQty: inventory[`currentQty] + fillQty;
    leverage: inventory[`leverage];
    currentQty: inventory[`currentQty];
    faceValue:inventory[`faceValue]; // TODO change
    markPrice:inventory[`markPrice];
    takerFee:account[`activeTakerFee];
    makerFee:account[`activeMakerFee];

    // If the order is close and is in a hedged
    // position return with err
    $[(((inventory[`side]=`LONG) and ((currentQty < 0) or (nxtQty < 0))) or 
       ((inventory[`side]=`SHORT) and ((currentQty > 0) or (nxtQty > 0))));:0b;0N]; // TODO better error


    realizedPnlDelta:0f; // TODO change to inst realized pnl

    $[(currentQty*nxtQty)<0; // CROSS
      [
        // The position is being crossed i.e.
        // being changed from long to short or
        // short to long and visa versa.  
        realizedPnlDelta:deriveRealisedPnl[inventory[`avgPrice];price;faceValue;currentQty];

        // Reset entries because of the change in position
        // side and add an entry of a size equal to the
        // size of the next position.
        inventory[`totalEntry]: abs[nxtQty];
        inventory[`execCost]: floor[1e8%price] * abs[nxtQty];
        inventory[`totalCrossVolume]+:abs[fillQty]; 
        inventory[`totalCrossAmt]+:abs[fillQty%price];
        inventory[`totalCrossMarketValue]+:abs[fillQty%price]%leverage;

        // TODO reset position realized pnl (dont reset account realized pnl)

        / Calculates the average price of entry for the current postion, used in calculating 
        / realized and unrealized pnl.
        inventory[`avgPrice]: {$[x[`currentQty]>0;
           1e8%floor[x[`execCost]%x[`totalEntry]];
           1e8%ceiling[x[`execCost]%x[`totalEntry]]
          ]}[inventory];
      ];
      (abs currentQty)>(abs nxtQty); // CLOSE
      [
        // Because the position is being closed the realized pnl 
        // will be inversely proportional to the position.
        realizedPnlDelta:deriveRealisedPnl[inventory[`avgPrice];price;faceValue;neg fillQty];
        inventory[`totalCloseVolume]+:abs[fillQty]; 
        inventory[`totalCloseAmt]+:abs[fillQty%price];
        inventory[`totalCloseMarketValue]+:abs[fillQty%price]%leverage;
      ];
      [ // OPEN
        / Because the current position is being increased
        / an entry is added for calculation of average entry
        / price. 
        inventory[`totalEntry]+: abs[fillQty];
        inventory[`execCost]+: floor[1e8%price] * abs[fillQty];
        inventory[`totalOpenVolume]+:abs[fillQty];
        inventory[`totalOpenAmt]+:abs[fillQty%price];
        inventory[`totalOpenMarketValue]+:abs[fillQty%price]%leverage;
        / inventory[`totalOpenNotional]+:(fillQty%price)%leverage;

        / Calculates the average price of entry for the current postion, used in calculating 
        / realized and unrealized pnl.
        inventory[`avgPrice]: {$[signum[x[`currentQty]]>0;
           1e8%floor[x[`execCost]%x[`totalEntry]];
           1e8%ceiling[x[`execCost]%x[`totalEntry]]
          ]}[inventory];
      ]
    ];
    / TODO implement
    // frozen, maintMargin, netLongPosition, netShortPosition, available, posMargin etc.
    realizedPnlDelta-:cost;
    account[`totalCommission]+:cost;
    inventory[`totalCommission]+:cost;
    inventory[`currentQty]: nxtQty;

    // If the next position will be 0
    // reset the entry values for the position.
    $[nxtQty=0;[
        inventory[`totalEntry]:0;
        inventory[`execCost]:0;
        inventory[`avgPrice]: 0f;
        inventory[`currentQty]: 0;
    ];0N;];

    inventory[`fillCount]+:1;
    account[`tradeCount]+:1;
    account[`tradeVolume]+:abs[fillQty]; 
    
    // TODO unrealized pnl for inventory and account
    unrealizedPnl:deriveUnrealizedPnl[
        inventory[`avgPrice];
        markPrice;
        faceValue;
        inventory[`currentQty]];

    // Inventory values
    inventory[`entryValue]: $[
        (abs[inventory[`currentQty]]>0) and (inventory[`avgPrice]>0);
        abs[inventory[`currentQty]]%inventory[`avgPrice];
        0f];

    / The portion of your margin that is assigned to the initial margin requirements 
    / on your open positions. This is the entry value of all contracts you hold 
    / divided by the selected leverage, plus unrealised profit and loss.
    inventory[`initMargin]:inventory[`entryValue]%leverage;
    inventory[`posMargin]:inventory[`initMargin] + unrealizedPnl;

    inventory[`realizedPnl]+:realizedPnlDelta;
    inventory[`unrealizedPnl]:unrealizedPnl;

    // TODO update maint margin to take account of short and long
    // positions // TODO update account maint margin
    account[`maintMargin]:deriveMaintainenceMargin[
        inventory[`currentQty];
        takerFee;
        markPrice;
        faceValue];

    $[(inventory[`side]=`SHORT) or (inventory[`currentQty]<0);
        [
            account[`shortMargin]:inventory[`posMargin];
            account[`shortValue]:inventory[`entryValue];
            account[`shortUnrealizedPnl]:inventory[`unrealizedPnl];
        ];
        [
            account[`longMargin]:inventory[`posMargin];
            account[`longValue]:inventory[`entryValue];
            account[`longUnrealizedPnl]:inventory[`unrealizedPnl];
        ]
    ];

    account[`posMargin]:account[`longMargin] + account[`shortMargin]; // TODO both margin
    account[`realizedPnl]+:realizedPnlDelta;
    account[`totalLossPnl]+:min[realizedPnlDelta,0]; // TODO cur off 0
    account[`totalGainPnl]+:max[realizedPnlDelta,0]; // TODO cut off 0
    account[`unrealizedPnl]:account[`longUnrealizedPnl]+account[`shortUnrealizedPnl];
    account[`balance]+:realizedPnlDelta; 
    account[`available]:((account[`balance]+account[`unrealizedPnl])-(account[`orderMargin]+account[`posMargin])); 

    // TODO account average entry price

    // In hedge mode, both long and short positions of the 
    // same contract are sharing the same liquidation price 
    // in cross margin mode.
    // TODO cross margin vs isolated margin (implement for multiple hedged positions)
    liquidationPrice:deriveLiquidationPrice[
        inventory[`currentQty]; // TODO change to account liquidation
        inventory[`avgPrice];
        account[`initMargin];
        account[`maintMargin]]; 
    bankruptPrice:deriveBankruptPrice[
        inventory[`currentQty]; // TODO change to account bankruptcy
        inventory[`avgPrice];
        inventory[`initMargin]];

    // TODO update all liquidation prices for all positions
    // in hedge mode
    inventory[`liquidationPrice]: liquidationPrice;
    inventory[`bankruptPrice]: bankruptPrice;
    account[`bankruptPrice]: bankruptPrice;
    account[`liquidationPrice]: liquidationPrice;

    / netLongPosition
    / account[`withdrawable]: bankruptPrice;
    
    // TODO withdrawable, net open position, unrealized pnl, shortMargin, longMargin, liquidation price

    `.account.Account upsert account;
    `.inventory.Inventory upsert inventory;
    // todo instrument update
    / :(account;inventory);
    };

// update order margin

// TODO remove order margin
    // TODO on hedged position check if close greater than open position.
    $[(abs qty)>0f;[
        $[acc[`positionType]=`HEDGED;
            $[qty>0;
            execFill[acc;getInventory[accountId;`LONG];$[isClose;neg qty;qty];price;fee];
            execFill[acc;getInventory[accountId;`SHORT];$[isClose;neg qty;qty];price;fee]
            ]; // LONG; SHORT
          acc[`positionType]=`COMBINED;
            [execFill[acc;getInventory[accountId;`BOTH];$[side=`SELL;neg qty;qty];price;fee]];
          [0N]
        ];
    ];];
// liquidation

openPosition        :{[]
    update 
        openBuyPremium:0f,
        openSellPremium:0f,
        openBuyOrderQty:0,
        openSellOrderQty:0,
        orderMargin:0f,
        frozen:0f,
        available:0f from `.account.Account where accountId=o[`accountId]; 
};
                    