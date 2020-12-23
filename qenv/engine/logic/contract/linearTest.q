
nl:{neg l[x]};

.qt.Unit[
    ".engine.logic.contract.linear.ExecCost";
    {[c]
        p:c[`params];

        res:.engine.logic.contract.linear.ExecCost . p`args;
        .qt.A[res;~;p[`eRes];"execCost";c];
    };
    {[p]  :`args`eRes!p; };
    (
        ("ExecCost multiple entries";((0 0 1e8);0));
        ("ExecCost single entry";((0 0 1e8);0))
    );
    ({};{};{};{});
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".engine.logic.contract.linear.AvgPrice";
    {[c]
        p:c[`params];

        res:.engine.logic.contract.linear.AvgPrice . p`args;
        .qt.A[res;~;p[`eRes];"avgPrice";c];
    };
    {[p]  :`args`eRes!p; };
    (
        ("AvgPrice multiple entries";((0 0 0 1e8);0));
        ("AvgPrice single entry";((0 0 0 1e8);0))
    );
    ({};{};{};{});
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".engine.logic.contract.linear.UnrealizedPnl";
    {[c]
        p:c[`params];
        res:.engine.logic.contract.linear.UnrealizedPnl . p`args;
        .qt.A[res;~;p[`eRes];"unrealizedPnl";c];
    };
    {[p]  :`args`eRes!p; };
    (
        ("Zero args:Binance BTCUSDT analog, faceValue 1";((0 0 0 0 0 0);0));
        ("Zero args:Bitmex XBTUSD linear analog, faceValue 1";((0 0 0 0 0 0);0));
        ("Zero args:Okex BTCUSDT linear analog, faceValue 100";((0 0 0 0 0 0);0)); 
        ("0.50 UPL short:Binance BTCUSDT analog, faceValue 1";((200 -1 100 100 1 1e8);l 5e7));
        ("0.50 UPL short:Bitmex XBTUSD linear analog, faceValue 1";((200 -1 100 100 1 1e8);l 5e7));
        ("0.50 UPL short:Okex BTCUSDT linear analog, faceValue 100";((200 -1 100 100 100 1e8);l 5e9)); 
        ("0.50 UPL long:Binance BTCUSDT analog, faceValue 1";((100 1 100 200 1 1e8);nl 5e7));
        ("0.50 UPL long:Bitmex XBTUSD linear analog, faceValue 1";((100 1 100 200 1 1e8);l 5e7));
        ("0.50 UPL long:Okex BTCUSDT linear analog, faceValue 100";((100 1 100 200 100 1e8);l 5e9)); 
        ("-0.50 UPL short:Binance BTCUSDT analog, faceValue 1";((200 -1 100 100 1 1e8);nl 5e7));
        ("-0.50 UPL short:Bitmex XBTUSD linear analog, faceValue 1";((200 -1 100 100 1 1e8);nl 5e7));
        ("-0.50 UPL short:Okex BTCUSDT linear analog, faceValue 100";((200 -1 100 100 100 1e8);nl 5e9)); 
        ("-0.50 UPL long:Binance BTCUSDT analog, faceValue 1";((100 1 100 200 1 1e8);nl 5e7));
        ("-0.50 UPL long:Bitmex XBTUSD linear analog, faceValue 1";((100 1 100 200 1 1e8);nl 5e7));
        ("-0.50 UPL long:Okex BTCUSDT linear analog, faceValue 100";((100 1 100 200 100 1e8);nl 5e9)); 
        ("Check Null amt";((0n 0 0 0 0 0);0))
    );
    ({};{};{};{});
    "Function for deriving the exec cost from the qty and the price"];

//

.qt.Unit[
    ".engine.logic.contract.linear.RealizedPnl";
    {[c]
        p:c[`params];
        res:.engine.logic.contract.linear.RealizedPnl . p`args;
        .qt.A[res;~;p[`eRes];"realizedPnl";c];
    };
    {[p] :`args`eRes!p; };
    (
        ("Zero args:Binance BTCUSDT analog, faceValue 1";((0 0 0 0 0 0);0));
        ("Zero args:Bitmex XBTUSD linear analog, faceValue 1";((0 0 0 0 0 0);0));
        ("Zero args:Okex BTCUSDT linear analog, faceValue 100";((0 0 0 0 0 0);0)); 
        ("0.50 RPL short:Binance BTCUSDT analog, faceValue 1";((200 -1 100 100 1 1e8);l 5e7));
        ("0.50 RPL short:Bitmex XBTUSD linear analog, faceValue 1";((200 -1 100 100 1 1e8);l 5e7));
        ("0.50 RPL short:Okex BTCUSDT linear analog, faceValue 100";((200 -1 100 100 100 1e8);l 5e9)); 
        ("0.50 RPL long:Binance BTCUSDT analog, faceValue 1";((100 1 100 200 1 1e8);nl 5e7));
        ("0.50 RPL long:Bitmex XBTUSD linear analog, faceValue 1";((100 1 100 200 1 1e8);l 5e7));
        ("0.50 RPL long:Okex BTCUSDT linear analog, faceValue 100";((100 1 100 200 100 1e8);l 5e9)); 
        ("-0.50 RPL short:Binance BTCUSDT analog, faceValue 1";((200 -1 100 100 1 1e8);nl 5e7));
        ("-0.50 RPL short:Bitmex XBTUSD linear analog, faceValue 1";((200 -1 100 100 1 1e8);nl 5e7));
        ("-0.50 RPL short:Okex BTCUSDT linear analog, faceValue 100";((200 -1 100 100 100 1e8);nl 5e9)); 
        ("-0.50 RPL long:Binance BTCUSDT analog, faceValue 1";((100 1 100 200 1 1e8);nl 5e7));
        ("-0.50 RPL long:Bitmex XBTUSD linear analog, faceValue 1";((100 1 100 200 1 1e8);nl 5e7));
        ("-0.50 RPL long:Okex BTCUSDT linear analog, faceValue 100";((100 1 100 200 100 1e8);nl 5e9)); 
        ("Check Null amt";((0n 0 0 0 0 0);0))
    );
    ({};{};{};{});
    "Function for deriving the exec cost from the qty and the price"];

