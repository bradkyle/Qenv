






buyCost+: ($[isinverse;floor[1e8%price];1e8%price] * abs[qty]); 
buyPremium+:premium;
buyQty+: qty;

.account.avgPrice[];

grossOpenPremium:(
        (abs[(buyPremium * (sum[account[`netLongPosition], buyQty]%newOpenBuyOrderQty))] | 0) + 
        (abs[(sellPremium * (sum[neg[account[`netShortPosition]], buyQty]%newOpenSellOrderQty))] | 0)
    );