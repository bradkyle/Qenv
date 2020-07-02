/
Global is used to store enumeration types and state that can be
unilaterraly accessed throughout the program. For instance the 
current step, step time and default instrument (and associated config)
that serves as a single source of configuration.
\

/ Enumerations
/ -------------------------------------------------------------------->
// TODO tick size, face value etc.

/*******************************************************
/ instrument enumerations
MAINTTYPE           :   `TIERED`FLAT;
FEETYPE             :   `TIERED`FLAT;
INSTRUMENTSTATE     :   `ONLINE;
INITMARGINTYPE      :   `TIERED`FLAT;
INSTRUMENTTYPE      :   `PERPETUAL`ADAPTIVE;
LIQUIDATIONSTRAT    :   `COMPLETE`PARTIAL; 
SETTLETYPE          :   `QUANTO`INVERSE;

/*******************************************************
/ adapter enumerations
ADAPTERTYPE :   (`MARKETMAKER;        
                `DUALBOX;          
                `SIMPLEBOX;    
                `DISCRETE);   

/*******************************************************
/ account related enumerations  
MARGINTYPE   :   `CROSS;`ISOLATED;
POSITIONTYPE :   `HEDGED`COMBINED;

/*******************************************************
/ liquidation engine enumerations  
LIQUIDATESTRAT   :  `IMMEDIATE`GRADUAL;
LIQUIDATEFEETYPE :  `TOTAL`COMMISSION;

/*******************************************************
/ Return code
RETURNCODE  :   (`INVALID_MEMBER;
                `INVALID_ORDER_STATUS;
                `INVALID_ORDER;
                `OK);

/ StateFul Singletons
/ -------------------------------------------------------------------->

CurrentStep: `long$();
StepTime: `datetime$();