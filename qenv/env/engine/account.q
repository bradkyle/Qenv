/ \l inventory.q
// THIS FILE REPRESENTS THE LOGIC PERTAINING TO THE ACCOUNT OF AN INSTRUMENT


\d .account
\l util.q

accountCount:0;

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
    acc:Sanitize[account;defaults[];allCols];
    / show value type each 1_account;
    / show value type each .account.Account@0;
    .account.Account,:acc;

    };


// Global Account Utils
// -------------------------------------------------------------->

// TODO derive avg price, total entry, exec cost, gross open premium etc.

OrderLoss:{(sum[x`openSellLoss`openBuyLoss] | 0)};
Available:{((x[`balance]-sum[x`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0)};


// Balance Management
// -------------------------------------------------------------->

// Adds a given amount to the accounts balance.
// Update available/withdrawable etc. // TODO validate arguments?
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

    .account.Account,:acc;

    // TODO add update event
    .pipe.event.AddAccountEvent[acc;time];
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

        .account.Account,:acc;
        .pipe.event.AddAccountEvent[acc;time];    
        
        ];'InsufficientMargin];  
    };


// Inventory Management
// -------------------------------------------------------------->

/*******************************************************
/ Inventory 

inventoryCount:0;
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

/ default:  // TODO validation here
NewInventory : {[inventory;time] 
    if[any null inventory[`accountId`side]; :0b];
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
ApplyFill     :{[a; i; side; time; reduce; ismaker; price; qty]

    // Common derivations
    ck:instrument`contractType;      
    fill:(side;time;reduce;ismaker;qty);  

    // TODO change to vector conditional?
    res:$[ck=0;.linear.account.ApplyFill[a;iB;iL;iS;fill];
          ck=1;.inverse.account.ApplyFill[a;iB;iL;iS;fill];
          ck=3;.quanto.account.ApplyFill[a;iB;iL;iS;fill]];

    .account.Account,:res[0];
    .account.Inventory,:res[1];

    .pipe.event.AddAccountEvent[res[0];time];
    .pipe.event.AddInventoryEvent[res[1];time];

    };


// Update Mark Price
// ---------------------------------------------------------------------------------------->

UpdateMarkPrice : {[intrument;time]
    // TODO validate instrument exists

    // TODO derive risk buffer
    ((select from .account.Account where sum[netLongPosition,netShortPosition,openBuyQty,openSellQty]>0) 
                lj (select sum unrealizedPnl by accountId from i))

    // TODO change to vector conditional?
    res:$[ck=0;.linear.account.UpdateMarkPrice[a;iB;iL;iS;i];
          ck=1;.inverse.account.UpdateMarkPrice[a;iB;iL;iS;i];
          ck=3;.quanto.account.UpdateMarkPrice[a;iB;iL;iS;i]];

    .account.Account,:res[0];
    .account.Inventory,:res[1];

    .pipe.event.AddAccountEvent[res[0];time];
    .pipe.event.AddInventoryEvent[res[1];time];
    };

