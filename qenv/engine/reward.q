\d .reward


// Reward Derivation utils
//----------------------------------------------------->

/
Default reward type for environments, which is derived from PnL and order quantity.
The inputs are as follows:
    (1) Change in exposure value between time steps, in dollar terms; and,
    (2) Realized PnL from a open order being filled between time steps,
        in dollar terms.
:param inventory_count: TRUE if long order is filled within same time step
:param midpoint_change: percentage change in midpoint price
:return: reward
\
Default  :{[]

    };

/
Same as Default reward type for environments, but includes PnL from closing positions.
The inputs are as follows:
    (1) Change in exposure value between time steps, in dollar terms; and,
    (2) Realized PnL from a open order being filled between time steps,
        in dollar terms.
:param inventory_count: TRUE if long order is filled within same time step
:param midpoint_change: percentage change in midpoint price
:param step_pnl: limit order pnl
:return: reward
\
DefaultWithFills        :{[]

    };

/
Only provide reward signal when a trade is closed (round-trip).
:param current_pnl: Realized PnL at current time step
:param last_pnl: Realized PnL at former time step
:return: reward
\
RealizedPNL             :{[]

    };

/
Method to calculate Differential Sharpe Ratio online.
Source 1: http://www.cs.cmu.edu/afs/cs/project/link-3/lafferty/www/ml-stat-www/moody.pdf
Source 2: http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.87.8437&rep=rep1&type=pdf
:param R_t: reward from current time step (midpoint price change a.k.a. 'price returns')
:param A_tm1: A from previous time step
:param B_tm1: B form previous time step
:param eta: discount rate (same as EMA's alpha)
:return: (tuple) reward, A_t, and B_t
\
DifferentialSharpeRatio :{[]

    };

/
Asymmetrical reward type for environments, which is derived from percentage
changes and notional values.
The inputs are as follows:
    (1) Change in exposure value between time steps, in percentage terms; and,
    (2) Realized PnL from a open order being filled between time steps,
        in percentage.
:param inventory_count: Number of open positions
:param midpoint_change: Percentage change of midpoint between steps
:param half_spread_pct: Percentage distance from bid/ask to midpoint
:param long_filled: TRUE if long order is filled within same time step
:param short_filled: TRUE if short order is filled within same time step
:param step_pnl: limit order pnl and any penalties for bad actions
:param dampening: discount factor towards pnl change between time steps
:return: (float) reward
\
Asymmetrical            :{[]

    };

/
Alternate approach for reward calculation which places greater importance on
trades that have returned at least a 1:1 profit-to-loss ratio after
transaction fees.
:param step_pnl: limit order pnl and any penalties for bad actions
:param market_order_fee: transaction fee for market orders
:param profit_ratio: minimum profit-to-risk ratio to earn '1' point (e,g., 2x)
:return: reward
\
TradeCompletion         :{[]

    };

/
We train the weights of this equation by backpropogating the total rewards across the 3600 second time steps
during the entire hour. To calculate these rewards, we design a reward function that represents a realistic
depiction of the amount of money that can be expected to be made if the predicted actions were carried out,
and represented the cash flow. Any amount of the currency pair that is bought represents a reward of r =
−(Ask Price)(Units Purchased), while any amount sold represents a reward of r = (Bid Price)(Units Sold).
Note this amount is actually based on the difference between the previous and current actions. These amounts
account for the spread and are expressed as if any amount in the currency pair is not cash and the reward
is relative to solely our cash holdings. We make sure that at the end of the hour, the position is liquidated,
so that a realistic return is calculated. The total reward is thus the sum of the reward of all the time steps
R = r1 + r2 + .... + r3600. This reward is exactly what one would expect to make trading using the posted
quotes and prices. At the end of the step, the reward is back-propagated to the weights of the network and
equation.
\

/
Vanilla sortino
\