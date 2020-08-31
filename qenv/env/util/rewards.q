


// TODO make sure that this isn't applying sortino ratio to the realized pnl as opposed to the balance
sortinoRatio:{[asset;minAccRet] 
 excessRet:-1*minAccRet-(100*1_asset-prev[asset])%1_asset;
 100*avg[excessRet]% sqrt sum[(excessRet*0>excessRet) xexp 2]%count[excessRet]
 };
