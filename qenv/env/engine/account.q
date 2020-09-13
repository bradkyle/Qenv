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


// Balance Management
// -------------------------------------------------------------->

// Adds a given amount to the accounts balance.
// Update available/withdrawable etc. // TODO validate arguments?
.account.Deposit  :{[deposited;time;accountId]
    // TODO more expressive and complete upddate statement accounting for margin etc.
    // Account: available, liquidationprice, bankruptcyprice, depositCount
    acc:exec from  .account.Account where accountId=accountId;

    if[not[count[acc]>0];'INVALID_ACCOUNTID];

    acc[`balance]-:deposited;
    acc[`depositAmount]+:deposited;
    acc[`depositCount]+:1;
    acc[`withdrawable]+:deposited;
    / account[`available]:.account.Available[acc]; // TODO
    / account[`initMarginReq`maintMarginReq]

    .account.Account,:acc;

    // TODO add update event
    .pipe.egress.AddAccountEvent[acc;time];
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
.account.Withdraw       :{[withdrawn;time;accountId]
    acc:exec from  .account.Account where accountId=accountId;
    // Account: available, liquidationprice, bankruptcyprice, withdrawCount

    if[not[count[acc]>0];'INVALID_ACCOUNTID];

    $[withdrawn < acc[`withdrawable];[
        // TODO more expressive and complete upddate statement accounting for margin etc.

        acc[`balance]-:withdrawn;
        acc[`withdrawAmount]+:withdrawn;
        acc[`withdrawCount]+:1;
        acc[`withdrawable]-:withdrawn;
        / account[`available]:.account.Available[acc]; // TODO

        .account.Account,:acc;
        .pipe.egress.AddAccountEvent[acc;time]; 
        // TODO update liquidation price   
        
        ];'InsufficientMargin];  
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

// AdjustOrderMargin
// ---------------------------------------------------------------------------------------->

// TODO Convert to matrix/batch/array oriented
// Adjusts the amount of margin that is allocated to the limit orders
// of an agent and throws an error in the event of an insufficiency.
/  @param i     (Instrument) The instrument that the order belongs to
/  @param a   (Account) The account that thte order belongs to
/  @param side   (Long) The side of the margin delta.
/  @param time (datetime) The time at which this update is taking place.
/  @return (Inventory) The new updated inventory
.account.AdjustOrderMargin       :{[i; a; side; time; reduce; ismaker; price; qty]

    // Common derivations
    k:i`contractType;      
    fill:(side;time;reduce;ismaker;qty);  

    // TODO change to vector conditional?
    res:$[k=0;.linear.account.AdjustOrderMargin[a;iB;iL;iS;fill];
          k=1;.inverse.account.AdjustOrderMargin[a;iB;iL;iS;fill];
          k=3;.quanto.account.AdjustOrderMargin[a;iB;iL;iS;fill];
          'INVALID_CONTRACT_TYPE];

    .account.Account,:res[0];
    .account.Inventory,:res[1];

    .pipe.egress.AddAccountEvent[res[0];time];
    .pipe.egress.AddInventoryEvent[res[1];time];
    };

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



// Main Public Fill Function
// ---------------------------------------------------------------------------------------->

// Convert to matrix/batch/array oriented
.account.ApplyFill           :{[a; i; side; time; fill]

    // Common derivations
    k:i`contractType;      
    / fill:(side;time;reduce;ismaker;qty);  

    // TODO change to vector conditional?
    res:$[k=0;.linear.account.ApplyFill[a;iB;iL;iS;fill];
          k=1;.inverse.account.ApplyFill[a;iB;iL;iS;fill];
          k=3;.quanto.account.ApplyFill[a;iB;iL;iS;fill];
          'INVALID_CONTRACT_TYPE];

    .account.Account,:res[0];
    .account.Inventory,:res[1];

    .pipe.egress.AddAccountEvent[res[0];time];
    .pipe.egress.AddInventoryEvent[res[1];time];
    };


// Main Public Funding Function
// ---------------------------------------------------------------------------------------->

// Applies funding to all accounts with open positions
.account.ApplyFunding        : {[i;fr;ft;time]
    // TODO validate instrument exists
    k:i`contractType;      

    // TODO derive risk buffer
    xyz:((select from .account.Account where sum[netLongPosition,netShortPosition,openBuyQty,openSellQty]>0) 
                lj (select sum unrealizedPnl by accountId from i));

    // TODO change to vector conditional?
    res:$[k=0;.linear.account.ApplyFunding[a;iB;iL;iS;i];
          k=1;.inverse.account.ApplyFunding[a;iB;iL;iS;i];
          k=3;.quanto.account.ApplyFunding[a;iB;iL;iS;i];
          'INVALID_CONTRACT_TYPE];

    .account.Account,:res[0];
    .account.Inventory,:res[1];

    .pipe.egress.AddAccountEvent[res[0];time];
    .pipe.egress.AddInventoryEvent[res[1];time];
    };


// Update Mark Price
// ---------------------------------------------------------------------------------------->

// Updates the mark price of all accounts
.account.UpdateMarkPrice     : {[i;mp;time]
    // TODO validate instrument exists
    k:i`contractType;      

    // TODO derive risk buffer
    xyz:((select from .account.Account where sum[netLongPosition,netShortPosition,openBuyQty,openSellQty]>0) 
                lj (select sum unrealizedPnl by accountId from i));

    // TODO change to vector conditional?
    res:$[k=0;.linear.account.UpdateMarkPrice[a;iB;iL;iS;i];
          k=1;.inverse.account.UpdateMarkPrice[a;iB;iL;iS;i];
          k=3;.quanto.account.UpdateMarkPrice[a;iB;iL;iS;i];
          'INVALID_CONTRACT_TYPE];

    .account.Account,:res[0];
    .account.Inventory,:res[1];

    .pipe.egress.AddAccountEvent[res[0];time];
    .pipe.egress.AddInventoryEvent[res[1];time];
    };


// Apply Settlement
// ---------------------------------------------------------------------------------------->

// Applies a given settlement to all accounts
.account.ApplySettlement     : {[i;time]
    // TODO validate instrument exists
    k:i`contractType;      

    // TODO logic for settlement

    .account.Account,:res[0];
    .account.Inventory,:res[1];

    .pipe.egress.AddAccountEvent[res[0];time];
    .pipe.egress.AddInventoryEvent[res[1];time];
    };