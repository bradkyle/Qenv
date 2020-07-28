

// INITIAL MARGIN REQUIIRED
/ If a contract uses Fair Price Marking initial margin will be calculated differently. 
/ If a buy order is placed above the mark price, or if a sell order is placed below 
/ the mark price then the trader must fully fund the difference between the order price 
/ and the mark price. For example, if the mark price is $100 and the trader submits a 
/ bid order for 10 contracts at $110, then the 
/ initial margin required = (IM * 10 contracts * $110 * Multiplier) + 
/ (100% * 10 contracts * ($110 - $100) * Multiplier).

// MAINTENENCE MARGIN
/ For all positions the 
/ Maintenance Margin required = (MM * Contracts * Mark Price * Multiplier). 
/ The amount of commission applicable to close out all your positions will 
/ also be added onto your maintenance margin requirement. 
/ This is the minimum amount of margin you must maintain to avoid 
/ liquidation on your position .

/ DELEVERAGING
/ The Insurance Fund is used to prevent ADL. If it is depleted for a given
/ contract, ADL will occur.

/ PRIORITY RANKING
/ Deleveraging priority is calculated by profit and leverage. 
/ More profitable and higher leveraged traders are deleveraged first.
/ The ranking calculation is as follows:
/ Ranking = PNL Percentage * Effective Leverage  (if PNL percentage > 0)
/         = PNL Percentage / Effective Leverage  (if PNL percentage < 0)
/ where
/   Effective Leverage = abs(Mark Value) / (Mark Value - Bankrupt Value)
/   PNL percentage = (Mark Value - Avg Entry Value) / abs(Avg Entry Value)
/   Mark Value = Position Value at Mark Price
/   Bankrupt Value = Position Value at Bankruptcy Price
/   Avg Entry Value = Position Value at Average Entry Price
/  The system splits these positions by longs and shorts and ranks the 
/  positions from highest to lowest.

/ FAIR PRICE FOR PERPETUAL CONTRACTS
/ Funding Basis = Funding Rate * (Time Until Funding / Funding Interval)
/ Fair Price    = Index Price * (1 + Funding Basis)

/ LIQUIDATION
/ Liquidation Process
/ BitMEX employs a partial liquidation process involving automatic reduction 
/ of maintenance margin in an attempt to avoid a full liquidation of a 
/ trader’s position.
/ Users on the Lowest Risk Limit tiers
/ BitMEX cancels any open orders in the contract.
/ If this does not satisfy the maintenance margin requirement then the 
/ position will be liquidated by the liquidation engine at the bankruptcy price.
/ Users on Higher Risk Limit tiers
/ The liquidation system attempts to bring a user down to a lower Risk Limit, 
/ and thus lower margin requirements by:
/ Attempting to bring a user down to a Risk Limit associated with their 
/ open orders and current position.
/ Cancelling any open orders and then attempting to bring a user down to 
/ a Risk Limit associated with their current position.
/ Submitting a FillOrKill order of the difference between the current 
/ Risk Limit position size and the position size to satisfy the margin 
/ requirement to avoid liquidation.
/ If the position is still in liquidation then the entire position is 
/ taken over by the liquidation engine and a limit order to close the 
/ position is placed at the bankruptcy price.

/ Wallet Balance	
/ Deposits - Withdrawals + Realised PNL

/ Unrealised PNL	
/ Current profit and loss from all open positions.

/ Margin Balance	
/ Your total equity held with the exchange. 
/ Margin Balance = Wallet Balance + Unrealised PNL.

/ Position Margin	
/ The portion of your margin that is assigned to 
/ the initial margin requirements on your open positions. 
/ This is the entry value of all contracts you hold 
/ divided by the selected leverage, plus 
/ unrealised profit and loss.

/ Order Margin	
/ The portion of your margin that is assigned to the 
/ initial margin requirements on your open orders.

/ Available Balance	
/ Your margin available for new positions. 
/ Available Balance = Margin Balance - Order Margin - Position Margin.

/ John is long 1,000 XBTUSD contracts with an average entry price of $1,000. The mark price of XBTUSD is currently $1,250.

/ John’s unrealised PNL is based on the difference between his average entry price and the mark price.

/ Unrealised Profit = ($1/$1,000 - $1/$1,250) * 1,000 = 0.20 XBT

/ The last price of XBTUSD is $1,500. However for the calculation of unrealised PNL, the mark price is used not the last price. To understand why, please read Fair Price Marking.

/ John decides to sell 500 XBTUSD contracts at $1,500 and realise some profit.

/ John’s realised PNL is based on the difference between his average entry price and the price at which he sells XBTUSD.

/ Realised Profit = ($1/1,000 - $1/$1,500) * 500 = 0.17 XBT

/ Realised PNL is based on where you can actually buy or sell your position, which in most cases is not the mark price. If John had sold his 500 contracts at the mark price of $1,250, he would have a realised profit of 0.10 XBT.

/ Example 2, Funding Fees
/ BitMEX has a type of derivative contract called a Perpetual Contract. Buyers and sellers of perpetual contacts pay and receive funding fees periodically throughout the trading day. To learn more, please read the Perpetual Contracts Guide.

/ John is trading XBTUSD, which is a perpetual contract. Every 8 hours, there is a funding fee. The funding fee is currently 1%, and is paid from buyers to sellers.

/ John is currently long 100 XBT worth of XBTUSD. The position has no realised PNL. It is funding time and John must pay 1 XBT because he is long XBTUSD. After the funding fee has been paid, John’s realised PNL is now -1 XBT.

/ If John had been short 100 XBT worth of XBTUSD instead, he would have received 1 XBT. His realised profit would then be 1 XBT instead of -1 XBT.

/ Example 3, Trading Fees
/ All trading fees are accounted for through realised pnl.

/ John bought XBTUSD. The market has not moved. His unrealised PNL is 0, but his realised PNL is negative. John’s realised PNL is negative because he paid a taker fee when he bought XBTUSD.

/ If John had placed a passive limit order, he would be classified as a maker once the order was executed. As a maker, John would have been paid a rebate on the trade. In that situation, his unrealised PNL would be 0 and realised PNL positive.

/ Example 4, Realised PNL Accounting
/ Realised PNL is displayed in different locations on the BitMEX trading dashboard depending on whether you are merely reducing the size of an existing position, or closing it entirely.

/ If you have an open position with a realised profit of 10 XBT, this amount will show on the Open Positions tab.

/ If you completely close the same position and you realise a profit of 10 XBT, this 10 XBT will be shown on the Closed Positions tab.

/ If you then create a new position on the same contract, realised PNL will be reset to 0 XBT on the Open Positions tab. Realised PNL resulting from a partial closure of this new position will be displayed on the Open Positions tab.

/ If you then completely close this new position, any realised PNL will be added to that symbol on the Closed Positions tab.

/ BitMEX imposes risk limits on all trading accounts to minimise 
/ the occurrence of large liquidations on margined contracts.
/ As users amass larger positions, they pose a risk to others on the 
/ exchange who may experience a deleveraging event if the position 
/ cannot be fully liquidated. The Step model helps avoid this by 
/ increasing margin requirements for large positions.
/ Dynamic Risk Limits
/ Each instrument has a Base Risk Limit and Step. 
/ These numbers combined with the base Maintenance and 
/ Initial Margin requirements are used to calculate your 
/ full margin requirement at each position size.
/ As the position size increases, the maintenance 
/ and initial margin requirements will increase. 
/ Users must authorize a higher or lower risk limit 
/ on the Positions panel. Margin requirements will
/ automatically increase and decrease as your 
/ risk limit changes.

/ Symbol	Base Risk Limit	Step	Base Maintenance Margin	Base Initial Margin
/ XRPU20	50 XBT	50 XBT	2.50%	5.00%
/ BCHU20	50 XBT	50 XBT	2.50%	5.00%
/ ADAU20	50 XBT	50 XBT	2.50%	5.00%
/ EOSU20	50 XBT	50 XBT	2.50%	5.00%
/ TRXU20	50 XBT	50 XBT	2.50%	5.00%
/ XRPUSD	50 XBT	50 XBT	1.00%	2.00%
/ BCHUSD	50 XBT	50 XBT	2.00%	4.00%
/ XBTUSD	200 XBT	100 XBT	0.40%	1.00%
/ XBTU20	50 XBT	50 XBT	0.40%	1.00%
/ XBTZ20	50 XBT	50 XBT	0.40%	1.00%
/ ETHUSD	50 XBT	50 XBT	0.80%	2.00%
/ ETHU20	50 XBT	50 XBT	0.80%	2.00%
/ ETHUSDU20	50 XBT	50 XBT	0.80%	2.00%
/ LTCU20	50 XBT	50 XBT	1.50%	3.00%

/ Formulas
/ Term	Formula	XBTUSD Example (1 Step)
/ New Maintenance Margin %	Base MM % + ( Steps * Base MM % )	0.40% + ( 1 * 0.40% ) = 0.80%
/ New Initial Margin %	Base IM % + ( Steps * Base MM % )	1.00% + ( 1 * 0.40% ) = 1.40%
/ XBT Maintenance Margin	New MM * Gross XBT Position Value	0.80% * 300 XBT = 2.4 XBT
/ At each step, the maintenance and initial margin are raised by the base maintenance margin. 
/ For example, with XBTUSD the base maintenance and initial margin are 0.40% and 1.00% respectively.

/ See the Risk Limits Page for up-to-date risk limits, which are unique per contract.

/ The calculation for the new maintenance margin becomes 0.40% + ( # of Steps * 0.40% ) and the 
/ new initial margin becomes 1.00% + ( # of Steps * 0.40% ). Hence we can create a table as such:

/ Position Size	Maintenance Margin	Initial Margin
/ < 200 XBT	0.40%	1.00%
/ < 300 XBT	0.80%	1.40%
/ < 400 XBT	1.20%	1.80%
/ < 500 XBT	1.60%	2.20%
/ Trade Example

/ A trader has a XBTUSD position worth 180 XBT. 
/ The current maintenance margin requirement is 0.40% (0.72 XBT),
/  and current initial margin requirement for new orders is 1.00%.

/ The trader wishes to place a new order of 50 XBT on XBTUSD that 
/ would increase his position to 230 XBT. 
/ Because their account is now greater than 200 XBT, he is 1 step 
/ above the Base Risk Limit of 200 XBT. 
/ The trader thus increases their maintenance and initial margin 
/ to the next step (<300XBT) to 0.80% and 1.40%, respectively.

/ Auto-Deleveraging Further Information
/ BitMEX employs an Auto-Deleveraging (ADL) system as a margining method for its speculative derivative instruments as an evolution to the “Socialised Loss” system.

/ Socialised Loss systems have a few disadvantages:

/ A single risky trader can create a large loss for all traders, including low-risk traders.
/ Profit must be locked until rebalance or settlement in case of loss.
/ The ADL system aims to resolve loss uncertainty, allowing traders to make decisions as soon as the deleveraging event occurs, 
/ rather than wait for rebalance or settlement. Traders who become deleveraged will be immediately informed of their closeout price 
/ and size. They may then choose to re-enter the market.

/ Example of Auto-Deleveraging and the Ranking System
/ Let’s assume within the system there are 6 longs and their effective leveraged PnL score has been calculated. 
/ Note the higher the PnL Ranking, the higher their effective leveraged PnL.

/ Account	Quantity	PNL Ranking
/ 1	10	3
/ 2	10	6
/ 3	20	1
/ 4	30	4
/ 5	20	5
/ 6	10	2
/ The system will next rank these positions from the highest score to the lowest 
/ and calculate the quintile associated in that position.

/ Account	Quantity	PNL Ranking	Percentile
/ 2	10	6	20%
/ 5	20	5	40%
/ 4	30	4	60%
/ 1	10	3	80%
/ 6	10	2	80%
/ 3	20	1	100%
/ In the case of a liquidation, those users in the top percentiles will be deleveraged first. 
/ Let’s consider a short position that has been liquidated with size 20 and bankruptcy price of USD 650.

/ Accounts 2 and 5 will be deleveraged at the bankruptcy price of USD 650. Account 2 will have their entire position of 10 contracts closed, 
/ while the remaining 10 contracts from the short liquidation will be assigned to account 5.

/ Account 5 will thus have 10 contracts remaining (from 20). Depending on his/her effective leverage, 
/ account 5 may or may not remain in the lowest quintile.

/ Both users will be notified and given the opportunity to re-enter 
/ their positions.

/ # First, the position updates to a 'posState' of 'Deleverage'.
/ < {"table":"position",
/    "action":"update",
/    "data":[{
/     "account":2,"symbol":"XBTUSD","currency":"XBt","currentQty":2000,
/     "markPrice":1160.72,"posState":"Deleverage","simpleQty":1.746,"liquidationPrice":1140.1,
/     "timestamp":"2017-04-04T22:16:38.460Z"
/    }]}

/ # Then, a 'Deleverage' execution is inserted. Notice the 'text'.
/ < {"table":"execution",
/    "action":"insert",
/    "data":[{
/     "execID":"20ad1ff4-c110-a4f2-dd31-f94eaa0701fd",
/     "orderID":"00000000-0000-0000-0000-000000000000","clOrdID":"","clOrdLinkID":"","account":2,"symbol":"XBTUSD",
/     "side":"Sell","lastQty":2000,"lastPx":1160.72,"underlyingLastPx":null,"lastMkt":"XBME",
/     "lastLiquidityInd":"AddedLiquidity","simpleOrderQty":null,"orderQty":2000,"price":1160.72,"displayQty":null,
/     "stopPx":null,"pegOffsetValue":null,"pegPriceType":"","currency":"USD","settlCurrency":"XBt","execType":"Trade",
/     "ordType":"Limit","timeInForce":"GoodTillCancel","execInst":"","contingencyType":"","exDestination":"XBME",
/     "ordStatus":"Filled","triggered":"","workingIndicator":false,"ordRejReason":"",
/     "simpleLeavesQty":0,"leavesQty":0,"simpleCumQty":1.746,"cumQty":2000,"avgPx":1160.72,"commission":-0.00025,
/     "tradePublishIndicator":"PublishTrade","multiLegReportingType":"SingleSecurity","text":"Deleverage",
/     "trdMatchID":"1e849b8a-7e88-3c67-a93f-cc654d40e8ba","execCost":172306000,"execComm":-43077,
/     "homeNotional":-1.72306,"foreignNotional":2000,"transactTime":"2017-04-04T22:16:38.472Z",
/     "timestamp":"2017-04-04T22:16:38.472Z"
/    }]}

/ # Quickly thereafter, the position resets.
/ < {"table":"position",
/    "action":"update",
/    "data":[{
/     "account":2,"symbol":"XBTUSD","currency":"XBt",
/     "deleveragePercentile":null,"rebalancedPnl":-2171150,"prevRealisedPnl":2172153,"execSellQty":2001,
/     "execSellCost":172394155,"execQty":0,"execCost":-2259128,"execComm":87978,
/     "currentTimestamp":"2017-04-04T22:16:38.547Z","currentQty":0,"currentCost":-2259128,
/     "currentComm":87978,"realisedCost":-2259128,"unrealisedCost":0,"grossExecCost":0,"isOpen":false,
/     "markPrice":null,"markValue":0,"riskValue":0,"homeNotional":0,"foreignNotional":0,"posState":"","posCost":0,
/     "posCost2":0,"posInit":0,"posComm":0,"posMargin":0,"posMaint":0,"maintMargin":0,"realisedGrossPnl":2259128,
/     "realisedPnl":2171150,"unrealisedGrossPnl":0,"unrealisedPnl":0,"unrealisedPnlPcnt":0,"unrealisedRoePcnt":0,
/     "simpleQty":0,"simpleCost":0,"simpleValue":0,"simplePnl":0,"simplePnlPcnt":0,"avgCostPrice":null,
/     "avgEntryPrice":null,"breakEvenPrice":null,"marginCallPrice":null,"liquidationPrice":null,"bankruptPrice":null,
/     "timestamp":"2017-04-04T22:16:38.547Z"
/    }]}

Introduction
BitMEX enforces the following Trading Rules to encourage efficient trading strategies and incentivise behaviours that improve the executable liquidity of the market. Even though these rules apply to all users of the platform, customers who trade predominantly from the website are unlikely to be affected by them due to the thresholds within each rule. We monitor for these, and other abusive trading behaviours closely and, pursuant to our Terms of Service, reserve the right to restrict your use of our services, including the closure of your account, at any time.

Quote Fill Ratio Threshold
The Quote Fill Ratio (QFR) Threshold aims to discourage use of strategies that submit quotes to the market without the intent to trade and therefore further strengthen the quality of liquidity on the platform.

Accounts on the platform making over 2000 quotes a day will need to maintain a 7 day moving average QFR above a minimum QFR threshold. Violations of this rule will result in email warnings and an eventual API ban.

Definition of Quote Fill Ratio (QFR)
We define Quote Fill Ratio (QFR) as the proportion of quotes filled per quotes submitted to the platform per calendar day. A quote submitted is any individual order sent to the market. A quote filled is an order that has been filled for any amount. QFR is calculated as follows:

QFR = (# quotes filled in time period T / # quotes submitted in time period T)
Where T = 24 hours

Quote Fill Ratio example
A market maker quotes a two-sided price on XBTUSD and submits one bulk new order request containing 4 bids and 4 asks which rest in the book at different price levels. The market maker then receives a price signal and submits a bulk amend request to change the prices of the 4 bids in the market down by one tick each.

Another market participant submits a large market buy order which lifts 3 of the asks that the market maker has resting in the book. There is no more quoting or trading for these two participants for the remainder of the day.

The maker’s QFR for the day is calculated as follows:



# quotes filled = 3
# quotes submitted = 12
QFR = 3/12 = 25%
The taker’s QFR for the day is calculated as follows:

# quotes filled = 1
# quotes submitted = 1
QFR = 1/1 = 100%
Minimum QFR Threshold
QFR must be kept above 0.1% on a 7 day moving average.

We may update the minimum QFR threshold and / or mechanism from time to time. Advanced notice of any changes will be published via the API Announcements section of the blog to ensure users have ample time to adjust their trading behaviour.

Thank you for contacting support. Once a position is closed, the realized PnL is instantly applied to the account balance for the user to use/trade. 

You can learn about how PNL is calculated on our exchange by consulting the PNL Guide:
https://www.bitmex.com/app/pnlGuide

Please note that the balance on your wallet page is a 24-hour account of all realised PNL on a specific contract for a 24 hour period between 12:00 UTC and 12:00 the next day. This figure does not relate to a single trade, unless you have only made one trade during that period:
https://www.bitmex.com/app/wallet

When order is partially filled only filled quantity would be charged from account balance.
​Gross Open Premium will be included in the initial margin.

Whenever a reduce order takes place (e.g. you have made several sell orders to begin your position then partially close with a buy order) your position value is recalculated using the following equation: 

current_value * (new_quantity / old_quantity) = new_value

Let us know if you have further questions. 

Hi Bradky,

The exact Average Entry Price of your position is calculated using the following steps:

1. The execCost of each entry order is added together. For our XBTUSD contracts, execCost is calculated as round(1e8/price) * number of contracts.
2. The total execCost is divided by the total number of entry contracts. This is the 'average satoshi price' of the position.
3. For long positions, floor() the average satoshi price. For short position, round() the average satoshi price.
4. For our XBTUSD contracts, divide 1e8 by the average satoshi price to get the average USD price. This is then rounded to 4 decimal places for the API, and rounded to the nearest tick for the front-end.

Note that the easiest way to know the exact average entry price of your position is to retrieve from the engine via the API.

Additional rules apply when reduce orders have taken place and when the front-end chooses a price to display. If you need further help, please let us know.

Regards,
Chad
BitMEX

If the price is far above the mark price you have to pay the difference called gross open premium, this is the reason for the cost being higher for the Sell/Short.
The calculation for Gross Open Premium is as follows:
Math.abs((newOpenBuyPremium * net(currentQty, newOpenBuyQty) / newOpenBuyQty) || 0) +
Math.abs((newOpenSellPremium * net(-currentQty, newOpenSellQty) / newOpenSellQty) || 0);
Where:
Math.abs = absolute value
|| 0 means, if net does not return a value, default to 0

GrossOpenPremium only applies to sell orders when the mark price is above the limit price, and buy orders when the mark price is below the limit price.

Please note that these equations are close estimates and we do not give out the full equations used by the engine. You can use the calculator tool to estimate your margin requirement as well.

Regards,
Sen

Regards,
