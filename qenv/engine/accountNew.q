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

mandCols, defaults, allCols : DeriveDefaults();

execFill    :{[account;inventory;fillQty;price;fee]

    };