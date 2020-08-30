


/ https://www.bitmex.com/app/liquidationExamples
/ https://www.bitmex.com/app/liquidation
/ https://www.bitmex.com/app/wsAPI#Deleverage
/ https://www.bitmex.com/app/wsAPI#Liquidation
/ https://huobiglobal.zendesk.com/hc/en-us/articles/360000143042-Partial-Liquidation-of-Futures
/ https://www.okex.com/academy/en/full-liquidation
/ https://www.binance.com/en/support/faq/360033525271
/ https://binance.zendesk.com/hc/en-us/articles/360033525271-Liquidation
/ https://help.ftx.com/hc/en-us/articles/360027668712-Liquidations

Liquidate :{[]
    .order.CancelAllOrders[];

    // Check if still incorrect
    // takeOver
    i:.account.TakeOverPosition[];

    };