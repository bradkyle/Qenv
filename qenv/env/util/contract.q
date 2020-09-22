

// Liquidation price utils
// -------------------------------------------------->
// Given the rules provided by the instrument and the account's current
// state this function will derive the approximate price point at which 
// the account will be liquidated.

.util.contract.inverse.LiquidationPrice       :{
    sB:iB[`isignum]; // TODO check
    sum[(a`balance),((iB;iL;iS)`maintMarginReq)]
    x:prd[iB`isignum`amt];
    :(prd[x,iB[`avgPrice]]
    -((-/)prd[(iL;iS)`amt`avgPrice]))
        %(sum[prd[(iB;iL;iS)`amt`mmr]]-sum[x;(-/)(iB;iS)]);
    };

.util.contract.linear.LiquidationPrice       :{
    sB:iB[`isignum]; // TODO check
    sum[(a`balance),((iB;iL;iS)`maintMarginReq)]
    x:prd[iB`isignum`amt];
    :(prd[x,iB[`avgPrice]]
    -((-/)prd[(iL;iS)`amt`avgPrice]))
        %(sum[prd[(iB;iL;iS)`amt`mmr]]-sum[x;(-/)(iB;iS)]);
    };
 
.util.contract.quanto.LiquidationPrice       :{[a;iB;iL;iS;ins]
    
    };

/ / // Given the rules provided by the instrument and the account's current
/ / // state this function will derive the price point at which the account
/ / // will become bankrupt.
/ .inverse.account.BankruptcyPrice        :{[account;iB;iL;iS;ins] // TODO check
/     x:prd[iB`isignum`amt];
/     :(prd[x,iB[`avgPrice]]
/     -((-/)prd[(iL;iS)`amt`avgPrice]))
/         %(sum[prd[(iB;iL;iS)`amt`imr]]-sum[x;(-/)(iB;iS)]);
/     };

