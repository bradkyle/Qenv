

// Inventory of an account
// ----------------------------------------------------------------------------->

.engine.model.inventory.Inventory               :(
        [
            accountId    :  `long$();
            side         :  `long$()
        ]
        amt                      :  `long$();
        leverage                 :  `long$();
        margin                   :  `long$()
    );

.engine.model.inventory.NewAccountInventory     :{[aId;side]
    .engine.model.inventory.Inventory,:flip`accountId`side!(aId;side);
    .engine.model.inventory.Inventory[aId;side];
    };  

.engine.model.inventory.GetInventoryByKey       :{[]
      
    };

.engine.model.inventory.UpdateInventory         :{[i]
    .engine.model.inventory.Inventory,:i;
    };  

.engine.model.inventory.GetInventoryOfAccounts  :{[aId]
    ?[`.engine.model.inventory.Inventory;enlist(=;`accountId;aid);0b;()]
    };

.engine.model.inventory.GetInMarketInventory:{[iId]
    ?[`.engine.model.inventory.Inventory;((=;`instrument;iid);(>;`amt;0));0b;()]
    }

