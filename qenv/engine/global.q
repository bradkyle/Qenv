/
Global is used to store enumeration types and state that can be
unilaterraly accessed throughout the program. For instance the 
current step, step time and default instrument (and associated config)
that serves as a single source of configuration.
\

/ StateFul Singletons
/ -------------------------------------------------------------------->

CurrentStep: `long$();
StepTime: `datetime$();

/ ActiveInstrument: .instrument.NewInstrument{[]

/     };

/*******************************************************
/ event kind enumerations
EVENTKIND    :  (`DEPTH;      / place a new order
                `TRADE;    / modify an existing order
                `DEPOSIT;    / increment a given accounts balance
                `WITHDRAWAL; / decrement a given accounts balance
                `FUNDING; / apply  a funding event
                `MARK;
                `PLACE_ORDER;
                `PLACE_BATCH_ORDER;
                `CANCEL_ORDER;
                `CANCEL_BATCH_ORDER;
                `CANCEL_ALL_ORDERS;
                `AMEND_ORDER;
                `AMEND_BATCH_ORDER;
                `LEVERAGE_UPDATE;
                `LIQUIDATION;
                `ORDER_UPDATE;
                `POSITION_UPDATE;
                `ACCOUNT_UPDATE;
                `INSTRUMENT_UPDATE;
                `FEATURE;
                `NEW_ORDER;
                `ORDER_DELETED;
                `AGENT_FORCED_CLOSE_ORDERS;
                `AGENT_LIQUIDATED;
                `FAILED_REQUEST);

// TODO functions for making evens

EVENTCMD      :   `NEW`UPDATE`DELETE`FAILED;

