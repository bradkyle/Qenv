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
LiquidationPrice :{[account;inventoryB;inventoryL;inventoryS;instrument]

    };

// Given the rules provided by the instrument and the account's current
// state this function will derive the price point at which the account
// will become bankrupt.
BankruptcyPrice  :{[account;inventoryB;inventoryL;inventoryS;instrument]

    };

// TODO make shorter
/ ppcprice:$[isnv;ppc[ins;price];price];
/ ppcmark:$[isnv;ppc[ins;ins[`markPrice]];ins[`markPrice]];

/ // returns the price premium/loss that is charged
/ p:.account.premium[isignum;ins[`markPrice];price]; // TODO isinverse
/ v:$[isnv;ppcprice*dlt;price*dlt]; // TODO size scale to long
/ l:$[isnv;ppc[ins;p]*dlt;p*dlt];
/ show l;

/ $[(isignum>0) and (p>0);[ // TODO fix
/     acc[`openBuyQty]+:dlt; 
/     acc[`openBuyValue]+:`long$(price*dlt); // TODO check
/     acc[`openBuyLoss]+:`long$(p*dlt);
/ ];
/ [
/     acc[`openSellQty]+:dlt; 
/     acc[`openSellValue]+:`long$(price*dlt);
/     acc[`openSellLoss]+:`long$(p*dlt);
/ ]];

// AdjustOrderMargin interprets whether a given margin 
// delta principly derived from either the placement/cancellation
// of a limit order or the application of a order fill will exceed the
// accounts available balance in which case an exception will be 
// thrown, or otherwise will return the resultant account state that the
// given delta will cause on execution. TODO dry!
/  @param price (Long) The effective price of the delta
/  @param delta (Long) The quantity delta that is to be applied 
/  @param isign (Long) Either 1: Long, -1:Short 
/  @return (Account) The input as a symbol
/  @throws InsufficientMargin account has insufficient margin for adjustment
AdjustOrderMargin       :{[price;delta;markPrice;isign]

    premium: abs[min[0,(isign*(markPrice-price))]];

    account[`openBuyLoss]:(min[0,(markPrice*account[`openBuyQty])-account[`openBuyValue]] | 0);
    account[`openSellLoss]:(min[0,(markPrice*account[`openSellQty])-account[`openSellValue]] |0);
    account[`openLoss]:(sum[acc`openSellLoss`openBuyLoss] | 0);
    account[`available]:((account[`balance]-sum[account`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);

    $[account[`available]<account[`maintMarginReq];'InsufficientMargin] // TODO check
    };


// Main Public Fill Function
// ---------------------------------------------------------------------------------------->



// ApplyFill applies a given execution to an account and its respective
// inventory, The function is for all intensive purposes only referenced
// from ProcessTrade in .order. // TODO
// 
ApplyFill               :{[]
    $[ishedged;[
        
    ]]

    };

// TODO make better
// UpdateMarkPrice updates an accounts state i.e. openLoss, available, posMargin
// and its unrealizedPnl when the mark price for a given instrument changes, it
// is generally used with fair price marking. Assumes unrealizedPnl is already derived? 
// TODO change openLoss to orderLoss TODO dry
// @param markPrice (Long) The latest mark price of the instrument
UpdateMarkPrice         :{[markPrice;instrument;account]

    account[`openBuyLoss]:(min[0,(markPrice*account[`openBuyQty])-account[`openBuyValue]] | 0);
    account[`openSellLoss]:(min[0,(markPrice*account[`openSellQty])-account[`openSellValue]] |0);
    account[`openLoss]:(sum[acc`openSellLoss`openBuyLoss] | 0);
    account[`available]:((account[`balance]-sum[account`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);

    };


/ // Applies the current funding rate and subsequent
/ // Account: available, fundingCount, frozen, realizedPnl, 
/ //          unrealizedPnl, posMargin, initMargin, netLongPosition, 
/ //          netShortPosition, liquidationPrice, bankruptcyPrice
/ //          
/ // Inventory: amt, lastValue, markValue, realizedPnl, unrealizedPnl, 
/ //            posMargin, initMargin, entryValue, totalCost, totalEntry, 
/ //            execCost, maintMarginReq, initMarginReq, (isignum if both)
/ update balance:balance-((longValue*fundingRate)-(shortValue*fundingRate)), 
/     longFundingCost:longFundingCost+(longValue*fundingRate),
/     shortFundingCost:shortFundingCost+(longValue*fundingRate),
/     totalFundingCost:totalFundingCost+((longValue*fundingRate)-(longValue*fundingRate))
/     by accountId from `.account.Account;

// TODO make better
// Positive funding rate means long pays short an amount equal to their current position
// * the funding rate.
// Negative funding rate means short pays long an amount equal to their current position
// * the funding rate.
// The funding rate6\ can either be applied to the current position or to the margin/balance.
// This function is accessed by the engine upon a funding event and unilaterally applies
// an update to all the open position quantites held in the schema/state representation.
// TODO next funding rate and next funding time (funding time delta)
// Update available withdrawable etc. // TODO move to instrumentTODO dry
// @param markPrice (Long) The latest mark price of the instrument // TODO return updated values?
ApplyFunding        :{[fundingRate;instrument;account]

    account[`balance]:0;
    account[`available]:((account[`balance]-sum[account`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);

    };