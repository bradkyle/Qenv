
.engine.logic.contract.inverse.Value :{[qty;price]
    qty*price         
    };

.engine.logic.contract.inverse.Loss  :{[markprice;qty;val]
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
.engine.logic.contract.inverse.AvgPrice               :{[isignum;execCost;totalEntry;multiplier]
    :$[all[(totalEntry,execCost)>0];[
        p:execCost%totalEntry;
        $[isignum>0;1e8%floor[p];1e8%ceiling[p]] // TODO change 1e8 to multiplier?
        ];0];
    };

// Given the current Inventory state, this function will derive the
// unrealized pnl that the inventory has incurred.
.engine.logic.contract.inverse.UnrealizedPnl          :{[amt;isignum;avgPrice;markPrice;faceValue;multiplier] // todo return multiplier val
    :7h$($[all[(amt,avgPrice,markPrice,faceValue)>0];
        (((faceValue%avgPrice)-(faceValue%markPrice))*(amt*isignum))*multiplier;0]);
    };

// Given the current Inventory state, this function will derive the
// resultant pnl that will be realized when a given amount is added
// back to the balance. // TODO check multiplier is working?
.engine.logic.contract.inverse.RealizedPnl            :{[fillQty;fillPrice;isignum;avgPrice;faceValue;multiplier]
    :7h$($[all[(fillQty,avgPrice,fillPrice,faceValue)>0];
        (((faceValue%fillPrice)-(faceValue%avgPrice))*(fillQty*isignum))*multiplier;0]);
    };
