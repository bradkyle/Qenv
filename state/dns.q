

.state.dns.GetDones  :{[step;lookback;aIds] // TODO configurable window size
    :flip[`accountId`dones!(aIds;count[aIds]#0b)]
    };
