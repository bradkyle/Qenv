/ \l inventory.q

\d .account
\l util.q

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
// TODO ownFillCount, requestCount
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

AddAccountUpdateEvent  :{[time;account]
    // TODO check if value is null
    :.global.AddEvent[time;`UPDATE;`ACCOUNT_UPDATE;account];
    };

AddAllAccountsUpdatedEvents :{[time]
    :.global.AddEvent[time;`UPDATE;`ACCOUNT_UPDATE;()]; // TODO get all for account
    };

// Account CRUD Logic
// -------------------------------------------------------------->
/ q.account)allCols!(enlist ["b"$not[null[account[allCols]]];((count allCols)-7)#0N;defaults[]])[2]
// Generates a new account with default 
// values and inserts it into the account 
// table. // TODO gen events. // TODO change to event?
NewAccount :{[account;time]
    if[any null account[mandCols]; :0b];
    // Replace null values with their respective defailt values
    // TODO dynamic account type checking
    account:Sanitize[account;defaults[];allCols];
    .logger.Debug["account validated and decorated"];
    / show value type each 1_account;
    / show value type each .account.Account@0;
    `.account.Account upsert account;

    accountId:account[`accountId];
    / AddAccountUpdateEvent[accountId;time];
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

    // todo available, frozen
    update balance:balance-((longValue*fundingRate)-(shortValue*fundingRate)), 
        longFundingCost:longFundingCost+(longValue*fundingRate),
        shortFundingCost:shortFundingCost+(longValue*fundingRate),
        totalFundingCost:totalFundingCost+((longValue*fundingRate)-(longValue*fundingRate))
        by accountId from `.account.Account;
    :AddAllAccountsUpdatedEvents[time];
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
    :AddAccountUpdateEvent[accountId;time];
    };


// Checks that a given account has enough available balance to
// withdraw a given amount and then executes a withdrawal
// updating balance,withdrawCount and withdrawAmount
Withdraw       :{[withdrawn;time;accountId]
    acc:exec from  .account.Account where accountId=accountId;

    $[withdrawn < acc[`available];
        [
        // TODO more expressive and complete upddate statement accounting for margin etc.
        update 
            balance:balance-withdrawAmount 
            withdrawAmount:withdrawAmount+withdrawn
            withdrawCount:withdrawCount+1
            from `.account.Account 
            where accountId=accountId;
        :AddAccountUpdateEvent[accountId;time];
        ];
        [
            0N; //TODO create failure
        ]
    ];  
    };


// Inventory Management
// -------------------------------------------------------------->

/*******************************************************
/ Inventory 

inventoryCount:0;
POSITIONSIDE   : `LONG`SHORT`BOTH;

Inventory: (
    [
        accountId    :  `.account.Account$();
        side         :  `.account.POSITIONSIDE$()
    ]
    currentQty               :  `int$();
    avgPrice                 :  `int$();
    realizedPnl              :  `int$();
    unrealizedPnl            :  `int$();
    posMargin                :  `int$();
    initMargin               :  `int$();
    entryValue               :  `int$();
    totalCost                :  `int$();
    totalEntry               :  `int$();
    execCost                 :  `int$();
    totalCloseVolume         :  `int$();
    totalCrossVolume         :  `int$();
    totalOpenVolume          :  `int$(); 
    totalCloseMarketValue    :  `int$();
    totalCrossMarketValue    :  `int$();
    totalOpenMarketValue     :  `int$(); 
    totalCloseAmt            :  `int$();
    totalCrossAmt            :  `int$();
    totalOpenAmt             :  `int$(); 
    liquidationPrice         :  `int$();
    bankruptPrice            :  `int$();
    breakEvenPrice           :  `int$(); 
    lastValue                :  `int$(); 
    markValue                :  `int$();
    initMarginReq            :  `int$();
    maintMarginReq           :  `int$();
    leverage                 :  `int$();
    effectiveLeverage        :  `int$();
    totalCommission          :  `int$();
    faceValue                :  `int$();
    fillCount                :  `int$());

/ .account.Inventory@(1;`.account.POSITIONSIDE$`BOTH)

DefaultInventory:{(0,`BOTH,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,100,100,0,1,0i)};

/ default:  
NewInventory : {[inventory;time] 
    if[any null inventory[mandCols]; :0b];
    inventory:Sanitize[inventory;defaults[];cols Inventory];
    .logger.Debug["inventory validated and decorated"];

    `.account.Inventory upsert inventory; // TODO check if successful

    };


// Fill
// -------------------------------------------------------------->

AddFill     :{[accountId; price; side; time; isClose; isMaker]

    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[o[`accountId]]," could not be found"]];

    fee: $[isMaker;acc[`activeMakerFee];acc[`activeTakerFee]];

    acc:.account.Account@accountId;
    $[acc[`positionType]=`HEDGED;
        [

        ];
        [

        ]
    ];
    }