Initial Margin (IM)
Buy/Long order IM requirement: [Contract value*Min (Buy/Long limit order price, best ask price)]/Leverage. Order will reserve a two-way (fee to open + fee to close) taker fee of 0.075%. Actual trading fees will be calculated based on the nature of the order and the execution price.

Sell/Short order IM requirement: [Contract value*Max (Sell/Short limit order, best bid price)]/Leverage. Order will reserve a two-way (fee to open + fee to close) taker fee of 0.075%. Actual trading fees will be calculated based on the nature of the order and the execution price.

If an order does not increase the size of the existing position, no IM will be posted.

If a trader has a concurrent Buy and Sell position/order, the system will take Max [Buy order IM (X), Sell order IM (Y)] as the account IM. Assuming X=200, Y=150, then the account IM will be 200. If the trader places another sell order with order cost less than 50, no extra margin is required. However, if the additional sell order cost is 70, causing Y=220, then it will require additional 20 (220-200) margin to place the additional sell order.