
// TODO better / faster matrix operations
// TODO randomize placement of hidden orders.
// TODO change price type to int, longs etc.
// TODO allow for data derived i.e. exchange market orders. 
// TODO move offset into seperate table?
// oqty: initial size
// lqty: leaves qty
// dqty: display qty 
.engine.model.order.Order:([oId:`long$()] 
				side:`long$();acc:`.engine.model.account.Account$();price:`long$();lprice:`long$();
				sprice:`long$();trig:`long$();tif:`long$();okind:`long$();oskind:`long$();reduce:`boolean$();
				state:`long$();oqty:`long$();dqty:`long$();lqty:`long$();offset:`long$();
				einst:`long$();time:`datetime$());
.engine.model.order.r:.util.NullRowDict[`.engine.model.order.Order];

.engine.model.order.Get:.engine.model.common.Get[`.engine.model.order.Order];
.engine.model.order.Update:.engine.model.common.Update[`.engine.model.order.Order];
.engine.model.order.Create:.engine.model.common.Create[`.engine.model.order.Order];
.engine.model.order.Delete:.engine.model.common.Delete[`.engine.model.order.Order];

ordCols:`clOid`aId`price`lprice`sprice`trig`tif`okind`oskind`state`oqty`dqty`lqty`einst`reduce;

.model.Order:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:.model.Model[.engine.model.order.r;cl;vl];
    x[`aId]:`.engine.model.account.Account$x[`aId];
    x[`ivId]:`.engine.model.inventory.Inventory$x[`ivId]; 
    x[`iId]:`.engine.model.instrument.Instrument$x[`iId];
    x
    };
