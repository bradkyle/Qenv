/ \l inventory.q
// THIS FILE REPRESENTS THE LOGIC PERTAINING TO THE ACCOUNT OF AN INSTRUMENT


\d .account
\l util.q

isinv:{x[`contractType]=`INVERSE}; // Is the instrument an inverse contract
ppc:{x[`faceValue]%y}; // Derive price per contract

accountCount:0;

// TODO executions

/*******************************************************
/ account related enumerations  
MARGINTYPE      :   `CROSS`ISOLATED;
POSITIONTYPE    :   `HEDGED`COMBINED;

// FAIR price vs ema 
// Account state in this instance serves as a proxy
// for a single agent and contains config therin
// pertaining to what the agent setting is.
// TODO realized Gross PNL, unrealized Gross PNL, total Unrealized Pnl etc
// TODO is suspended, state etc.
// TODO ownFillCount, requestCount
// TODO margin call price
Account: (
            [accountId          : `long$()]
            balance             : `long$();
            frozen              : `long$();
            maintMargin         : `long$();
            available           : `long$();
            withdrawable        : `long$();
            openBuyQty          : `long$();
            openBuyLoss         : `long$();
            openBuyValue        : `long$();
            openSellLoss        : `long$();
            openSellValue       : `long$();
            openSellQty         : `long$();
            openLoss            : `long$();
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
            shortFundingCost    : `long$();
            longFundingCost     : `long$();
            totalFundingCost    : `long$();
            totalLossPnl        : `long$();
            totalGainPnl        : `long$();
            realizedPnl         : `long$();
            unrealizedPnl       : `long$();
            liquidationPrice    : `long$();
            bankruptPrice       : `long$();
            totalCommission     : `long$();
            selfFillCount       : `long$();
            selfFillVolume      : `long$();
            leverage            : `long$();
            monthVolume         : `long$());

mandCols:();
defaults:{:((accountCount+:1),0,0,0,0,0,0,0,0,0,0,0,0,0,`CROSS,`COMBINED,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)};
allCols:cols Account;

// Event creation utilities
// -------------------------------------------------------------->

AddAccountUpdateEvent  :{[time;account] // TODO convert to list instead of dict
    // TODO check if value is null
    :.global.AddEvent[time;`UPDATE;`ACCOUNT_UPDATE;account];
    };

AddAllAccountsUpdatedEvents :{[time] // TODO convert to list instead of dict
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

    / AddAccountUpdateEvent[accountId;time];
    };


// Global Account Utils
// -------------------------------------------------------------->

// TODO derive avg price, total entry, exec cost, gross open premium etc.

OrderLoss:{(sum[x`openSellLoss`openBuyLoss] | 0)};
Available:{((x[`balance]-sum[x`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0)};

// Funding Application
// -------------------------------------------------------------->

ApplyFunding       :{[fundingRate;nextFundingRate;nextFundingTime;time] // TODO convert to cnt (cntPosMrg)
    
    :.account.AddAllAccountsUpdatedEvents[time];
    };

// Balance Management
// -------------------------------------------------------------->

// Adds a given amount to the accounts balance.
// Update available/withdrawable etc.
Deposit  :{[deposited;time;accountId]
    // TODO more expressive and complete upddate statement accounting for margin etc.
    // Account: available, liquidationprice, bankruptcyprice, depositCount
    acc:exec from  .account.Account where accountId=accountId;

    acc[`balance]-:deposited;
    acc[`depositAmount]+:deposited;
    acc[`depositCount]+:1;
    acc[`withdrawable]+:deposited;
    / account[`available]:.account.Available[acc]; // TODO
    / account[`initMarginReq`maintMarginReq]

    ![`.account.Account;
        enlist (=;`accountId;accountId);
        0b;acc];

    :.account.AddAccountUpdateEvent[acc;time];
    };


// Checks that a given account has enough available balance to
// withdraw a given amount and then executes a withdrawal
// updating balance,withdrawCount and withdrawAmount
// Update available/withdrawable etc
/  @param withdrawn (Long) The amount that is to be withdrawn
/  @param time (datetime) The time of the withdraw event
/  @param accountId (Long) The id of the account to withdraw from
/  @throws InvalidAccountId accountId was not found.
/  @throws InsufficientMargin account has insufficient margin for withdraw
Withdraw       :{[withdrawn;time;accountId]
    acc:exec from  .account.Account where accountId=accountId;
    // Account: available, liquidationprice, bankruptcyprice, withdrawCount

    $[withdrawn < acc[`withdrawable];
        [
        // TODO more expressive and complete upddate statement accounting for margin etc.

        acc[`balance]-:withdrawn;
        acc[`withdrawAmount]+:withdrawn;
        acc[`withdrawCount]+:1;
        acc[`withdrawable]-:withdrawn;
        / account[`available]:.account.Available[acc]; // TODO

        ![`.account.Account;
            enlist (=;`accountId;accountId);
            0b;acc];
        
        :.account.AddAccountUpdateEvent[acc;time];
        ];'InsufficientMargin];  
    };


// Inventory Management
// -------------------------------------------------------------->

/*******************************************************
/ Inventory 

inventoryCount:0;
POSITIONSIDE   : `LONG`SHORT`BOTH;
// TODO posState
// TODO liqudation price
Inventory: (
    [
        accountId    :  `.account.Account$();
        side         :  `.account.POSITIONSIDE$()
    ]
    amt                      :  `long$();
    avgPrice                 :  `long$();
    realizedPnl              :  `long$();
    unrealizedPnl            :  `long$();
    posMargin                :  `long$();
    entryValue               :  `long$();
    totalEntry               :  `long$();
    execCost                 :  `long$();
    initMarginReq            :  `long$();
    maintMarginReq           :  `long$();
    leverage                 :  `long$();
    isignum                  :  `long$();
    fillCount                :  `long$());

/ .account.Inventory@(1;`.account.POSITIONSIDE$`BOTH)

DefaultInventory:{(0,`BOTH,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)};

/ default:  // TODO validation here
NewInventory : {[inventory;time] 
    if[any null inventory[`accountId`side]; :0b];
    inventory[`isignum]:$[inventory[`side]=`LONG;
        1;
      inventory[`side]=`SHORT;
        -1;
      inventory[`side]=`BOTH;
        1;
        'INVALID_POSITIONSIDE;
    ];
    inventory:Sanitize[inventory;DefaultInventory[];cols Inventory];
    .logger.Debug["inventory validated and decorated"];
    `.account.Inventory upsert inventory; // TODO check if successful
    };

// Fill
// -------------------------------------------------------------->

// Gets the position side that an order fills
HedgedSide      :{[side] :$[side=`SELL;`SHORT;`LONG]};
HedgedNegSide   :{[side] :$[side=`SELL;`LONG;`SHORT]};

// Increments the occurance of an agent's self fill.
// @x : unique account id
// @y : self filled count
// @z : amount that is self filled
IncSelfFill    :{
        ![`.account.Account;
            enlist (=;`accountId;x);
            0b;`selfFillCount`selfFillVolume!(
                (+;`selfFillCount;y);
                (+;`selfFillVolume;z)
            )];};

dcMrg   :{`long(x*y)};
dcCnt   :{`long(x*y)};

// Main Public Fill Function
// ---------------------------------------------------------------------------------------->

// TODO make global enums file
// TOD7,776e+6/1000
// TODO make simpler
// TODO update applicable fee when neccessary // TODO convert accountId/instrumentId to dictionary
// Apply fill is only used from within ProcessTrade and as such should assume that multipliers are correct
ApplyFill     :{[accountId; instrumentId; side; time; reduceOnly; isMaker; price; qty]
    qty:abs[qty];

    // TODO if is maker reduce order margin here!
    // TODO fill cannot occur when BOTH inventory is open

    // Validation
    // ---------------------------------------------------------------------------------------->

    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[accountId]," could not be found"]];

    if[null instrumentId; :.event.AddFailure[time;`INVALID_INSTRUMENTID;"instrumentId is null"]];
    if[not(instrumentId in key .instrument.Instrument);
        :.event.AddFailure[time;`INVALID_INSTRUMENTID;"An instrument with the id:",string[instrumentId]," could not be found"]];

    acc:.account.Account@accountId;
    ins:.instrument.Instrument@instrumentId;

    // Common derivations
    fee: $[isMaker;acc[`activeMakerFee];acc[`activeTakerFee]];
    cost:qty*fee;
    markprice:ins[`markPrice];


    // TODO if oi exists

    ![`.account.Account;enlist(=;`accountId;accountId);0b;acc];
    ![`.account.Inventory;((=;`accountId;accountId);(=;`side;iside));0b;i];

    };


// Liquidation And MarkPrice updates
// -------------------------------------------------------------->

GetInsolvent    :{[select from x where available<maintMarginReq]};

UpdateMarkPrice : {[mp;instrumentId;time]
    / https://www.bitmex.com/app/liquidationExamples
    / https://www.bitmex.com/app/liquidation
    / https://www.bitmex.com/app/wsAPI#Deleverage
    / https://www.bitmex.com/app/wsAPI#Liquidation
    / https://huobiglobal.zendesk.com/hc/en-us/articles/360000143042-Partial-Liquidation-of-Futures
    / https://www.okex.com/academy/en/full-liquidation
    / https://www.binance.com/en/support/faq/360033525271
    / https://binance.zendesk.com/hc/en-us/articles/360033525271-Liquidation
    / https://help.ftx.com/hc/en-us/articles/360027668712-Liquidations

    // TODO validate instrument exists

    ins:.instrument.Instrument@instrumentId;
    // TODO derive risk buffer

    // Instrument specific
    UpdateMarkPrice[mp;ins]'(
                (select from .account.Account where sum[netLongPosition,netShortPosition,openBuyQty,openSellQty]>0) 
                lj (select sum unrealizedPnl by accountId from i)); // TODO test this
    
    };