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
            balance             : `long$();
            frozen              : `long$();
            maintMargin         : `long$();
            available           : `long$();
            withdrawable        : `long$();
            openBuyOrderQty     : `long$();
            openBuyPremium      : `long$();
            openSellOrderQty    : `long$();
            openSellPremium     : `long$();
            orderMargin         : `long$();
            marginType          : `.account.MARGINTYPE$();
            positionType        : `.account.POSITIONTYPE$();
            depositAmount       : `long$();
            depositCount        : `long$();
            withdrawAmount      : `long$();
            withdrawCount       : `long$();
            tradeVolume         : `long$();
            tradeCount          : `long$();
            netLongPosition     : `long$();
            netShortPosition    : `long$();
            posMargin           : `long$();
            longMargin          : `long$();
            shortMargin         : `long$();
            longValue           : `long$();
            shortValue          : `long$();
            shortFundingCost    : `long$();
            longFundingCost     : `long$();
            totalFundingCost    : `long$();
            totalLossPnl        : `long$();
            totalGainPnl        : `long$();
            realizedPnl         : `long$();
            liquidationPrice    : `long$();
            bankruptPrice       : `long$();
            longUnrealizedPnl   : `long$();
            shortUnrealizedPnl  : `long$();
            unrealizedPnl       : `long$();
            activeMakerFee      : `long$();
            activeTakerFee      : `long$();
            totalCommission     : `long$()
        );

mandCols:();
defaults:{:((accountCount+:1),0,0,0,0,0,0,0,0,0,0,`CROSS,`COMBINED,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)};
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
    currentQty               :  `long$();
    avgPrice                 :  `long$();
    realizedPnl              :  `long$();
    unrealizedPnl            :  `long$();
    posMargin                :  `long$();
    initMargin               :  `long$();
    entryValue               :  `long$();
    totalCost                :  `long$();
    totalEntry               :  `long$();
    execCost                 :  `long$();
    totalCloseVolume         :  `long$();
    totalCrossVolume         :  `long$();
    totalOpenVolume          :  `long$(); 
    totalCloseMarketValue    :  `long$();
    totalCrossMarketValue    :  `long$();
    totalOpenMarketValue     :  `long$(); 
    totalCloseAmt            :  `long$();
    totalCrossAmt            :  `long$();
    totalOpenAmt             :  `long$(); 
    liquidationPrice         :  `long$();
    bankruptPrice            :  `long$();
    breakEvenPrice           :  `long$(); 
    lastValue                :  `long$(); 
    markValue                :  `long$();
    initMarginReq            :  `long$();
    maintMarginReq           :  `long$();
    leverage                 :  `long$();
    effectiveLeverage        :  `long$();
    totalCommission          :  `long$();
    faceValue                :  `long$();
    fillCount                :  `long$());

/ .account.Inventory@(1;`.account.POSITIONSIDE$`BOTH)

DefaultInventory:{(0,`BOTH,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,100,100,0,1,0)};

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

    acc:.account.Account@accountId;
    fee: $[isMaker;acc[`activeMakerFee];acc[`activeTakerFee]];
    if[]

    $[acc[`positionType]=`HEDGED;
        $[isClose;
            [

            ];
            [

            ]
        ];
        $[isClose or ();
            [];
            []
        ]
    ];
    }