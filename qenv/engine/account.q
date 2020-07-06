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
Account: (
            [accountId          : `long$()]
            balance             : `float$();
            frozen              : `float$();
            maintMargin         : `float$();
            available           : `float$();
            openBuyOrderQty     : `long$();
            openSellOrderQty    : `long$();
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
            longMargin          : `float$();
            shortMargin         : `float$();
            shortFundingCost    : `float$();
            longFundingCost     : `float$();
            totalFundingCost    : `float$();
            realizedPnl         : `float$();
            unrealizedPnl       : `float$();
            activeMakerFee      : `float$();
            activeTakerFee      : `float$()
        );

mandCols:();
defaults:{:((accountCount+:1),0f,0f,0f,0f,0,0,`CROSS,`COMBINED,0f,0,0f,0,0,0,0,0,0f,0f,0f,0f,0f,0f,0f,0f,0f)};
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

// Deriving Cross and Isolated liquidation price
// -------------------------------------------------------------->

// TODO
/ crossLiquidationPrice{[]0N};

// TODO
/ crossBankruptcyPrice{[]0N};

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
/ your maintenance margin requirement.
deriveMaintainenceMargin    :{[qty;takerFee;markPrice;faceValue]
    :((maintMarginCoeff[takerFee;markPrice]+takerFee)*qty)*markPrice;
    };

// TODO type assertions
// TODO what happens when in hedge mode and close is larger than position
// Converts an execution from a fill operation on an order to the corresponding 
// position and balance respectively. 
execFill    :{[account;inventory;fillQty;price;fee]
    $[abs[fillQty]>0;0N;:0b];
    $[price>0 & (type price)=-9h;0N;:0b];
    $[(type account)=99h;0N;:0b];
    $[(type inventory)=99h;0N;:0b];
    // TODO errors
    cost: fee * abs fillQty;
    nxtQty: inventory[`currentQty] + fillQty;
    leverage: inventory[`leverage];
    currentQty: inventory[`currentQty];
    faceValue:inventory[`faceValue]; // TODO change

    realizedPnlDelta:0f; // TODO change to inst realized pnl

    $[(currentQty*nxtQty)<0;
      [
        // The position is being crossed i.e.
        // being changed from long to short or
        // short to long and visa versa.  
        realizedPnlDelta:deriveRealisedPnl[inventory[`avgPrice];price;faceValue;fillQty];

        // Reset entries because of the change in position
        // side and add an entry of a size equal to the
        // size of the next position.
        inventory[`totalEntry]: abs[nxtQty];
        inventory[`execCost]: floor[1e8%price] * abs[nxtQty];
        inventory[`currentQty]: nxtQty;
        inventory[`totalCrossVolume]+:fillQty;

        / Calculates the average price of entry for the current postion, used in calculating 
        / realized and unrealized pnl.
        inventory[`avgPrice]: {$[signum[x[`currentQty]]>0;
           1e8%floor[x[`execCost]%x[`totalEntry]];
           1e8%ceiling[x[`execCost]%x[`totalEntry]]
          ]}[inventory];

        // Closing of the position means that the value is
        // moving from the current position into the balance
        // cost is subtracted from this execution amount.
        // Because the execution is larger than the position the 
        // amount of value added back to the balance is equivalent
        // to the position.
        amt:CntToMrg[((abs[currentQty]-abs[nxtQty])%leverage)-cost;price;faceValue;0b];
        account[`balance]+:(amt + realizedPnlDelta)
        inventory[`totalCrossAmt]+:amt;
      ];
      (abs currentQty)>(abs nxtQty);
      [
        // Because the position is being closed the realized pnl 
        // will be inversely proportional to the position.
        realizedPnlDelta:deriveRealisedPnl[inventory[`avgPrice];price;faceValue;fillQty];
        inventory[`currentQty]: nxtQty;
        inventory[`realizedPnl]+:realizedPnlDelta;
        inventory[`totalCloseVolume]+:fillQty;

        // Closing of position means that the value is moving
        // from the current position into the balance, cost is
        // subtracted from this execution amount, it also means
        // that the execution is smaller than the position
        // and as such is used as the value
        amt:CntToMrg[(abs[fillQty]%leverage)-cost;price;faceValue;1b];
        account[`balance]+: (amt + realizedPnlDelta);
        inventory[`totalCloseAmt]+:amt;
      ];
      [
        / Because the current position is being increased
        / an entry is added for calculation of average entry
        / price. 
        inventory[`totalEntry]+: abs[fillQty];
        inventory[`execCost]+: floor[1e8%price] * abs[fillQty];
        inventory[`currentQty]: nxtQty;
        inventory[`totalOpenVolume]+:fillQty;

        / Calculates the average price of entry for the current postion, used in calculating 
        / realized and unrealized pnl.
        inventory[`avgPrice]: {$[signum[x[`currentQty]]>0;
           1e8%floor[x[`execCost]%x[`totalEntry]];
           1e8%ceiling[x[`execCost]%x[`totalEntry]]
          ]}[inventory];

        / Opening of position means that value is moving from
        / the current balance to the position and as thus
        / the cost is added to the execution i.e. an additional
        / amount is subtracted to simulate fee.
        amt: CntToMrg[(abs[fillQty]%leverage)+cost;price;faceValue;1b];
        account[`balance]-: amt;
        inventory[`totalOpenAmt]+:amt;
      ]
    ];

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
    // TODO change available 

    $[nextQty>0;
        [
            account[`longMargin]+:0;
            account[`maintMargin]+:0;
        ];
        [

        ]
    ];
    
    / TODO implement
    / inventory[`realizedGrossPnl]+:(realizedPnlDelta - (cost%price))
    / account[`totalCommission]+:(cost%price);
    // TODO pos margin, order margin, available, liquidation price,
    // frozen, maintMargin, netLongPosition, netShortPosition, available, posMargin etc.

    `.account.Account upsert account;
    `.inventory.Inventory upsert inventory;
    / :(account;inventory);
    };

// TODO type assertions
// Apply fill is an internal function i.e. it is not exposed
// to the engine but is used by the orderbook to add a given
// qty to the active position of an account.
// todo allow for onlyclose and calcualte fee
ApplyFill  :{[qty;price;side;time;isClose;isMaker;accountId]
    events:();
    acc: exec from Account where accountId=accountId;
    fee: $[isMaker;acc[`activeMakerFee];acc[`activeTakerFee]];

    // TODO on hedged position check if close greater than open position.
    $[(abs qty)>0f;[
        $[acc[`positionType]=`HEDGED;
            $[qty>0;
            execFill[acc;exec from .inventory.Inventory where accountId=accountId & side=`LONG;$[isClose;neg qty;qty];price;fee];
            execFill[acc;exec from .inventory.Inventory where accountId=accountId & side=`SHORT;$[isClose;neg qty;qty];price;fee]
            ]; // LONG; SHORT
          acc[`positionType]=`COMBINED;
            [execFill[acc;exec from .inventory.Inventory where accountId=accountId & side=`BOTH;$[side=`SELL;neg qty;qty];price;fee]];
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
    update balance:balance-((longMargin*fundingRate)-(shortMargin*fundingRate)), 
        longFundingCost:longFundingCost+(longMargin*fundingRate),
        shortFundingCost:shortFundingCost+(shortMargin*fundingRate),
        totalFundingCost:totalFundingCost+((longMargin*fundingRate)-(shortMargin*fundingRate))
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