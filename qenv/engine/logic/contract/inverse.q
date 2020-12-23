
.engine.logic.contract.inverse.Value :{[qty;price]
    qty*price         
    };

.engine.logic.contract.inverse.Loss  :{[markprice;qty;price]
    val:.engine.logic.contract.inverse.Value[qty;price];
    min[(prd[(markprice;qty)]-val;0)]  
  };


// Derives the execCost which is the cumulative sum of the product of
// the fillQty and price of entering into a position.
.engine.logic.contract.inverse.ExecCost               :{[price;qty;multiplier]
    :(floor[1e8%price]*abs[qty]);
    };

// Given the total entry and the exec cost of the given Inventory
// this function will derive the average price at which the inventory
// was opened at/ entered into.
.engine.logic.contract.inverse.AvgPriceDeriv               :{[isignum;price;qty;totalEntry;multiplier]
    execCost:.engine.logic.contract.inverse.ExecCost[price;qty;multiplier];
    p:execCost%totalEntry;
    ?[isignum>0;1e8%floor[p];1e8%ceiling[p]] // TODO change 1e8 to multiplier?
    };

// Given the total entry and the exec cost of the given Inventory
// this function will derive the average price at which the inventory
// was opened at/ entered into.
.engine.logic.contract.inverse.AvgPrice               :{[isignum;execCost;totalEntry;multiplier]
    p:execCost%totalEntry;
    ?[isignum>0;1e8%floor[p];1e8%ceiling[p]] // TODO change 1e8 to multiplier?
    };

// Given the current Inventory state, this function will derive the
// unrealized pnl that the inventory has incurred.
.engine.logic.contract.inverse.UnrealizedPnl          :{[amt;isignum;avgPrice;markPrice;faceValue;multiplier] 
    7h$((((faceValue%avgPrice)-(faceValue%markPrice))*(amt*isignum))*multiplier)
    };

// Given the current Inventory state, this function will derive the
// resultant pnl that will be realized when a given amount is added
// back to the balance. // TODO check multiplier is working?
.engine.logic.contract.inverse.RealizedPnl            :{[fillQty;fillPrice;isignum;avgPrice;faceValue;multiplier]
    7h$((((faceValue%fillPrice)-(faceValue%avgPrice))*(fillQty*isignum))*multiplier)
    };
