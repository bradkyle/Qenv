
// Orders of Account/Orderbook/Instrument/Inventory
// ---------------------------------------------------------------------------->

.order.orderCount:0;

// TODO better / faster matrix operations
// TODO randomize placement of hidden orders.
// TODO change price type to int, longs etc.
// TODO allow for data derived i.e. exchange market orders. 
// TODO move offset into seperate table?
.engine.model.order.Order           :(
    [orderId        :`long$()]
    clId            : `long$();
    price           : `long$();
    side            : `long$();
    otype           : `long$();
    offset          : `long$();
    timeinforce     : `long$();
    size            : `long$(); / multiply by 100 etc
    leaves          : `long$();
    filled          : `long$();
    limitprice      : `long$(); / multiply by 100 etc
    stopprice       : `long$(); / multiply by 100 etc
    status          : `long$();
    time            : `datetime$();
    reduce          : `boolean$();
    trigger         : `long$();
    displayqty      : `long$(); // for iceberg/hidden orders
    pricevar        : `long$(); // for iceberg/hidden orders
    avgamt          : `long$(); // for iceberg/hidden orders
    execInst        : `long$();
    instrument      : `long$();
    account         : `long$();
    inventory       : `long$()
    );

.engine.model.order.NewOrders           :{[o]
    .engine.model.order.Order,:o;
    };

.engine.model.order.UpdateOrders        :{[o]
    .engine.model.order.Order,:o;
    };

.engine.model.order.ValidOrderIds        :{[oId]
    oId in key[.engine.model.order.Order][`orderId]
    };

.engine.model.order.GetOrdersById       :{[oId]
    .engine.model.order.Order[oId]
    };

.engine.model.order.ValidClientOrderIds        :{[clId]
    clId in key[.engine.model.order.Order][`clId]
    };

.engine.model.order.GetOrdersByClientId       :{[clId]
    .engine.model.order.Order[oId]
    };

.engine.model.order.GetOrdersByPrice    :{[iId;price]
    ?[`.engine.model.order.Order;((in;`instrumentId;iId);(in;`price;price));0b;()]
    };

.engine.model.order.GetOrdersBySide     :{[iId;side]
    ?[`.engine.model.order.Order;((in;`instrumentId;iId);(in;`side;side));0b;()]
    };

.engine.model.order.GetOrdersBySideAndPrice     :{[iId;side;price]
    ?[`.engine.model.order.Order;((=;`instrumentId;iId);(=;`side;side);(=;`price;price));0b;()]
    };

.engine.model.order.GetOrdersByAccountId    :{[aId]
    ?[`.engine.model.order.Order;enlist(in;`accountId;aId);0b;()]
    };

.engine.model.order.GetInstrumentOrdersByAccountId    :{[iId;aId]
    ?[`.engine.model.order.Order;((in;`instrumentId;iId);(in;`accountId;aId));0b;()]
    };

.engine.model.order.RemoveOrdersByAccountId :{[aId]
    ![`.engine.model.order.Order;enlist(in;`accountId;aId);0b;`symbol$()]    
    };

.engine.model.order.RemoveInstrumentOrdersByAccountId :{[iId;aId]
    ![`.engine.model.order.Order;((in;`instrumentId;iId);(in;`accountId;aId));0b;`symbol$()]
    };

.engine.model.order.RemoveOrdersById        :{[oId]
    ![`.engine.model.order.Order;enlist(in;`orderId;oId);0b;`symbol$()]
    };

.engine.model.order.RemoveOrdersByClientId        :{[clId]
    ![`.engine.model.order.Order;enlist(in;`clId;clId);0b;`symbol$()]
    };

.engine.model.order.PruneOrders                    :{
    ![`.engine.model.order.Order;enlist(<=;`leaves;0);0b;`symbol$()]    
    };                     

.engine.model.order.GetActiveLimitOrders            :{
    'nyi
    };

.engine.model.order.GetActiveLimitOrdersBySide      :{
    'nyi
    };

