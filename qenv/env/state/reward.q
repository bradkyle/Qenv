

GetRewards  :{[aids; windowsize; step] // TODO configurable window size
    r:select 
        returns:0^1_deltas[realizedPnl] 
        by accountId 
        from select[-100] 
            last realizedPnl 
            by 1 xbar `minute$time, 
            accountId from .state.InventoryEventHistory where time within (max[time]-(`minute$windowsize);max[time]),accountId in aids; // TODO window size

    :update sortino:sortinoRatio'[returns;0] from r;

    };
