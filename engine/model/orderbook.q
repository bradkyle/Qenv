
// Orderbook of an Instrument
// ---------------------------------------------------------------------------->

// Instantiate a singleton class of Orderbook
// qtys: represent the different level quantities at their given prices
// the events will be generated using the sum of the quantities and the 
// orderbook sizes at each price.
// TODO add hidden/Iceberg qty
.engine.model.orderbook.OrderBook           :(
    [price      :`long$()]  // price
    side        :`long$();  // side
    qty         :`long$(); // data qty
    hqty        :`long$(); // hidden qty  (only for data depth updates)
    iqty        :`long$(); // iceberg qty (only for agent orders)
    vqty        :`long$()); // Visible qty (including order qty)=(qty+displayqty)

.engine.model.orderbook.NewLevels           :{
    .engine.model.orderbook.OrderBook,:o;
    };

.engine.model.orderbook.UpdateLevels        :{
    .engine.model.orderbook.OrderBook,:o;
    };

.engine.model.orderbook.GetLevelsByPrice    :{[price]
    ?[`.engine.model.orderbook.OrderBook;enlist(=;`price;price);0b;()]    
    };

.engine.model.orderbook.GetLevelsBySide     :{[side]
    ?[`.engine.model.orderbook.OrderBook;enlist(=;`side;side);0b;()]    
    };

.engine.model.orderbook.GetFullOrderBook    :{
    ?[`.engine.model.orderbook.OrderBook;();0b;()]
    };

.engine.model.orderbook.PruneOrderBook     :{
    ![`.engine.model.orderbook.OrderBook;enlist(<=;(+;`vqty;(+;`iqty;`hqty));0);0b;`symbol$()]    
    };
