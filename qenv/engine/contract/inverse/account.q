\d .contract.inverse.account

// Derives the execCost which is the cumulative sum of the product of
// the fillQty and price of entering into a position.
ExecCost         :{[price;qty]
    :(floor[1e8%price]*abs[qty]);
    };

// Given the total entry and the exec cost of the given Inventory
// this function will derive the average price at which the inventory
// was opened at/ entered into.
AvgPrice         :{[isignum;execCost;totalEntry]
    :$[all[(totalEntry,execCost)>0];[
        p:execCost%totalEntry;
        $[isignum>0;1e8%floor[p];1e8%ceiling[p]] // TODO change 1e8 to multiplier
        ];0];
    };

// Given the current Inventory state, this function will derive the
// unrealized pnl that the inventory has incurred.
UnrealizedPnl    :{[amt;isignum;avgPrice;markPrice;faceValue] // todo return multiplier val
    :$[all[(amt,avgPrice,markPrice,faceValue)>0];
        (((faceValue%markPrice)-(faceValue%avgPrice))*(amt*isignum)) // TODO change 1e8 to multiplier
        ;0];
    };

// Given the current Inventory state, this function will derive the
// resultant pnl that will be realized when a given amount is added
// back to the balance.
RealizedPnl      :{[fillQty;fillPrice;isignum;avgPrice;faceValue]
    :$[all[(fillQty,avgPrice,fillPrice,faceValue)>0];
        (((faceValue%fillPrice)-(faceValue%avgPrice))*(fillQty*isignum)) // TODO change 1e8 to multiplier
        ;0];
    };

// Derive the maintenence margin i.e. the amount of margin required to
// keep the specified inventory open. 
MaintMargin      :{[]

    };

// Derives the initial margin that is reserved for a given inventory 
// which should not be confused with posMargin which stipulates the
// inventory/position size divided by the selected margin.
InitMargin       :{[]

    };

// Given the rules provided by the instrument and the account's current
// state this function will derive the approximate price point at which 
// the account will be liquidated.
LiquidationPrice :{[]

    };

// Given the rules provided by the instrument and the account's current
// state this function will derive the price point at which the account
// will become bankrupt.
BankruptcyPrice  :{[]

    };

// AdjustOrderMargin interprets whether a given margin 
// delta principly derived from either the placement/cancellation
// of a limit order or the application of a order fill will exceed the
// accounts available balance in which case an exception will be 
// thrown, or otherwise will return the resultant account state that the
// given delta will cause on execution.
/  @param price (Long) The effective price of the delta
/  @param delta (Long) The quantity delta that is to be applied
/  @param isign (Long) Either 1: Long, -1:Short 
AdjustOrderMargin       :{[price;delta;isign]


    };


// ApplyFill applies a given execution to an account and its respective
// inventory, The function is for all intensive purposes only referenced
// from ProcessTrade in .order.
// 
ApplyFill               :{[]


    };


// UpdateMarkPrice updates an accounts state i.e. openLoss, available, posMargin
// and its unrealizedPnl when the mark price for a given instrument changes, it
// is generally used with fair price marking. Assumes unrealizedPnl is already derived?
UpdateMarkPrice         :{[markPrice;instrument;account]

    account[`openBuyLoss]:min[0,(markPrice*account[`openBuyLoss])-account[`openBuyValue]];
    account[`openSellLoss]:min[0,(markPrice*account[`openSellLoss])-account[`openSellValue]];

    account[`available]:(account[`balance]-
        sum[account`posMargin`unrealizedPnl`orderMargin`openBuyLoss`openSellLoss])

    };