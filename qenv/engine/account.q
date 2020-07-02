\d .account

/ \l global.q
/ account related enumerations  
MARGINTYPE      :   `CROSS`ISOLATED;
POSITIONTYPE    :   `HEDGED`COMBINED;

// Account state in this instance serves as a proxy
// for a single agent and contains config therin
// pertaining to what the agent setting is.
Accounts: (
            [id                 : `long$()]
            balance             : `long$();
            frozen              : `long$();
            maintMargin         : `long$();
            available           : `long$();
            openBuyOrderQty     : `long$();
            openSellOrderQty    : `long$();
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
            shortFundingCost    : `float$();
            longFundingCost     : `float$();
            totalFundingCost    : `float$();
            totalFundingCostMrg : `float$()
        );

// Generates a new account with default 
// values and inserts it into the account 
// table.
/ NewAccount              :{[accountId]

/     / .inventory.NewInventory[];
/     / .inventory.NewInventory[];
/     / .inventory.NewInventory[];
/ };

/ MakeAccountUpdateEvent  :{[accountId]

/ }

/ MakeAllAccountsUpdatedEvent :{[]

/ }