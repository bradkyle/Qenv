/ \l inventory.q

\d .account
\l util.q

accountCount:0;

/*******************************************************
/ account related enumerations  
MARGINTYPE      :   `CROSS`ISOLATED;
POSITIONTYPE    :   `HEDGED`COMBINED;

// Account state in this instance serves as a proxy
// for a single agent and contains config therin
// pertaining to what the agent setting is.
// TODO realized Gross PNL, unrealized Gross PNL, total Unrealized Pnl etc
// TODO is suspended, state etc.
// TODO ownFillCount, requestCount
Account: (
            [accountId          : `long$()]
            balance             : `long$();
            frozen              : `long$();
            maintMargin         : `long$();
            available           : `long$();
            withdrawable        : `long$();
            openBuyOrderQty     : `long$();
            openBuyPremium      : `long$();
            openSellOrderQty    : `long$();
            openSellPremium     : `long$();
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
            longValue           : `long$();
            shortValue          : `long$();
            shortFundingCost    : `long$();
            longFundingCost     : `long$();
            totalFundingCost    : `long$();
            totalLossPnl        : `long$();
            totalGainPnl        : `long$();
            realizedPnl         : `long$();
            liquidationPrice    : `long$();
            bankruptPrice       : `long$();
            longUnrealizedPnl   : `long$();
            shortUnrealizedPnl  : `long$();
            unrealizedPnl       : `long$();
            activeMakerFee      : `long$();
            activeTakerFee      : `long$();
            totalCommission     : `long$();
            selfFillCount       : `long$();
            selfFillVolume      : `long$());

mandCols:();
defaults:{:((accountCount+:1),0,0,0,0,0,0,0,0,0,0,`CROSS,`COMBINED,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)};
allCols:cols Account;

// Event creation utilities
// -------------------------------------------------------------->

AddAccountUpdateEvent  :{[time;account]
    // TODO check if value is null
    :.global.AddEvent[time;`UPDATE;`ACCOUNT_UPDATE;account];
    };

AddAllAccountsUpdatedEvents :{[time]
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
ApplyFunding       :{[fundingRate;nextFundingTime;time] // TODO convert to cnt (cntPosMrg)

    // todo available, frozen
    update balance:balance-((longValue*fundingRate)-(shortValue*fundingRate)), 
        longFundingCost:longFundingCost+(longValue*fundingRate),
        shortFundingCost:shortFundingCost+(longValue*fundingRate),
        totalFundingCost:totalFundingCost+((longValue*fundingRate)-(longValue*fundingRate))
        by accountId from `.account.Account;
    :AddAllAccountsUpdatedEvents[time];
    };

// Balance Management
// -------------------------------------------------------------->

Deposit  :{[deposited;time;accountId]
    // TODO more expressive and complete upddate statement accounting for margin etc.
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
Withdraw       :{[withdrawn;time;accountId]
    acc:exec from  .account.Account where accountId=accountId;

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
    totalCloseVolume         :  `long$();
    totalCrossVolume         :  `long$();
    totalOpenVolume          :  `long$(); 
    totalCloseMarketValue    :  `long$();
    totalCrossMarketValue    :  `long$();
    totalOpenMarketValue     :  `long$(); 
    totalCloseAmt            :  `long$();
    totalCrossAmt            :  `long$();
    totalOpenAmt             :  `long$(); 
    liquidationPrice         :  `long$();
    bankruptPrice            :  `long$();
    breakEvenPrice           :  `long$(); 
    lastValue                :  `long$(); 
    markValue                :  `long$();
    initMarginReq            :  `long$();
    maintMarginReq           :  `long$();
    leverage                 :  `long$();
    effectiveLeverage        :  `long$();
    totalCommission          :  `long$();
    faceValue                :  `long$();
    fillCount                :  `long$());

/ .account.Inventory@(1;`.account.POSITIONSIDE$`BOTH)

DefaultInventory:{(0,`BOTH,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)};

/ default:  
NewInventory : {[inventory;time] 
    if[any null inventory[`accountId`side]; :0b];
    inventory:Sanitize[inventory;DefaultInventory[];cols Inventory];
    .logger.Debug["inventory validated and decorated"];
    `.account.Inventory upsert inventory; // TODO check if successful
    };

// ORDER Margin
// -------------------------------------------------------------->
// Does premium change with changing mark price?

// Validates that the account can open the order.
// Updates the open order state of an account
// Updates an accounts order margin, open order amount, order premium 
// netLongPosition/netShortPosition
// @delta      : the amount by which the order quantity is to be changed.
// @side       : the side that is to be updated by the order.
// @price      : the price of the given order.
// @account    : dict representation of the account to be updated
// @instrument : dict representation of the orders instrument 
UpdateOrderMargin    :{[side;price;size;reduceOnly;accountId]

    };

// Fill
// -------------------------------------------------------------->

// Gets the position side that an order fills
HedgedSide      :{[side] :$[side=`SELL;`SHORT;`LONG]};
HedgedNegSide   :{[side] :$[side=`SELL;`LONG;`SHORT]};
pricePerContract  :{[faceValue;price]$[price>0;faceValue%price;0]};


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
            )];}

avgPrice        :{[]
        :$[kind=`INVERSE;
            $[side=`LONG;]
          kind=`VANILLA;
            $[];
          kind=`QUANTO;
            $
        ];
        `long$($[y=`LONG;
                    1e8%floor[x[`execCost]%x[`totalEntry]]; // TODO make this calc unilaterally applicable
                    1e8%ceiling[x[`execCost]%x[`totalEntry]]
                    ])};

// Returns the unrealized profit for the current position considering the current
// mark price and the average entry price (uses mark price to prevent liquidation).
unrealizedPnl       :{[avgprice;markprice;amt;faceValue;kind]
    :$[kind=`INVERSE;
        (.account.pricePerContract[faceValue;avgprice] - .account.pricePerContract[faceValue;markprice])*amt;
      kind=`VANILLA;
        ();
      kind=`QUANTO;
        ();
      () 
    ];
    };

// Calculates the realized profit and losses for a given position, size is a positive
// or negative number that represents the portion of the current position that has been
// closed and thus should be of the same side as the position i.e. negative for short and 
// positive for long.
realizedPnl         :{[avgprice;fillprice;fillqty;faceValue;kind]
    :$[kind=`INVERSE;
        (.account.pricePerContract[faceValue;avgprice] - .account.pricePerContract[faceValue;fillprice])*fillqty;
      kind=`VANILLA;
        ();
      kind=`QUANTO;
        ();
      ()
    ];
    };

initMargin          :{

    };

maintMargin         :{

    };

liquidationPrice    :{

    };

bankruptcyPrice     :{

    };



// TODO
// maint margin
// liquidation price
// initial margin
// bankruptcy price


// TODO make global enums file
// TOD7,776e+6/1000
// TODO make simpler
// TODO update applicable fee when neccessary
ApplyFill     :{[accountId; instrumentId; side; time; reduceOnly; isMaker; price; qty]
    qty:abs[qty];

    if[null accountId; :.event.AddFailure[time;`INVALID_ACCOUNTID;"accountId is null"]];
    if[not(accountId in key .account.Account);
        :.event.AddFailure[time;`INVALID_ACCOUNTID;"An account with the id:",string[accountId]," could not be found"]];

    if[null instrumentId; :.event.AddFailure[time;`INVALID_INSTRUMENTID;"instrumentId is null"]];
    if[not(instrumentId in key .instrument.Instrument);
        :.event.AddFailure[time;`INVALID_INSTRUMENTID;"An instrument with the id:",string[instrumentId]," could not be found"]];

    acc:.account.Account@accountId;
    ins:.instrument.Instrument@instrumentId;
    fee: $[isMaker;acc[`activeMakerFee];acc[`activeTakerFee]];

    $[acc[`positionType]=`HEDGED;
        $[reduceOnly;
            [
                // CLOSE given side for position
                i:.account.Inventory@(accountId;HedgedNegSide[side]);
                oi:.account.Inventory@(accountId;HedgedSide[side]);

                if[size>i[`amt];:.event.AddFailure[]];

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

                // TODO account netShortPosition, netLongPosition
            ];
            [
                // OPEN given side for position
                side:HedgedNegSide[side];
                i:.account.Inventory@(accountId;side);
                oi:.account.Inventory@(accountId;HedgedSide[side]);

                i[`currentQty]+:qty;

                cost:qty*fee;
                i[`totalCommission]+:cost;
                i[`fillCount]+:1;
                i[`tradeVolume]+:qty;
                i[`realizedPnl]-:cost;

                / Because the current position is being increased
                / an entry is added for calculation of average entry
                / price. 
                i[`totalEntry]+: abs[qty];
                i[`execCost]+: floor[1e8%price] * abs[qty]; // TODO make unilaterally applicable.

                / Calculates the average price of entry for the current postion, used in calculating 
                / realized and unrealized pnl.
                i[`avgPrice]: .account.avgPrice[i;side];
                i[`unrealizedPnl]:.account.unrealizedPnl[i[`avgPrice];i[`amt];ins];

                i[`entryValue]:i[`amt]%i[`avgPrice];
                i[`initMargin]:i[`entryValue]%acc[`leverage];
                i[`posMargin]:i[`initMargin]+i[`unrealizedPnl];
                i[`maintMargin]:.account.maintainenceMargin[i;ins];

                lp:.account.liquidationPrice[i;oi;acc]; // TODO liquidation price
                bp:.account.bankruptcyPrice[i;oi;acc]; // TODO bankruptcy price
 
                acc[`balance]+:(rpl-cost); 
                acc[`unrealizedPnl]: i[`unrealizedPnl]+oi[`unrealizedPnl];
                acc[`orderMargin]: i[`orderMargin]+oi[`orderMargin];
                acc[`posMargin]: i[`posMargin]+oi[`posMargin];
                acc[`available]:((acc[`balance]+acc[`unrealizedPnl])-(acc[`orderMargin]+acc[`posMargin]));
                // TODO account netShortPosition, netLongPosition

            ]
        ];
        [
            i:.account.Inventory@(accountId;`BOTH);
            namt:i[`amt]+qty;
            $[(reduceOnly or (abs[i[`amt]]>abs[namt])); // Close position
                [
                    // Close positionType BOTH
                    // TODO account netShortPosition, netLongPosition
                    // CLOSE given side for position
                    i:.account.Inventory@(accountId;HedgedNegSide[side]);

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
    };


UpdateMarkPrice : {[markPrice;instrumentId;time]
    ins:.instrument.Instrument@instrumentId;

    // TODO check for liquidations
    update unrealizedPnl:unrealizedPnl[avgPrice;amt;ins] from `.account.Inventory;
    update 
        unrealizedPnl:0, 
        posMargin:0, 
        available:0, 
        leverage:0 from `.account.Inventory;
  

    // do liquidation protocol
    {
        .order.CancelAllOrders[x];
        acc:.account.Account@x;
        if[acc[`initMargin];[
            
        ]]; 
    } select accountId from .account.Account where (initMargin+realizedPnl+unrealizedPnl)<maintMargin;
    
    };