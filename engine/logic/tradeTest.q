

// TODO integration tests

// TODO no liquidity
// TODO add order update events!!!!
// TODO agent trade fills entire price level
// TODO trade size larger than orderbook qty
// TODO instrument id, tick size, lot size etc. 
// TODO inc self fill called
// TODO test that qty is ordered correctly for fills i.e. price is ordered
// TODO less than offset fills price and removes price
// TODO test reduce only, immediate or cancel, participate don't initiate etc.
// TODO test with different accounts
// TODO reduce only
// TODO test other side
// TODO benchmarking
// TOOD test instrument/account doesn't exist
// TODO test erroring
// TODO iceberg/hidden order logic
// TODO hidden orders from agent, hidden orders from data.
// TODO drifts out of book bounds
// TODO no previous depth however previous orders.
// TODO fills 3 levels
// TODO test different instrument
// TODO test with different accounts
.qt.Unit[
    ".engine.logic.trade.ProcessAgentTrades";
    {[c]
        .qt.RunUnit[c;.engine.logic.trade.Trade];
    };
		{};
    (

    );
		({};{};{};{});
    "Process trades from the historical data or agent orders",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders and call Add Events/Fills etc. where necessary"];
