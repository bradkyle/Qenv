
inftonull:{(x where x=0w|-0w):0n;x} 
inftozero:{(x where x=0w|-0w):0;x}
amn[amn?-0w]:0n
amn[amn?0w]:0n
tab upsert flip (cols tab)!0^(99;0N)#amn
\t:1000 `tab upsert flip (cols tab)!0^(99;0N)#amn
`tab insert(0^(99;0N)#amn)
0^last .ml.minmaxscaler[-100#tab]

// Customized simple min max scaler
// https://stackoverflow.com/questions/57778187/kdb-q-custom-min-max-scaler
minmaxCustom:{[l;u;x]l + (u - l) *  (x-mnx)%max[x]-mnx:min x}

// https://qkdb.wordpress.com/tag/sortino-ratio/
sortinoRatio:{[asset;minAccRet] 
 excessRet:-1*minAccRet-(100*1_asset-prev[asset])%1_asset;
 100*avg[excessRet]% sqrt sum[(excessRet*0>excessRet) xexp 2]%count[excessRet]}


// https://code.kx.com/q/wp/trend-indicators/

//Relative strength index - RSI
//close-close price
/n-number of periods
relativeStrength:{[num;y]
  begin:num#0Nf;
  start:avg((num+1)#y);
  begin,start,{(y+x*(z-1))%z}\[start;(num+1)_y;num] }

//
rsiMain:{[close;n]
  diff:-[close;prev close];
  rs:relativeStrength[n;diff*diff>0]%relativeStrength[n;abs diff*diff<0];
  rsi:100*rs%(1+rs);
  rsi }

// Money Flow Index
// We use the relativeStrength function as in the RSI calculation above.
mfiMain:{[h;l;c;n;v]
  TP:avg(h;l;c);                    / typical price
  rmf:TP*v;                         / real money flow
  diff:deltas[0n;TP];               / diffs
  /money-flow leveraging func for RSI
  mf:relativeStrength[n;rmf*diff*diff>0]%relativeStrength[n;abs rmf*diff*diff<0];
  mfi:100*mf%(1+mf);                /money flow as a percentage
  mfi }

// To calculate the Mean Deviation, a helper function called maDev (moving-average deviation)
maDev:{[tp;ma;n]
  ((n-1)#0Nf),
    {[x;y;z;num] reciprocal[num]*sum abs z _y#x}'
    [(n-1)_tp-/:ma; n+l; l:til count[tp]-n-1; n] }

// Commodity Channel Index
CCI:{[high;low;close;nperiod]
  TP:avg(high;low;close);
  sma:mavg[nperiod;TP];
  mad:maDev[TP;sma;n];
  reciprocal[0.015*mad]*TP-sma }

/tab-input table
/n-number of days
/ex-exchange
/id-id to run for
bollB:{[tab;n;ex;id]
  tab:select from wpData where sym=id,exch=ex;
  tab:update sma:mavg[n;TP],sd:mdev[n;TP] from update TP:avg(high;low;close) from tab;
  select date,sd,TP,sma,up:sma+2*sd,down:sma-2*sd from tab}

//Force Index Indicator
/c-close
/v-volume
/n-num of periods
//ForceIndex1 is the force index for one period
forceIndex:{[c;v;n]
  forceIndex1:1_deltas[0nf;c]*v;
  n#0nf,(n-1)_ema[2%1+n;forceIndex1] }

//Ease of movement value -EMV
/h-high
/l-low
/v-volume
/s-scale
/n-num of periods
emv:{[h;l;v;s;n]
  boxRatio:reciprocal[-[h;l]]*v%s;
  distMoved:deltas[0n;avg(h;l)];
  (n#0nf),n _mavg[n;distMoved%boxRatio]}

//Price Rate of change Indicator (ROC)
/c-close
/n-number of days prior to compare
roc:{[c;n]
  curP:_[n;c];
  prevP:_[neg n;c];
  (n#0nf),100*reciprocal[prevP]*curP-prevP }

//null out first 13 days if 14 days moving avg
//Stochastic Oscillator
/h-high
/l-low
/n-num of periods
/c-close price
/o-open
stoOscCalc:{[c;h;l;n]
  lows:mmin[n;l];
  highs:mma[n;h];
  (a#0n),(a:n-1)_100*reciprocal[highs-lows]*c-lows }

/k-smoothing for %D
/for fast stochastic oscillation smoothing is set to one k=1/slow k=3 default
/d-smoothing for %D -  this generally set for 3
/general set up n=14,k=1(fast),slow(slow),d=3

stoOcsK:{[c;h;l;n;k] (a#0nf),(a:n+k-2)_mavg[k;stoOscCalc[c;h;l;n]] }

stoOscD:{[c;h;l;n;k;d] (a#0n),(a:n+k+d-3)_mavg[d;stoOscK[c;h;l;n;k]] }

//Aroon Indicator
aroonFunc:{[c;n;f]
  m:reverse each a _'(n+1+a:til count[c]-n)#\:c;
  #[n;0ni],{x? y x}'[m;f] }

aroon:{[c;n;f] 100*reciprocal[n]*n-aroonFunc[c;n;f]}

/- aroon[tab`high;25;max]-- aroon up
/- aroon[tab`low;25;max]-- aroon down
aroonOsc:{[h;l;n] aroon[h;n;max] - aroon[l;n;min]}

// Used to pivot a table
piv:{[t;k;p;v]f:{[v;P]`${raze "_" sv x} each string raze P,'/:v};v:(),v; k:(),k; p:(),p;G:group flip k!(t:.Q.v t)k;F:group flip p!t p;key[G]!flip(C:f[v]P:flip value flip key F)!raze{[i;j;k;x;y]a:count[x]#x 0N;a[y]:x y;b:count[x]#0b;b[y]:1b;c:a i;c[k]:first'[a[j]@'where'[b j]];c}[I[;0];I J;J:where 1<>count'[I:value G]]/:\:[t v;value F]};

