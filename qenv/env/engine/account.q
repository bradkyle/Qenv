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
            marginType          : `long$();
            positionType        : `long$();
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
defaults:{:((accountCount+:1),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)};
allCols:cols Account;

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

    $[withdrawn < acc[`withdrawable];[
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
        side         :  `long$()
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

// Main Public Fill Function
// ---------------------------------------------------------------------------------------->

// Convert to matrix/batch/array oriented
ApplyFill     :{[account; instrument; side; time; reduceOnly; isMaker; price; qty]

    // Common derivations
    fee: $[isMaker;acc[`activeMakerFee];acc[`activeTakerFee]];
    cost:qty*fee;
    markprice:ins[`markPrice];

    // preprocessing values based on instrument?

    // TODO if oi exists

    ![`.account.Account;enlist(=;`accountId;accountId);0b;acc]; // change to amend
    ![`.account.Inventory;((=;`accountId;accountId);(=;`side;iside));0b;i]; // change to amend

    };


// UpdateMarkPrice
// -------------------------------------------------------------->

UpdateMarkPrice : {[mp;instrumentId;time]
    // TODO validate instrument exists

    ins:.instrument.Instrument@instrumentId;
    // TODO derive risk buffer

    // Instrument specific
    UpdateMarkPrice[mp;ins]'(
                (select from .account.Account where sum[netLongPosition,netShortPosition,openBuyQty,openSellQty]>0) 
                lj (select sum unrealizedPnl by accountId from i)); // TODO test this
    
    };

