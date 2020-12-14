

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
.event.Event				:{e:flip `time`datum`aId!y;e[`kind]:x;e};
.event.Failure 			:{()}
.event.Account 			:{.event.Event[`account;(x`time;(x`aId`time`bal`avail`froz);7h$x`aId)]}
.event.Inventory		:{.event.Event[`inventory;(x`time;(x`aId`side`time`amt`rpnl`avgPrice`upnl);7h$x`aId)]}
.event.Order     		:{.event.Event[`order;(x`time;(flip .event.RmFk[flip x]`oId`time`aId`amt`rpnl`avgPrice`upnl);7h$x`aId)]}
.event.Deposit 			:{.event.Event[`deposit;(x`time;(x`aId`time`dep);7h$x`aId)]}
.event.Withdraw 		:{.event.Event[`withdraw;(x`time;(x`aId`time`wit);7h$x`aId)]}
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
