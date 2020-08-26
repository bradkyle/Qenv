





isignum:1;



buyCost+: ($[isinverse;floor[1e8%price];1e8%price] * abs[qty]); 
buyPremium+:premium;
buyQty+: qty;

.account.avgPrice[isignum;buyCost;buy];

grossOpenPremium:(
        (abs[(buyPremium * (sum[account[`netLongPosition], buyQty]%newOpenBuyOrderQty))] | 0) + 
        (abs[(sellPremium * (sum[neg[account[`netShortPosition]], buyQty]%newOpenSellOrderQty))] | 0)
    );

// checks if an account has enough balance to place an order!