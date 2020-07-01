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

EVENTCMD      :   `NEW`UPDATE`DELETE`FAILED;

/*******************************************************
/ order related enumerations  
ORDERSIDE      :   `BUY`SELL;

ORDERTYPE   :   (`MARKET;       / executed regardless of price
                `LIMIT;         / executed only at required price
                `STOP_MARKET;   / executed as market order once stop price reached
                `STOP_LIMIT;
                `REMAINDERLIMIT;
                `PEGGED);   / executed as limit order once stop price reached
//TODO trailing stop order

ORDERSTATUS :   (`NEW;          / begining of life cycle
                `PARTIALFILLED; / partially filled
                `FILLED;        / fully filled
                `FAILED;        / failed due to expiration etc
                `UNTRIGGERED;
                `TRIGGERED`;
                `CANCELED);     / user or system cancel


TIMEINFORCE :   (`GOODTILCANCEL;     / good til user manual cancellation (max 90days)
                `IMMEDIATEORCANCEL; / fill immediately or cancel, allow partially fill
                `FILLORKILL;        / fill immediately or cancel, full fill only 
                `NIL);

STOPTRIGGER :   `LIMIT`MARK`INDEX; 
EXECINST    :   `PARTICIPATEDONTINITIATE`ALLORNONE`REDUCEONLY   


/*******************************************************
/ position related enumerations  
POSITIONSIDE   :   `LONG`SHORT`BOTH;

/*******************************************************
/ account related enumerations  
MARGINTYPE   :   `CROSS`ISOLATED;
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

/ Utility functions
/ -------------------------------------------------------------------->

// Todo move to schema/event
MakeEvent   : {[time;cmd;kind;datum]
        if[not (type time)=-15h; :`]; //TODO fix
        if[not (cmd in EVENTCMD); ];
        if[not (kind in EVENTKIND); ];
        if[not] //validate datum 
        :`time`cmd`kind`datum!(time;cmd;kind;datum);
};

MakeDepthEvent  :{[time;asks;bids]

        :MakeEvent[time]
};

MakeTradeEvent  :{[]

        :MakeEvent[];
};

MakeOrderEvent  :{[]

        :MakeEvent[];
};

MakeCancelAllOrdersEvent  :{[]

        :MakeEvent[];
};

MakeAccountUpdateEvent  :{[]

        :MakeEvent[];
};


MakeAccountUpdateAllEvent  :{[]

        :MakeEvent[];
};

MakeInventoryEvent  :{[]

        :MakeEvent[];
};

MakeFailureEvent    :{[]

}

MakeDepositEvents   :{[]

};

/ StateFul Singletons
/ -------------------------------------------------------------------->

CurrentStep: `long$();
StepTime: `datetime$();