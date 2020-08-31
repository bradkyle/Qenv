
// 

// TODO sort by time?
InsertResultantEvents :{
    {
        k:x`kind;
        r:x`datum;
        $[
            k=0;[.state.DepthEventHistory,:r]; // TODO fix ordering
            k=1;[.state.TradeEventHistory,:r];
            k=2;[.state.MarkEventHistory,:r];
            k=3;[.state.SettlementHistory,:r];
            k=4;[.state.FundingEventHistory,:r];
            k=5;[.state.LiquidationEventHistory,:r];
            k=6;[.state.AccountEventHistory,:r];
            k=7;[.state.InventoryEventHistory,:r];
            k=8;[.state.OrderEventHistory,:r];
            k=9;[.state.PriceLimitHistory,:r];
            k=10;[.state.SignalEventHistory,:r];
            'INVALID_EVENT_KIND
        ];
    }'[0!(`kind xgroup x)];
}

