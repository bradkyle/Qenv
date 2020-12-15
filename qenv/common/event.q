

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

.event.Failure 			:{}
.event.Mark					:{x:.event.prep[x];([]time:x`time;datum:flip x`iId`time`markprice)}
.event.Settlement		:{x:.event.prep[x];([]time:x`time;datum:flip x`iId`time)}
.event.PriceLimit 	:{x:.event.prep[x];([]time:x`time;datum:flip x`iId`time`highest`lowest)}
.event.Level        :{x:.event.prep[x];([]time:x`time;datum:flip x`iId`time`side`price`qty)}
.event.Trade				:{x:.event.prep[x];([]time:x`time;datum:flip x`iId`time`side`price`qty)}
.event.Instrument   :{}
.event.Liquidation	:{}
.event.Account 			:{x:.event.prep[x];([]time:x`time;datum:flip(x`aId`time`bal`avail`froz);aId:7h$x`aId)}
.event.Inventory		:{x:.event.prep[x];([]time:x`time;datum:flip x`aId`side`time`amt`rpnl`avgPrice`upnl;aId:7h$x`aId)}
.event.Order     		:{x:.event.prep[x];([]kind:`order;time:x`time;datum:flip x`oId`time`aId`amt`rpnl`avgPrice`upnl;aId:7h$x`aId)}
.event.Deposit 			:{x:.event.prep[x];([]kind:`deposit;time:x`time;datum:flip x`aId`time`dep;aId:7h$x`aId)}
.event.Withdraw 		:{x:.event.prep[x];([]kind:`withdraw;time:x`time;datum:flip x`aId`iId`time`wit;aId:7h$x`aId)}
.event.Funding      :{x:.event.prep[x];([]time:x`time;datum:flip x`iId`time`fundingrate)}
.event.Fill					:{x:.event.prep[x];([]time:x`time;datum:flip x`oId`time`aId`qty`price)}

/*******************************************************
