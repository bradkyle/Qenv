/
The following logic prepares the set of kdb tables that make up the state
to be queried using a current step mechanism that refers to a static windowed
period of a given size (in this instance 1 second)
\
`source_funding`source_instrument`source_depth`source_trades 

source_depth: `time xasc source_depth; 
source_depth: update sec:time: (`date$time) + 1 xbar `second$time from source_depth;
source_depth: update grp: (sums 0b, 1_differ sec) from source_depth;
source_depth: delete symbol from source_depth;

prim: select max grp by sec from source_depth;

source_trades: `time xasc source_trades; 
source_trades: update sec:time: (`date$time) + 1 xbar `second$time from source_trades;
source_trades: `sec xkey source_trades;
source_trades: source_trades ij prim;
source_trades: 0!(`time xkey 0!source_trades);

source_instrument: update "Z"$(string time) from source_instrument
source_instrument: `time xasc source_instrument; 
source_instrument: update sec:time: (`date$time) + 1 xbar `second$time from source_instrument;
source_instrument: `sec xkey source_instrument;
source_instrument: source_instrument ij prim;
source_instrument: 0!(`time xkey 0!source_instrument);

source_mark: select time, sec, grp, markPrice from source_instrument where not null markPrice;
source_mark: 0!(`time xkey 0!source_mark);

source_open_value: select time, sec, grp, openValue from source_instrument where not null openValue;
source_open_value: 0!(`time xkey 0!source_open_value);

source_open_interest: select time, sec, grp, openInterest from source_instrument where not null openInterest;
source_open_interest: 0!(`time xkey 0!source_open_interest);

source_funding: `time xasc source_funding; 
source_funding: update sec:time: (`date$time) + 1 xbar `second$time from source_funding;
source_funding: `sec xkey source_funding;
source_funding: source_funding ij prim;
source_funding: 0!(`time xkey 0!source_funding);