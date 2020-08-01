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

// Deriving Isolated Values
// -------------------------------------------------------------->


// TODO
/ isolatedLiquidationPrice{[]0N};

// Fill and Position Related Logic
// -------------------------------------------------------------->

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
    ins:.instrument.GetActiveInstrument[];
    acc: exec from Account where accountId=accountId;
    fee: $[isMaker;acc[`activeMakerFee];acc[`activeTakerFee]];
    
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


/*******************************************************
/ Inventory Related Enumerations

inventoryCount:0;

/*******************************************************
/ position related enumerations  
POSITIONSIDE   : `LONG`SHORT`BOTH;

Inventory: (
    [inventoryId             :  `long$()]
    accountId                :  `.account.Account$();
    side                     :  `.inventory.POSITIONSIDE$();
    currentQty               :  `long$();
    avgPrice                 :  `float$();
    realizedPnl              :  `float$();
    unrealizedPnl            :  `float$();
    posMargin                :  `float$();
    initMargin               :  `float$();
    entryValue               :  `float$();
    totalCost                :  `long$();
    totalEntry               :  `long$();
    execCost                 :  `long$();
    totalCloseVolume         :  `long$();
    totalCrossVolume         :  `long$();
    totalOpenVolume          :  `long$(); 
    totalCloseMarketValue    :  `float$();
    totalCrossMarketValue    :  `float$();
    totalOpenMarketValue     :  `float$(); 
    totalCloseAmt            :  `float$();
    totalCrossAmt            :  `float$();
    totalOpenAmt             :  `float$(); 
    liquidationPrice         :  `float$();
    bankruptPrice            :  `float$();
    breakEvenPrice           :  `float$();
    lastPrice                :  `float$();
    lastValue                :  `float$();
    markPrice                :  `float$();
    markValue                :  `float$();
    initMarginReq            :  `float$();
    maintMarginReq           :  `float$();
    leverage                 :  `float$();
    effectiveLeverage        :  `float$();
    totalCommission          :  `float$();
    faceValue                :  `long$();
    fillCount                :  `long$());


mandCols:`accountId`side; // TODO update defaults function to derive from default instrument
DefaultInventory:{((inventoryCount+:1),0,`BOTH,0,0f,0f,0f,0f,0f,0f,0,0,0,0,0,0,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,100f,100f,0f,1,0)};

/ default:  
NewInventory : {[inventory;time] 
    if[any null inventory[mandCols]; :0b];
    inventory:Sanitize[inventory;defaults[];cols Inventory];
    .logger.Debug["inventory validated and decorated"];

    `.inventory.Inventory upsert inventory; // TODO check if successful

    };
