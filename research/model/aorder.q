
// Algo aorders of Account/aorderbook/Instrument/Inventory
// ---------------------------------------------------------------------------->

.engine.model.aorder.Algoaorder:.engine.model.order.Order;

.engine.model.aorder.NewAlgoaorders           :{[o]
    .engine.model.aorder.Algoaorder,:o;
    };

.engine.model.aorder.UpdateAlgoaorders        :{[o]
    .engine.model.aorder.Algoaorder,:o;
    };

.engine.model.aorder.GetAlgoaordersByPrice    :{[iId;price]
    'nyi
    };

.engine.model.aorder.GetAlgoaordersBySide     :{[iId;side]
    'nyi
    };
