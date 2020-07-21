\l inventory.q

\d .account
\l util.q
\l state.q

accountCount:0;

/*******************************************************
/ account related enumerations  
MARGINTYPE      :   `CROSS`ISOLATED;
POSITIONTYPE    :   `HEDGED`COMBINED;

// Account state in this instance serves as a proxy
// for a single agent and contains config therin
// pertaining to what the agent setting is.
Account: (
            [accountId          : `long$()]
            balance             : `float$();
            frozen              : `float$();
            maintMargin         : `float$();
            available           : `float$();
            withdrawable        : `float$();
            openBuyOrderQty     : `long$();
            openBuyPremium      : `float$();
            openSellOrderQty    : `long$();
            openSellPremium     : `float$();
            orderMargin         : `float$();
            marginType          : `.account.MARGINTYPE$();
            positionType        : `.account.POSITIONTYPE$();
            depositAmount       : `float$();
            depositCount        : `long$();
            withdrawAmount      : `float$();
            withdrawCount       : `long$();
            tradeVolume         : `long$();
            tradeCount          : `long$();
            netLongPosition     : `long$();
            netShortPosition    : `long$();
            posMargin           : `float$();
            longMargin          : `float$();
            shortMargin         : `float$();
            longValue           : `float$();
            shortValue          : `float$();
            shortFundingCost    : `float$();
            longFundingCost     : `float$();
            totalFundingCost    : `float$();
            totalLossPnl        : `float$();
            totalGainPnl        : `float$();
            realizedPnl         : `float$();
            liquidationPrice    : `float$();
            bankruptPrice       : `float$();
            unrealizedPnl       : `float$();
            activeMakerFee      : `float$();
            activeTakerFee      : `float$();
            totalCommission     : `float$()
        );

mandCols, defaults, allCols : DeriveDefaults[.account.Account];

// Apply fill is an internal function i.e. it is not exposed
// to the engine but is used by the orderbook to add a given
// qty to the active position of an account.
// todo allow for onlyclose and calcualte fee
ApplyFill  :{[qty;price;side;time;isClose;isMaker;accountId]
    events:();
    acc: exec from Account where accountId=accountId;
    fee: $[isMaker;acc[`activeMakerFee];acc[`activeTakerFee]];
    // TODO remove order margin
    // TODO on hedged position check if close greater than open position.
    $[(abs qty)>0f;[
        $[acc[`positionType]=`HEDGED;
            $[qty>0;
            execFill[acc;getInventory[accountId;`LONG];$[isClose;neg qty;qty];price;fee];
            execFill[acc;getInventory[accountId;`SHORT];$[isClose;neg qty;qty];price;fee]
            ]; // LONG; SHORT
          acc[`positionType]=`COMBINED;
            [execFill[acc;getInventory[accountId;`BOTH];$[side=`SELL;neg qty;qty];price;fee]];
          [0N]
        ];
    ];];
    :events;
    };
