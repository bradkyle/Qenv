
Liquidation
Avatar Binance
1 year ago
Binance uses Mark Price to avoid unnecessary liquidations and to combat market manipulation. 

Risk and Leverage are adjusted based on the customer’s total exposure; the larger the total position, the higher the required margin, and the lower the leverage. A liquidation is triggered when 

Collateral = Initial Collateral + Realized PnL + Unrealized PnL < Maintenance Margin

On liquidation, all open orders are immediately cancelled. All traders will be subject to the same liquidation protocols referred to as “Smart Liquidation.” Binance avoids full clear of the user’s position whenever possible, and a precise example is listed below. For any traders that are cleared via forced liquidation and not by an order issued from the trader, a liquidation fee (0.3% on BTC/USDT perpetual contract; 0.5% on all other perpetual contracts) will be charged on the amount liquidated only (not the notional value of the position).

All orders will be issued at the bankruptcy price on the market. If the position cannot be fully closed, the insurance fund and / or counterparty-liquidation will take effect. The insurance fund will accumulate USDT reserves based on liquidations above the bankruptcy price from the liquidation fee rate.

It is important to mention that, as a general rule, users who hold relatively smaller positions that enter liquidation will almost always be fully liquidated. Larger users will see a smaller percentage of their accounts liquidated compared to smaller users. This is because maintenance margin is based around a user’s position size, and not their leverage selection. As a result, for smaller users, the effective maintenance margin is lower than the liquidation fee rate, so they are already bankrupt when first entering liquidation, regardless of the final price when clearing.

Note that all orders for liquidations are Immediate or Cancel orders. The order will fill as much as possible, and cancel the rest. This is different from a Fill or Kill order which will only execute if the order can be completely executed, and will be cancelled, if otherwise. The remaining positions will be either assigned to the insurance fund or counterparty liquidated.

For all traders, the system will first cancel all open orders, then attempt to reduce the trader’s margin usage with one *single* large Immediate or Cancel order without fully liquidating the trader.  If the trader is margin compliant after the order and liquidation fee, the liquidation event is over. If the trader is still margin deficient, the trader’s position will be closed down at the bankruptcy price and the insurance fund will take over the position, and the trader is declared bankrupt. A portion of the remaining collateral (if any) will go to the insurance fund. If an account becomes bankrupt (negative wallet balance), the insurance fund will pay out to bring the account's balance back to 0.

 

About Liquidation Price

Liquidation occurs when Mark Price hits the liquidation price of a position.Traders are advised to pay close attention to the movement of Mark Price and the liquidation price to avoid an open position being liquidated.

In hedge mode, both long and short positions of the same contract are sharing the same liquidation price in cross margin mode.

1.png

If both long and short positions of the same contract are in isolated mode, the positions will have two different liquidation prices depending on the margin allocated to the positions.

2.png

Binance allows for highly leveraged trading by using a sophisticated risk engine and liquidation model. The liquidation model might be intricate. Alternatively, you could use the built-in calculator to calculate the liquidation price.

Liquidation Price of Contract 1 (“LP1”) under cross margin mode:

mceclip0.png

Where

WB

Wallet Balance

TMM1

Total Maintenance Margin of Other Contracts (except Contract 1)

UPNL1

Total Unrealized PnL of Other Contracts (except Contract 1)

cumB

Maintenance Amount of One-Way Mode Contract 1

cumL

Maintenance Amount of Long Contract 1 (Hedge Mode)

cumS

Maintenance Amount of Short Contract 1 (Hedge Mode)

Side1BOTH

Direction of Contract 1 (One Way Mode); “1” for long position, “-1” for short position 

Position1BOTH

Size of Position for Contract 1 (One Way Mode); Absolute value regardless long/short

EP1BOTH

Entry Price of Contract 1 (One Way Mode)

Position1LONG

Size of Long Position (Hedge Mode); Absolute value regardless long/short

EP1LONG

Entry Price of Long Position (Hedge Mode); Absolute value regardless long/short

Position1SHORT

Size of Short Position (Hedge Mode); Absolute value regardless long/short

EP1SHORT

Entry Price of Short Position (Hedge Mode); Absolute value regardless long/short

MMB

Maintenance Margin Rate of One-Way Mode Contract

MML

Maintenance Margin Rate of Long Contract (Hedge Mode)

MMS

Maintenance Margin Rate of Short Contract (Hedge Mode)

Further Details:

1.Maintenance Amount

You can find the “Maintenance Amount” from the table below with the position value of Contract 𝑥. For example, if the position of BTC/USDT Contract is 264,000 USDT, then the maintenance amount would be 1,300 USDT. 

Maintenance Amount formula 

= [ Floor of Position Bracket on Level n * difference between Maintenance Margin Rate on Level n and Maintenance Margin Rate on Level n-1) ] + Maintenance Amount on Level n-1

For example, the Maintenance Amount on Level 5

= 5,000,000 USDT * (5%  -2.5%) +16,300 USDT

= 141,300 USDT

4.png

2.Maintenance Margin Rate 

You can find the “Maintenance Margin Rate” from the table below with the position value of Contract 𝑥. For example, if the position of BTC/USDT Contract is 264,000 USDT, then the maintenance margin rate would be 1% (or 0.01).

Important Note:

If the notional value of a position (post liquidation), is not within the range of the current maintenance margin bracket, a new liquidation price will be calculated based on a level of position post liquidation. 

5.png

Example:

6.png

Liquidation Price of BTC/USDT perpetual contract

To calculate the liquidation price of BTC/USDT perpetual contract, the parameters are as follows:

WB

10.72

TMM1

= 200*1*0.65% = 1.3

UPNL1

0.47

cumB

0

Side1BOTH

-1

Position1BOTH

0.005

EP1BOTH

9451.53

MMB

0.004


Liquidation Price of BTC/USDT perpetual contract

=[10.72 - 1.3 + 0.47 + 0 -(-1*0.005*9,451.53)]/[(0.005*0.004) - (-1*0.005)]

= 11,383.99 USDT (difference due to rounding off)

 

Liquidation Price of ETH/USDT perpetual contract

To calculate the liquidation price of ETH/USDT perpetual contract, the parameters are as follows:

WB

10.72

TMM1

= 9,462.81*0.005*0.4% = 0.19

UPNL1

-0.06

cumB

0

Side1BOTH

1

Position1BOTH

1

EP1BOTH

199.53

MMB

0.0065

 

Liquidation Price of ETH/USDT perpetual contract

=[10.72 - 0.19 - 0.06 + 0 -(1*1*199.53)]/[(1*0.0065) - (1*1)]

= 190.29 USDT (difference due to rounding off)

Differences Between Spot Trading and Futures Trading
Avatar Binance
1 year ago
This section outlines key differences between Spot trading and Futures trading, and introduces basic concepts to help you read deeper into futures contract.

In a futures market, prices on the exchange are not ‘settled’ instantly, unlike in a traditional spot market. Instead, two counterparties will make a trade on the contract, with settlement on a future date (when the position is liquidated).

Important note: Due to how the futures market calculates unrealized profit and loss, a futures market does not allow traders to directly buy or sell the commodity; instead, they are buying a contract representation of the commodity, which will be settled in the future.

There are further differences between a perpetual futures market and a traditional futures market

To open a new trade in a futures exchange, there will be margin checks against collateral. There are two types of margin:

Initial Margin: In order to open a new position, your collateral needs to be greater than the Initial Margin.

Maintenance Margin: If your collateral + unrealized profit and loss fall below your maintenance margin, you will be auto liquidated. This results in penalties and additional fees. You can liquidate yourself before this point to avoid being auto liquidated.

Due to leverage, it is possible to hedge out spot or holding risk with relatively small capital outlays in the futures market. For example, if you are holding 1000 USDT worth of BTC, you can deposit a much smaller (50 USDT) collateral into the futures market, and short 1000 USDT of BTC to fully hedge out the positional risk.

Note that futures prices are different from spot market prices, because of carrying costs and carrying return. Like many futures markets, Binance uses a system to encourage the futures market to converge to the ‘mark price’ via funding rates. While this will encourage long-term convergence of prices between spot and futures for the BTC/USDT contract, in the short term there may be periods of relatively large price differences.

The premier futures market, Chicago Mercantile Exchange Group (CME Group), provides a traditional futures contract. But modern exchanges are moving toward the perpetual contract model. 

Differences Between a Perpetual Contract and a Traditional Futures Contract
Avatar Binance
1 year ago
A Perpetual Contract is similar to a traditional Futures Contract, but the key difference is: There is no expiration or settlement of Perpetual Contracts.

Consider a Futures Contract for a physical commodity, like wheat (or gold), as an example. In traditional futures markets, these contracts are marked for delivery of the wheat - in other words, the wheat should be delivered according to the contract when the futures contract expires. As such, someone is physically holding the wheat, which results in ‘carrying costs’ for the contract. Additionally, the price for wheat may differ depending on how far apart the current time and the future settlement time for the contract is. As this gap widens, the contract’s carrying costs increase, the potential future price becomes more uncertain, and the potential price gap between the Spot and traditional Futures markets grows larger.

The Perpetual Contract is an attempt to take advantage of a Futures Contract - specifically, the non-delivery of the actual commodity - while mimicking the behavior of the Spot market in order to reduce the price gap between the Futures Price and the Mark Price. This is a marked improvement compared to the traditional Futures Contract, which can have prolonged or even permanent differences versus the Spot Price.

In order to ensure long-term convergence between the Perpetual Contract and the Mark Price, we use Funding. There are several key concepts that traders should be aware of in a Perpetual Contract:

Mark Price: To avoid market manipulations and to ensure that the Perpetual Contract is price-matched to the Spot Price, we utilize Mark Price to calculate unrealized Profit and Loss for all traders.

Initial and Maintenance Margin: Traders should be extremely familiar with both Initial and Maintenance Margin levels, in particular, the Maintenance Margin, where auto-liquidation will occur. It is strongly recommended that traders liquidate their positions above the Maintenance Margin to avoid higher fees from auto-liquidations.

Funding: Payments between all longs and shorts in the Perpetual Futures Market. The Funding Rate determines which party is the payer and the payee. If the rate is positive, longs pay short; If negative, shorts pay longs.

Risk: Unlike Spot Markets, Futures Markets allow traders to place large orders that are not fully covered by their initial collateral. This is known as ‘margin trading.’ As markets have become more technologically advanced, the amount of available margin has increased. 、

Leverage and Margin
Avatar Binance
1 year ago
On Binance Futures, traders can trade with leverage between 20-125x on our crypto perpetual contracts. The maximum amount of leverage available for users depends on the notional value of their position. Generally, the larger the position, the lower the leverage allowed. Thus, initial margin deposits are calculated using the leverage selected by the trader.

mceclip0.png

Note that the trader will first select his leverage (and fulfill its initial margin requirement), and then will open his positions. If the trader makes no selection on leverage, it will be set at 20x by default. The higher the leverage, the smaller the notional size the trader will have access to. The lower the leverage, the higher the notional size the trader can open.

The system will display the maximum allowable position size at different tiers of leverage as shown below.

mceclip1.png

Maintenance margin calculations are done via a “Tax Bracket” setup. This means that the maintenance margin is always calculated the same way, regardless of what leverage the trader selects. Moving from one bracket to another will not cause the earlier bracket to change its leverage. 

It is important to note that the maintenance margin required, and the resulting liquidation price is far more favorable to the trader than would be normally expected by the initial margin. In other words, in virtually all cases, the maintenance margin is less than half the initial margin, and the resulting liquidation price is much more favorable than would be the case if the maintenance margin was equal to 50% of the initial margin, as is the case in most exchanges. 

It is very important to note that the maintenance margin is *always less* than 50% of the initial margin, and is thus very beneficial to the trader. Again, as noted earlier, it is highly recommended for the trader to liquidate positions before the collateral falls below the Maintenance Margin to avoid auto-liquidation. 

Mark Price and Unrealized PnL
Avatar Binance
1 year ago
The calculation of Mark Price is intricately linked to the Funding Rate and vice versa. It is highly recommended to read both sections to get a full picture of how the system works.

As Unrealized PnL is the primary driver of liquidations, and as the Perpetual Contract allows for highly leveraged (up to 125x) positions, it is important to ensure that the Unrealized PnL calculation is accurate to avoid unnecessary liquidations. The underlying contract for the Perpetual Contract is the ‘true’ value of the Contract, and an average of the prices on the major markets constitutes the “Index Price” which is the primary component of Mark Price.

The Index Price is a bucket of prices from the major Spot Market Exchanges, weighted by their relative volume. The Exchanges used are: 

- Bitfinex 
- Binance 
- Huobi 
- OKEx 
- Bittrex
- HitBTC

There are additional protections to avoid poor market performance during outages of Spot Exchanges or during connectivity problems. These protections are listed below:

Single price source deviation: When the latest price of a certain exchange deviates more than 5% from the median price of all price sources, the exchange weight will be set to zero for weighting purposes.
Multi price source deviation: If more than 1 exchange shows greater than 5% deviation, the median price of all price sources will be used as the index value instead of the weighted average.
Exchange Connectivity Problem: If we can’t access the data feed for exchange and this exchange has trades updated in the last 10 seconds, we can take price data from the last result and use it for index calculation.
If one exchange has no updates for 10 seconds, the weight of this exchange will be zero when calculating the weighted average.

Now that we’ve computed the Index Price, which can be considered as the “Spot Price”, we can move forward in calculating the Mark Price which is used for all Unrealized PnL calculations. Note that Realized PnL is still based on the actual executed market prices.

As introduced in the last section, Funding occurs every 8 hours. Funding Rate is calculated at that time, and the Funding Rate in the formula is the most recent prior Funding Rate.

Basis=FundingRate×(Time Until Funding /8)
Mark Price=Index Price∗(1+Basis)

As an example: 

- Funding Rate = 0.03%
- Time until funding = 4
- Index Price = 10,000

Basis=Funding Rate×(Time Until Funding/8)=0.03%×4/8=0.015%
Mark Price=Index Price×(1+Basis)=10,000×(1+0.015%)=10001.5

Mark Price is a better estimate of the ‘true’ value of the contract, compared to Perpetual Futures prices which can be more volatile in the short term. We use this price to prevent unnecessary liquidations for traders and to discourage any market manipulations by poor actors.

Unrealized PnL is thus calculated as (all values in USDT):

Net Negative Position: UnrealizedPnL= (Entry Price−MarkPrice)×S
Net Positive Position: UnrealizedPnL=(MarkPrice−InitialBuyPrice)×Position
Total Collateral for Margin and Liquidation purposes: Collateral=InitialCollateral+RealizedPnL+UnrealizedPnL
The maximum amount of collateral can be withdrawn from the account so long as collateral > (initial margin + borrowed amount) . 

Funding Rate
Avatar Binance
1 year ago
In this section, we define the Funding Rate, its constituent components, and how it is used.

Purpose of the Funding Rate

The Funding Rate is used essentially to force convergence of prices between the Perpetual Futures Market and the actual underlying commodity. 


Why is the Funding Rate Important?

In traditional futures contracts, settlements occur on a monthly or quarterly basis - depending on the contract specifications. At settlement, the contract price converges with the spot price, and all open positions expire. Perpetual contracts are widely offered by crypto-derivative exchanges, and it is designed similar to a traditional futures contract. Albeit, perpetual contracts offer a key difference. 

Unlike conventional futures, traders can hold positions without an expiry date and do not need to keep track of various delivery months. For instance, a trader can keep a short position to perpetuity unless he gets liquidated. As a result, trading perpetual contracts are very similar to trading pairs on the spot market. 

In short, perpetual contracts never settle in the traditional sense. As such, crypto-exchanges created a mechanism to ensure that contract prices correspond to the index. This is known as Funding Rate.


What is the Funding Rate?

Funding rates are periodic payments either to traders that are long or short based on the difference between perpetual contract markets and spot prices. When the market is bullish, the funding rate is positive and long traders pay short traders. When the market is bearish, the funding rate is negative and short traders pay long traders.

Binance takes no fees for Funding Rate transfers; these are directly between traders.

On Binance Futures, Funding occurs every 8 hours at 00:00 UTC; 08:00 UTC and 16:00 UTC. Traders are only liable for funding payments in either direction if they have open positions at the pre-specified funding times. If traders do not have a position, they are not liable for any funding. If you close your position prior to the funding exchange then you will not pay or receive funding.

Important Note: There is up to 15 seconds of delay in the actual charging time of the funding fee. For example, when User A opens a position at 08:00:05 UTC, User A would be liable for the funding fee (either paying or receiving the funding fee).

On Binance Futures platform, funding rates (highlighted in red) and a countdown to the next funding (highlighted in white) are displayed as such:
mceclip0.png

How to Calculate the Funding Amount?

Funding is calculated as:

Funding Amount=Nominal Value of Positions* ×Funding Rate
*Nominal Value of Positions = Mark Price x Size of a Contract


What Determines the Funding Rate?

There are two components to the Funding Rate: the Interest Rate and the Premium. The Premium particular is why the price of the Perpetual Contract will converge with the price of the underlying instrument.

Binance uses a flat interest rate component, with the assumption that holding cash equivalent returns a higher interest than BTC equivalent. The difference is stipulated to be 0.03% per day by default (0.01% per funding interval)* and may change depending on market conditions such as the Federal Funds Rate. 

* The interest rate of LINK/USDT, LTC/USDT and BNB/USDT perpetual contracts is 0%.

There may exist a significant difference in price between the Perpetual Contract and the Mark Price. In such instances, a Premium Index will be used to enforce price convergence between the two markets. It is calculated separately for every instrument, and the formula is below:

Premium Index(P)=Max(0, Impact Bid Price−Mark Price)−Max(0, Mark Price−Impact Ask Price)/Spot Price
Impact Bid Price=The price to Buy the Notional Impact
Impact Ask Price=The price to Sell the Notional Impact

The Notional Impact is the amount in USDT available to trade with 200 USDT worth of margin; at default levels, this is 4,000 USDT.

Binance calculates the Premium Index every second, and takes a Time-weighted average across all indices to the Funding Time.

The Funding Rate formula itself is:
Funding Rate (F) = Premium Index (P) + clamp(0.01% - Premium Index (P), 0.05%, -0.05%)

In other words, as long as the Premium Index is between -0.04% to 0.06%, the Funding Rate will equal 0.01% (the interest rate).

If (Interest Rate (I) - Premium Index (P)) is within +/-0.05% then F = P + (I - P) = I. In other words, the Funding Rate will be equal to the Interest Rate.

Counterparty Liquidation
Avatar Binance
1 year ago
Counterparty Liquidation is the final step taken only when the Insurance Fund cannot accept the bankrupt client’s positions. Binance takes every possible step to avoid counterparty liquidation, and has several features such as Immediate or Cancel Limit Orders (see definition of Immediate or Cancel Order) to minimize the potential impact of any counterparty liquidation when it does occur. Unfortunately, due to the volatility in the Crypto markets, and the high leverage offered to clients, it is not possible to fully avoid this possibility. In order to provide the best possible client experience, we are striving to keep counterparty liquidations to an absolute minimum.

As a trader, your position is at risk of counterparty-liquidation based on an indicator with your priority in the queue. Below is an example of the indicators, from lowest priority to highest priority.

blobid0.png

When there is a counterparty-liquidation, a notice is immediately sent to the affected client. Clients will be free to re-enter at any time.

The trader’s position in the priority ranking is calculated by both profit and leverage; the formula is presented at the end of this page. More profitable and higher leveraged traders will be liquidated first. Specifically, traders will be ranked by their margin ratio and unrealized PnL as a percentage of their collateral. The precise rank is known as “LeveragePnL” defined as unrealized pnl/collateral multiplied by the margin ratio. The exact formulation is at the end.

From there, traders will be ranked by the LeveragePnlQuantile term; traders at imminent risk of being automatically liquidated will see the appropriate indicator in their UI. If the liquidation occurs, the trader will be sent a notice with the amount and liquidation price. The trader’s positions will be closed out at bankruptcy price of the initial liquidated order. Any open orders will be cancelled. Once the liquidation process is completed, the trader will be able to re-enter immediately.

Note: Bankruptcy price might be out of contract market price range. It is highly recommended that the trader pays attention to ADL indicator to avoid from being deleveraged.

Calculation of Liquidation Priority Ranking
Pnl Percent=max(0,Unrealized Profit)/max(1,Wallet Balance)

If (Wallet Balance+Unrealized Profit)≤0, then Margin Ratio=0

If (Wallet Balance+Unrealized Profit)＞0, then Margin Ratio=Maintenance Margin/(Wallet Balance+Unrealized Profit)

Leverage Pnl=Pnl Percent×Margin Ratio Leverage Pnl=Pnl Percent×Margin Ratio

Leverage Pnl Quantile=rank(user.Leverage Pnl)/Total User Count

The Insurance Fund is designed to use the collateral from fees on non-bankrupt clients to cover losses when the client accounts go below 0 in value. The primary purpose of the Insurance Fund is to limit the occurrences of counterparty-liquidation.

In the cases where a trader in liquidation (defined as collateral < maintenance margin) has less than 0 USDT after all liquidation or is otherwise unable to liquidate positions, the trader is bankrupt, and Binance will need to take over remaining positions.
In the vast majority of these cases, Binance will use the insurance fund to take the positions, and offload them onto the market slowly. The insurance fund will collect liquidation fees from clients that do not result in client bankruptcy. If the insurance fund is unable to accept positions from the liquidations, then the counterparty-liquidation will occur.
The Insurance Fund will be subject to the following rules:

The fund will have a maximum net notional position check. The fund will not be allowed to exceed a predefined position notional on the market; by default, this is 100% the size of the insurance fund. Any positions that would increase beyond the max notional will be subject to counterparty-liquidation. The insurance fund will offload positions according to a preset algorithm. All events that would normally require intervention by the insurance fund will instead go into counterparty-liquidation before the fund could take positions.

All perpetual futures contracts on Binance Futures share a common insurance fund, with the exception of BTCUSDT and ETHUSDT, that have their own insurance fund.

Now, you can access the insurance fund balance (USDT) of BTCUSDT, ETHUSDT, and all other perpetual contracts. 

Click “Information” and go to “Funding Rate History”. Alternatively, you can directly visit https://www.binance.com/en/futures/funding-history/2

Fellow Binancians,

On 2019/08/02 0:00 AM (UTC), the calculation mechanism used to record daily BNB balance will change from being recorded in a snapshot at 0:00 AM (UTC) each day, to Daily Average BNB Balance (including BNB held in normal Binance Accounts, Margin Accounts, Sub-Accounts, Binance Lending Products, Binance Fiat Accounts, Futures wallet Accounts and Binance Card Wallet Accounts).

Total Daily Average BNB Balance = Daily Average Spot Account Balance + Daily Average Margin Account Balance + Daily Average Sub-accounts Balance + Daily Average Binance Lending Account Balance + Daily Average Binance Fiat Account Balance + Daily Average Futures wallet Balance + Daily Binance Card Wallet Balance.

Note:

Average Spot Account Balance is calculated using the sum of the hourly snapshots of  BNB balance in the spot account in a day divided by 24 (hours)
Daily Average Sub-account Balance is calculated as the sum of the hourly snapshots of the BNB balance in the sub-account in a day divided by 24 (hours)
The sum of the hourly snapshots of the Net BNB balance（Net BNB Balance = BNB Total Balance - Borrowed BNB - BNB Interest） in both master and sub-account margin accounts in a day divided by 24 (hours).
Daily Average Binance Lending Account Balance is calculated as the sum of the hourly snapshots of the BNB balance in the Binance Lending Account in a day divided by 24 (hours)
Daily Average Binance Fiat Account Balance is calculated as the sum of the hourly snapshots of the BNB balance in the Binance Fiat Account in a day divided by 24 (hours).
Daily Average Binance Futures Wallet Balance is calculated as the sum of the hourly snapshots of the BNB balance in the Binance Futures Account in a day divided by 24 (hours).
Daily Average Binance Card Wallet Balance is calculated as the sum of the hourly snapshots of the BNB balance in the Binance Card Wallet Account in a day divided by 24 (hours).
This update to the BNB balance calculation mechanism will impact the following aspects of the Binance Ecosystem:

Launchpad’s BNB holding calculation
Trading fee VIP rating system
Referral Program
Please note that：

Hourly snapshots will occur at random times
Pending orders are included in the balance calculation
Positions prior to 2019/08/02 will be calculated using the original mechanism
Thanks for your support!

Binance uses Mark Price to avoid unnecessary liquidations and to combat market manipulation. 

Risk and Leverage are adjusted based on the customer’s total exposure; the larger the total position, the higher the required margin, and the lower the leverage. A liquidation is triggered when 

Collateral = Initial Collateral + Realized PnL + Unrealized PnL < Maintenance Margin

On liquidation, all open orders are immediately cancelled. All traders will be subject to the same liquidation protocols referred to as “Smart Liquidation.” Binance avoids full clear of the user’s position whenever possible, and a precise example is listed below. For any traders that are cleared via forced liquidation and not by an order issued from the trader, a liquidation fee (0.3% on BTC/USDT perpetual contract; 0.5% on 75x futures contracts and 0.75% on 50x futures contracts) will be charged on the amount liquidated only (not the notional value of the position).

All orders will be issued at the bankruptcy price on the market. If the position cannot be fully closed, the insurance fund and / or counterparty-liquidation will take effect. The insurance fund will accumulate USDT reserves based on liquidations above the bankruptcy price from the liquidation fee rate.

It is important to mention that, as a general rule, users who hold relatively smaller positions that enter liquidation will almost always be fully liquidated. Larger users will see a smaller percentage of their accounts liquidated compared to smaller users. This is because maintenance margin is based around a user’s position size, and not their leverage selection. As a result, for smaller users, the effective maintenance margin is lower than the liquidation fee rate, so they are already bankrupt when first entering liquidation, regardless of the final price when clearing.

Note that all orders for liquidations are Immediate or Cancel orders. The order will fill as much as possible, and cancel the rest. This is different from a Fill or Kill order which will only execute if the order can be completely executed, and will be cancelled, if otherwise. The remaining positions will be either assigned to the insurance fund or counterparty liquidated.

For all traders, the system will first cancel all open orders, then attempt to reduce the trader’s margin usage with one *single* large Immediate or Cancel order without fully liquidating the trader.  If the trader is margin compliant after the order and liquidation fee, the liquidation event is over. If the trader is still margin deficient, the trader’s position will be closed down at the bankruptcy price and the insurance fund will take over the position, and the trader is declared bankrupt. A portion of the remaining collateral (if any) will go to the insurance fund. If an account becomes bankrupt (negative wallet balance), the insurance fund will pay out to bring the account's balance back to 0.
// Fee schedule

// derive maintenence margin


// derive unrealized pnl


// derive realized pnl


// derive liquidation price


// derive bankruptcy price


// derive breakeven price


// exec fill


// update order margin


// liquidation