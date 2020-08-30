\d .instrument.inverse.account

ExecCost        :{[]


    };

AvgPrice        :{[]


    };

UnrealizedPnl  :{[]


    };

RealizedPnl    :{[]


    };


MaintMargin    :{[]

    };


InitMargin     :{[]

    };

// AdjustOrderMargin interprets whether a given margin 
// delta principly derived from either the placement/cancellation
// of a limit order or the application of a order fill will exceed the
// accounts available balance in which case an exception will be 
// thrown, or otherwise will return the resultant account state that the
// given delta will cause on execution.
AdjustMargin    :{[price;dlt;isignum]


    };


// ApplyFill applies a given execution to an account and its respective
// inventory
ApplyFill       :{[]


    };