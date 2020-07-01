
1) raw json results are processed into a form that can be processed and thereafter written to disk in compressed parquet files
2) cleaned events are read and inserted into a KDB (or other) event store
3) The events are batched by either time i.e. 1 second 5 second etc. or event based
4) The batches are held in memory subject to configuration
5) The first batch with given constraints is inserted into hist store and features are subsequently derived from this
6) The features are fed to the agent
7) The agent makes an action and the action is subsequently converted into events by the given event adaptor
8) The action events are inserted into the next event batch with a given determinism (i.e. delay etc.)
9) The events batch is sent to the engine, the engine loops through all the events updating state and raising errors when they occur. 
10) The engine returns the events that have occured as well as metrics to be logged
11) The events are inserted back into the event hist along with non simulatable events.
12) The next feature vector is derived from the events hist and fed to the agent, the agent makes an action.

In this paper we consider a state-based market making agent that
acts on events as they occur in the LOB, subject to constraints such
as upper and lower limits on inventory. An event may occur due to
anything from a change in price, volume or arrangement of orders
in the book; anything that constitutes an observable change in the
state of the environment. Importantly, this means that the agent’s
actions are not spaced regularly in time. Since we are building a
market maker, the agent is required to quote prices at which it is
willing to buy and sell at all valid time points, unless the inventory constraints are no longer satisfied at which point trading is
restricted to orders that bring the agent closer to a neutral position.

x = """(
    select from orderbook where grp=17;
    select from trades where grp=17;
    select from mark where grp=17;
)"""