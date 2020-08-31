



// Trend Indicators
//----------------------------------------------------->
vwap:{[ts;tp] wavg[ts;tp]}
volatility:{100*dev[x]%avg[x]}
totalReturn:{100*reciprocal[last[x]]*max[x]-min[x]}
dollarVol:{[ts;tp] sum[tp*ts]}
//p=can be any quantable feature, size price, spread
tw:{[t;p] reciprocal(sum td) %sum p*td:1_deltas[t],0D00:00:00.000000000}

macd:{[tab;id;ex]
        macd:{[x] ema[2%13;x]-ema[2%27;x]};
        signal:{ema[2%10;x]};
        res:select sym,date,exch,close,ema12:ema[2%13;close],ema26:ema[2%27;close],macd:macd[close] from tab where sym=id,exch=ex;
        update signal:signal[macd] from res
        }
//Relative strentgh index- RSI
rsFunc:{[num;y]
	begin:num#0Nf;
	start:avg((num+1)#y);
	begin,start,{(y+x*(z-1))%z}\[start;(num+1)_y;num]}

rsiMain:{[close;n]
	diff:-[close;prev close];
	rs:rsFunc[n;diff*diff>0]%rsFunc[n;abs diff*diff<0];
	rsi:100*rs%(1+rs);
	rsi}

//Money Flow Index -RSI but including volume
/h-high
/l-low
/c-close
/n-number of periods
/volume
mfiMain:{[h;l;c;n;v]
		TP:avg(h;l;c); /typical price
		rmf:TP*v; /real money flow
		diff:deltas[0n;TP]; /diffs
		mf:rsFunc[n;rmf*diff*diff>0]%rsFunc[n;abs rmf*diff*diff<0]; /money flow leveraging func for rsi.
		mfi:100*mf%(1+mf); /money flow as a percentage
		mfi}

//Eae of movement value -EMV
/h-high
/l-low
/v-volume
/s-scale
/n-num of periods
emv:{[h;l;v;s;n]
		boxRatio:reciprocal[-[h;l]]*v%s;
		distMoved:deltas[0n;avg(h;l)];
		(n#0nf),n _mavg[n;distMoved%boxRatio]
		}

//Price Rate of change Inicator (ROC)
roc:{[c;n]
		curP:_[n;c];
		prevP:_[neg n;c];
		(n#0nf),100*reciprocal[prevP]*curP-prevP
		}

//Force Index Indicator
/c-close
/v-volume
/n-num of periods
//ForceIndex1 is the force index for one period
forceIndex:{[c;v;n]
		
		forceIndex1:1_deltas[0nf;c]*v;
		(n#0nf),(n-1)_ema[2%1+n;forceIndex1]}

//null out first 13days if 14 days moving avg
//Stochastic Oscillator
/h-high
/l-low
/n-num of periods
/c-close price
/o-open
stoOscCalc:{[c;h;l;n]
		lows:mmin[n;l];
		highs:mmax[n;h];
		(a#0n),(a:n-1)_100*reciprocal[highs-lows]*c-lows
		}
/k-smoothing for %D
/for fast stochastic oscillation smoothing is set to one k=1/slow k=3 default
/d-smoothing for %D -  this generally set for 3
/general set up n=14,k=1(fast),slow(slow),d=3

stoOscK:{[c;h;l;n;k]
		(a#0nf),(a:n+k-2)_mavg[k;stoOscCalc[c;h;l;n]]
		}

stoOscD:{[c;h;l;n;k;d]
		(a#0n),(a:n+k+d-3)_mavg[d;stoOscK[c;h;l;n;k]]
		}

//Aroon indicator
aroonFunc:{[c;n;f] 
		m:reverse each a _'(n+1+a:til count[c]-n)#\:c;
		#[n;0ni],{x? y x}'[m;f]}

aroon:{[c;n;f] 100*reciprocal[n]*n-aroonFunc[c;n;f]}
//aroon[tab`high;24;max]-- aroon up

aroonOsc:{[h;l;n] aroon[h;n;max] - aroon[l;n;min]}

/tab-input table
/n-number of days
/ex-exchange
/id-id to run for 
bollB:{[tab;n;ex;id]
	tab:select from wpData where sym=id,exch=ex;
	tab:update sma:mavg[n;TP],sd:mdev[n;TP] from update TP:avg(high;low;close) from tab;
	select date,sd,TP,sma,up:sma+2*sd,down:sma-2*sd from tab}


//exec bollB[25;close] by id,date from tab
//CCI = Commodity Channel Index
CCI:{[high;low;close;n]
	TP:avg(high;low;close);
	sma:mavg[n;TP];
	mad:madFunc[TP;sma;n];
    reciprocal[0.015*mad]*TP-sma  
    }
/Moving average Deviation function
madFunc:{[tp;ma;n] 
		((n-1)#0Nf),{[x;y;z;num] reciprocal[num]*sum abs z _y#x}'[(n-1)_tp-/:ma;n+l;l:til -[count tp;n-1];n]}


// TODO check if successful feature derive

// Efficiently returns the aggregated and normalised
// feature vector represenations of the agent state 
// and environment state for a set of agent ids. // CHANGE to FeatureVector
// https://code.kx.com/q/wp/trend-indicators/


relativeStrength:{[num;y]
        begin:num#0Nf;
        start:avg((num+1)#y);
        begin,start,{(y+x*(z-1))%z}\[start;(num+1)_y;num]};


rsiMain:{[close;n]
    diff:-[close;prev close];
    rs:relativeStrength[n;diff*diff>0]%relativeStrength[n;abs diff*diff<0];
    rsi:100*rs%(1+rs);
    rsi };

mfiMain:{[h;l;c;n;v]
            TP:avg(h;l;c);                    / typical price
            rmf:TP*v;                         / real money flow
            diff:deltas[0n;TP];               / diffs
            /money-flow leveraging func for RSI
            mf:relativeStrength[n;rmf*diff*diff>0]%relativeStrength[n;abs rmf*diff*diff<0];
            mfi:100*mf%(1+mf);                /money flow as a percentage
            mfi };

maDev:{[tp;ma;n]
    ((n-1)#0Nf),
        {[x;y;z;num] reciprocal[num]*sum abs z _y#x}'
        [(n-1)_tp-/:ma; n+l; l:til count[tp]-n-1; n] };

// TODO change to interval
CCI:{[high;low;close;n] 
    TP:avg(high;low;close);
    sma:mavg[n;TP];
    mad:maDev[TP;sma;n];
    reciprocal[0.015*mad]*TP-sma };


// TODO doesn't work
/ forceIndex:{[c;v;n]
/     forceIndex1:1_deltas[0nf;c]*v;
/     n#0nf,(n-1)_ema[2%1+n;forceIndex1] }

/ ohlc:update ForceIndex:forceIndex[close;volume;13] from ohlc;

//Ease of movement value -EMV
/h-high
/l-low
/v-volume
/s-scale
/n-num of periods
emv:{[h;l;v;s;n]
    boxRatio:reciprocal[-[h;l]]*v%s;
    distMoved:deltas[0n;avg(h;l)];
    (n#0nf),n _mavg[n;distMoved%boxRatio] };


//Price Rate of change Indicator (ROC)
/c-close
/n-number of days prior to compare
roc:{[c;n]
    curP:_[n;c];
    prevP:_[neg n;c];
    (n#0nf),100*reciprocal[prevP]*curP-prevP };


//null out first 13 days if 14 days moving avg
//Stochastic Oscillator
/h-high
/l-low
/n-num of periods
/c-close price
/o-open
stoOscCalc:{[c;h;l;n]
    lows:mmin[n;l];
    highs:mmax[n;h];
    (a#0n),(a:n-1)_100*reciprocal[highs-lows]*c-lows };

stoOcsK:{[c;h;l;n;k] (a#0nf),(a:n+k-2)_mavg[k;stoOscCalc[c;h;l;n]] };
stoOscD:{[c;h;l;n;k;d] (a#0n),(a:n+k+d-3)_mavg[d;stoOscK[c;h;l;n;k]] };


//Aroon Indicator
aroonFunc:{[c;n;f]
    m:reverse each a _'(n+1+a:til count[c]-n)#\:c;
    #[n;0ni],{x? y x}'[m;f] };

aroon:{[c;n;f] 100*reciprocal[n]*n-aroonFunc[c;n;f]};

/- aroon[tab`high;25;max]-- aroon up
/- aroon[tab`low;25;max]-- aroon down
aroonOsc:{[h;l;n] aroon[h;n;max] - aroon[l;n;min]};

signal:{ema[2%10;x]};
macd:{[x] ema[2%13;x]-ema[2%27;x]};