\l util.q

\d .inventory

inventoryCount:0;

/*******************************************************
/ position related enumerations  
POSITIONSIDE   : `LONG`SHORT`BOTH;

Inventory: (
    [inventoryId        :  `long$()]
    accountId           :  `long$();
    faceValue           :  `int$();
    side                :  `.inventory.POSITIONSIDE$();
    currentQty          :  `long$();
    avgPrice            :  `float$();
    realizedPnl         :  `long$();
    unrealizedPnl       :  `long$();
    totalCost           :  `long$();
    totalEntry          :  `long$();
    execCost            :  `long$();
    grossProfit         :  `long$();
    totalCloseAmt       :  `long$();
    totalCrossAmt       :  `long$();
    totalOpenAmt        :  `long$(); 
    liquidationPrice    :  `float$();
    bankruptPrice       :  `float$();
    breakEvenPrice      :  `float$();
    lastPrice           :  `float$();
    lastValue           :  `float$();
    markPrice           :  `float$();
    markValue           :  `float$();
    initMarginReq       :  `float$();
    maintMarginReq      :  `float$();
    activeTakerFee      :  `float$();
    activeMakerFee      :  `float$()
    );

// Event creation utilities
// -------------------------------------------------------------->

MakeInventoryUpdateEvent   :  {[time];
    :1b;
    };

MakeAccountInventoryUpdateEvent : {[time]
    :1b;
    };

// Inventory CRUD Logic
// -------------------------------------------------------------->

/ default: 
// TODO generate unique inventory id
NewInventory : {[accountId;side;time]
    // TODO markPrice, lastPrice, activeTakerFee, activeMakerFee
    // initMarginReq, maintMarginReq
    `.inventory.Inventory insert (inventoryCount+:1;accountId;0;side;
        0;0f;0;0;0;0;0;0;0;0;0;0f;0f;0f;0f;0f;0f;0f;0f;0f;0f;0f);
    :MakeInventoryUpdateEvent[time];
    };
