

orderMandatoryFields    :`accountId`side`otype`osize;
Order: (
    [orderId        : `long$()]
    accountId       : `long$();
    side            : `ORDERSIDE$();
    otype           : `ORDERTYPE$();
    timeinforce     : `TIMEINFORCE$();
    osize           : `long$(); / multiply by 100
    leaves          : `long$();
    filled          : `long$();
    limitprice      : `long$(); / multiply by 100
    stopprice       : `long$(); / multiply by 100
    effdate         : `long$(); / as YYYYMMDD
    status          : `ORDERSTATUS$();
    time            : `datetime$();
    trigger         : `STOPTRIGGER$();
    execInst        : `EXECINST$();
);

ValidateOrder   : {[order]

}

MakeNewOrderEvent   :{[]

}

MakeOrderUpdateEvent :{[]

}

MakeBatchOrderEvent   :{[]

}

MakeCancelAllOrdersEvent :{[]

}