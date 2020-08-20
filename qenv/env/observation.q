\d .observation

FeatureBuffer   :();

// Agent specific observation functions
// --------------------------------------------------->

// Efficiently returns the aggregated and normalised
// feature vector represenations of the agent state 
// and environment state for a set of agent ids.
getFeatureVectors    :{[accountIds]

        // TODO add long term prediction features.

        // TODO add account id to feature vector
        obs: raze(
            value 1_last depth;
            last mark.mark_price;
            last funding.funding_rate;
            last trades.price;
            value 1_last account;
            value last piv[0!update time:max time from select num:count size, high:max price, low: min price, open: first price, close: last price, volume: sum size, msize: avg size, hsize: max size, lsize: min size by side from source_trades where time>= max time - `minute$5;`time;`side;`high`low`open`close`volume`msize`hsize`lsize`num];
            value last piv[0!update time:max source_trades.time from select high:max price, low: min price, open: first price, close: last price, volume: sum size, msize: avg size, hsize: max size, lsize: min size by side from source_trades where {x|next x}/[100;time=max time];`time;`side;`high`low`open`close`volume`msize`hsize`lsize];
            value exec sum leaves, avg price from orders where ordtyp=`limit, status=`new, side=`buy;
            value exec sum leaves, avg price from orders where ordtyp=`limit, status=`new, side=`sell;
            value exec sum leaves, max price from orders where ordtyp=`stop_market, status=`new, side=`buy;
            value exec sum leaves, min price from orders where ordtyp=`stop_market, status=`new, side=`sell; 
            value exec last amount, last average_entry_price, last leverage, last realized_pnl, last unrealized_pnl from positions where side=`long;
            value exec last amount, last average_entry_price, last leverage, last realized_pnl, last unrealized_pnl from positions where side=`short
        );

        `.observation.FeatureBuffer upsert obs;

        // TODO count by account id
        / $[(count .schema.FeatureBuffer)>maxBufferSize;]; // TODO make max buffer size configurable
        // TODO fill forward + normalize
        :.ml.minmaxscaler[-100#.schema.FeatureBuffer];
    };