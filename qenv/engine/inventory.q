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
    realizedPnl         :  `float$();
    unrealizedPnl       :  `float$();
    posMargin           :  `float$();
    totalCost           :  `long$();
    totalEntry          :  `long$();
    execCost            :  `long$();
    grossProfit         :  `float$();
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
    fillCount           :  `long$()
    );

mandCols:`accountId`side;
fltCols:(`avgPrice`realizedPnl`unrealizedPnl`posMargin,
        `grossProfit`totalCloseAmt`totalCrossAmt`totalOpenAmt,
        `liquidationPrice`bankruptPrice`breakEvenPrice`lastPrice,
        `lastValue`markPrice`markValue`initMarginReq`maintMarginReq);
lngCols:`totalCost`totalEntry`execCost`fillCount;

// Event creation utilities
// -------------------------------------------------------------->

MakeInventoryUpdateEvent   :  {[time;inventory];
    // TODO check if value is null
    :MakeEvent[time;`UPDATE;`INVENTORY_UPDATE;inventory];
    };

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

    if[all null inventory[mandCols]; :0b];

    // TODO drop unnceccessary cols
    inventory:Default[inventory;`inventoryId; inventoryCount+:1]; // TODO id generator
    inventory:Default[inventory;fltCols;0f];    
    inventory:Default[inventory;lngCols;0];      
    inventory:Default[inventory;`lastPrice;0f]; // TODO derive from instrument
    inventory:Default[inventory;`markPrice;0f]; // TODO derive from instrument
    .logger.Debug["inventory validated and decorated"];
 
    `.inventory.Inventory upsert inventory; // TODO check if successful

    :MakeInventoryUpdateEvent[time;inventory];
    };

// 
ResetInventory :{[account;time]

    };