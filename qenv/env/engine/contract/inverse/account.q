
// Derives the execCost which is the cumulative sum of the product of
// the fillQty and price of entering into a position.
.inverse.account.ExecCost               :{[price;qty;multiplier]
    :(floor[1e8%price]*abs[qty]);
    };

// Given the total entry and the exec cost of the given Inventory
// this function will derive the average price at which the inventory
// was opened at/ entered into.
.inverse.account.AvgPrice               :{[isignum;execCost;totalEntry;multiplier]
    :$[all[(totalEntry,execCost)>0];[
        p:execCost%totalEntry;
        $[isignum>0;1e8%floor[p];1e8%ceiling[p]] // TODO change 1e8 to multiplier
        ];0];
    };

// Given the current Inventory state, this function will derive the
// unrealized pnl that the inventory has incurred.
.inverse.account.UnrealizedPnl          :{[amt;isignum;avgPrice;markPrice;faceValue;multiplier] // todo return multiplier val
    :7h$($[all[(amt,avgPrice,markPrice,faceValue)>0];
        (((faceValue%avgPrice)-(faceValue%markPrice))*(amt*isignum))*multiplier;0]);
    };

// Given the current Inventory state, this function will derive the
// resultant pnl that will be realized when a given amount is added
// back to the balance.
.inverse.account.RealizedPnl            :{[fillQty;fillPrice;isignum;avgPrice;faceValue;multiplier]
    :7h$($[all[(fillQty,avgPrice,fillPrice,faceValue)>0];
        (((faceValue%fillPrice)-(faceValue%avgPrice))*(fillQty*isignum))*multiplier;0]);
    };


// Derive the coefficient of maintenence margin that is required for
// a given account given its 
/  @param i  (Instrument) The current instrument
/  @param a  (Account) The account
/  @return (Float) A float representing the fraction of initMarginRequired
.inverse.account.MaintMarginReq          :{[i;a]
    :(![i`riskTiers;enlist(>;`mxamt;amt); (); `mmr])+(i[`riskBuffer] | 0); // TODO derive
    };

// Derives the initial margin that is reserved for a given inventory 
// which should not be confused with posMargin which stipulates the
// inventory/position size divided by the selected margin.
/  @param i  (Instrument) The current instrument
/  @param a  (Account) The account
/  @return (Float) A float representing the fraction of initMarginRequired
.inverse.account.InitMarginReq           :{[i;a]
    :(![i`riskTiers;enlist(>;`mxamt;amt); (); `imr])+(i[`riskBuffer] | 0);
    };


// Derive the maintenence margin i.e. the amount of margin required to
// keep the specified inventory open. 
/  @param i  (Instrument) The current instrument
/  @param iv (Inventory) The given inventory
/  @return (Long) The total maintenence margin that is required
.inverse.account.MaintMargin            :{[i;a;iv]
    mmreq:.inverse.account.MaintMarginReq[i;a];
    :7h$()
    };

// Derives the initial margin that is reserved for a given inventory 
// which should not be confused with posMargin which stipulates the
// inventory/position size divided by the selected margin.
/  @param i  (Instrument) The current instrumentc
/  @param iv (Inventory) The given inventory
/  @return (Long) The total initial margin that is required
.inverse.account.InitMargin             :{[i;a;iv]
    imreq:.inverse.account.InitMarginReq[i;a];
    :7h$()
    };


// Adjust Open Limit Order Margin
// ---------------------------------------------------------------------------------------->

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
.inverse.account.AdjustOrderMargin       :{[price;delta;markPrice;isign]

    premium: abs[min[0,(isign*(markPrice-price))]];

    account[`openBuyLoss]:(min[0,(markPrice*account[`openBuyQty])-account[`openBuyValue]] | 0);
    account[`openSellLoss]:(min[0,(markPrice*account[`openSellQty])-account[`openSellValue]] |0);
    account[`openLoss]:(sum[acc`openSellLoss`openBuyLoss] | 0);
    account[`available]:((account[`balance]-sum[account`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);

    $[account[`available]<account[`maintMarginReq];'InsufficientMargin] // TODO check
    };


// Main Public Fill Functionality
// ---------------------------------------------------------------------------------------->


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.inverse.account.incFill                 :{[price;qty;account;inventory]
    
    // Increase the total Entry and amt
    inventory[`amt`totalEntry]+:qty;

    // derive execCost
    inventory[`execCost]+: .inverse.account.execCost[
        price;
        qty]; 

    / Calculates the average price of entry for 
    / the current postion, used in calculating 
    / realized and unrealized pnl.
    inventory[`avgPrice]: .inverse.account.AvgPrice[
        inventory[`isignum];
        inventory[`execCost];
        inventory[`totalEntry]];

    // TODO unrealizedPnl

    :inventory
    };

// Red Fill is used when the fill is to be removed from the given inventory.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return          (Inventory) The new updated inventory
.inverse.account.redFill                 :{[price;qty;account;inventory]

    // When the inventory is being closed it realizes 
    rpl:.inverse.account.RealizedPnl[
        qty;
        price;
        isign;
        inventory[`avgPrice];
        faceValue];

    inventory[`amt]-:qty;
    inventory[`realizedPnl]+:rpl;

    if[abs[inventory[`amt]]=0;inventory[`avgPrice`execCost]:0];

    :inventory
    };

// Crs Fill is only ever used for combined inventory i.e. `POSITIONSIDE$`BOTH.
/  @param price     (Long) The price at which the fill is occuring
/  @param namt      (Long) The resultant amt of the inventory
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return          (Inventory) The new updated inventory
.inverse.account.crsFill                 :{[price;namt;account;inventory]
    inventory:.inverse.account.redFill[price;inventory[`amt];account;inventory];
    inventory:.inverse.account.incFill[price;namt;account;inventory];
    inventory[`isignum]:neg[inventory[`isignum]];  
    :inventory                  
    };

// ApplyFill applies a given execution to an account and its respective
// inventory, The function is for all intensive purposes only referenced
// from ProcessTrade in .order. // TODO
// 
.inverse.account.ApplyFill               :{[i;a;iB;iL;iS;fill]

    k:a`positionType;
    res:$[k=0;[ // TODO
            $[reduce;
                .inverse.account.redFill[price;qty;a;];
                .inverse.account.incFill[price;qty;a;]];
      ];
      k=1;[
            // TODO should be neg?
            namt:abs[inventory[`amt]+neg[qty]]; // TODO fix
            $[(reduce or (abs[i[`amt]]>abs[namt]); // TODO make sure sign is correct
                .inverse.account.redFill[price;qty;a;iB];
              ((iB[`amt]*namt)<0)); 
                .inverse.account.crsFill[price;namt;a;iB];
                .inverse.account.incFill[price;qty;a;iB]];
      ];'INVALID_POSITION_TYPE];

    // Common logic // TODO make aplicable to active inventory
    i[`realizedPnl]-:cost;
    i[`fillCount]+:1;
    i[`tradeVolume]+:qty;
    i[`unrealizedPnl]:.inverse.account.UnrealizedPnl[
        i[`amt];
        isign;
        i[`avgPrice];
        markPrice;
        faceValue];
    i[`markValue]+:qty;

    i[`entryValue]:(((%/)i`amt`avgPrice) | 0); // TODO to long
    i[`posMargin]:(((%/)i`entryValue`leverage) | 0); // TODO to long

    a[`balance]-:cost;
    a[`totalCommission]+:cost;
 
    (a;(iB;iL;iS))    
    };


// Update Mark Price Functionality // TODO return annotation
// ---------------------------------------------------------------------------------------->

// TODO make better
// UpdateMarkPrice updates an accounts state i.e. openLoss, available, posMargin
// and its unrealizedPnl when the mark price for a given instrument changes, it
// is generally used with fair price marking. Assumes unrealizedPnl is already derived? 
// TODO change openLoss to orderLoss TODO dry
// @param markPrice (Long) The latest mark price of the instrument
.inverse.account.UpdateMarkPrice         :{[markPrice;i;a;iB;iL;iS]

    a[`openBuyLoss]:(min[0,(markPrice*a[`openBuyQty])-a[`openBuyValue]] | 0);
    a[`openSellLoss]:(min[0,(markPrice*a[`openSellQty])-a[`openSellValue]] |0);
    a[`openLoss]:(sum[acc`openSellLoss`openBuyLoss] | 0);

    iB[`unrealizedPnl]:0;
    iL[`unrealizedPnl]:0;
    iS[`unrealizedPnl]:0;

    // TODO posMargin, markValue, maintMarginReq, initMarginReq
    a[`unrealizedPnl]:iB[`unrealizedPnl]+iL[`unrealizedPnl]+iS[`unrealizedPnl];
    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);

    (a;(iB;iL;iS))
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


// Apply Funding Functionality // TODO return annotation
// ---------------------------------------------------------------------------------------->

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
.inverse.account.ApplyFunding        :{[fundingRate;i;a]

    a[`balance]:0;

    // TODO this is subtracted from the margin?

    a[`longFundingCost]:0;
    a[`shortFundingCost]:0;
    a[`totalFundingCost]:0;
    a[`realizedPnl]:0;
  
    // TODO balance - realizedPnl

    a[`available]:((a[`balance]-sum[a`posMargin`unrealizedPnl`orderMargin`openLoss]) | 0);
 
    a
    };



// Deposit
// ---------------------------------------------------------------------------------------->

// Adds a given amount to the accounts balance.
// Update available/withdrawable etc. // TODO validate arguments?
.inverse.account.Deposit  :{[i;a;deposited;time]
    // TODO more expressive and complete upddate statement accounting for margin etc.
    // Account: available, liquidationprice, bankruptcyprice, depositCount

    a[`balance]-:deposited;
    a[`depositAmount]+:deposited;
    a[`depositCount]+:1;
    a[`withdrawable]+:deposited;
    / account[`available]:.account.Available[acc]; // TODO
    / account[`initMarginReq`maintMarginReq]


    // TODO add update event
    a
    };


// Withdraw
// ---------------------------------------------------------------------------------------->

// Checks that a given account has enough available balance to
// withdraw a given amount and then executes a withdrawal
// updating balance,withdrawCount and withdrawAmount
// Update available/withdrawable etc
/  @param withdrawn (Long) The amount that is to be withdrawn
/  @param time (datetime) The time of the withdraw event
/  @param accountId (Long) The id of the account to withdraw from
/  @throws InvalidAccountId accountId was not found.
/  @throws InsufficientMargin account has insufficient margin for withdraw
.inverse.account.Withdraw       :{[i;a;withdrawn;time]
    // Account: available, liquidationprice, bankruptcyprice, withdrawCount

    if[not[count[a]>0];'INVALID_ACCOUNTID];

    $[withdrawn < a[`withdrawable];[
        // TODO more expressive and complete upddate statement accounting for margin etc.

        a[`balance]-:withdrawn;
        a[`withdrawAmount]+:withdrawn;
        a[`withdrawCount]+:1;
        a[`withdrawable]-:withdrawn;
        / account[`available]:.account.Available[acc]; // TODO

        // TODO update liquidation price 
        
        ];'InsufficientMargin];  
    a
    };


// Withdraw
// ---------------------------------------------------------------------------------------->

// Moves realizedPnl into the balance and resets unrealizedPnl etc.?
/  @param withdrawn (Long) The amount that is to be withdrawn
/  @param time (datetime) The time of the withdraw event
/  @param accountId (Long) The id of the account to withdraw from
/  @throws InvalidAccountId accountId was not found.
/  @throws InsufficientMargin account has insufficient margin for withdraw
.inverse.account.ApplySettlement  :{[i;a;time]
    // Account: available, liquidationprice, bankruptcyprice, withdrawCount
    
    a
    };
