
// Derives the sortino ratio for a given account balance/returns vector
// with respect to a given minimum acct return.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.state.rewards.sortinoRatio:{[asset;minAccRet] 
 excessRet:-1*minAccRet-(100*1_asset-prev[asset])%1_asset;
 100*avg[excessRet]% sqrt sum[(excessRet*0>excessRet) xexp 2]%count[excessRet]
 };


.state.rewards.GetRewards  :{[aids; windowsize; step] // TODO configurable window size
    r:select 
        returns:0^1_deltas[realizedPnl] 
        by accountId 
        from select[-100] 
            last realizedPnl 
            by 1 xbar `minute$time, 
            accountId from .state.InventoryEventHistory where time within (max[time]-(`minute$windowsize);max[time]),accountId in aids; // TODO window size

    :update sortino:sortinoRatio'[returns;0] from r;

    };
