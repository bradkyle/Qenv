
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
.qt.SkpBesTest[36];
.qt.Unit[
    ".engine.logic.trade.Trade";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.orderbook.GetLevel;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.order.GetOrder;{[a;b] a}[m[0][3]];c];
        mck3: .qt.M[`.engine.Emit;{[a;b]};c];
        mck4: .qt.M[`.engine.model.order.UpdateOrder;{[a;b] a}[m[3][3]];c];
        mck5: .qt.M[`.engine.logic.account.Fill;{[a;b] a}[m[4][3]];c];
        mck6: .qt.M[`.engine.model.order.UpdateOrder;{[a;b] a}[m[4][3]];c];

        res:.engine.logic.trade.Trade[a 0;a 1];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        (("1a) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade doesn't fill agent", // 12
          "order, trade execution <= agent order offset, fill is agent (partial hidden qty fill)");( // Mocks
            (
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `side`size`price`reduce`displayqty!(0;1;0;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        (("1b) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade doesn't fill agent", // 13
          "order, trade execution <= agent order offset, fill is agent");(
            (
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        (("1c) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade partially fills agent", // 14
          "order, trade execution >= agent order offset, fill is agent (partially fills iceberg order < displayqty)");(
            (
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        (("1d) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade partially fills agent", // 14
          "order, trade execution >= agent order offset, fill is agent (partially fills iceberg order > display qty)");(
            (
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        (("1e) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade fills agent", // 16
          "orders, trade execution > agent order offset, fill is agent (3 orders on second level)");(
            (
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ));
        (("1f) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade fills agent", // 17
          "orders, trade execution > agent order offset, fill is agent (3 orders on first level)");(    
            (
                `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
                `balance`mmr`imr!(0.1;0.03;32); // account
                `fqty`fprice`dlt!(0;1;0) // fill
            );
            (); // res 
            (
                (1b;3;();`balance`mmr`imr!(0.1;0.03;32)); // account
                (1b;3;();());
                (1b;3;();`amt`abc!());
                (1b;3;();`imr`mmr!(0.1;0.1));
                (1b;3;();`mkrfee`tkrfee!(0.1;0.1))
            ); // mocks 
            (

            ) // err 
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

