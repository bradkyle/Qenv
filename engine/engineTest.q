



.qt.Unit[
    ".engine.ProcessEvents";
    {[c]
        p:c[`params];
        m:p[`mocks];
        .engine.test.m:m;
        .engine.WaterMark:p[`watermark];

        mck1:  .qt.M[`.engine.ProcessDepthUpdateEvents;{[a]};c];
        mck2:  .qt.M[`.engine.ProcessNewTradeEvents;{[a]};c];
        mck3:  .qt.M[`.engine.ProcessMarkUpdateEvents;{[a]};c];
        mck4:  .qt.M[`.engine.ProcessSettlementEvents;{[a]};c];
        mck5:  .qt.M[`.engine.ProcessFundingEvents;{[a]};c];
        mck6:  .qt.M[`.engine.ProcessLiquidationEvents;{[a]};c];
        mck7:  .qt.M[`.engine.ProcessNewOrderEvents;{[a]};c];
        mck8:  .qt.M[`.engine.ProcessAmendOrderEvents;{[a]};c];
        mck9:  .qt.M[`.engine.ProcessCancelOrderEvents;{[a]};c];
        mck10:  .qt.M[`.engine.ProcessCancelAllOrdersEvents;{[a]};c];
        mck11:  .qt.M[`.engine.ProcessNewPriceLimitEvents;{[a]};c];
        mck12:  .qt.M[`.engine.ProcessWithdrawEvents;{[a]};c];
        mck13: .qt.M[`.engine.ProcessDepositEvents;{[a]};c];
        mck14: .qt.M[`.engine.ProcessSignalEvents;{[a]};c];

        .engine.ProcessEvents[p[`events]];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected    .engine.ProcessDepthUpdateEvents                                         
        .util.testutils.checkMock[mck2;m[1];c];  // Expected    .engine.ProcessNewTradeEvents                                      
        .util.testutils.checkMock[mck3;m[2];c];  // Expected    .engine.ProcessMarkUpdateEvents                  
        .util.testutils.checkMock[mck4;m[3];c];  // Expected    .engine.ProcessSettlementEvents                  
        .util.testutils.checkMock[mck5;m[4];c];  // Expected    .engine.ProcessFundingEvents               
        .util.testutils.checkMock[mck6;m[5];c];  // Expected    .engine.ProcessLiquidationEvents                   
        .util.testutils.checkMock[mck7;m[6];c];  // Expected    .engine.ProcessNewOrderEvents              
        .util.testutils.checkMock[mck8;m[7];c];  // Expected    .engine.ProcessAmendOrderEvents                     
        .util.testutils.checkMock[mck9;m[8];c];  // Expected    .engine.ProcessCancelOrderEvents                
        .util.testutils.checkMock[mck10;m[9];c];  // Expected   .engine.ProcessCancelAllOrdersEvents                         
        .util.testutils.checkMock[mck11;m[10];c];  // Expected  .engine.ProcessNewPriceLimitEvents                         
        .util.testutils.checkMock[mck12;m[11];c];  // Expected  .engine.ProcessWithdrawEvents                     
        .util.testutils.checkMock[mck13;m[12];c];  // Expected  .engine.ProcessDepositEvents                     
        .util.testutils.checkMock[mck14;m[13];c];  // Expected  .engine.ProcessSignalEvents                     

    };
    {[p]
        e:({`time`kind`cmd`datum!x} each p[1]);
        :`watermark`events`mocks`err!(p[0];e;p[2];p[3]);
    };
    (
        (".engine.ProcessEvents";(
            z;
            (
                enlist(z+1;2#8;2#0;((0;0;0;0;0;0);(0;0;0;0;0;0)))
            );
            (
                (0b;0;()); // .engine.ProcessDepthUpdateEvents      
                (0b;0;()); // .engine.ProcessNewTradeEvents         
                (0b;0;()); // .engine.ProcessMarkUpdateEvents       
                (0b;0;()); // .engine.ProcessSettlementEvents       
                (0b;0;()); // .engine.ProcessFundingEvents          
                (0b;0;()); // .engine.ProcessLiquidationEvents      
                (1b;1;()); // .engine.ProcessNewOrderEvents         
                (0b;0;()); // .engine.ProcessAmendOrderEvents       
                (0b;0;()); // .engine.ProcessCancelOrderEvents      
                (0b;0;()); // .engine.ProcessCancelAllOrdersEvents  
                (0b;0;()); // .engine.ProcessNewPriceLimitEvents    
                (0b;0;()); // .engine.ProcessWithdrawEvents         
                (0b;0;()); // .engine.ProcessDepositEvents          
                (0b;0;())  // .engine.ProcessSignalEvents                       
            );
            ()
        ));
        (".engine.ProcessEvents";(
            z;
            (
                enlist(z+1;2#8;2#0;((0;0;0;0;0;0);(0;0;0;0;0;0)))
            );
            (
                (0b;0;()); // .engine.ProcessDepthUpdateEvents      
                (0b;0;()); // .engine.ProcessNewTradeEvents         
                (0b;0;()); // .engine.ProcessMarkUpdateEvents       
                (0b;0;()); // .engine.ProcessSettlementEvents       
                (0b;0;()); // .engine.ProcessFundingEvents          
                (0b;0;()); // .engine.ProcessLiquidationEvents      
                (1b;1;()); // .engine.ProcessNewOrderEvents         
                (0b;0;()); // .engine.ProcessAmendOrderEvents       
                (0b;0;()); // .engine.ProcessCancelOrderEvents      
                (0b;0;()); // .engine.ProcessCancelAllOrdersEvents  
                (0b;0;()); // .engine.ProcessNewPriceLimitEvents    
                (0b;0;()); // .engine.ProcessWithdrawEvents         
                (0b;0;()); // .engine.ProcessDepositEvents          
                (0b;0;())  // .engine.ProcessSignalEvents 
            );
            ()
        ))
    );
    ({};{};{};{});
    "Process a batch of events"];


.qt.Unit[
    ".engine.Advance";
    {[c]
        p:c[`params];
        m:p[`mocks][;0];
        f:p[`mocks][;1];
        .engine.CONF:p[`conf];
        .engine.WaterMark:p`watermark;
        .engine.Threshold:p`watermark;

        mck1:  .qt.M[`.ingest.GetBatch;f[0];c];
        mck2:  .qt.M[`.engine.ProcessEvents;f[1];c];
        mck2:  .qt.M[`.ingest.RequestBatch;f[2];c];
        mck3:  .qt.M[`.pipe.ingress.AddBatch;f[3];c];
        mck4:  .qt.M[`.pipe.ingress.GetIngressEvents;f[4];c];
        mck5:  .qt.M[`.pipe.egress.GetEgressEvents;f[5];c];

        .engine.Advance[p[`events]];

        .util.testutils.checkMock[mck1;m[0];c];  // Expected    .ingest.GetBatch                                         
        .util.testutils.checkMock[mck2;m[1];c];  // Expected    .ingest.RequestBatch                                     
        .util.testutils.checkMock[mck3;m[2];c];  // Expected    .pipe.ingress.AddBatch  
        .util.testutils.checkMock[mck4;m[3];c];  // Expected    .pipe.ingress.GetIngressEvents  
        .util.testutils.checkMock[mck5;m[4];c];  // Expected    .pipe.ingress.GetIngressEvents  
        .util.testutils.checkMock[mck5;m[5];c];  // Expected    .pipe.ingress.GetIngressEvents  
    };
    {[p]
        e:({`time`kind`cmd`datum!x} each p[2]);
        :`watermark`conf`events`mocks`err!(p[0];p[1];e;p[3];p[4]);
    };
    (
        enlist("Advance everything ok";(
            z;
            `pullInterval`dataInterval`frequency!();
            (
                enlist(z+1;2#8;2#0;((0;0;0;0;0;0);(0;0;0;0;0;0)))
            );
            (
                ((0b;0;());{[]:()}); // Expected    .ingest.GetBatch                      
                ((0b;0;());{[x]:()}); // Expected    .engine.ProcessEvents                    
                ((0b;0;());{[x]:()}); // Expected    .ingest.RequestBatch                  
                ((0b;0;());{[x]:()}); // Expected    .pipe.ingress.AddBatch     
                ((0b;0;());{[x;y]:()});  // Expected    .pipe.ingress.GetIngressEvents   
                ((0b;0;());{[x;y]:()})  // Expected    .pipe.ingress.GetEgressEvents   
            );
            ()
        ))
    );
    ({};{};{};{});
    "Reset the engine with different config"];


.qt.Unit[
    ".engine.Reset";
    {[c]
        p:c[`params];

        mck1:  .qt.M[`.ingest.NewEpisode;{[a;b;c]};c];
        mck2:  .qt.M[`.pipe.ingress.AddBatch;{[a;b;c]};c];
        mck3:  .qt.M[`.pipe.ingress.GetIngressEvents;{[a;b;c]};c];
        mck4:  .qt.M[`.pipe.egress.GetEgressEvents;{[a;b;c]};c];
        mck5:  .qt.M[`.engine.ProcessEvents;{[a;b;c]};c];
        mck6:  .qt.M[`.pipe.egress.GetEgressEvents;{[a;b;c]};c];

        .engine.Reset[p[`config]];

    };
    {[p]
        :`config`mocks`err`eAcc`eInv`eEng`eIns!p;
    };
    (
        enlist("Set up engine with one account, no balance no errors";(
            (`instrument`accounts`engine!(
              (`instrumentId`faceValue`maxLeverage`minPrice`maxPrice`minOrderSize`maxOrderSize,
                `tickSize`lotSize`hasLiquidityBuy`hasLiquiditySell`bestBidPrice`bestAskPrice`markPrice,
                `riskTiers`feeTiers)!(0;1;1001;0;7h$(1e6);0;7h$(1e8);1f;1;1b;1b;1000;1001;1001;
                .util.testutils.defaultRiskTier;
                .util.testutils.defaultFeeTier);
              (
                  `account`inventory!(
                      `accountId`balance`available`initMarginReq`leverage!(1;10000;10000;0f;10);
                      (
                          // TODO add inventory
                      ) 
                  ); 
                  `account`inventory!(
                      `accountId`balance`available`initMarginReq`leverage!(1;10000;10000;0f;10);
                      (
                        // TODO add inventory
                      )
                  )
              );
              `pullInterval`dataInterval`frequency`episode!(1 1 1 1)));
            (
                ();
                ();
                ();
                ()
            );
            ();
            (
                ()
            );
            (
                ()
            );
            (
                ()
            );
            (
                ()
            )
        )) 
    );
    ({};{};{};{});
    "Reset the engine with different config"];
