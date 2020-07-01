

sortinoRatio:{[asset;minAccRet] 
 excessRet:-1*minAccRet-(100*1_asset-prev[asset])%1_asset;
 100*avg[excessRet]% sqrt sum[(excessRet*0>excessRet) xexp 2]%count[excessRet]}

sortinoRatio[select deltas last amount by (`date$time) + 1 xbar `minute$time from account where time >= `hour$24, 0]