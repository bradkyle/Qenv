\l inventory.q
\l util.q

\d .account

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
            totalFundingCost    : `float$()
        );

// Event creation utilities
// -------------------------------------------------------------->

MakeAccountUpdateEvent  :{[accountId;time]

    };

MakeAllAccountsUpdatedEvent :{[time]

    };

// Account CRUD Logic
// -------------------------------------------------------------->

// Generates a new account with default 
// values and inserts it into the account 
// table. // TODO gen events. // TODO change to event?
NewAccount :{[accountId;marginType;positionType;time]
    events:();
    `.account.Account insert (accountId;0;0;0;0;0;0;marginType;positionType;0;0;0;0;0;0;0;0;0f;0f;0f;0f);
    events,:MakeAccountUpdateEvent[accountId];
    events,:.inventory.NewInventory[accountId;`LONG];
    events,:.inventory.NewInventory[accountId;`SHORT];
    events,:.inventory.NewInventory[accountId;`BOTH];
    :events;
    };


// Fill and Position Related Logic
// -------------------------------------------------------------->

// Funding Event/Logic
// -------------------------------------------------------------->
// Positive funding rate means long pays short an amount equal to their current position
// * the funding rate.
// Negative funding rate means short pays long an amount equal to their current position
// * the funding rate.
// The funding rate6\ can either be applied to the current position or to the margin/balance.
// This function is accessed by the engine upon a funding event and unilaterally applies
// an update to all the open position quantites held in the schema/state representation.
ApplyFunding       :{[event]

    update 
        balance-:((netLongPosition*fundingRate)-(netShortPosition*fundingRate)), 
        longFundingCost+:netLongPosition*fundingRate,
        shortFundingCost+:netShortPosition*fundingRate,
        totalFundingCost+:((netLongPosition*fundingRate)-(netShortPosition*fundingRate)),
        from `.account.Account;

    / `schema.Account update balance:

    :MakeAllAccountsUpdatedEvent[]
    };

// Balance Management
// -------------------------------------------------------------->

ProcessDeposit  :{[event]
    // TODO more expressive and complete upddate statement accounting for margin etc.
    update 
        balance:balance+depositAmount, 
        depositAmount+:depositAmount,
        depositCount+:1,
        from `.account.Account 
        where accountId=accountId;
    :MakeAccountUpdateEvent[];
    };

// TODO
deriveAvailableBalance  :{[accountId]
    :exec from .schema.Account where accountId=accountId;
    };

ProcessWithdraw       :{[event]
    events:();
    withdrawAmount: event[`datum][`withdrawAmount];
    accountId:event[`accountId];
    time:event[`time];
    $[withdrawAmount < deriveAvailableBalance(accountId);

        // TODO more expressive and complete upddate statement accounting for margin etc.
        update 
            balance:balance-withdrawAmount 
            from `.account.Account 
            where accountId=accountId;
        events,:MakeAccountUpdateEvent[];
    ];  
    :events;
    };