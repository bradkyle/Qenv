

// TODO if is training and use randomize
// TODO the 

// TODO observation randomization i.e. selective dropping of features for a given period

// Configuration
//=========================================================================================> 

// Server
// ---------------------------------------------------------------------------------->
// 
.conf.Config[`server;([]
    port                        : .conf.Env[`port]
    )];

// Env
// ---------------------------------------------------------------------------------->

// Contains static configuration 
.conf.Config[`env;([]
    exchangeRep                 : .conf.Static[`binance];                                 // The name of the exchange that is being replicated                               
    doneBalance                 : .conf.Static[250];                                      // The balance at which the agent is considered done and a reset is needed                                 
    maxNumSteps                 : .conf.Static[12e6];                                     // The maximum number of steps per episode
    accountIds                  : .conf.Static[enlist(til 4)];                            // The accountIds for each agent         
    adapterType                 : .conf.Static[1];                                        // The action adapter type that is being used i.e. HedgedPathFinder
    encouragement               : .conf.Static[0.0];                                      // The penalty as a result of not taking an action
    rewardType                  : .conf.Static[0];                                        // The type of reward that is being used i.e. sortino
    activeTradeFraction         : .conf.Static[0.5f];                                     // The amount of balance that is used for active trading
    numDepthBuckets             : .conf.Static[10];                                       // The number of depth buckets to use for actions and observations
    priceBucketSize             : .conf.Static[2];                                        // The number of ticks that a bucket encapsulates
    tickSize                    : .conf.Static[0.01f];                                    // The size of the price ticks
    lotSize                     : .conf.Static[0.001f];                                   // The lot size i.e. number of contracts / Base/Quote/Underlying  
    priceMultiplier             : .conf.Static[100];                                      // The price multiplier   
    sizeMultiplier              : .conf.Static[1000];                                     // The size multiplier    
    activeSignals               : .conf.Static[0b];                                       // The active signals that are to be used in observations
    historicPruneThreshold      : .conf.Static[enlist(til 10)]                            // The maximum historic lookback window for the env state
    obsWindowSize               : .conf.Static[100];                                      
    rewWindowSize               : .conf.Static[100];
    dneWindowSize               : .conf.Static[100]
    )];

// TODO move adapter to own config

// Engine
// ---------------------------------------------------------------------------------->
.conf.Config[`engine;([]
    rebalanceHigh               : .conf.RandomWithin[1500000;100000];                     // The maximum balance for which new rebalances will be triggered
    rebalanceLow                : .conf.RandomWithin[1500;0];                             // The minimum balance for which new rebalances will be triggered
    maxRebalanceAmt             : .conf.RandomWithin[15000;0];                            // The maximum balance randomization value
    minRebalanceAmt             : .conf.Static[1];                                        // The minimum balance randomization value
    depositfreq                 : .conf.RandomDurationWithin[1440;1;`minute];             // The frequency of deposit randomizations
    withrawFreq                 : .conf.RandomDurationWithin[1440;1;`minute];             // The frequency of withdrawal randomization
    leverageHigh                : .conf.Static[25];                                       // The maximum leverage randomization value
    leverageLow                 : .conf.Static[1];                                        // The minimum leverage randomization value
    releveragefreq              : .conf.RandomDurationWithin[1440;1;`minute];             // The frequency of leverage randomizations
    outageFreq                  : .conf.RandomDurationWithin[14400;1440;`minute];         // The frequency of data/connection outages
    outageMaxLength             : .conf.RandomDurationWithin[30;10;`minute];              // The maximum length of data/connection outages
    outageMinLength             : .conf.RandomDurationWithin[10;1;`minute];               // The minimul length of data/connection outages
    stepFrequency               : .conf.StaticInterval[5;`second];                        // The threshold frequency of each step (temporal)
    stepPeriod                  : .conf.Static[100];                                      // The threshold period of each step (event count)
    dataInterval                : .conf.StaticInterval[5;`second];                        // The size of the batch data to request from ingress server
    pullInterval                : .conf.StaticInterval[5;`second];                        // The interval for which new data is requested
    ingestHost                  : .conf.Static[`localhost];                               // The host on which to connect to the ingest server
    ingestPort                  : .conf.Static[5001];                                     // The port on which to connect to the ingest server
    ingressWindowKind           : .conf.Static[0];                                        // The type of window to use for selecting events to be passed into engine
    egressWindowKind            : .conf.Static[0];                                        // The type of window to use for selecting events to be retrieved froms engine
    selfTradePenalty            : .conf.Static[0.001];                                    // The penalty associated with filling one's own orders
    maxNewOrderBatchSize        : .conf.Static[10];                                       // The maximum new order batch size
    maxAmendOrderBatchSize      : .conf.Static[10];                                       // The maximum amend order batch size
    maxCancelOrderBatchSize     : .conf.Static[10]                                        // The maximum cancel order batch size
    )];

// TODO endpoint specific rate limits
// max self fill count

// IngressDelays
// ---------------------------------------------------------------------------------->

.conf.Config[`delays;([] // mu; sigma
    depth                    :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for depth updates                   
    trade                    :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for trade updates                  
    mark                     :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for mark updates                 
    settlement               :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for settlement updates                       
    funding                  :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for funding updates                    
    pricelimit               :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for pricelimit updates                       
    neworderreq              :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for neworder request                     
    neworderbatchreq         :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for neworderbatch request                          
    amendorderreq            :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for amendorder request                       
    amendorderbatchreq       :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for amendorderbatch request                            
    cancelorderreq           :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for cancelorder request                        
    cancelorderbatchreq      :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for cancelorderbatch request                             
    cancelallordersreq       :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for cancelallorders request                            
    withdrawreq              :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for withdraw request                     
    depositreq               :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for deposit request                    
    leverageupdatereq        :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for leverageupdate request    
    neworderres              :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for neworder response                     
    neworderbatchres         :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for neworderbatch response                          
    amendorderres            :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for amendorder response                       
    amendorderbatchres       :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for amendorderbatch response                            
    cancelorderres           :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for cancelorder response                        
    cancelorderbatchres      :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for cancelorderbatch response                             
    cancelallordersres       :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for cancelallorders response                            
    withdrawres              :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for withdraw response                     
    depositres               :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for deposit response                    
    leverageupdateres        :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for leverageupdate response                          
    liquidation              :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for liquidation updates                        
    signal1                  :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal1 updates                    
    signal2                  :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal2 updates                    
    signal3                  :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal3 updates                    
    signal4                  :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal4 updates                    
    signal5                  :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal5 updates                    
    signal6                  :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal6 updates                    
    signal7                  :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal7 updates                    
    signal8                  :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal8 updates                    
    signal9                  :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal9 updates                    
    signal10                 :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal10 updates           
    signal11                 :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal11 updates                    
    signal12                 :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal12 updates                    
    signal13                 :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal13 updates                    
    signal14                 :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal14 updates                    
    signal15                 :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal15 updates                    
    signal16                 :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal16 updates                    
    signal17                 :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal17 updates                    
    signal18                 :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal18 updates                    
    signal19                 :.conf.NDTimespan[1.804904e-06;1.918936e-06];                //  The normal distribution of the time delay for signal19 updates                    
    signal20                 :.conf.NDTimespan[1.804904e-06;1.918936e-06]                 //  The normal distribution of the time delay for signal20 updates           
    )]; 

// Instrument
// ---------------------------------------------------------------------------------->
// serves as a proxy for general instrument specific config

riskCols:`mxamt`mmr`imr`maxlev;
feeCols:`vol`makerFee`takerFee`wdrawFee`dpsitFee`wdrawLimit;

.conf.Config[`instrument;([]
    state                   : .conf.Static[0];                                            //                                    
    quoteAsset              : .conf.Static[`BTC];                                         //                                        
    baseAsset               : .conf.Static[`USDT];                                        //                                        
    underlyingAsset         : .conf.Static[`BTCUSDT];                                     //                                            
    faceValue               : .conf.Static[1];                                            //                                    
    maxLeverage             : .conf.Static[125];                                          //                                        
    minLeverage             : .conf.Static[1];                                            //                                    
    tickSize                : .conf.Static[0.01f];                                        //                                        
    lotSize                 : .conf.Static[0.001];                                        //                                        
    priceMultiplier         : .conf.Static[100];                                          //                                        
    sizeMultiplier          : .conf.Static[1000];                                         //                                        
    fundingInterval         : .conf.StaticInterval[480;`minute];                          //                                                          
    taxed                   : .conf.Static[0b];                                           //                                    
    deleverage              : .conf.Static[0b];                                           //                                    
    capped                  : .conf.Static[0b];                                           //                                    
    usePriceLimits          : .conf.Static[0b];                                           //                                    
    maxPrice                : .conf.Static[1e6];                                          //                                        
    minPrice                : .conf.Static[0];                                            //                                    
    upricelimit             : .conf.Static[0];                                            //                                    
    lpricelimit             : .conf.Static[0];                                            //                                    
    maxOrderSize            : .conf.Static[1e6];                                          //                                        
    minOrderSize            : .conf.Static[0.001];                                        //                                        
    junkOrderSize           : .conf.Static[0.001];                                        //                                        
    contractType            : .conf.Static[0];                                            //                                     
    maxOpenOrders           : .conf.Static[25];                                           // The default maximum number of orders that an agent can have open.                                                            
    maxDepthLevels          : .conf.Static[100];                                          // The maximum number of depth levels to maintain in the order book simulation.                                           
    takeOverFee             : .conf.Static[0];
    riskTiers               : .conf.Static[flip[riskCols!flip[(
        50000       0.004    0.008    125f;
        250000      0.005    0.01     100f;
        1000000     0.01     0.02     50f;
        5000000     0.025    0.05     20f;
        20000000    0.05     0.1      10f;
        50000000    0.1      0.20     5f;
        100000000   0.125    0.25     4f;
        200000000   0.15     0.333    3f;
        500000000   0.25     0.50     2f;
        500000000   0.25     1.0      1f)]]];
    feeTiers                 : .conf.Static[flip[feeCols!flip[(
        50      0.0006    0.0006    0  0 600f;
        500     0.00054   0.0006    0  0 600f;
        1500    0.00048   0.0006    0  0 600f;
        4500    0.00042   0.0006    0  0 600f;
        10000   0.00042   0.00054   0  0 600f;
        20000   0.00036   0.00048   0  0 600f;
        40000   0.00024   0.00036   0  0 600f;
        80000   0.00018   0.000300  0  0 600f;
        150000  0.00012   0.00024   0  0 600f)]]]                             // 
    )]; 
 
// Account
// ---------------------------------------------------------------------------------->

.conf.Config[`accounts;([]
    [accountId          : .conf.Static[til 4]]                                             //                               
    state               : .conf.Static[4#0];                                               //                               
    frozen              : .conf.Static[4#0];                                               //                               
    balance             : .conf.RandomWithin[150000;0];                                    //                                       
    withdrawable        : .conf.Static[4#0];                                               //                               
    marginType          : .conf.Static[4#0];                                               //                               
    positionType        : .conf.Static[4#0];                                               //                               
    monthVolume         : .conf.RandomWithin[150000;0];                                    //                                       
    leverage            : .conf.RandomWithin[25;1]                                         //                                   
    )];
