
// Instantiate a singleton class of Orderbook
// qtys: represent the different level quantities at their given prices
// the events will be generated using the sum of the quantities and the 
// orderbook sizes at each price.

/ data qty
/ hidden qty  (only for data depth updates)
/ iceberg qty (only for agent orders)
// Visible qty (including order qty)=(qty+displayqty)

.engine.model.orderbook.Orderbook:([price:`long$()]side:`long$();qty:`long$();hqty:`long$();iqty:`long$();vqty:`long$())

.engine.model.orderbook.GetLevel:.engine.model.common.Get[`.engine.model.orderbook.Orderbook];
.engine.model.orderbook.UpdateLevel:.engine.model.common.Update[`.engine.model.orderbook.Orderbook];
.engine.model.orderbook.Delete:.engine.model.common.Delete[`.engine.model.orderbook.Orderbook];


