\d .contract.inverse.account

// Derives the execCost which is the cumulative sum of the product of
// the fillQty and price of entering into a position.
ExecCost         :{[]

    };

// Given the total entry and the exec cost of the given Inventory
// this function will derive the average price at which the inventory
// was opened at/ entered into.
AvgPrice         :{[]


    };

// Given the current Inventory state, this function will derive the
// unrealized pnl that the inventory has incurred.
UnrealizedPnl    :{[]


    };

// Given the current Inventory state, this function will derive the
// resultant pnl that will be realized when a given amount is added
// back to the balance.
RealizedPnl      :{[]


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
AdjustOrderMargin    :{[price;dlt;isignum;]


    };


// ApplyFill applies a given execution to an account and its respective
// inventory, The function is for all intensive purposes only referenced
// from ProcessTrade in .order.
// 
ApplyFill       :{[]


    };