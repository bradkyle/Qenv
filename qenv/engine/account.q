\l inventory.q

\d .account

accountCount:0;

/ account related enumerations  
MARGINTYPE      :   `CROSS`ISOLATED;
POSITIONTYPE    :   `HEDGED`COMBINED;

// Account state in this instance serves as a proxy
// for a single agent and contains config therin
// pertaining to what the agent setting is.
Account: (
            [accountId          : `long$()]
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

// Event creation utilities
// -------------------------------------------------------------->

/ MakeAccountUpdateEvent  :{[accountId]

/ }

/ MakeAllAccountsUpdatedEvent :{[]

/ }

// Account Logic
// -------------------------------------------------------------->

// Generates a new account with default 
// values and inserts it into the account 
// table. // TODO gen events.
NewAccount :{[accountId;marginType;positionType;time]
    events:();
    `.account.Account insert (accountId;0;0;0;0;0;0;marginType;positionType;0;0;0;0;0;0;0;0;0f;0f;0f;0f);
    events,:MakeAccountUpdateEvent[accountId];
    events,:.inventory.NewInventory[accountId;`LONG];
    events,:.inventory.NewInventory[accountId;`SHORT];
    events,:.inventory.NewInventory[accountId;`BOTH];
    :events;
    };

ProcessDeposit  :{[event]
    // TODO more expressive and complete upddate statement accounting for margin etc.
    update 
        balance:balance+depositAmount 
        from `.account.Account 
        where accountId=accountId;
    :MakeAccountUpdateEvent[];
};

// TODO
deriveAvailableBalance  :{[accountId]:exec from .schema.Account where accountId=accountId;};

ProcessWithdraw       :{[event]
    events:();
    withdrawAmount: event[`datum][`withdrawAmount];
    accountId:event[`accountId];
    time:event[`time];
    $[withdrawAmount < deriveAvailableBalance(accountId);

        // TODO more expressive and complete upddate statement accounting for margin etc.
        update balance:balance-withdrawAmount from `.schema.Account where accountId=accountId;
        events,:.global.MakeWithdrawEvent[agentId;time;withdrawAmount];
        events,:.global.MakeAccountUpdateEvent[agentId;time];
    ];  
    :events;
};