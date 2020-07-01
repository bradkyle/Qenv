

\d .util

// TODO make face value global for instrument.
CntToMrg    : {[price;qty;faceValue;doAbs]
    $[price>0 & doAbs;
    :(faceValue%price)* abs[qty];
    doAbs;
    :(faceValue%price)*qty;
    :0];
};

MakeAction  : {[]

    }

SortinoRatio :{[asset;minAccRet] 
 excessRet:-1*minAccRet-(100*1_asset-prev[asset])%1_asset;
 100*avg[excessRet]% sqrt sum[(excessRet*0>excessRet) xexp 2]%count[excessRet]
 }

Piv :{[t;k;p;v]f:{[v;P]`${raze "_" sv x} each string raze P,'/:v};v:(),v; k:(),k; p:(),p;G:group flip k!(t:.Q.v t)k;F:group flip p!t p;key[G]!flip(C:f[v]P:flip value flip key F)!raze{[i;j;k;x;y]a:count[x]#x 0N;a[y]:x y;b:count[x]#0b;b[y]:1b;c:a i;c[k]:first'[a[j]@'where'[b j]];c}[I[;0];I J;J:where 1<>count'[I:value G]]/:\:[t v;value F]};

