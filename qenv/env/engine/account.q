/ \l inventory.q
// THIS FILE REPRESENTS THE LOGIC PERTAINING TO THE ACCOUNT OF AN INSTRUMENT

.account.accountCount:0;

// TODO executions

/*******************************************************

// FAIR price vs ema 
// Account state in this instance serves as a proxy
// for a single agent and contains config therin
// pertaining to what the agent setting is.
// TODO realized Gross PNL, unrealized Gross PNL, total Unrealized Pnl etc
// TODO is suspended, state etc.
// TODO ownFillCount, requestCount
// TODO margin call price
.account.Account: (
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
            netLongPosition     : `long$(); // Scalar Positive > 0 
            netShortPosition    : `long$(); // Scalar Negative < 0
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

.account.mandCols:();
.account.allCols:cols .account.Account;

// Account CRUD Logic
// -------------------------------------------------------------->
/ q.account)allCols!(enlist ["b"$not[null[account[allCols]]];((count allCols)-7)#0N;defaults[]])[2]
// Generates a new account with default 
// values and inserts it into the account 
// table. // TODO gen events. // TODO change to event?
.account.NewAccount :{[account;time]
    if[any null account[mandCols]; :0b];
    // Replace null values with their respective defailt values
    // TODO dynamic account type checking
    acc:Sanitize[account;defaults[];allCols];
    / show value type each 1_account;
    / show value type each .account.Account@0;
    .account.Account,:acc;
    };


// Global Account Utils
// -------------------------------------------------------------->

// TODO derive avg price, total entry, exec cost, gross open premium etc.

.account.OrderLoss:{(sum[x`openSellLoss`openBuyLoss] | 0)};
.account.Available:{((x[`balance]-sum[x`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0)};

.account.IsAccountInsolvent         :{
    
    };

.account.GetInMarketAccounts:{
    (select from .account.Account where sum[netLongPosition,netShortPosition,openBuyQty,openSellQty]>0)
    };
 
// IncSelfFill
// -------------------------------------------------------------->

// Increments the occurance of an agent's self fill.
// @x : unique account id
// @y : self filled count
// @z : amount that is self filled
.account.IncSelfFill    :{
        ![`.account.Account;
            enlist (=;`accountId;x);
            0b;`selfFillCount`selfFillVolume!(
                (+;`selfFillCount;y);
                (+;`selfFillVolume;z)
            )];};

// Inventory Management
// -------------------------------------------------------------->

/*******************************************************
/ Inventory 

.account.inventoryCount:0;
// TODO posState
// TODO liqudation price
.account.Inventory: (
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

/ default:  // TODO validation here
.account.NewInventory : {[inventory;time] 
    if[any null inventory[`accountId`side]; :0b];
    inventory:Sanitize[inventory;DefaultInventory[];cols Inventory];
    .logger.Debug["inventory validated and decorated"];
    `.account.Inventory upsert inventory; // TODO check if successful
    };

.account.GetInventoryOfAccount     :{[a]
    ?[`.account.Inventory;enlist(=;`accountId;a`accountId);0b;()]
    };
  
.account.ApplyFill                  :{}