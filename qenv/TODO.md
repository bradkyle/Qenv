https://www.interactivebrokers.com/en/software/tws/usersguidebook/ordertypes/advanced_order_types.htm

All or None (AON)
Auto Trailing Stop
Block
Bracket
Box Top
Conditional
Discretionary
Funari
Hidden
IBDARK Orders
Iceberg/Reserve
ISE Stock Exchange Midpoint Match
Limit + Market
Market with Protection
Minimum Quantity
One-Cancels-All (OCA)
Passive Relative
Pegged-to-Market
Pegged to Midpoint
Pegged to Stock
Pegged to Benchmark
Price Improvement Auction
Relative/Pegged-to-Primary
Relative + Market
Retail Price Improvement Orders
Snap to Market
Snap to Midpoint
Snap to Primary
Sweep-to-Fill
Stop Order with Protection
Trailing Stop
Trailing Stop Limit
Trailing Market if Touched
Trailing Limit if Touched
Trailing Limit + Market
Trailing Relative + Market

https://tickertape.tdameritrade.com/trading/trading-basics-advanced-stock-order-types-17852#:~:text=These%20advanced%20order%20types%20fall,or%20%E2%80%9Ctime%20in%20force.%E2%80%9D


shuffeling accounts for larger simulations i.e. create 1000 accounts and shuffle 10 randomly (resetting state of agent in process);


run engine in seperate process, communicate via rpc?


reduceOnly on both position closes order amount fully or rejects order?
is the order margin updated?
derive updates from 20 levels* full update


Worker Types
    - Websocket
    - Headless Chrome
    - Scraper
    - Crawling
    - Rest 
    - Image/Video Compression
    - Mathematica


Distributed Crawler cluster and rerouting on block etc.


Training episodes 1000 days
Training sample size ∼ 120 days
Testing sample size 40 days
Memory size 107
Number of tilings (M) 32
Weights for linear combination of tile codings (0.6, 0.1, 0.3)
[agent, market, full] (λi )
Learning rate (α) 0.001
Step-size [R-learning] (β) 0.005
Discount factor (γ ) 0.97
Trace parameter (λ) 0.96
Exploration rate (ε) 0.7
εFloor 0.0001
εT 1000
Order size (ω) 1000
Min inventory (min Inv) -10000
Max inventory (max Inv) 10000

No problem, I just need to find a solution
Specifically with respect to the article, the open loss is incurred as the difference 
between the current mark price and the limit price of the orders
the mark price changes and surely as such the open loss should change
if one were to open a given buy order when there were already 4 unfavorably placed buy orders, 
one would need to know the sum of the open loss of the other orders at that instant
This article is also insufficient. i.e. the available margin isn't only affected by initial
margin requirements of the open orders, it is also affected by the sum of the loss of 
the unfavorably placed orders. How does one calculate this loss?
This article is also insufficient. i.e. the available margin isn't only affected by initial 
margin requirements of the open orders, it is also affected by the sum of the loss of the 
unfavorably placed orders. How does one calculate this loss?