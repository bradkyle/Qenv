
/ https://www.bitmex.com/app/liquidationExamples
/ https://www.bitmex.com/app/liquidation
/ https://www.bitmex.com/app/wsAPI#Deleverage
/ https://www.bitmex.com/app/wsAPI#Liquidation
/ https://huobiglobal.zendesk.com/hc/en-us/articles/360000143042-Partial-Liquidation-of-Futures
/ https://www.okex.com/academy/en/full-liquidation
/ https://www.binance.com/en/support/faq/360033525271
/ https://binance.zendesk.com/hc/en-us/articles/360033525271-Liquidation
/ https://help.ftx.com/hc/en-us/articles/360027668712-Liquidations
/ https://help.bybit.com/hc/en-us/articles/360039261334-How-to-calculate-Liquidation-Price-Inverse-Contract-
/ https://help.bybit.com/hc/en-us/articles/360039261474-Liquidation-process-Inverse-Contract-
/ https://help.bybit.com/hc/en-us/articles/900000389743-Introduction-to-Mutual-Insurance

.engine.logic.liquidation.ForceCancel        :{[a;time]
    .engine.services.order.CancelAllOrders[a]; // TODO make requests
    :(exec from .account.Account where accountId=a[`accountId])
    };

// Trades the given opposing positions with eachother
// to reduce exposure as seen with huobi.
.engine.logic.liquidation.SelfTrade          :{[a;iB;iL;iS]

    };

// Takes over the inventory and returns the resultant
// inventory with the fee being removed.
.engine.logic.liquidation.TakeOverWithFee    :{[a;iB;iL;iS]

    };

// Takes over the inventory completely without returning
// it, essentially the entire inventory has been lost.
.engine.logic.liquidation.TakeOverTotally    :{[a;iB;iL;iS]

    };

.engine.logic.liquidation.IsAccountInsolvent :{[]

    };

// Enacts liquidation of a specified account/inventory pair 
// Considering the current implementation only supports cross margin
// mode, all positions will be liquidated.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.engine.logic.liquidation.Liquidate    :{[a]
    a:.engine.model.account.SetAccountStateLiquidating[a];
    a:.engine.logic.liquidation.ForceCancel[a;time];
    // TODO branch
    if[.engine.logic.liquidation.IsAccountInsolvent[a];[

        ]];
    };