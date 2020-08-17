

// select dst:qtyDist[last maxN;last numLvls;pleaves;poffset;shft;qty;rp] from lt


deriveFills :{
        

    };

deriveOrderUpdates :{
    oupd:();
    };

// Derives transitionary state from 
deriveNextStateFromTrade :{
    lt: 

    }


nonAgentQtys:{[maxN;poffset;shft;qtys]
    maxNl:til maxN;
    numLvls:count[poffset]; 
    n:(numLvls,(maxN+1))#0;
    n[;0]: poffset[;0];
    n[;-1_(1+maxNl)]: Clip(poffset[;1_maxNl] - shft[;-1_maxNl]);
    n[;maxN]: Clip(qtys-max'[shft]);
    :n;
    };

deriveNextStateFromDepthUpdate  :{


    };