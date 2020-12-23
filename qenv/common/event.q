

// Stores Common logic for all events

// TODO setup in seperate process?


/*******************************************************
/ Event LOGIC

// TODO move to global
// The Event table acts as a buffer for all Event that occur within
// the given environment step, this allows for unilateral event post/pre
// processing after the environment state has progressed i.e. .common.event.Adding lag
// .common.event.Adding "dropout" and randomization etc. it has the .common.event.Added benifit of 
// simplifying (removing) nesting/recursion within the engine. 
// Drawbacks may include testability?
// The Event table is used exclusively within the engine and is not used
// by for example the state.
// Acts like a kafka queue/pubsub.
.common.event.Event  :([] // TODO .common.event.Add failure to table
    time        :`datetime$();
    kind        :`symbol$();
		datum       :();
    aId         :`long$());
// TODO set table attributes


.common.event.COLS                   :`eid`time`cmd`kind`datum;
.common.event.DCOLS                  :.common.event.COLS!.common.event.COLS;

/*******************************************************
/Construction

// TODO allow for many events
.event.prep:{$[(type[x]=99h) and (count[first[x]]=1);enlist x;type[x]=99h;flip x;x]};

// TODO implement kind
.event.Failure      :{x:.event.prep[x];([]time:x`time;datum:x)}
.event.Mark					:{x:.event.prep[x];([]time:x`time;datum:flip x`iId`time`mkprice)}
.event.Settlement		:{x:.event.prep[x];([]time:x`time;datum:flip x`iId`time)}
.event.PriceLimit 	:{x:.event.prep[x];([]time:x`time;datum:flip x`iId`time`highest`lowest)}
.event.Level        :{x:.event.prep[x];([]time:x`time;datum:flip x`iId`time`side`price`qty)}
.event.Trade				:{x:.event.prep[x];([]time:x`time;datum:flip x`iId`time`side`price`qty)}
.event.Instrument   :{}
.event.Liquidation	:{}
.event.Account 			:{x:.event.prep[x];x[`aId]:7h$x[`aId];([]time:x`time;datum:flip(x`aId`time`bal`avail);aId:x`aId)}
.event.Inventory		:{x:.event.prep[x];x[`aId]:7h$x[`aId];([]time:x`time;datum:flip x`aId`side`time`amt`rpnl`avgPrice`upnl;aId:x`aId)}
.event.Order     		:{x:.event.prep[x];([]kind:`order;time:x`time;datum:flip x`oId`time`aId`side`okind`price`lqty`lprice`sprice`state`reduce`trig`einst;aId:x`aId)}
.event.Deposit 			:{x:.event.prep[x];x[`aId]:7h$x[`aId];([]kind:`deposit;time:x`time;datum:flip x`aId`time`dep;aId:x`aId)}
.event.Withdraw 		:{x:.event.prep[x];x[`aId`iId]:7h$x[`aId`iId];([]kind:`withdraw;time:x`time;datum:flip x`aId`iId`time`wit;aId:x`aId)}
.event.Funding      :{x:.event.prep[x];([]time:x`time;datum:flip x`iId`time`fundingrate)}
.event.Fill					:{x:.event.prep[x];x[`aId`ivId`iId`oId]:7h$x[`aId`ivId`iId`oId];([]time:x`time;datum:flip x`oId`time`aId`qty`price;aId:x`aId)}

/*******************************************************
