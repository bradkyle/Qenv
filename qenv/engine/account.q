\l inventory.q

\d .account
\l util.q
\l state.q

accountCount:0;

/*******************************************************
/ account related enumerations  
MARGINTYPE      :   `CROSS`ISOLATED;
POSITIONTYPE    :   `HEDGED`COMBINED;

// Account state in this instance serves as a proxy
// for a single agent and contains config therin
// pertaining to what the agent setting is.
// TODO realized Gross PNL, unrealized Gross PNL, total Unrealized Pnl etc
// TODO is suspended, state etc.
Account: (
            [accountId          : `long$()]
            balance             : `float$();
            frozen              : `float$();
            maintMargin         : `float$();
            available           : `float$();
            withdrawable        : `float$();
            openBuyOrderQty     : `long$();
            openBuyPremium      : `float$();
            openSellOrderQty    : `long$();
            openSellPremium     : `float$();
            orderMargin         : `float$();
            marginType          : `.account.MARGINTYPE$();
            positionType        : `.account.POSITIONTYPE$();
            depositAmount       : `float$();
            depositCount        : `long$();
            withdrawAmount      : `float$();
            withdrawCount       : `long$();
            tradeVolume         : `long$();
            tradeCount          : `long$();
            netLongPosition     : `long$();
            netShortPosition    : `long$();
            posMargin           : `float$();
            longMargin          : `float$();
            shortMargin         : `float$();
            longValue           : `float$();
            shortValue          : `float$();
            shortFundingCost    : `float$();
            longFundingCost     : `float$();
            totalFundingCost    : `float$();
            totalLossPnl        : `float$();
            totalGainPnl        : `float$();
            realizedPnl         : `float$();
            liquidationPrice    : `float$();
            bankruptPrice       : `float$();
            longUnrealizedPnl   : `float$();
            shortUnrealizedPnl  : `float$();
            unrealizedPnl       : `float$();
            activeMakerFee      : `float$();
            activeTakerFee      : `float$();
            totalCommission     : `float$()
        );

mandCols:();
defaults:{:((accountCount+:1),0f,0f,0f,0f,0f,0,0f,0,0f,0f,`CROSS,`COMBINED,0f,0,0f,0,0,0,0,0,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f)};
allCols:cols Account;

// Event creation utilities
// -------------------------------------------------------------->

MakeAccountUpdateEvent  :{[time;account]
    // TODO check if value is null
    :MakeEvent[time;`UPDATE;`ACCOUNT_UPDATE;account];
    };

MakeAllAccountsUpdatedEvents :{[time]
    :MakeEvent[time;`UPDATE;`ACCOUNT_UPDATE;()]; // TODO get all for account
    };

// Account CRUD Logic
// -------------------------------------------------------------->
/ q.account)allCols!(enlist ["b"$not[null[account[allCols]]];((count allCols)-7)#0N;defaults[]])[2]
// Generates a new account with default 
// values and inserts it into the account 
// table. // TODO gen events. // TODO change to event?
NewAccount :{[account;time]
    events:();
    if[any null account[mandCols]; :0b];
    // Replace null values with their respective defailt values
    // TODO dynamic account type checking
    account:Sanitize[account;defaults[];allCols];
    .logger.Debug["account validated and decorated"];
    / show value type each 1_account;
    / show value type each .account.Account@0;
    `.account.Account upsert account;

    accountId:account[`accountId];
    MakeAccountUpdateEvent[accountId;time];
    .inventory.NewInventory[.inventory.mandCols!(accountId;`LONG);time];
    .inventory.NewInventory[.inventory.mandCols!(accountId;`SHORT);time];
    .inventory.NewInventory[.inventory.mandCols!(accountId;`BOTH);time];

    :events;
    };

// TODO
ResetAccount :{[account;time]

    };

// Deriving Isolated Values
// -------------------------------------------------------------->


// TODO
/ isolatedLiquidationPrice{[]0N};

// Fill and Position Related Logic
// -------------------------------------------------------------->

// Derives the price per contract 
pricePerContract  :{[faceValue;price]$[price>0;faceValue%price;0]};
maintMarginCoeff  :{[takerFee;fundingRate] 0.005 + takerFee + fundingRate}

// Calculates the realized profit and losses for a given position, size is a positive
// or negative number that represents the portion of the current position that has been
// closed and thus should be of the same side as the position i.e. negative for short and 
// positive for long.
deriveRealisedPnl :{[avgPrice;fillPrice;faceValue;fillQty]; // TODO is fillQty sign agnostic?
    :(pricePerContract[faceValue;avgPrice] - pricePerContract[faceValue;fillPrice])*fillQty;
    };

// Returns the unrealized profit for the current position considering the current
// mark price and the average entry price (uses mark price to prevent liquidation).
deriveUnrealizedPnl :{[avgPrice;markPrice;faceValue;currentQty]; // TODO is currentQty sign agnostic?
    :(pricePerContract[faceValue;avgPrice] - pricePerContract[faceValue;markPrice])*currentQty;
    };

/ This is the minimum amount of margin you must maintain to avoid liquidation on your position.
/ The amount of commission applicable to close out all your positions will also be added onto 
/ your maintenance margin requirement. // TODO make strategy dependent
deriveMaintainenceMargin    :{[currentQty;takerFee;markPrice;faceValue]
    :((maintMarginCoeff[takerFee;markPrice]+takerFee)*currentQty)*pricePerContract[faceValue;markPrice];
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

// TODO
deriveBreakevenPrice        :{[]};


// TODO type assertions
// TODO what happens when in hedge mode and close is larger than position
// Converts an execution from a fill operation on an order to the corresponding 
// position and balance respectively. 
// TODO realized pnl entry happens daily

// Huobi hedged cross
// only remove 50 from the position of 50 i.e. flatten the position
// If it is Limit order，would reject the order and error. If it is 
// Trigger Orders, would only remove 50 from the position of 50

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

getInventory    :{[accountId;side]
    exec from .inventory.Inventory where accountId=accountId & side=side;
    };

// TODO type assertions
// Apply fill is an internal function i.e. it is not exposed
// to the engine but is used by the orderbook to add a given
// qty to the active position of an account.
// todo allow for onlyclose and calcualte fee
// TODO update active fees
ApplyFill  :{[qty;price;side;time;isClose;isMaker;accountId]
    events:();
    show 99#"H";                                
    ins:.instrument.GetActiveInstrument[];
    acc: exec from Account where accountId=accountId;
    fee: $[isMaker;acc[`activeMakerFee];acc[`activeTakerFee]];
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
    :events;
    };

// Funding Event/Logic //TODO convert to cnt for reference
// -------------------------------------------------------------->
// Positive funding rate means long pays short an amount equal to their current position
// * the funding rate.
// Negative funding rate means short pays long an amount equal to their current position
// * the funding rate.
// The funding rate6\ can either be applied to the current position or to the margin/balance.
// This function is accessed by the engine upon a funding event and unilaterally applies
// an update to all the open position quantites held in the schema/state representation.
// TODO next funding rate and next funding time (funding time delta)
ApplyFunding       :{[fundingRate;nextFundingTime;time] // TODO convert to cnt (cntPosMrg)

    // todo available, 
    update balance:balance-((longValue*fundingRate)-(shortValue*fundingRate)), 
        longFundingCost:longFundingCost+(longValue*fundingRate),
        shortFundingCost:shortFundingCost+(longValue*fundingRate),
        totalFundingCost:totalFundingCost+((longValue*fundingRate)-(longValue*fundingRate))
        by accountId from `.account.Account;
    :MakeAllAccountsUpdatedEvents[time];
    };

// Balance Management
// -------------------------------------------------------------->

Deposit  :{[deposited;time;accountId]
    // TODO more expressive and complete upddate statement accounting for margin etc.
    update 
        balance:balance+deposited, 
        depositAmount:depositAmount+deposited,
        depositCount:depositCount+1
        from `.account.Account 
        where accountId=accountId;
    :MakeAccountUpdateEvent[accountId;time];
    };


// Checks that a given account has enough available balance to
// withdraw a given amount and then executes a withdrawal
// updating balance,withdrawCount and withdrawAmount
Withdraw       :{[withdrawn;time;accountId]
    acc:exec from  .account.Account where accountId=accountId;

    $[withdrawn < acc[`available];
        // TODO more expressive and complete upddate statement accounting for margin etc.
        update 
            balance:balance-withdrawAmount 
            withdrawAmount:withdrawAmount+withdrawn
            withdrawCount:withdrawCount+1
            from `.account.Account 
            where accountId=accountId;
        :MakeAccountUpdateEvent[accountId;time];
    ];  
    :();
    };