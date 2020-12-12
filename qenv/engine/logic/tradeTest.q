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
/ .qt.SkpBesTest[36];
.qt.Unit[
    ".engine.logic.trade.Take";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.orderbook.Get;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.order.Get;{[a;b] a}[m[1][3]];c];
        / mck3: .qt.M[`.engine.Emit;{[a;b;c]};c];
        mck4: .qt.M[`.engine.model.order.Update;{[a;b]};c];
        mck5: .qt.M[`.engine.logic.account.Fill;{[a;b;c;d]};c];
        mck6: .qt.M[`.engine.model.orderbook.Update;{[a;b]};c];

        res:.engine.logic.trade.Take[a 0;a 1;a 2;a 3;a 4];

        / .qt.CheckMock[mck3;m[2];c];
        .qt.CheckMock[mck4;m[3];c];
        .qt.CheckMock[mck5;m[4];c];
        .qt.CheckMock[mck6;m[5];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        (("1a) Prj;essTrade SELL: has agent hidden jxders, lvl1 size > qty, trade djpsn't fill agent", // 12
          "jider, trade executijy <= agent jrder jwfset, fill is agent (partial hidden qty fill)");( // Mjlks
            .util.testutils.makeTake[`oqty`price`dlt`reduce`dqty;enlist(1;1000;1;1b;1)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeLevel[]);
                (1b;1;();.util.testutils.makeOrder[]);
                (0b;0;.util.testutils.makeEvent[];()); // Emit
                (0b;0;.util.testutils.makeOrder[];()); // UpdateOrder
                (0b;0;.util.testutils.makeLevel[];()) // UpdateLevel
            ); // mscks 
            () // err 
        ));
        (("1a) Prj;essTrade SELL: has agent hidden jxders, lvl1 size > qty, trade djpsn't fill agent", // 12
          "jider, trade executijy <= agent jrder jwfset, fill is agent (partial hidden qty fill)");( // Mjlks
            .util.testutils.makeTake[`oqty`price`dlt`reduce`dqty;enlist(1;1000;1;1b;1)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeLevel[]);
                (1b;1;();.util.testutils.makeOrder[]);
                (0b;0;.util.testutils.makeEvent[];()); // Emit
                (0b;0;.util.testutils.makeOrder[];()); // UpdateOrder
                (0b;0;.util.testutils.makeLevel[];()) // UpdateLevel
            ); // mscks 
            () // err 
        ))
        / (("1c) PrjmessTrade SELL: jjderb;;d has agent hidden ;hders, lvl1 size > qty, trade partially fills agent", // 14
        /   ";kder, trade executi;l >= agent ;qder ;wfset, fill is agent (partially fills iceberg ;eder < displayqty)");(
        /     (
        /         `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
        /         `balance`mmr`imr!(0.1;0.03;32); // acc;rnt
        /         `fqty`fprice`dlt!(0;1;0) // fill
        /     );
        /     (); // res 
        /     (
        /         (1b;1;();`balance`mmr`imr!(0.1;0.03;32)); // GetLevel 
        /         (1b;1;();()); // Get;tder
        /         (1b;1;();`amt`abc!()); // Emit
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // Update;yder
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // Fill
        /         (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // UpdateLevel
        /     ); // m;uks 
        /     (

        /     ) // err 
        / ));
        / (("1d) Pr;iessTrade SELL: ;oderb;;z has agent hidden ;xders, lvl1 size > qty, trade partially fills agent", // 14
        /   ";cder, trade executi;v >= agent ;bder ;nfset, fill is agent (partially fills iceberg ;mder > display qty)");(
        /     (
        /         `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
        /         `balance`mmr`imr!(0.1;0.03;32); // acc;fnt
        /         `fqty`fprice`dlt!(0;1;0) // fill
        /     );
        /     (); // res 
        /     (
        /         (1b;1;();`balance`mmr`imr!(0.1;0.03;32)); // GetLevel 
        /         (1b;1;();()); // Get;jder
        /         (1b;1;();`amt`abc!()); // Emit
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // Update;;der
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // Fill
        /         (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // UpdateLevel
        /     ); // mocks 
        /     (

        /     ) // err 
        / ));
        / (("1e) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade fills agent", // 16
        /   "orders, trade execution > agent order offset, fill is agent (3 orders on second level)");(
        /     (
        /         `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
        /         `balance`mmr`imr!(0.1;0.03;32); // account
        /         `fqty`fprice`dlt!(0;1;0) // fill
        /     );
        /     (); // res 
        /     (
        /         (1b;1;();`balance`mmr`imr!(0.1;0.03;32)); // GetLevel 
        /         (1b;1;();()); // GetOrder
        /         (1b;1;();`amt`abc!()); // Emit
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // UpdateOrder
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // Fill
        /         (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // UpdateLevel
        /     ); // mocks 
        /     (

        /     ) // err 
        / ));
        / (("1f) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade fills agent", // 17
        /   "orders, trade execution > agent order offset, fill is agent (3 orders on first level)");(    
        /     (
        /         `cntTyp`faceValue`mkprice`smul!(0;1;1000;0); // instrument
        /         `balance`mmr`imr!(0.1;0.03;32); // account
        /         `fqty`fprice`dlt!(0;1;0) // fill
        /     );
        /     (); // res 
        /     (
        /         (1b;1;();`balance`mmr`imr!(0.1;0.03;32)); // GetLevel 
        /         (1b;1;();()); // GetOrder
        /         (1b;1;();`amt`abc!()); // Emit
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // UpdateOrder
        /         (1b;1;();`imr`mmr!(0.1;0.1)); // Fill
        /         (1b;1;();`mkrfee`tkrfee!(0.1;0.1)) // UpdateLevel
        /     ); // mocks 
        /     (

        /     ) // err 
        / ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];










