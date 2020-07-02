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
    :1b;
    };

MakeAllAccountsUpdatedEvents :{[time]
    :1b;
    };

// Account CRUD Logic
// -------------------------------------------------------------->

// Generates a new account with default 
// values and inserts it into the account 
// table. // TODO gen events. // TODO change to event?
NewAccount :{[accountId;marginType;positionType;time]
    events:();
    `.account.Account insert (accountId;0;0;0;0;0;0;marginType;positionType;0;0;0;0;0;0;0;0;0f;0f;0f);
    events,:MakeAccountUpdateEvent[accountId;time];
    events,:.inventory.NewInventory[accountId;`LONG;time];
    events,:.inventory.NewInventory[accountId;`SHORT;time];
    events,:.inventory.NewInventory[accountId;`BOTH;time];
    :events;
    };
    
// Fill and Position Related Logic
// -------------------------------------------------------------->

// Derives the price per contract 
pricePerContract  :{[faceValue;price]$[price>0;faceValue%price;0]};

// Calculates the realized profit and losses for a given position, size is a positive
// or negative number that represents the portion of the current position that has been
// closed and thus should be of the same side as the position i.e. negative for short and 
// positive for long.
deriveRealisedPnl :{[avgPrice;fillPrice;faceValue;fillQty]; // TODO is fillQty sign agnostic?
    :(pricePerContract[faceValue;avgPrice] - pricePerContract[faceValue;fillPrice])*fillQty;
    };

// Returns the unrealized profit for the current position considering the current
// mark price and the average entry price (uses mark price to prevent liquidation).
deriveUnrealisedPnl :{[avgPrice;markPrice;faceValue;currentQty]; // TODO is currentQty sign agnostic?
    :(pricePerContract[faceValue;avgPrice] - pricePerContract[faceValue;markPrice])*currentQty;
    };

execFill    :{[account;inventory;fillQty;price;fee]
    // TODO errors
    cost: fee * abs fillQty;
    nxtQty: inventory[`currentQty] + fillQty;
    leverage: account[`];
    faceValue:1;

    realizedPnlDelta:0; // TODO change to inst realized pnl

    $[(currentQty*nxtQty)<0;
      [
        // The position is being crossed i.e.
        // being changed from long to short or
        // short to long and visa versa.  
        realizedPnlDelta:deriveRealisedPnl[inventory[`avgPrice];price;faceValue;fillQty];

        // Reset entries because of the change in position
        // side and add an entry of a size equal to the
        // size of the next position.
        inventory[`totalEntry]: abs[nxtQty];
        inventory[`execCost]: floor[1e8%price] * abs[nxtQty];
        inventory[`currentQty]: nxtQty;

        / Calculates the average price of entry for the current postion, used in calculating 
        / realized and unrealized pnl.
        inventory[`avgPrice]: {$[signum[x[`currentQty]]>0;
           1e8%floor[x[`execCost]%x[`totalEntry]];
           1e8%ceiling[x[`execCost]%x[`totalEntry]]
          ]}[inventory];

        // Closing of the position means that the value is
        // moving from the current position into the balance
        // cost is subtracted from this execution amount.
        // Because the execution is larger than the position the 
        // amount of value added back to the balance is equivalent
        // to the position.
        amt:CntToMrg[((abs[currentQty]-abs[nxtQty])%leverage)-cost;price;faceValue;0b];
        nextBalance:balance + amt + realizedPnlDelta; //Todo next balance
      ];
      (abs currentQty)>(abs nxtQty);
      [
        // Because the position is being closed the realised pnl 
        // will be inversely proportional to the position.
        realizedPnlDelta:deriveRealisedPnl[inventory[`avgPrice];price;faceValue;fillQty];
        inventory[`currentQty]: nxtQty;
        inventory[`realizedPnl]+:realizedPnlDelta;

        // Closing of position means that the value is moving
        // from the current position into the balance, cost is
        // subtracted from this execution amount, it also means
        // that the execution is smaller than the position
        // and as such is used as the value
        amt:CntToMrg[(abs[fillQty]%leverage)-cost;price;faceValue;1b];
        nextBalance: balance + amt + realizedPnlDelta;
      ];
      [
        / Because the current position is being increased
        / an entry is added for calculation of average entry
        / price. 
        inventory[`totalEntry]+: abs[nxtQty];
        inventory[`execCost]+: floor[1e8%price] * abs[nxtQty];
        inventory[`currentQty]: nxtQty;

        / Calculates the average price of entry for the current postion, used in calculating 
        / realized and unrealized pnl.
        inventory[`avgPrice]: {$[signum[x[`currentQty]]>0;
           1e8%floor[x[`execCost]%x[`totalEntry]];
           1e8%ceiling[x[`execCost]%x[`totalEntry]]
          ]}[inventory];

        / Opening of position means that value is moving from
        / the current balance to the position and as thus
        / the cost is added to the execution i.e. an additional
        / amount is subtracted to simulate fee.
        amt: CntToMrg[(abs[fillQty]%leverage)+cost;price;faceValue;1b];
        nextBalance: balance - amt;
      ]
    ];

    // If the next position will be 0
    // reset the entry values for the position.
    $[nxtQty=0;[
        inventory[`totalEntry]:0;
        inventory[`execCost]:0;
        inventory[`avgPrice]: 0;
        inventory[`currentQty]: 0;
    ];0N;];

    // TODO derive liquidation price
    // TODO 

    / $[];
    /self.balance = round(next_balance, 8)
    /position.current_qty = next_position
    /position.total_costs += (cost/price)
    /position.total_realised_pnl += realised_pnl
    /position.total_summed_returns += realised_pnl - (cost/price)
    /position.total_fills_completed += 1
    // TODO update position values here.
    `.account.Account upsert account;
    `.inventory.Inventory upsert inventory;

    };

// Apply fill is an internal function i.e. it is not exposed
// to the engine but is used by the orderbook to add a given
// qty to the active position of an account.
// todo allow for onlyclose and calcualte fee
ApplyFill  :{[qty;price;side;time;isClose;isMaker;accountId]
    events:();
    absQty:abs qty;
    $[absQty > 0:[
        acc: exec from Account where accountId=accountId;
        $[acc[`positionType]=`HEDGED;
            $[qty>0;
            execFill[acc;exec from .inventory.Inventory where accountId=accountId & side=`LONG;qty;price;fee];
            execFill[acc;exec from .inventory.Inventory where accountId=accountId & side=`SHORT;qty;price;fee]
            ]; // LONG; SHORT
          acc[`positionType]=`COMBINED;
            [execFill[acc;exec from .inventory.Inventory where accountId=accountId & side=`BOTH;qty;price;fee]];
          [0N]
        ];
    ];];
    :events;
    };

// Funding Event/Logic
// -------------------------------------------------------------->
// Positive funding rate means long pays short an amount equal to their current position
// * the funding rate.
// Negative funding rate means short pays long an amount equal to their current position
// * the funding rate.
// The funding rate6\ can either be applied to the current position or to the margin/balance.
// This function is accessed by the engine upon a funding event and unilaterally applies
// an update to all the open position quantites held in the schema/state representation.
ApplyFunding       :{[fundingRate;time]

    update 
        balance-:((netLongPosition*fundingRate)-(netShortPosition*fundingRate)), 
        longFundingCost+:netLongPosition*fundingRate,
        shortFundingCost+:netShortPosition*fundingRate,
        totalFundingCost+:((netLongPosition*fundingRate)-(netShortPosition*fundingRate))
        by accountId from `.account.Account;

    :MakeAllAccountsUpdatedEvents[time];
    };

// Balance Management
// -------------------------------------------------------------->

ProcessDeposit  :{[event]
    // TODO more expressive and complete upddate statement accounting for margin etc.
    update 
        balance:balance+depositAmount, 
        depositAmount+:depositAmount,
        depositCount+:1
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