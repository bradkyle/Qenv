
\d .inventory
\l util.q
\l logger.q

inventoryCount:0;

/*******************************************************
/ position related enumerations  
POSITIONSIDE   : `LONG`SHORT`BOTH;

Inventory: (
    [inventoryId        :  `long$()]
    accountId           :  `long$();
    side                :  `.inventory.POSITIONSIDE$();
    currentQty          :  `long$();
    avgPrice            :  `float$();
    realizedPnl         :  `float$();
    unrealizedPnl       :  `float$();
    posMargin           :  `float$();
    entryValue          :  `float$();
    totalCost           :  `long$();
    totalEntry          :  `long$();
    execCost            :  `long$();
    totalCloseVolume    :  `long$();
    totalCrossVolume    :  `long$();
    totalOpenVolume     :  `long$(); 
    totalCloseAmt       :  `float$();
    totalCrossAmt       :  `float$();
    totalOpenAmt        :  `float$(); 
    liquidationPrice    :  `float$();
    bankruptPrice       :  `float$();
    breakEvenPrice      :  `float$();
    lastPrice           :  `float$();
    lastValue           :  `float$();
    markPrice           :  `float$();
    markValue           :  `float$();
    initMarginReq       :  `float$();
    maintMarginReq      :  `float$();
    leverage            :  `float$();
    effectiveLeverage   :  `float$();
    faceValue           :  `long$();
    fillCount           :  `long$()
    );

mandCols:`accountId`side; // TODO update defaults function to derive from default instrument
defaults:{((inventoryCount+:1),0,`BOTH,0,0f,0f,0f,0f,0f,0:0;,0,0,0,0,0,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,100f,1,0)};
allCols: cols Inventory;

// Event creation utilities
// -------------------------------------------------------------->

MakeInventoryUpdateEvent   :  {[inventory;time];
    // TODO check if value is null
    :MakeEvent[time;`UPDATE;`INVENTORY_UPDATE;inventory];
    };

// TODO make work
MakeAccountInventoryUpdateEvent : {[time]
    :MakeEvent[time;`UPDATE;`INVENTORY_UPDATE;()]; // TODO get all for account
    };

MakeAllInventoryUpdateEvent :{[time]
    :MakeEvent[time;`UPDATE;`INVENTORY_UPDATE;()]; // TODO get all inventory
    };

// Inventory CRUD Logic
// -------------------------------------------------------------->

/ default:  
NewInventory : {[inventory;time] 
    if[any null inventory[mandCols]; :0b];
    inventory:Sanitize[inventory;defaults[];allCols];
    .logger.Debug["inventory validated and decorated"];

    `.inventory.Inventory upsert inventory; // TODO check if successful

    :MakeInventoryUpdateEvent[inventory;time]; 
    };

// 
ResetInventory :{[account;time]

    };