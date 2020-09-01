\d .state

// State specifically represents a set of events that are derived from the engine
// TODO max history size

// TODO house state in its own process
// TODO prioritized experience replay
// TODO train test split with batches of given length (Hindsight experience replay/teacher student curriculum)

// COMMON COUNTERS
// =====================================================================================>
maxLvls:20;
DefaultInstrumentId:0;
.state.clOrdCount:0;
.state.genNextClOrdId  :.util.IncRet[`.state.clOrdCount];


// Singleton State and Lookback Buffers
// =====================================================================================>
// The lookback buffers attempt to build a realistic representation of what the
// agent will percieve in a real exchange.


// ACCOUNT
// ----------------------------------------------------------------------------------------------->

// The following tables maintain a local state buffer 
// representative of what the agent will see when
// interacting with a live exchange. 
.state.AccountEventHistory: (
    [accountId : `long$(); time : `datetime$()]
    balance             : `long$();
    available           : `long$();
    frozen              : `long$();
    maintMargin         : `long$());
.state.accountCols:cols .state.AccountEventHistory;
.state.CurrentAccount: `accountId xkey .state.AccountEventHistory;

// INVENTORY
// ----------------------------------------------------------------------------------------------->

// Maintains a historic and current record of the 
// positions (Inventory) each agent has held and
// subsequently provides agent specific details
// therin
.state.InventoryEventHistory: ( // TODO change side to long 1,2,3
    [accountId:  `long$();side: `long$();time : `datetime$()]
    amt                 :  `long$();
    realizedPnl         :  `long$();
    avgPrice            :  `long$(); // TODO check all exchanges have
    unrealizedPnl       :  `long$());
.state.inventoryCols:cols .state.InventoryEventHistory;
.state.CurrentInventory: `accountId`side xkey .state.InventoryEventHistory;


// Return all open positions for an account
.state.openInventory :{?[`.state.CurrentInventory;]};

// Return the amt of each inventory by side for account
.state.amtBySide     :{?[`.state.CurrentInventory;]};

// ORDERS
// ----------------------------------------------------------------------------------------------->

.state.OrderEventHistory: (
    [
        orderId:`long$();
        time:`datetime$()
    ]
    accountId       :   `long$();
    side            :   `long$(); // TODO change to long
    otype           :   `long$(); // TODO change to long
    price           :   `long$();
    leaves          :   `long$();
    filled          :   `long$();
    limitprice      :   `long$(); / multiply by 100
    stopprice       :   `long$(); / multiply by 100
    status          :   `long$();
    reduce          :   `boolean$();
    trigger         :   `long$(); // TODO change to long
    execInst        :   `long$()); // TODO change to long
.state.ordCols:cols .state.OrderEventHistory;
.state.CurrentOrders: `orderId xkey .state.OrderEventHistory;

// Get the current qtys at each order level
// .util.cond.isActiveAccountOrder
.state.ordQtyByPrice :{?[`.order.CurrentOrders]};

// Get the sum of the outstanding order qtys for each
// level by price
.state.lvlQtyByPrice :{?[`.order.CurrentOrders]};


// DEPTH
// ----------------------------------------------------------------------------------------------->

// Maintains a historic record of depth snapshots
// with the amount of levels stored dependent upon
// the config for the specified from the engine 
// i.e. The depth has been directly affected by 
// the agent.
.state.DepthEventHistory: (
    [price:`long$();time:`datetime$()]
    side:`long$(); // change side to long
    size:`int$());
.state.depthCols:cols DepthEventHistory;
.state.CurrentDepth: `price xkey .state.DepthEventHistory;

.state.lvlPrices     :{?[]};

// TODO add error handling
.state.priceAtLvl     :{?[]};


// Non-Essential Datums
// ----------------------------------------------------------------------------------------------->

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
TradeEventHistory: (
    [tid:`long$(); time:`datetime$()]
    size            :   `long$();
    price           :   `long$();
    side            :   `long$()); // TODO change side to long
tradeCols:cols TradeEventHistory;

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
MarkEventHistory: (
    [time            :   `datetime$()]
    markprice        :   `long$());
markCols:cols MarkEventHistory;

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
FundingEventHistory: (
    [time            :   `datetime$()]
    fundingrate      :   `long$();
    fundingtime      :   `datetime$());
fundingCols:cols FundingEventHistory;

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
LiquidationEventHistory: (
    [liqid:`long$(); time:`datetime$()]
    size            :   `long$();
    price           :   `long$();
    side            :   `long$()); // todo change side to long
liquidationCols:cols LiquidationEventHistory;

// Maintains a set of historic trade events
// that could be used to create ohlc features
// and indicators etc.
SignalEventHistory: (
    [sigid:`long$(); time:`datetime$()]
    sigvalue        :   `float$()
    );

InsertEvents :{
    {
        k:x`kind;
        r:x`datum;
        $[
            k=0;[
                / .state.DepthEventHistory,:r;
                .state.CurrentDepth,:r;
            ]; // DEPTH
            k=1;[.state.TradeEventHistory,:r]; // TRADE
            k=2;[.state.MarkEventHistory,:r]; // MARK
            k=3;[.state.LiquidationEventHistory,:r]; // LIQUIDATION
            k=4;[.state.FundingEventHistory,:r]; // FUNDING
            k=5;[.state.SettlementHistory,:r]; // SETTLEMENT
            k=6;[
                / .state.AccountEventHistory,:r;
                .state.CurrentAccount,:r; 
            ]; // ACCOUNT
            k=7;[
                / .state.InventoryEventHistory,:r;
                .state.CurrentInventory,:r;
            ]; // INVENTORY
            k=8;[
                / .state.OrderEventHistory,:r;
                .state.CurrentOrders,:r; 
            ]; // ORDER
            k=9;[.state.PriceLimitHistory,:r]; // PRICELIMIT
            k=16;[.state.SignalEventHistory,:r]; // SIGNAL
            'INVALID_EVENT_KIND
        ];
    }'[0!(`kind xgroup x)];
    };


// Feature Extraction and Derivation
// =====================================================================================>

FeatureBuffer   :();

// Agent specific observation functions
// --------------------------------------------------->


/ tradeFuncs:`lowPr`highPr`tcnt`avgPr`vwap`volatility`totalReturn`volume`dollarVol`open`close`twap`twas`avgSz`minSz`maxSz`startTime`endTime!((min;`tp);(max;`tp);(count;`tp);(avg;`tp);(wavg;`ts;`tp);(volatility;`tp);(totalReturn;`tp);(sum;`ts);(dollarVol;`ts;`tp);(first;`tp);(last;`tp);(tw;`time;`tp);(tw;`time;`ts);(avg;`ts);(min;`ts);(max;`ts);(min;`time);(max;`time))
/ quoteFuncs:`minAp`maxAp`minBp`maxBp`qcnt`avgSprd`maxSprd`minSprd`twAsk`twBid`twSprd!((min;`ap);(max;`ap);(min;`bp);(max;`bp);(count;`ap);(avg;(-;`ap;`bp));(max;(-;`ap;`bp));(min;(-;`ap;`bp));(tw;`time;`ap);(tw;`time;`bp);(tw;`time;(-;`ap;`bp)))

getOhlcFeatures :{[]
        ohlc:0!select 
            num:count size, 
            high:max price, 
            low: min price, 
            open: first price, 
            close: last price, 
            volume: sum size, 
            msize: avg size, 
            hsize: max size,
            time: max time, 
            lsize: min size 
            by (1 xbar `minute$time) from .state.TradeEventHistory;

        ohlc:update 
            sma10:mavg[10;close], 
            sma20:mavg[20;close], 
            ema12:ema[2%13;close], 
            ema26:ema[2%27;close], 
            macd:macd[close] 
            from ohlc;
        
        ohlc:update signal:signal[macd] from ohlc;

        ohlc:update rsi:rsiMain[close;14] from ohlc;

        ohlc:update mfi:mfiMain[high;low;close;6;volume], avtp:avg(high;low;close) from ohlc;

        ohlc:update mfi:mfiMain[high;low;close;6;volume] from ohlc;

        ohlc:update cci:CCI[high;low;close;14] from ohlc;

        ohlc:update sma:mavg[20;avtp],sd:mdev[20;avtp] from ohlc;

        ohlc:update up:sma+2*sd,down:sma-2*sd from ohlc;

        ohlc:update EMV:emv[high;low;volume;1000000;14] from ohlc;

        ohlc:update ROC:roc[close;10] from ohlc;

        ohlc: update
            sC:stoOscCalc[close;high;low;5],
            sk:stoOscK[close;high;low;5;2],
            stoOscD[close;high;low;5;2;3] from ohlc;

        ohlc:update
            aroonUp:aroon[high;25;max],
            aroonDown:aroon[low;25;min],
            aroonOsc:aroonOsc[high;low;25] from ohlc;

        // Pivot and combine per accountId

        / ohlc:Piv[ohlc;`time;`side;`high`low`open`close`volume`msize`hsize`lsize`num];
        ohlc: value last (0^(`time`time _ ohlc));
    };

getPeriodSplit  :{

    };

// TODO store features in log to do reverse feature selection!
getOBFeatures   :{

        ob update avg(bestBid,bestAsk) from .state.DepthEventHistory;
    };

// TODO construct observation getter
// TODO register obs in order and parse them , register parsed result and use that in get observations


// TODO get orderbook features
// TODO volatility, standard deviation, etc.
// TODO testing etc.
GetObservations    :{[aids; windowsize; step] // TODO configurable window size
        / interval: 

        // TODO add liquidation as feature.
        bp:select[-5] price from .state.CurrentDepth where side=`BUY; // TODO fill 0's
        ap:select[-5] price from .state.CurrentDepth where side=`SELL;

        // TODO add account id to feature vector
        pobs: raze raze'[( 
            10#0;
            exec last markprice from .state.MarkEventHistory;
            exec last fundingrate from .state.FundingEventHistory;
            value flip bp; // TODO fill 0's
            value flip ap;
            value flip select[-5] size from .state.TradeEventHistory where side=`BUY;
            value flip select[-5] size from .state.TradeEventHistory where side=`SELL;
            value flip select[5] size from `price xasc .state.CurrentDepth where side=`BUY;
            value flip select[5] size from `price xdesc .state.CurrentDepth where side=`SELL
        )];

        // TODO do uj
        // select by accountId, price from .state.CurrentOrders where price in raze[ap], otype=`LIMIT, status in `NEW`PARTIALFILLED, side=`SELL
        oobs: raze(
            exec leaves from 0^(ap uj select leaves from .state.CurrentOrders where price in raze[ap], otype=`LIMIT, status in `NEW`PARTIALFILLED, side=`SELL);
            exec leaves from 0^(ap uj select leaves from .state.CurrentOrders where price in raze[ap], otype=`LIMIT, status in `NEW`PARTIALFILLED, side=`SELL)
        );

        ac:select last balance, last available, last frozen, last maintMargin by accountId from .state.AccountEventHistory where accountId in aids;
        ivn:Piv[0!select last amt, last realizedPnl, last avgPrice, last unrealizedPnl by accountId,side from .state.InventoryEventHistory where accountId in aids;`accountId;`side;`amt`realizedPnl`avgPrice`unrealizedPnl];

        aobs:0!(ac uj ivn);
        aobs[(`$string[til[count[pobs]]])]:pobs;
        obs:(`accountId,(`$string(til[count[cols[aobs]]-1]))) xcol 0!aobs;
        obs[`step]:step;

        // if count feature buffer
        `.state.FeatureBuffer upsert (`accountId`step xkey obs);

        // TODO count by account id
        / $[(count .schema.FeatureBuffer)>maxBufferSize;]; // TODO make max buffer size configurable
        // TODO fill forward + normalize
        :1!(0^select from ungroup(.ml.minmaxscaler'[`accountId xgroup .state.FeatureBuffer]) where step=1);
        // obs[`accountId]!value'[`accountId`step _ obs]
    };

PrimeFeatures   :{[]

    };


// Reset State
// =====================================================================================>

// TODO persist episode state

Reset :{[config]
    delete from `.state.AccountEventHistory;
    delete from `.state.InventoryEventHistory;
    delete from `.state.OrderEventHistory;
    delete from `.state.CurrentOrders;
    delete from `.state.TradeEventHistory;
    delete from `.state.MarkEventHistory;
    delete from `.state.FundingEventHistory;
    delete from `.state.LiquidationEventHistory;
    delete from `.state.FeatureBuffer;

    // TODO setup features 
    };