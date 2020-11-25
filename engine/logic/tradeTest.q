

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
/
.qt.Unit[
    ".engine.logic.trade.ProcessAgentTrades";
    {[c]
        .qt.RunUnit[c;.engine.services.mark.ProcessMarkUpdateEvents];
    };.qt.generalParams;
    (
        (("1a) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade doesn't fill agent", // 12
          "order, trade execution <= agent order offset, fill is agent (partial hidden qty fill)");(
                ( // Current Depth  
                    [price:1000-til 10] 
                    side:(10#1);
                    qty:10#1000;
                    hqty:((10 20),(8#10));
                    iqty:((170 170),(8#0)); // TODO fix
                    vqty:((1030 1030),(8#1000)) // TODO fix
                ); 
                (   // Current Orders  
                    til[4];4#0;4#1;4#1;4#1; // `orderId`instrumentId`accountId`side`otype 
                    ((2#400),(2#600)); // offset
                    4#100; // leaves
                    ((2#10),(2#20)); // displayqty
                    4#1000 999; // price
                    4#z // time
                );
                (-1;5;1b;z);  // Sell should reduce // TODO add time check
                (1b;1;( // Expected .order.applyNewTrades Mock
                    enlist(enlist'[(-1;1000;5;z)])
                ));    
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip((0;1000;395;100;10;0;z);(2;1000;595;100;20;0;z))
                ));    
                (1b;1;( // Expected .order.applyTakerFills Mock
                    enlist(enlist'[(0;0;-1;1000;5;1b;z)])
                ));   
                (0b;0;()); // Expected .order.applyMakerFills Mock
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist(enlist'[(1000;1;1000;5;170;1030;z)])
                ))     
          ));
          (("1b) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade doesn't fill agent", // 13
          "order, trade execution <= agent order offset, fill is agent");(
                ( // Current Depth  
                    [price:1000-til 10] 
                    side:(10#1);
                    qty:10#1000;
                    hqty:((10 20),(8#10));
                    iqty:((170 170),(8#0)); // TODO fix
                    vqty:((1030 1030),(8#1000)) // TODO fix
                ); 
                (   // Current Orders  
                    til[4];4#0;4#1;4#1;4#1; // `orderId`instrumentId`accountId`side`otype 
                    ((2#400),(2#600)); // offset
                    4#100; // leaves
                    ((2#10),(2#20)); // displayqty
                    4#1000 999; // price
                    4#z // time
                ); 
                (-1;200;1b;z);   // Sell should reduce
                (1b;1;( // Expected .order.applyNewTrades Mock
                    enlist flip((-1;1000;10;z);(-1;1000;190;z))
                ));    
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip((0;1000;200;100;10;0;z);(2;1000;400;100;20;0;z)) // offset includes hqty
                ));    
                (1b;1;( // Expected .order.applyTakerFills Mock
                    enlist(enlist'[(0;0;-1;1000;200;1b;z)]) // TODO should be same instrument
                ));   
                (0b;0;()); // Expected .order.applyMakerFills Mock
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist(enlist'[(1000;1;810;0;170;840;z)])
                )) 
          ));
          (("1c) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade partially fills agent", // 14
          "order, trade execution >= agent order offset, fill is agent (partially fills iceberg order < displayqty)");(
                ( // Current Depth  
                    [price:1000-til 10] 
                    side:(10#1);
                    qty:10#1000;
                    hqty:((10 20),(8#10));
                    iqty:((170 170),(8#0)); // TODO fix
                    vqty:((1030 1030),(8#1000)) // TODO fix
                ); 
                (   // Current Orders  
                    til[4];4#0;4#1;4#1;4#1; // `orderId`instrumentId`accountId`side`otype 
                    ((2#400),(2#600)); // offset
                    4#100; // leaves
                    ((2#10),(2#20)); // displayqty
                    4#1000 999; // price
                    4#z // time
                );  
                (-1;450;1b;z);  // Fill Execution Buy
                (1b;1;( // Expected .order.applyNewTrades Mock
                    enlist flip((-1;1000;10;z);(-1;1000;390;z);(-1;1000;50;z))
                ));    
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip((0;1000;0;50;10;1;z);(2;1000;150;100;20;0;z)) // offset includes hqty
                ));    
                (1b;1;( // Expected .order.applyTakerFills Mock
                    enlist(enlist'[(0;0;-1;1000;450;1b;z)]) 
                ));   
                (1b;1;( // Expected .order.applyMakerFills Mock
                    enlist(enlist'[(0;1;1;1000;50;0b;z)])
                )); 
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist(enlist'[(1000;1;610;0;120;640;z)])
                )) 
          ));
          (("1d) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade partially fills agent", // 14
          "order, trade execution >= agent order offset, fill is agent (partially fills iceberg order > display qty)");(
                ( // Current Depth  
                    [price:1000-til 10] 
                    side:(10#1);
                    qty:10#1000;
                    hqty:((10 20),(8#10));
                    iqty:((170 170),(8#0)); // TODO fix
                    vqty:((1030 1030),(8#1000)) // TODO fix
                ); 
                (   // Current Orders  
                    til[4];4#0;4#1;4#1;4#1; // `orderId`instrumentId`accountId`side`otype 
                    ((2#400),(2#600)); // offset
                    4#100; // leaves
                    ((2#10),(2#20)); // displayqty
                    4#1000 999; // price
                    4#z // time
                );  
                (-1;495;1b;z);  // Fill Execution Buy
                (1b;1;( // Expected .order.applyNewTrades Mock
                    enlist(3#-1;3#1000;10 390 95;3#z)
                ));    
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip((0;1000;0;5;5;1;z);(2;1000;105;100;20;0;z)) // offset includes hqty // TODO check
                ));    
                (1b;1;( // Expected .order.applyTakerFills Mock
                    enlist(enlist'[(0;0;-1;1000;495;1b;z)]) 
                ));   
                (1b;1;( // Expected .order.applyMakerFills Mock
                    enlist(enlist'[(0;1;1;1000;95;0b;z)])
                )); 
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist(enlist'[(1000;1;610;0;80;635;z)]) // TODO check
                )) 
          ));
          // TODO fills entire level
          (("1e) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade fills agent", // 16
          "orders, trade execution > agent order offset, fill is agent (3 orders on second level)");(
                ( // Current Depth  
                    [price:1000-til 10] 
                    side:(10#1);
                    qty:10#1000;
                    hqty:((10 20),(8#10));
                    iqty:((170 170),(8#0)); // TODO fix
                    vqty:((1030 1030),(8#1000)) // TODO fix
                ); 
                (   // Current Orders  
                    til[5];5#0;5#1;5#1;5#1; // `orderId`instrumentId`accountId`side`otype 
                    ((2#400),(2#600),850); // offset
                    5#100; // leaves
                    ((2#10),(3#20)); // displayqty
                    5#999 1000; // price
                    5#z // time
                ); 
                (-1;1850;1b;z);  // Fill Execution Buy
                (1b;1;( // Expected .order.applyNewTrades Mock
                    enlist flip(
                        (-1;999;20;z);
                        (-1;999;380;z);
                        (-1;999;100;z);
                        (-1;999;100;z);
                        (-1;999;40;z);
                        (-1;1000;10;z);
                        (-1;1000;390;z);
                        (-1;1000;100;z);
                        (-1;1000;100;z);
                        (-1;1000;100;z);
                        (-1;1000;330;z)
                    )
                ));    
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip(
                        (0;999;0;0;0;1;z);
                        (2;999;0;60;20;1;z);
                        (4;999;210;100;20;0;z);
                        (1;1000;0;0;0;1;z);
                        (3;1000;0;0;0;1;z)
                    )
                ));    
                (1b;1;( // Expected .order.applyTakerFills Mock
                    enlist flip((0;0;-1;999;640;1b;z);(0;0;-1;1000;1030;1b;z)) 
                ));   
                (1b;1;( // Expected .order.applyMakerFills Mock
                    enlist flip((0;1;1;999;100;0b;z);(0;1;1;999;40;0b;z);(0;1;1;1000;100;0b;z);(0;1;1;1000;100;0b;z))
                )); 
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist flip((999;1;520;0;120;560;z);(1000;1;0;0;0;0;z)) // TODO check
                )) 
          ));
          (("1f) ProcessTrade SELL: orderbook has agent hidden orders, lvl1 size > qty, trade fills agent", // 17
          "orders, trade execution > agent order offset, fill is agent (3 orders on first level)");(
                ( // Current Depth  
                 [price:1000-til 10] 
                 side:(10#1);
                 qty:10#1000;
                 hqty:((10 20),(8#10));
                 iqty:((250 170),(8#0)); // TODO fix
                 vqty:((1050 1030),(8#1000)) // (999:10 20=30(1200-170=1030), 1000:10 20 20=50(1300-250=1050))
                ); 
                (   // Current Orders  
                    til[5];5#0;5#1;5#1;5#1; // 
                    ((2#400),(2#600),850); // offset (includes hidden qty)
                    5#100; // leaves
                    ((2#10),(3#20)); // displayqty (999:10 20=30, 1000:10 20 20=50)
                    5#1000 999; // price 
                    5#z // time
                ); 
                (-1;1850;1b;z);  // Fill Execution Buy
                (1b;1;( // Expected .order.applyNewTrades Mock
                    enlist flip(
                        (-1;1000;10;z);
                        (-1;1000;390;z);
                        (-1;1000;100;z);
                        (-1;1000;100;z);
                        (-1;1000;100;z);
                        (-1;1000;150;z);
                        (-1;1000;100;z);
                        (-1;1000;100;z);
                        (-1;999;20;z);
                        (-1;999;380;z);
                        (-1;999;100;z);
                        (-1;999;40;z)                        
                    )
                ));    
                (1b;1;( // Expected .order.applyOrderUpdates Mock
                    enlist flip(
                        (0;1000;0;0;0;1;z);
                        (2;1000;0;0;0;1;z);
                        (4;1000;0;0;0;1;z);
                        (1;999;0;0;0;1;z);
                        (3;999;60;100;20;0;z))
                ));    
                (1b;1;( // Expected .order.applyTakerFills Mock
                    enlist flip(
                        (0;0;-1;1000;1050;1b;z);
                        (0;0;-1;999;540;1b;z)) 
                ));   
                (1b;1;( // Expected .order.applyMakerFills Mock
                    enlist flip(
                        (0;1;1;1000;100;0b;z);
                        (0;1;1;1000;100;0b;z);
                        (0;1;1;1000;100;0b;z);
                        (0;1;1;999;100;0b;z))
                )); 
                (1b;1;( // Expected .order.applyBookUpdates Mock
                    enlist flip((1000;1;0;0;0;0;z);(999;1;580;0;80;600;z)) // TODO check
                )) 
          ))
    );
    .util.testutils.defaultEngineHooks;
    "Process trades from the historical data or agent orders",
    "size update the orderbook and the individual order offsets/iceberg",
    "orders and call Add Events/Fills etc. where necessary"];
