/ use timespan with kdb+tick v2.5 or higher. Prior versions use time type

trades:(
    []time:`datetime$();
    side:`symbol$();
    price:`float$();
    size:`float$());

depths:(
    []time:`datetime$();
    ask0_price:`float$();
    ask1_price:`float$();
    ask2_price:`float$();
    ask3_price:`float$();
    ask4_price:`float$();
    ask5_price:`float$();
    ask6_price:`float$();
    ask7_price:`float$();
    ask8_price:`float$();
    ask9_price:`float$();
    bid0_price:`float$();
    bid1_price:`float$();
    bid2_price:`float$();
    bid3_price:`float$();
    bid4_price:`float$();
    bid5_price:`float$();
    bid6_price:`float$();
    ask0_size:`long$();
    ask1_size:`long$();
    ask2_size:`long$();
    ask3_size:`long$();
    ask4_size:`long$();
    ask5_size:`long$();
    ask6_size:`long$();
    ask7_size:`long$();
    ask8_size:`long$();
    ask9_size:`long$();
    bid7_pric:`long$();
    bid8_pric:`long$();
    bid9_pric:`long$();
    bid0_size:`long$();
    bid1_size:`long$();
    bid2_size:`long$();
    bid3_size:`long$();
    bid4_size:`long$();
    bid5_size:`long$();
    bid6_size:`long$();
    bid7_size:`long$();
    bid8_size:`long$();
    bid9_size:`long$());

funding_rates:(
    []time:`datetime$();
    funding_rate:`float$());

mark_prices:(
    []time:`datetime$();
    mark_price:`float$());

accounts:(
    []time:`datetime$();
    balance:`float$();
    available_balance:`float$();
    unrealized_pnl:`float$();
    equity:`float$();
    leverage:`float$();
    margin_balance:`float$();
    maint_margin:`float$());

positions:(
    []time:`datetime$();
    side:`symbol$());

orders:(
    []time:`datetime$();
    sym:`symbol$();
    exch:`symbol$();
    oid:`symbol$();
    side:`symbol$();
    order_type:`int$();
    state:`int$();
    price:`float$();
    size:`int$();
    filled:`int$());

features:(
    []time:`datetime$();
    name:`symbol$();
    scalar:`float$());