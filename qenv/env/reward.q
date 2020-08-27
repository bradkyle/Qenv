\d .reward

sortinoRatio:{[asset;minAccRet] 
 excessRet:-1*minAccRet-(100*1_asset-prev[asset])%1_asset;
 100*avg[excessRet]% sqrt sum[(excessRet*0>excessRet) xexp 2]%count[excessRet]
 };

// r:0!select raze 1_deltas[realizedPnl] by accountId from select[-100] last realizedPnl by 1 xbar `minute$time, accountId from .state.InventoryEventHistory

// Reward Derivation utils
//----------------------------------------------------->

/
Default reward type for environments, which is derived from PnL and order quantity.
The inputs are as follows:
    (1) Change in exposure value between time steps, in dollar terms; and,
    (2) Realized PnL from a open order being filled between time steps,
        in dollar terms.
:param inventoryCount: TRUE if long order is filled within same time step
:param midPointChange: percentage change in midpoint price
:return: reward
\
Default  :{[inventoryCount;midPointChange]
    :(inventoryCount*midPointChange)
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
DefaultWithFills        :{[inventoryCount;midPointChange;stepPnl]
    :(inventoryCount*midPointChange)+stepPnl
    };

/
Only provide reward signal when a trade is closed (round-trip).
:param current_pnl: Realized PnL at current time step
:param last_pnl: Realized PnL at former time step
:return: reward
\
RealizedPNL             :{[currentPnl;lastPnl]
    :(currentPnl-lastPnl)
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
DifferentialSharpeRatio :{[Rt;Atml;Btml;eta]
    
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
LINEAR sortino
\


/
Generally researchers (Ghandar et al, Michalewicz, Lam) have used the profit or return on investment (ROI) as a reward (fitness) function.

ROI=[∑Tt=1(Pricet−sc)×Is(t)]−[∑Tt=1(Pricet+bc)×Ib(t)][∑Tt=1(Pricet+bc)×Ib(t)]

where Ib(t) and Is(t) are equal to one if a rule signals a buy and sell, respectively, and zero otherwise; 
sc represents the selling cost and bc the buying cost. ROI is the difference between final bank balance 
and starting bank balance after trading.

You are correct, that the machine learning algorithm will then be influenced by spikes just before a sell.

Nicholls et al showed that using the average profit or area under the trade resulted in better performing trading rules.
This approach was used by Schoreels et al. This approach focuses on being in the market to capitalize on profit.
It does not penalize the trading rule when it is in the market and the market is going down. The accumulated asset value (AAV) is defined as:

AAV=∑Ni=1[(Prices−sc)−(Priceb+bc)]N

where i is a buy and sell trading event, N is the number of buy and sell events, s the day the sale took place, and 
b is the day the purchase took place.

Nicholls MSc thesis [available April 2019] showed that the fitness function used by Allen and Karjalainen is the preferred fitness 
function when evolving trading rules for the JSE using evolutionary programs.

Allen and Karjalainen used a fitness function based on the compounded excess returns over the buy-and-hold strategy. The excess return is given by:

Δr=r−rbh

where the continuously compounded return of the trading rule is computed as

r=∑Tt=1riIb(t)+∑Tt=1rfIs(t)+nlog(1−c1+c′)

and the return for the buy-and-hold strategy is calculated as

rbh=∑Tt=1rt+nlog(1−c1+c′)

In the above,

ri=logPt−logPt−1

and P is the daily close price for a given day t, c denotes the one-way transaction cost; rf is the risk free cost when the trader is not 
trading, Ib(t) and Is(t) are equal to one if a rule signals buy and sell, respectively, and zero otherwise; n denotes the number of 
trades and rbh represents the returns of a buy-and-hold, while r represents the returns of the trader.

A fixed trading cost of c=0.25% of the transaction was defined but this could be anything like a STATE fee + Brocker fee + Tax, 
and might even be 2 different values, one for buying and one for selling. Which was the approach used by Nicholls. 
The continuously compounded return function rewards an individual when the share value is dropping and the individual is 
out of the market. The continuously compounded return function penalises the individual when the market is rising and the 
individual is out of the market.

I would recommend that you use the compounded excess return over the buy and hold strategy as your reward function.
\



/
Return the reward based on PnL from the last step marked to the
mid-price of the instruments traded
:param e: Environment object. Environment where the agent operates
:param a: Agent object. the agent that will perform the action
:param s: dictionary. The inputs from environment to the agent
:param pnl: float. The current pnl of the agent
:param inputs: dictionary. The inputs from environment to the agent
\

/
OFI
Return the reward based on PnL from the last step marked to the
mid-price of the instruments traded
:param e: Environment object. Environment where the agent operates
:param a: Agent object. the agent that will perform the action
:param s: dictionary. The inputs from environment to the agent
:param pnl: float. The current pnl of the agent
:param inputs: dictionary. The inputs from environment to the agent
\