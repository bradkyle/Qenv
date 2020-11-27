
// TODO better / faster matrix operations
// TODO randomize placement of hidden orders.
// TODO change price type to int, longs etc.
// TODO allow for data derived i.e. exchange market orders. 
// TODO move offset into seperate table?
// oqty: initial size
// lqty: leaves qty
// dqty: display qty 
.engine.model.order.Order:([oId:`long$()] 
				acc:`.engine.model.account.Account$();invn:`.engine.model.inventory.Inventory$();price:`long$();lprice:`long$();
				sprice:`long$();trig:`long$();tif:`long$();okind:`long$();oskind:`long$();
				state:`long$();oqty:`long$();dqty:`long$();lqty:`long$();offset:`long$();
				einst:`long$());

.engine.model.order.GetOrder:.engine.model.common.Get[`.engine.model.order.Order];
.engine.model.order.UpdateOrder:.engine.model.common.Update[`.engine.model.order.Order];
