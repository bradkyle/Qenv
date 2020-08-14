


ProcessTrade    :{[instrumentId;side;fillQty;reduceOnly;isAgent;accountId;time]

// update noffsets:Clip[offset-rp] from select rp, PadM[offset] from lt
   
// select from (select raze[pprice], raze[porderId], raze[noffset], raze[nleaves] from lt) where porderId in (exec raze[orderId] from lt)
// select a:(sums'[poffset]<=rp)-(shft<=rp), b:(poffset<=rp)and(shft<=rp) from lt
 
    nonAgentQtys:   :{

        };
    
    };