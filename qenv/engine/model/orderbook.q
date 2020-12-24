
// Instantiate a singleton class of Orderbook
// qtys: represent the different level quantities at their given prices
// the events will be generated using the sum of the quantities and the 
// orderbook sizes at each price.

/ data qty
/ hidden qty  (only for data depth updates)
/ iceberg qty (only for agent orders)
// Visible qty (including order qty)=(qty+displayqty)
// TODO add num liquidations at level as a feature

.engine.model.orderbook.Orderbook:([price:`long$()]
    iId:`.engine.model.instrument.Instrument$();side:`long$();qty:`long$();
    hqty:`long$();iqty:`long$();vqty:`long$();time:`datetime$());
.engine.model.orderbook.r:.util.NullRowDict[`.engine.model.orderbook.Orderbook];

.engine.model.orderbook.Get:.engine.model.common.Get[`.engine.model.orderbook.Orderbook];
.engine.model.orderbook.Update:.engine.model.common.Update[`.engine.model.orderbook.Orderbook];
.engine.model.orderbook.Delete:.engine.model.common.Delete[`.engine.model.orderbook.Orderbook];

.model.Level:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:flip .model.Model[.engine.model.orderbook.r;cl;vl];  
    x[`iId]:`.engine.model.instrument.Instrument$x[`iId];
    x
    };
