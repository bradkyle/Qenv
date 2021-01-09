
.engine.logic.contract.linear.Value :{[qty;price]
    qty*price         
    };

.engine.logic.contract.linear.Loss  :{[markprice;qty;price]
    val:.engine.logic.contract.linear.Value[qty;price];
    min[(prd[(markprice;qty)]-val;0)]  
  };

// Derives the execCost which is the cumulative sum of the product of
// the fillQty and price of entering into a position.
.engine.logic.contract.linear.ExecCost               :{[price;qty;multiplier]
    :(floor[1e8%price]*abs[qty]);
    };

// Given the total entry and the exec cost of the given Inventory
// this function will derive the average price at which the inventory
// was opened at/ entered into.
.engine.logic.contract.linear.AvgPrice               :{[isignum;execCost;totalEntry;multiplier]
    p:execCost%totalEntry;
    7h$(?[isignum>0;1e8%floor[p];1e8%ceiling[p]] * multiplier) // TODO change 1e8 to multiplier?
    };

// Given the total entry and the exec cost of the given Inventory
// this function will derive the average price at which the inventory
// was opened at/ entered into.
.engine.logic.contract.linear.AvgPriceDeriv               :{[isignum;price;qty;totalEntry;multiplier]
    execCost:.engine.logic.contract.linear.ExecCost[price;qty;multiplier];
    .engine.logic.contract.linear.AvgPrice[isignum;execCost;totalEntry;multiplier]
    };

// Given the current Inventory state, this function will derive the
// unrealized pnl that the inventory has incurred.
.engine.logic.contract.linear.UnrealizedPnl          :{[amt;isignum;avgPrice;markPrice;faceValue;multiplier] 
    7h$((((faceValue%avgPrice)-(faceValue%markPrice))*(amt*isignum))*multiplier)
    };

// Given the current Inventory state, this function will derive the
// resultant pnl that will be realized when a given amount is added
// back to the balance. // TODO check multiplier is working?
.engine.logic.contract.linear.RealizedPnl            :{[fillQty;fillPrice;isignum;avgPrice;faceValue;multiplier]
    7h$((((faceValue%fillPrice)-(faceValue%avgPrice))*(fillQty*isignum))*multiplier)
    };


// Derives the approximate price at which the inventory will be liquidated
// Given the maintenence margin requirements and initial margin requirements
// of the current risk tier of the account
.engine.logic.contract.linear.LiquidationPrice :{[amt;isignum;avgPrice;initialMargin;mm;faceValue;multiplier]
    7h$(((facevalue%avgPrice)-())*(amt*isignum)*multiplier)
    };

// Derives the approximage price at which the inventory will become bankrupt
// given the leverage etc.
.engine.logic.contract.linear.BankruptcyPrice  :{[amt;isignum;avgPrice;faceValue;multiplier]
    7h$((((isignum*amt)*avgPrice*faceValue)%(((isignum*amt)*faceValue)+(avgPrice * 1)))*multiplier) 
    };


// Derives the approximage price at which the inventory will become bankrupt
// given the leverage etc.
.engine.logic.contract.linear.BankruptcyPrice  :{[amt;isignum;avgPrice;faceValue;pmul;smul]
    7h$((amt * (1%.engine.logic.contract.linear.BankruptcyPrice[amt;isignum;avgPrice;faceValue;pmul])) * smul)
    };


