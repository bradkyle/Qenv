\l global.q


// Inventory processing and realised pnl calculation
// --------------------------------------------------->

// TODO functional update
addEntry     :{[accountId;side;size;price] // TODO account for side
    update 
        totalEntry+:size, 
        execCost+: floor[(1 xexp 8) % price] * abs size 
        from `.schema.Inventory 
        where accountId=accountId;
}

// TODO functional q
resetEntry    :{[accountId;side]
    update 
        totalEntry:0, 
        execCost:0 
        from `.schema.Inventory 
        where accountId=accountId;
};

crossLiquidationPrice   :{[]

};

isolatedLiquidationPrice  :{[]

};

/ Calculates the average price of entry for the current postion, used in calculating 
/ realized and unrealized pnl.
averageEntryPrice   :{[totalEntry;execCost;currentQty]
    $[(totalEntry>0)&(abs currentQty)>0;
      [
          asp: execCost%totalEntry;
          $[signum[currentQty]>0;
           :1e8%floor[asp];
           :1e8%ceiling[asp];
          ];
      ];
      [:0]
    ]
};

// Derives the price per contract 
pricePerContract  :{[faceValue;price]$[price>0;faceValue%price;0]};

// Calculates the realized profit and losses for a given position, size is a positive
// or negative number that represents the portion of the current position that has been
// closed and thus should be of the same side as the position i.e. negative for short and 
// positive for long.
deriveRealisedPnl :{[avgPrice;fillPrice;faceValue;fillQty];
    :(pricePerContract[faceValue;avgPrice] - pricePerContract[faceValue;fillPrice])*fillQty;
};

// Returns the unrealized profit for the current position considering the current
// mark price and the average entry price (uses mark price to prevent liquidation).
deriveUnrealisedPnl :{[avgPrice;markPrice;faceValue;currentQty];
    :(pricePerContract[faceValue;avgPrice] - pricePerContract[faceValue;markPrice])*currentQty;
};

deriveInitialMargin : {[]

}

/ This is the minimum amount of margin you must maintain to avoid liquidation on your position.
/ The amount of commission applicable to close out all your positions will also be added onto 
/ your maintenance margin requirement. 
/ return ((self.maint_margin_coeficcient + self.taker_fee)*abs(self.position)) * self.mark_per_contract
deriveMaintenceMargin   :{[]

}

deriveMakerCommission   :{[]

}

deriveTakerCommission   :{[]

}

// Auxillary Processing Logic
// --------------------------------------------------->

execFill    :{[fill;price;fee;]
    
    // TODO errors
    cost: fee * abs fill;
    nxtQTY: currentQty + fill;
    leverage: 0;
    balance:0;
    faceValue:0;
    $[(currentQty*nxt)<0;
      [
        // The position is being crossed i.e.
        // being changed from long to short or
        // short to long and visa versa.    
        realizedPnl: deriveRealisedPnl[currentQty;price];

        // Reset entries because of the change in position
        // side and add an entry of a size equal to the
        // size of the next position.
        resetEntry[];
        addEntry[abs nxtQTY;price]

        // Closing of the position means that the value is
        // moving from the current position into the balance
        // cost is subtracted from this execution amount.
        // Because the execution is larger than the position the 
        // amount of value added back to the balance is equivalent
        // to the position.
        amt:.util.CntToMrg[((abs[currentQty]-abs[nxtQTY])%leverage)-cost;price;faceValue;0b];
        nextBalance:balance + amt + realizedPnl;
      ];
      (abs currentQty)>(abs nxtQTY);
      [
        // Because the position is being closed the realised pnl 
        // will be inversely proportional to the position.
        realizedPnl: deriveRealisedPnl[-fill;price];

        // Closing of position means that the value is moving
        // from the current position into the balance, cost is
        // subtracted from this execution amount, it also means
        // that the execution is smaller than the position
        // and as such is used as the value
        amt:.util.CntToMrg[(abs[fill]%leverage)-cost;price;faceValue;1b];
        nextBalance: balance + amt + realizedPnl;
      ];
      [
        / Because the current position is being increased
        / an entry is added for calculation of average entry
        / price.
        addEntry[abs[fill];price];

        / Opening of position means that value is moving from
        / the current balance to the position and as thus
        / the cost is added to the execution i.e. an additional
        / amount is subtracted to simulate fee.
        amt: .util.CntToMrg[(abs[fill]%leverage)+cost;price;faceValue;1b];
        nextBalance: balance - amt;
      ]
    ];

    // If the next position will be 0
    // reset the entry values for the position.
    $[nxtQTY=0:resetEntry[]];

    // TODO update position values here.
};

// Apply fill is an internal function i.e. it is not exposed
// to the engine but is used by the orderbook to add a given
// qty to the active position of an account.
ApplyFill  :{[qty;price;side;time;onlyClose;isMaker;accountId]
    events:();
    absQty:abs qty;
    $[absQty > 0:[
        account: GetAccount[accountId];
        $[account[`positionType]=`HEDGED;
            [
                execFill[];
            ];
          account[`positionType]=`COMBINED;
            [
                execFill[];
            ];
        ];
    ];];
    :events;
};

// Event Processing Logic
// --------------------------------------------------->
// Positive funding rate means long pays short an amount equal to their current position
// * the funding rate.
// Negative funding rate means short pays long an amount equal to their current position
// * the funding rate.
// The funding rate6\ can either be applied to the current position or to the margin/balance.
// This function is accessed by the engine upon a funding event and unilaterally applies
// an update to all the open position quantites held in the schema/state representation.
ApplyFunding       :{[event]
    events:();

    / update 
        / balance: -(newShortPosition) * fundingRate,

    shortFundingCost: -() * fundingRate;
    longFundingCost:   () * fundingRate;
    fundingCostCnt: shortFundingCost + longFundingCost;
    fundingCostMrg: ();

    / `schema.Account update balance:

    events,:.global.MakeAccountUpdateAllEvent[time]
    events,:.global.MakeFundingEvent[time]
    :events;
};

ProcessDeposit  :{[event]
    events: ();

    // TODO more expressive and complete upddate statement accounting for margin etc.
    update balance:balance+depositAmount from `.schema.Account where accountId=accountId;
    events,:.global.MakeAccountUpdateEvent[agentId;time];
    events,:.global.MakeDepositEvent[agentId;time;depositAmount];
    :events;
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

NewAccount       :{[event]
    events:();

};
