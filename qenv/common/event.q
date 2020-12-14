

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
.event.Event				:{(time:x[])};
.event.Failure 			:{()}
.event.Account 			:{([]kind:`account;time:x`time;datum:(x`aId`time`bal`avail`froz);aId:7h$x`aId)}
.event.Inventory		:{([]kind:`inventory;time:x`time;datum:x`aId`side`time`amt`rpnl`avgPrice`upnl;aId:7h$x`aId)}
.event.Order     		:{([]kind:`order;time:x`time;datum:x`oId`time`aId`amt`rpnl`avgPrice`upnl;aId:7h$x`aId)}
.event.Deposit 			:{([]kind:`deposit;time:x`time;datum:x`aId`time`dep;aId:7h$x`aId)}
.event.Withdraw 		:{([]kind:`withdraw;time:x`time;datum:x`aId`iId`time`wit;aId:7h$x`aId)}
.event.Funding 			:{}
.event.Mark					:{}
.event.Settlement		:{}
.event.PriceLimit 	:{}
.event.Level        :{}
.event.Trade				:{}
.event.Order				:{}
.event.Instrument   :{}
.event.Fill					:{.event.Event[`fill;(x`time;(flip .event.RmFk[flip x]`oId`time`aId`qty`price);7h$x`aId)]}
.event.Liquidation	:{}

/*******************************************************
