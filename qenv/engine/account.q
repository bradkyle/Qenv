/ \l inventory.q

\d .account
\l util.q

accountCount:0;

// TODO executions

/*******************************************************
/ account related enumerations  
MARGINTYPE      :   `CROSS`ISOLATED;
POSITIONTYPE    :   `HEDGED`COMBINED;

// FAIR price vs ema 
// Account state in this instance serves as a proxy
// for a single agent and contains config therin
// pertaining to what the agent setting is.
// TODO realized Gross PNL, unrealized Gross PNL, total Unrealized Pnl etc
// TODO is suspended, state etc.
// TODO ownFillCount, requestCount
// TODO margin call price
Account: (
            [accountId          : `long$()]
            balance             : `long$();
            frozen              : `long$();
            maintMargin         : `long$();
            available           : `long$();
            withdrawable        : `long$();
            openBuyQty          : `long$();
            openBuyLoss         : `long$();
            openBuyValue        : `long$();
            openBuyPremium      : `long$();
            openSellLoss        : `long$();
            openSellValue       : `long$();
            openSellQty         : `long$();
            openSellPremium     : `long$();
            grossOpenPremium    : `long$();
            openLoss            : `long$();
            orderMargin         : `long$();
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
            posMargin           : `long$();
            longMargin          : `long$();
            shortMargin         : `long$();
            shortFundingCost    : `long$();
            longFundingCost     : `long$();
            totalFundingCost    : `long$();
            totalLossPnl        : `long$();
            totalGainPnl        : `long$();
            realizedPnl         : `long$();
            unrealizedPnl       : `long$();
            liquidationPrice    : `long$();
            bankruptPrice       : `long$();
            totalCommission     : `long$();
            selfFillCount       : `long$();
            selfFillVolume      : `long$();
            leverage            : `long$();
            monthVolume         : `long$());

mandCols:();
defaults:{:((accountCount+:1),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,`CROSS,`COMBINED,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)};
allCols:cols Account;

// Event creation utilities
// -------------------------------------------------------------->

AddAccountUpdateEvent  :{[time;account] // TODO convert to list instead of dict
    // TODO check if value is null
    :.global.AddEvent[time;`UPDATE;`ACCOUNT_UPDATE;account];
    };

AddAllAccountsUpdatedEvents :{[time] // TODO convert to list instead of dict
    :.global.AddEvent[time;`UPDATE;`ACCOUNT_UPDATE;()]; // TODO get all for account
    };

// Account CRUD Logic
// -------------------------------------------------------------->
/ q.account)allCols!(enlist ["b"$not[null[account[allCols]]];((count allCols)-7)#0N;defaults[]])[2]
// Generates a new account with default 
// values and inserts it into the account 
// table. // TODO gen events. // TODO change to event?
NewAccount :{[account;time]
    if[any null account[mandCols]; :0b];
    // Replace null values with their respective defailt values
    // TODO dynamic account type checking
    account:Sanitize[account;defaults[];allCols];
    .logger.Debug["account validated and decorated"];
    / show value type each 1_account;
    / show value type each .account.Account@0;
    `.account.Account upsert account;

    / AddAccountUpdateEvent[accountId;time];
    };


// Global Account Utils
// -------------------------------------------------------------->

// TODO derive avg price, total entry, exec cost, gross open premium etc.

execCost :{[price;qty;isinverse]
    :$[isinverse;floor[1e8%price];1e8%price] * abs[qty]
    };

// Used to derive the average entry price for a given inventory
// TODO add randomization to this!!
avgPrice :{[isignum;execCost;totalEntry;isinverse] // TODO floor and ceiling respectively cause difference
    :$[(totalEntry>0) and (execCost>0);[
        :$[isinverse;
            [
                // If the contract is inverse, i.e. Bitmex
                p:execCost%totalEntry;
                :$[isignum>0;1e8%floor[p];1e8%ceiling[p]];
            ];
            [   
                // If the contract is linear i.e. Binance
                :1e8%(execCost*totalEntry);
            ]
        ];
    ];:0];
    };

// Returns the unrealized profit for the current position considering the current
// mark price and the average entry price (uses mark price to prevent liquidation).
// @avgprice: The average price the inventory was entered at
// @markprice: The current mark price of the instrument
// @amt: The size of the position
// @faceValue: The faceValue of the instrument
// @isignum: The sign of the instrument
// @isinverse: Is the instrument an inverse contract
unrealizedPnl       :{[avgprice;markprice;amt;faceValue;isignum;isinverse]
    :($[isinverse;(faceValue%markprice)-(faceValue%avgprice);markprice-avgprice]*(amt*isignum));
    };

// Calculates the realized profit and losses for a given position, size is a positive
// or negative number that represents the portion of the current position that has been
// closed and thus should be of the same side as the position i.e. negative for short and 
// positive for long.
// @avgprice: The average price the inventory was entered at
// @markprice: The current mark price of the instrument
// @fillqty: The size of the fill
// @faceValue: The faceValue of the instrument
// @isignum: The sign of the instrument
// @isinverse: Is the instrument an inverse contract
realizedPnl         :{[avgprice;fillprice;fillqty;faceValue;isignum;isinverse]
    :($[isinverse;(faceValue%fillprice)-(faceValue%avgprice);fillprice-avgprice]*(fillqty*isignum));
    };

// Calculates the amount of margin required to keep a position open, if the account no longer 
// has this margin available, the position will be liquidated.
// @amt: the size of the position
// @riskTiers: The table of risk tiers
// @riskBuffer: Additional risk buffer coefficient
maintainenceMargin   :{[amt;riskTiers;riskBuffer]
    // Derive risk limit
    lm:first ?[riskTiers;enlist(>;`mxamt;amt); 0b; ()];
    
    // Maintenence margin rate
    mm:lm[`mmr];

    // Maintenence amount
    // riskBuffer: i.e. takerFee*2 + fundingRate for bitmex
    :amt*(mm+riskBuffer);
    };

// Calculates the amount of margin required to initialize a position, including the premium 
// charged on the difference between the current price and the mark price of the contract.
// Initial margin is generally above maintenece margin .i.e. it requires more margin than
// the maintenence margin rate.
// @amt: the size of the position
// @riskTiers: The table of risk tiers
// @premium: The premium charged 
initialMargin      :{[amt;riskTiers;premium] // TODO fix
    // Derive risk limit
    lm:first ?[riskTiers;enlist(>;`mxamt;amt); 0b; ()];

    // Initial margin rate
    imr:lm[`imr];

    // TODO gross open premium

    // Maintenence amount
    // riskBuffer: i.e. takerFee*2 + fundingRate for bitmex
    :(amt*imr)+(amt * premium); // TODO derive premium
    };

// TODO inverse vs quanto vs LINEAR
// The point at which the exchange will force close all orders and shortly
// thereafter liquidate the position
// (raze(`isinverse;`rb;`bal;`tmm;`amtB;`amtL;`amtS;`lmB;`lmL;`lmS;`mmB;`mmL;`mmS;`cumB;`cumL;`cumS;`sB;`epB;`epL;`epS))!.qt.BAM

liquidationPrice    :{[account;inventoryB;inventoryL;inventoryS;instrument]
        bal:account[`balance]; // TODO change to margin?
        tmm:0; 

        rt:instrument[`riskTiers];
        rb:instrument[`riskBuffer];
        isinverse:(instrument[`contractType]=`INVERSE);

        .qt.RT:rt;

        // Current Position
        amtB:inventoryB[`amt];
        amtL:inventoryL[`amt];
        amtS:inventoryS[`amt];

        // Derive Average price // change total entry to execQty
        sB:inventoryB[`isignum];
        epB:.account.avgPrice[sB;inventoryB[`execCost];inventoryB[`totalEntry];isinverse];
        epL: .account.avgPrice[1;inventoryL[`execCost];inventoryL[`totalEntry];isinverse];
        epS: .account.avgPrice[-1;inventoryS[`execCost];inventoryS[`totalEntry];isinverse];

        $[isinverse;
            [nvalB:amtB%epB;nvalS:amtS%epS;nvalL:amtL%epL];
            [nvalB:amtB*epB;nvalS:amtS*epS;nvalL:amtS*epS]
        ];

        // Derive risk limits
        lmB:first ?[rt;enlist(>;`mxamt;nvalB); 0b; ()]; // TODO switch on leverage/amount etc.
        lmL:first ?[rt;enlist(>;`mxamt;nvalL); 0b; ()];
        lmS:first ?[rt;enlist(>;`mxamt;nvalS); 0b; ()];

        // Maintenence margin rate
        mmB:lmB[`mmr];
        mmL:lmL[`mmr];
        mmS:lmS[`mmr];

        // Maintenece Amount
        cumB: amtB*(mmB+rb);
        cumL: amtL*(mmL+rb);
        cumS: amtS*(mmS+rb);
 
        / .qt.BAM:(isinverse;rb;bal;tmm;amtB;amtL;amtS;lmB;lmL;lmS;mmB;mmL;mmS;cumB;cumL;cumS;sB;epB;epL;epS);

        // TODO round to nearest long vs short etc.

        :(((bal+tmm+cumB+cumL+cumS)-(sB*amtB*epB)+(amtL*epL)-(amtS*epS))
            %((amtB*mmB)+(amtL*mmL)+(amtS*mmS)-(sB*amtB)+(amtL-amtS)));
    };

// The point at which the entirety of the inventories initial margin has been 
// consumed. 
bankruptcyPrice     :{[account;inventoryL;inventoryS;inventoryB;instrument]
        bal:account[`balance];
        tmm:0; 

        rt:instrument[`riskTiers];

        // Current Position
        amtB:inventoryB[`amt];
        amtL:inventoryL[`amt];
        amtS:inventoryS[`amt];

        // Derive risk limits
        lmB:first ?[rt;enlist(>;`mxamt;amtB); 0b; ()]; // TODO move to instrument
        lmL:first ?[rt;enlist(>;`mxamt;amtL); 0b; ()];
        lmS:first ?[rt;enlist(>;`mxamt;amtS); 0b; ()];        

        // Initial margin rate
        imrB:lmB[`imr]; // TODO change this to the positions initial margin  
        imrL:lmL[`imr]; // TODO change this to the positions initial margin
        imrS:lmS[`imr]; // TODO change this to the positions initial margin

        // Maintenece Amount
        cumB: amtB*imrB;
        cumL: amtL*imrL;
        cumS: amtS*imrS;

        // Derive Average price
        sB:inventoryB[`isignum];
        epB:avgPrice[sB;inventoryB[`execCost];inventoryB[`totalEntry]];
        epL:avgPrice[1;inventoryL[`execCost];inventoryL[`totalEntry]];
        epS:avgPrice[-1;inventoryS[`execCost];inventoryS[`totalEntry]];

        :(((bal+tmm+cumB+cumL+cumS)-(sB*amtB*epB)-(amtL*epL)+(amtS*epS))
            %((amtB*imrB)+(amtL*imrL)+(amtS*imrS)-(sB*amtB)-(amtL+amtS)));
    };



// Funding Event/Logic //TODO convert to cnt for reference
// -------------------------------------------------------------->
// Positive funding rate means long pays short an amount equal to their current position
// * the funding rate.
// Negative funding rate means short pays long an amount equal to their current position
// * the funding rate.
// The funding rate6\ can either be applied to the current position or to the margin/balance.
// This function is accessed by the engine upon a funding event and unilaterally applies
// an update to all the open position quantites held in the schema/state representation.
// TODO next funding rate and next funding time (funding time delta)
// Update available withdrawable etc.
ApplyFunding       :{[fundingRate;nextFundingRate;nextFundingTime;time] // TODO convert to cnt (cntPosMrg)
    // Applies the current funding rate and subsequent
    // Account: available, fundingCount, frozen, realizedPnl, 
    //          unrealizedPnl, posMargin, initMargin, netLongPosition, 
    //          netShortPosition, liquidationPrice, bankruptcyPrice
    //          
    // Inventory: amt, lastValue, markValue, realizedPnl, unrealizedPnl, 
    //            posMargin, initMargin, entryValue, totalCost, totalEntry, 
    //            execCost, maintMarginReq, initMarginReq, (isignum if both)
    update balance:balance-((longValue*fundingRate)-(shortValue*fundingRate)), 
        longFundingCost:longFundingCost+(longValue*fundingRate),
        shortFundingCost:shortFundingCost+(longValue*fundingRate),
        totalFundingCost:totalFundingCost+((longValue*fundingRate)-(longValue*fundingRate))
        by accountId from `.account.Account;
    :.account.AddAllAccountsUpdatedEvents[time];
    };

// Balance Management
// -------------------------------------------------------------->

// Adds a given amount to the accounts balance.
// Update available/withdrawable etc.
Deposit  :{[deposited;time;accountId]
    // TODO more expressive and complete upddate statement accounting for margin etc.
    // Account: available, liquidationprice, bankruptcyprice, depositCount
    // 
    update 
        balance:balance+deposited, 
        depositAmount:depositAmount+deposited,
        depositCount:depositCount+1
        from `.account.Account 
        where accountId=accountId;
    :.account.AddAccountUpdateEvent[accountId;time];
    };


// Checks that a given account has enough available balance to
// withdraw a given amount and then executes a withdrawal
// updating balance,withdrawCount and withdrawAmount
// Update available/withdrawable etc
Withdraw       :{[withdrawn;time;accountId]
    acc:exec from  .account.Account where accountId=accountId;
    // Account: available, liquidationprice, bankruptcyprice, withdrawCount
    //          

    $[withdrawn < acc[`available];
        [
        // TODO more expressive and complete upddate statement accounting for margin etc.
        update 
            balance:balance-withdrawAmount 
            withdrawAmount:withdrawAmount+withdrawn
            withdrawCount:withdrawCount+1
            from `.account.Account 
            where accountId=accountId;
        :.account.AddAccountUpdateEvent[accountId;time];
        ];
        [
            0N; //TODO create failure
        ]
    ];  
    };


// Inventory Management
// -------------------------------------------------------------->

/*******************************************************
/ Inventory 

inventoryCount:0;
POSITIONSIDE   : `LONG`SHORT`BOTH;
// TODO posState
// TODO liqudation price
Inventory: (
    [
        accountId    :  `.account.Account$();
        side         :  `.account.POSITIONSIDE$()
    ]
    amt                      :  `long$();
    avgPrice                 :  `long$();
    realizedPnl              :  `long$();
    unrealizedPnl            :  `long$();
    posMargin                :  `long$();
    initMargin               :  `long$();
    entryValue               :  `long$();
    totalCost                :  `long$();
    totalEntry               :  `long$();
    execCost                 :  `long$();
    totalVolume              :  `long$();
    totalCloseVolume         :  `long$();
    totalCrossVolume         :  `long$();
    totalOpenVolume          :  `long$(); 
    totalCloseMarketValue    :  `long$();
    totalCrossMarketValue    :  `long$();
    totalOpenMarketValue     :  `long$(); 
    totalCloseAmt            :  `long$();
    totalCrossAmt            :  `long$();
    totalOpenAmt             :  `long$(); 
    lastValue                :  `long$(); 
    markValue                :  `long$();
    initMarginReq            :  `long$();
    maintMarginReq           :  `long$();
    leverage                 :  `long$();
    totalCommission          :  `long$();
    isignum                  :  `long$();
    fillCount                :  `long$());

/ .account.Inventory@(1;`.account.POSITIONSIDE$`BOTH)

DefaultInventory:{(0,`BOTH,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)};

/ default:  // TODO validation here
NewInventory : {[inventory;time] 
    if[any null inventory[`accountId`side]; :0b];
    $[inventory[`side]=`LONG;
        [
            inventory[`isignum]:1;
        ];
      inventory[`side]=`SHORT;
        [   
            inventory[`isignum]:-1;
        ];
      inventory[`side]=`BOTH;
        [
            inventory[`isignum]:1;
        ];
      [
          'INVALID_POSITIONSIDE;
      ]
    ];
    inventory:Sanitize[inventory;DefaultInventory[];cols Inventory];
    .logger.Debug["inventory validated and decorated"];
    `.account.Inventory upsert inventory; // TODO check if successful
    };

// Fill
// -------------------------------------------------------------->

// Gets the position side that an order fills
HedgedSide      :{[side] :$[side=`SELL;`SHORT;`LONG]};
HedgedNegSide   :{[side] :$[side=`SELL;`LONG;`SHORT]};

// Increments the occurance of an agent's self fill.
// @x : unique account id
// @y : self filled count
// @z : amount that is self filled
IncSelfFill    :{
        ![`.account.Account;
            enlist (=;`accountId;x);
            0b;`selfFillCount`selfFillVolume!(
                (+;`selfFillCount;y);
                (+;`selfFillVolume;z)
            )];};

 
dcMrg   :{`long(x*y)};
dcCnt   :{`long(x*y)};

// TODO
// maint margin
// liquidation price
// initial margin
// bankruptcy price

// Margin Transition logic
// ---------------------------------------------------------------------------------------->


accNewOrderTransition:{[price;markPrice;]

    // TODO update move to own function
    premium:`long$(abs[min[0,(isignum*(ins[`markPrice]-price))]]);
    $[(isignum>0) and (premium>0);[ // TODO fix
        acc[`openBuyPremium]+:premium; // TODO?
        acc[`openBuyQty]+:qty; 
        acc[`openBuyValue]+:`long$(price*qty); // TODO check
        acc[`openBuyLoss]+:`long$(premium*qty);
    ];
    [
        acc[`openSellPremium]-:premium;
        acc[`openSellQty]+:qty; 
        acc[`openSellValue]+:`long$(price*qty);
        acc[`openSellLoss]+:`long$(premium*qty);
    ]];

    acc[`openLoss]:`long$(sum[acc`openSellLoss`openBuyLoss] | 0);
    acc[`orderMargin]:`long$((acc[`openBuyValue]+acc[`openSellValue])%acc[`leverage]);
    acc[`available]:`long$(acc[`balance]-(sum[acc`unrealizedPnl`posMargin`orderMargin`openLoss]));
    :acc
 };

accFillTransition:{[price;markPrice;]

    // TODO update move to own function
    premium:`long$(abs[min[0,(isignum*(ins[`markPrice]-price))]]);
    $[(isignum>0) and (premium>0);[ // TODO fix
        acc[`openBuyPremium]-:premium; // TODO?
        acc[`openBuyQty]-:qty; 
        acc[`openBuyValue]-:`long$(price*qty); // TODO check
        acc[`openBuyLoss]-:`long$(premium*qty);
    ];
    [
        acc[`openSellPremium]-:premium;
        acc[`openSellQty]-:qty; 
        acc[`openSellValue]-:`long$(price*qty);
        acc[`openSellLoss]-:`long$(premium*qty);
    ]];

    acc[`openLoss]:`long$(sum[acc`openSellLoss`openBuyLoss] | 0);
    acc[`orderMargin]:`long$((acc[`openBuyValue]+acc[`openSellValue])%acc[`leverage]);
    acc[`available]:`long$(acc[`balance]-(sum[acc`unrealizedPnl`posMargin`orderMargin`openLoss]));
    :acc
 };

accCancelOrderTransition:{[price;markPrice;]

    // TODO update move to own function
    premium:`long$(abs[min[0,(isignum*(ins[`markPrice]-price))]]);
    $[(isignum>0) and (premium>0);[ // TODO fix
        acc[`openBuyPremium]-:premium; // TODO?
        acc[`openBuyQty]-:qty; 
        acc[`openBuyValue]-:`long$(price*qty); // TODO check
        acc[`openBuyLoss]-:`long$(premium*qty);
    ];
    [
        acc[`openSellPremium]-:premium;
        acc[`openSellQty]-:qty; 
        acc[`openSellValue]-:`long$(price*qty);
        acc[`openSellLoss]-:`long$(premium*qty);
    ]];

    acc[`openLoss]:`long$(sum[acc`openSellLoss`openBuyLoss] | 0);
    acc[`orderMargin]:`long$((acc[`openBuyValue]+acc[`openSellValue])%acc[`leverage]);
    acc[`available]:`long$(acc[`balance]-(sum[acc`unrealizedPnl`posMargin`orderMargin`openLoss]));
    :acc
 };


// Hedged Open And Close Fill Logic
// ---------------------------------------------------------------------------------------->

hedgedOpen    :{[]
        iside:HedgedNegSide[side];
        oside:HedgedSide[side];
        // OPEN given side for position
        i:.account.Inventory@(accountId;iside);
        oi:.account.Inventory@(accountId;oside);

        i[`amt]+:qty;

        cost:qty*fee;
        i[`totalCommission]+:cost;
        i[`fillCount]+:1;
        i[`tradeVolume]+:qty;
        i[`realizedPnl]-:cost;

        / Because the current position is being increased
        / an entry is added for calculation of average entry
        / price. 
        i[`totalEntry]+: abs[qty];

        // TODO dont divide price
        i[`execCost]+: sm[.account.execCost[
            price;
            qty;
            isinverse]];  // TODO make unilaterally applicable.
        .qt.INV:i;

        // TODO convert price to float
        / Calculates the average price of entry for 
        / the current postion, used in calculating 
        / realized and unrealized pnl.
        i[`avgPrice]: pm[.account.avgPrice[
            i[`isignum];
            i[`execCost];
            i[`totalEntry];
            isinverse]];

        i[`unrealizedPnl]:sm[.account.unrealizedPnl[
            i[`avgPrice];
            ins[`markPrice];
            i[`amt];
            ins[`faceValue];
            i[`isignum];
            isinverse]];

        i[`entryValue]: i[`amt]%i[`avgPrice];
        i[`initMargin]: i[`entryValue]%acc[`leverage];
        i[`posMargin]:  i[`initMargin]+i[`unrealizedPnl];
        i[`maintMargin]:.account.maintainenceMargin[i;ins];

        lp:.account.liquidationPrice[i;oi;acc]; // TODO liquidation price
        bp:.account.bankruptcyPrice[i;oi;acc]; // TODO bankruptcy price

        acc[`balance]+:(rpl-cost); 
        acc[`unrealizedPnl]: i[`unrealizedPnl]+oi[`unrealizedPnl];
        acc[`orderMargin]: i[`orderMargin]+oi[`orderMargin];
        acc[`posMargin]: i[`posMargin]+oi[`posMargin];
        acc[`available]:((acc[`balance]+acc[`unrealizedPnl])-(acc[`orderMargin]+acc[`posMargin]));
        // TODO account netShortPosition, netLongPosition
    };

hedgedClose    :{[]
        iside:HedgedNegSide[side];
        oside:HedgedSide[side];
        // CLOSE given side for position
        i:.account.Inventory@(accountId;iside);
        oi:.account.Inventory@(accountId;oside);

        if[size>i[`amt];:.event.AddFailure[]]; // TODO error

        cost:qty*fee;
        rpl:.account.realizedPnl[i[`avgPrice];price;qty;ins];
        i[`totalCommission]+:cost;
        i[`realizedGrossPnl]+:(rpl-cost);
        i[`realizedPnl]+:rpl;
        i[`amt]-:qty;
        i[`fillCount]+:1;
        i[`tradeVolume]+:qty;

        i[`unrealizedPnl]:.account.unrealizedPnl[i[`avgPrice];i[`amt];ins];

        i[`initMargin]:i[`entryValue]%acc[`leverage];
        i[`posMargin]:i[`initMargin]+i[`unrealizedPnl];
        if[isMaker;i[`orderMargin]];
        i[`maintMargin]:.account.maintainenceMargin[i[`amt];ins];

        acc[`balance]+:(rpl-cost); 
        acc[`unrealizedPnl]: i[`unrealizedPnl]+oi[`unrealizedPnl];
        acc[`orderMargin]: i[`orderMargin]+oi[`orderMargin];
        acc[`posMargin]: i[`posMargin]+oi[`posMargin];
        acc[`available]:((acc[`balance]+acc[`unrealizedPnl])-(acc[`orderMargin]+acc[`posMargin]));
    };

// Combined Cross, Open and Close Fill Logic
// ---------------------------------------------------------------------------------------->

// Main Public Fill Function
// ---------------------------------------------------------------------------------------->

// TODO make global enums file
// TOD7,776e+6/1000
// TODO make simpler
// TODO update applicable fee when neccessary // TODO convert accountId/instrumentId to dictionary
ApplyFill     :{[accountId; instrumentId; side; time; reduceOnly; isMaker; price; qty]
    qty:abs[qty];

    // TODO if is maker reduce order margin here!
    // TODO fill cannot occur when BOTH inventory is open

    // Validation
    // ---------------------------------------------------------------------------------------->

    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[accountId]," could not be found"]];

    if[null instrumentId; :.event.AddFailure[time;`INVALID_INSTRUMENTID;"instrumentId is null"]];
    if[not(instrumentId in key .instrument.Instrument);
        :.event.AddFailure[time;`INVALID_INSTRUMENTID;"An instrument with the id:",string[instrumentId]," could not be found"]];

    acc:.account.Account@accountId;
    ins:.instrument.Instrument@instrumentId;
    fee: $[isMaker;acc[`activeMakerFee];acc[`activeTakerFee]];
    isinverse: ins[`contractType]=`INVERSE;
    isignum:$[side=`SELL;-1;1];

    sm:{:`long$(x[`sizeMultiplier]*y)}[ins];
    pm:{:`long$(x[`priceMultiplier]*y)}[ins];

    if[(isMaker and not[reduceOnly]);.account.accFillTransition[]];

    .qt.ACC:acc;

    $[acc[`positionType]=`HEDGED;[ 
            $[reduceOnly;
                .account.hedgedClose[];
                .account.hedgedOpen[]
            ];
        ];
        [
            iside:`BOTH;
            i:.account.Inventory@(accountId;iside);
            namt:i[`amt]+qty;
            $[(reduceOnly or (abs[i[`amt]]>abs[namt])); // Close position // TODO change isignum
                [
                    // Close positionType BOTH
                    // TODO account netShortPosition, netLongPosition
                    // CLOSE given side for position

                    if[size>i[`amt];:.event.AddFailure[]];

                    cost:qty*fee;
                    rpl:deriveRealizedPnl[i[`avgPrice];price;qty;ins];
                    i[`totalCommission]+:cost;
                    i[`realizedGrossPnl]+:(rpl-cost);
                    i[`realizedPnl]+:rpl;
                    i[`amt]-:qty;
                    i[`fillCount]+:1;
                    i[`tradeVolume]+:qty;

                    i[`unrealizedPnl]:unrealizedPnl[i[`avgPrice];i[`amt];ins];

                    i[`initMargin]:i[`entryValue]%acc[`leverage];
                    i[`posMargin]:i[`initMargin]+i[`unrealizedPnl];
                    if[isMaker;i[`orderMargin]];
                    i[`maintMargin]:maintainenceMargin[i[`amt];ins];
                    i[`isignum]:neg[i[`isignum]];

                    acc[`balance]+:(rpl-cost); 
                    acc[`unrealizedPnl]: i[`unrealizedPnl];
                    acc[`orderMargin]: i[`orderMargin];
                    acc[`posMargin]: i[`posMargin];
                    acc[`available]:((acc[`balance]+acc[`unrealizedPnl])-(acc[`orderMargin]+acc[`posMargin]));

                ];
              ((i[`amt]*namt)<0); // TODO check sign
                [ 
                    // Cross position
                    i[`totalEntry]+: abs[namt];
                    i[`execCost]+: floor[1e8%price] * abs[namt]; // TODO make unilaterally applicable.

                    / Calculates the average price of entry for the current postion, used in calculating 
                    / realized and unrealized pnl.
                    i[`avgPrice]: {$[x[`side]=`LONG;
                        1e8%floor[x[`execCost]%x[`totalEntry]]; // TODO make this calc unilaterally applicable
                        1e8%ceiling[x[`execCost]%x[`totalEntry]]
                        ]}[i];

                    i[`unrealizedPnl]:unrealizedPnl[i[`avgPrice];i[`amt];ins];

                    i[`entryValue]:i[`amt]%i[`avgPrice];
                    i[`initMargin]:i[`entryValue]%acc[`leverage];
                    i[`posMargin]:i[`initMargin]+i[`unrealizedPnl];

                    i[`maintMargin]:maintainenceMargin[i[`amt];ins];

                    acc[`balance]+:(rpl-cost); 
                    acc[`unrealizedPnl]: i[`unrealizedPnl]+oi[`unrealizedPnl];
                    acc[`orderMargin]: i[`orderMargin]+oi[`orderMargin];
                    acc[`posMargin]: i[`posMargin]+oi[`posMargin];
                    acc[`available]:((acc[`balance]+acc[`unrealizedPnl])-(acc[`orderMargin]+acc[`posMargin]));
                ];
                [
                    // Open positionType BOTH
                    i[`totalEntry]+: abs[namt];
                    i[`execCost]+: floor[1e8%price] * abs[namt]; // TODO make unilaterally applicable.
                    
                    / Calculates the average price of entry for the current postion, used in calculating 
                    / realized and unrealized pnl.
                    i[`avgPrice]: {$[(x[`amt]>0);
                        1e8%floor[x[`execCost]%x[`totalEntry]]; // TODO make this calc unilaterally applicable
                        1e8%ceiling[x[`execCost]%x[`totalEntry]]
                        ]}[i];

                    i[`unrealizedPnl]:unrealizedPnl[i[`avgPrice];i[`amt];ins];

                    i[`entryValue]:i[`amt]%i[`avgPrice];
                    i[`initMargin]:i[`entryValue]%acc[`leverage];
                    i[`posMargin]:i[`initMargin]+i[`unrealizedPnl];

                    i[`maintMargin]:maintainenceMargin[i[`amt];ins];

                    acc[`balance]+:(rpl-cost); 
                    acc[`unrealizedPnl]: i[`unrealizedPnl]+oi[`unrealizedPnl];
                    acc[`orderMargin]: i[`orderMargin]+oi[`orderMargin];
                    acc[`posMargin]: i[`posMargin]+oi[`posMargin];
                    acc[`available]:((acc[`balance]+acc[`unrealizedPnl])-(acc[`orderMargin]+acc[`posMargin]));

                ]
            ];
        ]
    ];

    ![`.account.Account;enlist(=;`accountId;accountId);0b;acc];
    ![`.account.Inventory;((=;`accountId;accountId);(=;`side;iside));0b;i];

    };


// Liquidation
// -------------------------------------------------------------->

UpdateMarkPrice : {[mp;instrumentId;time]
    / https://www.bitmex.com/app/liquidationExamples
    / https://www.bitmex.com/app/liquidation
    / https://www.bitmex.com/app/wsAPI#Deleverage
    / https://www.bitmex.com/app/wsAPI#Liquidation
    / https://huobiglobal.zendesk.com/hc/en-us/articles/360000143042-Partial-Liquidation-of-Futures
    / https://www.okex.com/academy/en/full-liquidation
    / https://www.binance.com/en/support/faq/360033525271
    / https://binance.zendesk.com/hc/en-us/articles/360033525271-Liquidation
    / https://help.ftx.com/hc/en-us/articles/360027668712-Liquidations


    ins:.instrument.Instrument@instrumentId;
    // TODO derive risk buffer

    // update openSellLoss, openBuyLoss, openBuyPremium, openSellPremium
    / During liquidation, users are unable to send orders on their account
    / Liquidation is executed as Fill or Kill and it will be executed immediately.

    // TODO unrealizedPnl
    // TODO bankruptCost
    // grossOpenPremium
    // withdrawable
    // frozen

    // openLoss:openBuyLoss+openSellLoss
    // openSellLoss:min[0,neg[(mp*openSellQty)-openSellValue]];
    // openBuyLoss:min[0,(mp*openBuyQty)-openBuyValue];
    // 

    // todo update the open loss of all accounts
    // TODO check for liquidations
    // Update the unrealizedPnl and the markPrice 
    // of the inventory such that they can be used
    // later in deriving 
    i:update 
        unrealizedPnl:.account.unrealizedPnl[avgPrice;mp;amt;1;isignum;0b], // TODO upscale
        markValue:mp*amt // TODO upscale
        from .account.Inventory where amt>0;

    // max[0;(markDelta+openSellLoss)]
    // max[0;(markDelta+openBuyLoss)]
    // ((mp%ins[`markPrice])-1) * orderCost
    // new OrderCost: deltaMarkprice
    // {:y-(y mod x)}[0.5](((1004%996)-1)*806)
    
    // openLoss:(mp * (openBuyQty+openSellQty)) - (openBuyValue+openSellValue);
    // avgValue:
 
    // TODO check this 
    a:update // TODO change to openLoss
        openLoss:openBuyLoss+openSellLoss,
        available:balance - sum[
            posMargin, // TODO derive new maint margin
            unrealizedPnl, 
            orderMargin,
            sum[openBuyLoss, openSellLoss]]
        from update
        openBuyLoss:min[0,(mp*openBuyQty)-openBuyValue],
        openSellLoss: min[0,neg[(mp*openSellQty)-openSellValue]]
        from (select from .account.Account where sum[netLongPosition,netShortPosition,openBuyQty,openSellQty]>0);

    x:select
            maintMarginReq:0, 
            available:balance-sum[
            neg[unrealizedPnl],
            posMargin,
            orderMargin,
            openLoss] 
            by accountId from (a lj (select sum unrealizedPnl by accountId from i)); // TODO test this
    

    / select sum'[unrealizedPnl;posMargin;orderMargin;openLoss] by accountId from .account.Inventory where amt>0;

    // do liquidation protocol
    {
        // After force liquidation occurs, the liquidation 
        // positions will be separated from the user’s equity balance.
        
        // TODO check this
        // TODO close orders where not reduce only
        .order.CancelAllOrders[y[`accountId]];
        z:exec from .qt.Account where accountId:z[`accountId];
        if[z[`available]<z[`maintMarginReq];[
            // The system will cancel all current orders for this symbol contract;

            // The long and short positions of the contract of the same period will be self-traded;

            // If the maintMargin req still exceeds available liquidation shall occur
            x[`liquidationStrat]
            
        ]]; 
    }[ins;time]'[select from x where available<maintMarginReq];
    
    };