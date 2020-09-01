
// 

// TODO sort by time?
InsertResultantEvents :{
    {
        k:x`kind;
        r:x`datum;
        $[
            k=0;[.state.DepthEventHistory,:r]; // DEPTH
            k=1;[.state.TradeEventHistory,:r]; // TRADE
            k=2;[.state.MarkEventHistory,:r]; // MARK
            k=3;[.state.LiquidationEventHistory,:r]; // LIQUIDATION
            k=4;[.state.FundingEventHistory,:r]; // FUNDING
            k=5;[.state.SettlementHistory,:r]; // SETTLEMENT
            k=6;[.state.AccountEventHistory,:r]; // ACCOUNT
            k=7;[.state.InventoryEventHistory,:r]; // INVENTORY
            k=8;[.state.OrderEventHistory,:r]; // ORDER
            k=9;[.state.PriceLimitHistory,:r]; // PRICELIMIT
            k=16;[.state.SignalEventHistory,:r]; // SIGNAL
            'INVALID_EVENT_KIND
        ];
    }'[0!(`kind xgroup x)];
}

