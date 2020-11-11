

.engine.logic.fill.DeriveRiskTier                  :{[instrument;account]
    
    };

// TODO move to contract
.engine.logic.fill.DeriveApproxLiquidationPrice     :{[]

    };

// TODO move to contract
.engine.logic.fill.DeriveBankruptcyPrice            :{[]

    };

.engine.logic.fill.InitMarginReq                    :{[]

    };

.engine.logic.fill.MaintMarginReq                   :{[]

    };

.engine.logic.fill.MaintMargin                      :{[]

    };

.engine.logic.fill.InitMargin                       :{[]

    };

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param.engine.logic.fill.  (Account) The.engine.logic.fill.to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.logic.fill.incFill                 :{[i;dlt;price;iv]
    
    // Increase the total Entry and amt
    iv[`amt`totalEntry]+:qty;

    // derive execCost 
    iv[`execCost]+: .engine.logic.contract.ExecCost[
        i`contractType;
        price;
        dlt]; 

    / Calculates the average price of entry for 
    / the current postion, used in calculating 
    / realized and unrealized pnl.
    iv[`avgPrice]: .engine.logic.contract.AvgPrice[
        i`contractType;
        iv`isignum;
        iv`execCost;
        iv`totalEntry];
    iv
    };

// Red Fill is used when the fill is to be removed from the given inventory.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param.engine.logic.fill.  (Account) The.engine.logic.fill.to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return          (Inventory) The new updated inventory
.engine.logic.fill.redFill                 :{[i;dlt;price;iv]

    // When the inventory is being closed it realizes 
    iv[`realizedPnl]+:.engine.logic.contract.RealizedPnl[
        i`contractType;
        dlt;
        price;
        iv[`isignum];
        iv[`avgPrice];
        i[`faceValue]];

    // Remove the dlt amount frou
    // the inventory amount and reset entry
    // values where necessary.
    iv[`amt]-:dlt;
    if[abs[iv[`amt]]=0;iv[`avgPrice`execCost]:0];

    :iv
    };

// Crs Fill is only ever used for combined inventory i.e. `POSITIONSIDE$`BOTH.
/  @param price     (Long) The price at which the fill is occuring
/  @param namt      (Long) The resultant amt of the inventory
/  @param.engine.logic.fill.  (Account) The.engine.logic.fill.to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return          (Inventory) The new updated inventory
.engine.logic.fill.crsFill                 :{[i;dlt;price;iv]
    iv:.engine.logic.fill.redFill[i;price;iv[`amt].engine.logic.fill.iv];
    iv:.engine.logic.fill.incFill[i;price;namt.engine.logic.fill.iv];
    iv[`isignum]:neg[iv[`isignum]];  
    :iv                  
    };


// Derives the set of order updates that will occur
// as a result of the trade and amends them 
// accordingly
/* .engine.logic.fill.ApplyFills[raze'[( */
/*         numLvls#ciId; // instrumentId */
/*         numLvls#caId; // accountId */
/*         state`tside; */ 
/*         state`price; */
/*         sum'[tqty]; */
/*         count[tqty]#reduce; */
/*         numLvls#fillTime)]]; */
.engine.logic.fill.ApplyFills      :{[x]

    // TODO get account
    // TODO cant change position while has open position
    // TODO change to allow ffor mutliple position types

    $[x[`side];
        [
            a[`openBuyQty]:0;
        ];
        [

        ]];

    a[`openBuyQty]:?[amts>0;x[`openBuyQty]+abs[amts];x[`openBuyQty]];
    a[`openBuyValue]+:prd[(a[`openBuyQty];x[`price])];
    a[`openSellQty]:?[amts<0;a[`openSellQty]+abs[amts];a[`openSellQty]];
    a[`openSellValue]+:prd[(a[`openSellQty];x[`price])];

    a[`openOrderValue]:sum[a[`openSellValue`openBuyValue]];
    a[`qtyInMarket]:sum[a[`openSellQty`openBuyQty`netLongPosition`netShortPosition]]; // TODO derive position from account
    a[`valueInMarket]:sum[a[`openSellValue`openBuyValue]]; // TODO derive position from account

    //Derive the account fee tier based on the  
    // trade folume/affiliate count etc.
    feeTier:.engine.logic.fill.DeriveFeeTier[i;a];

    // Remove orders that will increase the position size passed the given tier
    // todo derive order margin,
    // todo derive for leverage and max amt etc.
    riskTiers:.engine.logic.fill.DeriveRiskTier[i;a]; // TODO test this + make faster
    .test.riskTiers:.test.riskTiers;
    a[`initMarginReq]:riskTiers[`imr]+(i[`riskBuffer] | 0);
    a[`maintMarginReq]:riskTiers[`mmr]+(i[`riskBuffer] | 0);
    a[`orderMargin]:a[`openOrderValue]^div[a[`openOrderValue];a[`leverage]]; // TODO optional charge based on config
    
    / a[`leverage]:0;
    // TODO derive only the outstanding amount
    // TODO derive better
    // derive the instantaneous loss that will be incurred for each order
    // placement and thereafter derive the cumulative loss for each order
    // filter out orders that attribute to insufficient balance where neccessary
    a[`openBuyLoss]:(min[0,(i[`markPrice]*a[`openBuyQty])-a[`openBuyValue]] | 0); // TODO convert to long
    a[`openSellLoss]:(min[0,(i[`markPrice]*a[`openSellQty])-a[`openSellValue]] |0); // TODO convert to long
    a[`openLoss]:(sum[a`openSellLoss`openBuyLoss] | 0); // TODO convert to long
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0); // TODO convert to long
    if[a[`available]<prd[a[`initMarginReq`valueInMarket]];[0;"Account has insufficient balance"]]; 

    iId:$[];
    iv:.engine.model.inventory.GetInventoryByKey[];

    // If position type is 
    iv:$[k=0;[ 
            // If position type is hedged would use 
            // the reduce and side to imply which fill 
            // logic to use
            $[reduce;
                iv:.engine.logic.fill.redFill[i;dlt;price;iv];
                iv:.engine.logic.fill.incFill[i;dlt;price;iv]];
                 
      ];
      k=1;[
            // If the position is long would derive the next position
            // and then execute functions accordingly
            /* namt:abs[iB[`amt]+neg[qty]]; // TODO fix */
            /* $[(reduce or (abs[i[`amt]]>abs[namt]); // TODO make sure sign is correct */
            /*     iv:.engine.logic.fill.redFill[i;dlt;price;iv]; */
            /*     ((iB[`amt]*namt)<0)); */
            /*     []; */
            /*     [] */
            /*     iv:.engine.logic.fill.crsFill[i;dlt;price;iv]; */
            /*     iv:.engine.logic.fill.incFill[i;dlt;price;iv]; */
      ];'INVALID_POSITION_TYPE];

    // Common logic // TODO make aplicable to active inventory
    iv[`realizedGrossPnl]-:cost;
    iv[`fillCount]+:1;
    iv[`unrealizedPnl]:.engine.logic.contract.UnrealizedPnl[ // TODO
        i[`contractType]; 
        iv[`amt];
        iv[`isignum];
        iv[`avgPrice];
        i[`markPrice];
        i[`faceValue]];
    i[`markValue]+:qty;

    i[`entryValue]:(((%/)i`amt`avgPrice) | 0); // TODO to long
    i[`posMargin]:(((%/)i`entryValue`leverage) | 0); // TODO to long

    a[`balance]-:cost;
    a[`totalCommission]+:cost;
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);
    a[`tradeVolume]+:qty;
 
		.engine.model.account.UpdateAccount[a];
		.engine.model.inventory.UpdateInventory[i];
    .engine.model.instrument.UpdateInstrument[];

    };

  
  
  
