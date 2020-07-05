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
    posMargin           :  `long$();
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
    fillCount           :  `long$()
    );

mandCols:`accountId`side;
fltCols:0;
lngCols:0;


// Event creation utilities
// -------------------------------------------------------------->

MakeInventoryUpdateEvent   :  {[time;inventory];
    // TODO check if value is null
    :MakeEvent[time;`UPDATE;`INVENTORY_UPDATE;inventory];
};

MakeAccountInventoryUpdateEvent : {[time]
    :MakeEvent[time;`UPDATE;`INVENTORY_UPDATE;]; // TODO get all for account
};

MakeAllInventoryUpdateEvent :{[time]
    :MakeEvent[time;`UPDATE;`INVENTORY_UPDATE;]; // TODO get all inventory
};

// Inventory CRUD Logic
// -------------------------------------------------------------->

/ default: 
// TODO generate unique inventory id
NewInventory : {[inventory;time]
    // TODO markPrice, lastPrice, activeTakerFee, activeMakerFee
    // initMarginReq, maintMarginReq

    if[all null inventory[mandCols]; :0b];

    // TODO drop unnceccessary cols
    inventory:Default[inventory;`inventoryId; ]; // TODO id generator
    inventory:Default[inventory;fltCols;0f];    
    inventory:Default[inventory;lngCols;0f];  
    .logger.Debug["inventory validated and decorated"];
 
    `.inventory.Inventory upsert inventory; // TODO check if successful

    :MakeInventoryUpdateEvent[time;inventory];
    };
