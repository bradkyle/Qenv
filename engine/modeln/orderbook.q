
// Instantiate a singleton class of Orderbook
// qtys: represent the different level quantities at their given prices
// the events will be generated using the sum of the quantities and the 
// orderbook sizes at each price.

/ data qty
/ hidden qty  (only for data depth updates)
/ iceberg qty (only for agent orders)
// Visible qty (including order qty)=(qty+displayqty)

orderbook:([price:`long$()]side:`long$();qty:`long$();hqty:`long$();iqty:`long$();vqty:`long$())
