
// Accounts of an Instrument
// ---------------------------------------------------------------------------->

.account.accountCount:0;

// contains reference to instrument, 
.engine.model.account.Account                 :(
    [accountId          : `long$()]

    // Private Behavior Settings 
    initMarginReq       : `float$();
    maintMarginReq      : `float$();
    
    // Public Behavior settings
    marginType          : `long$();
    positionType        : `long$();
    
    // Boolean Values
    inMarket            : `boolean$();

    // Order Margin & Premium Values
    orderMargin         : `long$();
    openBuyQty          : `long$();
    openBuyLoss         : `long$();
    openBuyValue        : `long$();
    openBuyMargin       : `long$();
    openSellLoss        : `long$();
    openSellValue       : `long$();
    openSellQty         : `long$();
    openSellMargin      : `long$();
    openLoss            : `long$();
    openOrderValue      : `long$();

    // Position Margin & Pnl Values
    posMargin           : `long$();
    longMargin          : `long$();
    shortMargin         : `long$();

    // Accumultators
    depositAmount       : `long$();
    depositCount        : `long$();
    withdrawAmount      : `long$();
    withdrawCount       : `long$();
    shortFundingCost    : `long$();
    longFundingCost     : `long$();
    totalFundingCost    : `long$();
    totalLossPnl        : `long$();
    totalGainPnl        : `long$();
    selfFillCount       : `long$();
    selfFillVolume      : `long$();
    monthVolume         : `long$();
    totalRequestCount   : `long$();
    
    // Foreign table keys
    instrument          : `long$();
    long                : `long$();
    short               : `long$();
    both                : `long$()
    );  


.engine.model.account.NewAccounts             :{[a]
    long:.engine.model.account.NewInventory[a`accountId;1];  
    short:.engine.model.account.NewInventory[a`accountId;-1];  
    both:.engine.model.account.NewInventory[a`accountId;0];  
    a[`long]:key[long];
    a[`short]:key[short];
    a[`both]:key[both];

    .engine.model.account.Account,:a;
    a
    };  

// TODO unify
.engine.model.account.UpdateAccount          :{[a]
    .engine.model.account.Account,:a;a
    };  

.engine.model.account.UpdateAccounts          :{[a]
    .engine.model.account.Account,:a;a
    };  

.engine.model.account.ValidAccountIds        :{[aIds] 
    aIds in key[.engine.model.account.Account][aIds]
    }; // TODO

.engine.model.account.GetAccountsById         :{[aId]
    .engine.model.account.Account'[aId] // TODO benchmark
    };  

.engine.model.account.GetInMarketAccounts     :{[iId]
    ?[`.engine.model.account.Account;((=;`instrumentId;iId);(=;`inMarket;1b));0b;()]
    };  

.engine.model.account.GetAllInsolvent         :{[iId]
    // TODO
    ?[`.engine.model.account.Account;enlist();0b;()]
    };  

.engine.model.account.GetAllUnsettled         :{[iId]
    ?[`.engine.model.account.Account;enlist();0b;()]
    };

.engine.model.accounts.ValidAccountIds        :{[aId]
    aId in key[.engine.model.account.Account][`accountId]
    };

.engine.model.account.IncSelfFill             :{
    ![`.account.Account;
            enlist (=;`accountId;x);
            0b;`selfFillCount`selfFillVolume!(
                (+;`selfFillCount;y);
                (+;`selfFillVolume;z)
            )];
    };

.engine.model.account.SetAccountStateLiquidating    :{[aId]
    ![`.engine.model.account.Account;enlist(=;`accountId;aId);0b;enlist(`state)!enlist(1)]
    };


.engine.model.account.SetAccountStateActive         :{[aId]
    ![`.engine.model.account.Account;enlist(=;`accountId;aId);0b;enlist(`state)!enlist(0)]
    };

