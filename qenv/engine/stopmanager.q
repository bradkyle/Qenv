\l global.q
\l orderbook.q

stopTriggers:()

// INTE
updateToTriggered   :{[]
     update status=`TRIGGERED from `.schema.Order where orderId=x;
}

// Agent Stop Order Event Processing Logic
// --------------------------------------------------->

NewStopOrder   :  {[]

};

AmendStopOrder    :{[]

};

CancelStopOrder    :{[]

};

CancelStopOrderBatch   :{[]

};

CancelAllStopOrders    :{[]

};

// Processing Logic
// --------------------------------------------------->

execStops   :{[orderIds;events]
    [
        o:exec .schema.Order where orderId=x;
        $[o[`ordTyp]=`STOP_MARKET;
            [
                events,: updateToTriggered[];
                events,: .orderbook.NewLimitOrder[];
                events,: removeStopOrder[]; // TODO should remove?
            ];
          o[`ordTyp]=`STOP_LIMIT;
            [
                events,: updateToTriggered[];
                events,: .orderbook.NewMarketOrder[];
                events,: removeStopOrder[]; // TODO should remove?
            ]
        ]
    ] each orderIds; //todo peach
    :events; 
};

CheckByLastPrice    :{[lastPrice;time]
    events:();
    trigIds:stopTriggers[`LAST][lastPrice];
    $[(count trigIds)>0;execStops[trigIds;events]];
    :events;
};

CheckByMarkPrice    :{[markPrice;time]
    events:();
    trigIds:stopTriggers[`MARK][markPrice];
    $[(count trigIds)>0;execStops[trigIds;events]];
    :events;
};

// Main Info and Reset Logic
// --------------------------------------------------->

Info        :{[]

}

Reset        :{[]

}