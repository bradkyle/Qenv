\d .order
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
                `TRIGGERED;
                `CANCELED);     / user or system cancel


TIMEINFORCE :   (`GOODTILCANCEL;     / good til user manual cancellation (max 90days)
                `IMMEDIATEORCANCEL; / fill immediately or cancel, allow partially fill
                `FILLORKILL;        / fill immediately or cancel, full fill only 
                `NIL);

STOPTRIGGER :   `LIMIT`MARK`INDEX; 
EXECINST    :   `PARTICIPATEDONTINITIATE`ALLORNONE`REDUCEONLY;   

orderMandatoryFields    :`accountId`side`otype`osize;
Order: (
    [orderId        : `long$()]
    accountId       : `long$();
    side            : `.order.ORDERSIDE$();
    otype           : `.order.ORDERTYPE$();
    timeinforce     : `.order.TIMEINFORCE$();
    size            : `long$(); / multiply by 100
    leaves          : `long$();
    filled          : `long$();
    limitprice      : `long$(); / multiply by 100
    stopprice       : `long$(); / multiply by 100
    effdate         : `long$(); / as YYYYMMDD
    status          : `.order.ORDERSTATUS$();
    time            : `datetime$();
    isClose         : `boolean$();
    trigger         : `.order.STOPTRIGGER$();
    execInst        : `.order.EXECINST$()
    );

// Event creation utilities
// -------------------------------------------------------------->

ValidateOrder   : {[order]
    :0b;
    }

/ MakeNewOrderEvent   :{[]

/     }

/ MakeOrderUpdateEvent :{[]

/     }

/ MakeBatchOrderEvent   :{[]

/     }

/ MakeCancelAllOrdersEvent :{[]

/     }

// Account CRUD Logic
// -------------------------------------------------------------->

// Generates a new account with default 
// values and inserts it into the account 
// table. // TODO gen events. // TODO change to event?
NewOrder :{[accountId;time]
    events:();
    `.order.Order insert (accountId;);
    events,:MakeNewOrderEvent[];
    :events;
    };


// Account CRUD Logic
// -------------------------------------------------------------->
