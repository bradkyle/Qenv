
// Derives the sortino ratio for a given account balance/returns vector
// with respect to a given minimum acct return.
/  @param asset     (Numeric) The step wise returns/asset balance
/  @param minAccRet (Inventory) The minimum expected return per period.
/  @return          (Numeric) The resultant sortino ratio
.state.rew.sortinoRatio:{[asset;minAccRet] 
    excessRet:-1*minAccRet-(100*1_asset-prev[asset])%1_asset;
    100*avg[excessRet]% sqrt sum[(excessRet*0>excessRet) xexp 2]%count[excessRet]
 };

// TODO lookback vs windowsize
// TODO use reward based upon realized pnl with respect to balance
.state.rew.GetRewards  :{[step;windowsize;aIds] // TODO configurable window size
    // todo fill
    n:count[aIds]; // todo improve
    a:select reward:0^.state.rew.sortinoRatio[0^1_deltas[balance];0] by accountId from 
            0!(select[neg[windowsize]] by 1 xbar `minute$time, 
                    accountId from .state.AccountEventHistory where time 
                    within (max[time]-(`minute$windowsize);max[time]),accountId in aIds); 
    0^lj[([accountId:aIds] reward:n#0f);a]
    };
