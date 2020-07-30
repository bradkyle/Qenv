\l account.q
\d .inventory
\l util.q

inventoryCount:0;

/*******************************************************
/ position related enumerations  
POSITIONSIDE   : `LONG`SHORT`BOTH;

Inventory: (
    [inventoryId             :  `long$()]
    accountId                :  `.account.Account$();
    side                     :  `.inventory.POSITIONSIDE$();
    currentQty               :  `long$();
    avgPrice                 :  `float$();
    realizedPnl              :  `float$();
    unrealizedPnl            :  `float$();
    posMargin                :  `float$();
    initMargin               :  `float$();
    entryValue               :  `float$();
    totalCost                :  `long$();
    totalEntry               :  `long$();
    execCost                 :  `long$();
    totalCloseVolume         :  `long$();
    totalCrossVolume         :  `long$();
    totalOpenVolume          :  `long$(); 
    totalCloseMarketValue    :  `float$();
    totalCrossMarketValue    :  `float$();
    totalOpenMarketValue     :  `float$(); 
    totalCloseAmt            :  `float$();
    totalCrossAmt            :  `float$();
    totalOpenAmt             :  `float$(); 
    liquidationPrice         :  `float$();
    bankruptPrice            :  `float$();
    breakEvenPrice           :  `float$();
    lastPrice                :  `float$();
    lastValue                :  `float$();
    markPrice                :  `float$();
    markValue                :  `float$();
    initMarginReq            :  `float$();
    maintMarginReq           :  `float$();
    leverage                 :  `float$();
    effectiveLeverage        :  `float$();
    totalCommission          :  `float$();
    faceValue                :  `long$();
    fillCount                :  `long$()
    );

mandCols:`accountId`side; // TODO update defaults function to derive from default instrument
defaults:{((inventoryCount+:1),0,`BOTH,0,0f,0f,0f,0f,0f,0f,0,0,0,0,0,0,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,100f,100f,0f,1,0)};
allCols: cols Inventory;

// Event creation utilities
// -------------------------------------------------------------->

AddInventoryUpdateEvent   :  {[inventory;time];
    // TODO check if value is null
    :.global.AddEvent[time;`UPDATE;`INVENTORY_UPDATE;inventory];
    };

// TODO make work
AddAccountInventoryUpdateEvent : {[time]
    :.global.AddEvent[time;`UPDATE;`INVENTORY_UPDATE;()]; // TODO get all for account
    };

AddAllInventoryUpdateEvent :{[time]
    :.global.AddEvent[time;`UPDATE;`INVENTORY_UPDATE;()]; // TODO get all inventory
    };

// Inventory CRUD Logic
// -------------------------------------------------------------->

/ default:  
NewInventory : {[inventory;time] 
    if[any null inventory[mandCols]; :0b];
    inventory:Sanitize[inventory;defaults[];allCols];
    .logger.Debug["inventory validated and decorated"];

    `.inventory.Inventory upsert inventory; // TODO check if successful

    :AddInventoryUpdateEvent[inventory;time]; 
    };

// 
ResetInventory :{[account;time]

    };